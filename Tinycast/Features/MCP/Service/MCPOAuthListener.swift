import Foundation
import Network

@MainActor
final class MCPOAuthListener {
    nonisolated static let redirectURI = "http://127.0.0.1:4962/callback"
    private var listener: NWListener?
    private var task: Task<Void, Never>?
    private var connections: [UUID: NWConnection] = [:]
    private var deadlines: [UUID: Task<Void, Never>] = [:]
    private var connectionCount = 0
    private var ready: CheckedContinuation<Void, Error>?
    private var reply: CheckedContinuation<String, Error>?
    private var result: Result<String, Error>?
    private var accepted = false

    isolated deinit {
        listener?.cancel()
        task?.cancel()
        for connection in connections.values { connection.cancel() }
        for deadline in deadlines.values { deadline.cancel() }
    }

    func start(
        state: String, issuer: String, requiresIssuer: Bool, timeout: Duration = .seconds(300)
    ) async throws {
        guard result == nil, listener == nil else { throw CancellationError() }
        let parameters = NWParameters.tcp
        parameters.requiredLocalEndpoint = .hostPort(host: .ipv4(.loopback), port: 4962)
        let listener = try NWListener(using: parameters)
        self.listener = listener
        try await withTaskCancellationHandler {
            try Task.checkCancellation()
            try await withCheckedThrowingContinuation { continuation in
                ready = continuation
                listener.stateUpdateHandler = { [weak self] status in
                    Task { @MainActor [weak self] in
                        guard let self, self.result == nil else { return }
                        switch status {
                        case .ready:
                            self.ready?.resume()
                            self.ready = nil
                        case .waiting, .failed:
                            self.finish(.failure(MCPOAuth.Failure.listenerUnavailable))
                        default: break
                        }
                    }
                }
                listener.newConnectionHandler = { [weak self] connection in
                    Task { @MainActor [weak self] in
                        guard let self, self.result == nil, self.connectionCount < 16 else {
                            connection.cancel()
                            return
                        }
                        self.connectionCount += 1
                        self.accept(connection, state: state, issuer: issuer, requiresIssuer: requiresIssuer)
                    }
                }
                task = Task { [weak self] in
                    do { try await Task.sleep(for: timeout) } catch { return }
                    self?.finish(.failure(MCPOAuth.Failure.timedOut))
                }
                listener.start(queue: .main)
            }
        } onCancel: {
            Task { @MainActor [weak self] in self?.cancel() }
        }
    }

    func code() async throws -> String {
        try await withTaskCancellationHandler {
            try Task.checkCancellation()
            if let result { return try result.get() }
            return try await withCheckedThrowingContinuation { reply = $0 }
        } onCancel: {
            Task { @MainActor [weak self] in self?.cancel() }
        }
    }

    func cancel() { finish(.failure(CancellationError())) }

    private func finish(_ result: Result<String, Error>) {
        guard self.result == nil else { return }
        self.result = result
        if case .failure(let error) = result {
            ready?.resume(throwing: error)
        } else {
            ready?.resume(throwing: CancellationError())
        }
        ready = nil
        reply?.resume(with: result)
        reply = nil
        task?.cancel()
        task = nil
        listener?.cancel()
        listener = nil
        for connection in connections.values { connection.cancel() }
        for deadline in deadlines.values { deadline.cancel() }
        connections = [:]
        deadlines = [:]
    }

    private func accept(_ connection: NWConnection, state: String, issuer: String, requiresIssuer: Bool) {
        let id = UUID()
        connections[id] = connection
        deadlines[id] = Task { [weak self] in
            do { try await Task.sleep(for: .seconds(5)) } catch { return }
            self?.close(id)
        }
        connection.start(queue: .main)
        read(id, bytes: Data(), state: state, issuer: issuer, requiresIssuer: requiresIssuer)
    }

    private func close(_ id: UUID) {
        connections.removeValue(forKey: id)?.cancel()
        deadlines.removeValue(forKey: id)?.cancel()
    }

    private func read(_ id: UUID, bytes: Data, state: String, issuer: String, requiresIssuer: Bool) {
        guard let connection = connections[id], bytes.count < 8192 else { close(id); return }
        let remaining = 8192 - bytes.count
        connection.receive(minimumIncompleteLength: 1, maximumLength: remaining) { [weak self] content, _, complete, error in
            Task { @MainActor [weak self] in
                guard let self, self.connections[id] != nil else { return }
                var next = bytes
                if let content { next.append(content) }
                if next.range(of: Data("\r\n\r\n".utf8)) != nil,
                    let request = String(bytes: next, encoding: .utf8), !self.accepted
                {
                    self.respond(id, request: request, state: state, issuer: issuer,
                                 requiresIssuer: requiresIssuer)
                } else if complete || error != nil || next.count >= 8192 {
                    self.close(id)
                } else {
                    self.read(id, bytes: next, state: state, issuer: issuer,
                              requiresIssuer: requiresIssuer)
                }
            }
        }
    }

    private func respond(_ id: UUID, request: String, state: String, issuer: String, requiresIssuer: Bool) {
        guard let connection = connections[id] else { return }
        let line = request.components(separatedBy: "\r\n").first ?? ""
        let parts = line.split(separator: " ")
        var outcome: Result<String, Error>?
        if parts.count == 3, parts[0] == "GET" {
            do {
                let code = try MCPOAuth.callback(
                    String(parts[1]), state: state, issuer: issuer,
                    requiresIssuer: requiresIssuer)
                outcome = .success(code)
            } catch MCPOAuth.Failure.denied {
                outcome = .failure(MCPOAuth.Failure.denied)
            } catch { outcome = nil }
        }
        let status = outcome == nil ? "400 Bad Request" : "200 OK"
        let page =
            outcome == nil
            ? String(localized: "Invalid sign-in response.")
            : String(localized: "Return to Tinycast. You can close this tab.")
        let response =
            "HTTP/1.1 \(status)\r\nContent-Type: text/html; charset=utf-8\r\n"
            + "Cache-Control: no-store\r\nContent-Security-Policy: default-src 'none'\r\n"
            + "Connection: close\r\nContent-Length: \(page.utf8.count)\r\n\r\n\(page)"
        if outcome != nil { accepted = true }
        let resolved = outcome
        connection.send(content: Data(response.utf8), isComplete: true, completion: .contentProcessed { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.connections[id] != nil else { return }
                self.close(id)
                if let resolved { self.finish(resolved) }
            }
        })
    }
}
