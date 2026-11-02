# Validation record

Baseline: v0.12.1 = ead1f770401b34f69065e279704a119d04609986.
Local host: Apple silicon, macOS 15.8.2 (24H225), CLT Swift 6.1.2; no full Xcode installed.
Existing installation and its private data were preserved.
No existing Tinycast settings or clipboard database was read, copied or changed.

## Cloud attempts

1. https://github.com/liwenqiang1990/tinycast/actions/runs/41382606855 — compilation failed on actual Network.framework, typed NotificationCenter and posix_spawn macOS 26 availability diagnostics. All three helper targets compiled.
2. https://github.com/liwenqiang1990/tinycast/actions/runs/41383174649 — Release compilation succeeded with Xcode 26.6 / SDK 26.5 / Swift 6.3.3. Main and three helpers signed. Verification script failed due incorrect codesign certificate extraction syntax. No test ZIP delivered from this attempt.
3. https://github.com/liwenqiang1990/tinycast/actions/runs/41384198420 — cancelled after reproducing the certificate extraction syntax error locally, to avoid waiting on an obsolete audit script.
4. https://github.com/liwenqiang1990/tinycast/actions/runs/41384331401 — in progress; not yet a passing build.

## Local source-level checks

- quick-action-test: passed with the shipped sources.
- hotkey-test: passed (1,627 assertions after platform-specific unavailable Translate behavior was reflected).
- file-search-test: passed outside the Codex sandbox. Initial eight UTType failures inside the sandbox are not platform failures.
- JavaScript runtime module fixtures: passed.
- SwiftLint 0.65.1: no errors. Existing source warnings remain; new listener warnings were removed. CLT SourceKit requires TOOLCHAIN_DIR and XCODE_DEFAULT_TOOLCHAIN_OVERRIDE; --no-cache avoids the sandbox cache error.
- settings search/localization check scripts: passed; new on-device AI explanation translated into every catalog language.
- generated Xcode project: regenerated with XcodeGen 2.46.0; no generation drift in cloud builds.
- pure model import boundary: no AppKit/SwiftUI/Cocoa imports found.
- Quicklinks cannot be compiled by local CLT because isolated deinit requires the newer compiler. The CLT production compiler also refuses the experimental feature flag. The source was not downgraded to work around that tooling limit.
- Working-directory spawn code uses a macOS 26 symbol in an availability branch, so the local macOS 15 SDK alone cannot compile that full file; cloud compilation covers it.

## Runtime status

Pending artifact download. Cloud compilation is not proof of macOS 15 runtime compatibility.
App launch, Settings, global hotkey, general clipboard, snippet expansion, file-search UI, plugin UI, dictation and external AI have not yet been marked passed.
