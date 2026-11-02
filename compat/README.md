# SequoiaCast Test — Tinycast 0.12.1 on macOS 15

Work in progress. A successful compile is not a macOS 15 runtime test.

- Baseline: upstream tag `v0.12.1`, commit `ead1f770401b34f69065e279704a119d04609986`.
- Branch: `compat/v0.12.1-macos15-isolated`.
- App: `SequoiaCast Test.app`, ID `org.sequoiacast.test`.
- Dictation app: `SequoiaCast Test Dictation.app`, ID `org.sequoiacast.test.dictation`.
- Native command-line helpers: ClipboardTextHelper and FileIndexHelper, embedded and signed separately.
- Builds require Xcode 26 / Swift 6.2 or newer within Xcode 26, not the local Swift 6.1.2 CLT. Existing source uses `@concurrent` and `isolated deinit`. No Xcode is installed locally.
- All targets deploy to macOS 15.0, with arm64-only output. Project is generated from project.yml.
- Historical d28b412 patch was inspected only; its 0.9-era UI hunks do not cover this tree's newer AI, translation, dictation, file indexing or additional glass surfaces.

## Compatibility behavior

Glass is available only within macOS 26 availability branches. Sequoia uses NSVisualEffectView and SwiftUI ultra-thin material.
Foundation Models types are confined to available functions; on-device AI is absent from provider controls and rejected on macOS 15. External HTTP and installed-tool providers are retained, off by default, with separate Keychain services.
Direct `TranslationSession(installedSource:target:)` requires macOS 26. On macOS 15 the Translate command, shortcut controls, action row and language picker are omitted and execution is refused. macOS 15's UI-owned translationTask session would need a different panel lifecycle; it is not substituted silently with a paid external model.
Dictation uses Core ML helpers rather than the new SpeechAnalyzer API; model inference remains unverified until tested.

## Isolation

No existing application, preference, shortcut, clipboard history or private data is copied or changed.
Settings: `~/Library/Preferences/org.sequoiacast.test.plist`.
Data: `~/Library/Application Support/org.sequoiacast.test/`.
Cache: `~/Library/Caches/org.sequoiacast.test/`.
Optional settings mirror: `~/.config/org.sequoiacast.test/settings.json`.
Keychain services begin with `org.sequoiacast.test.`.
Only the `sequoiacast-test` URL scheme is registered, to avoid taking existing Tinycast/Raycast handlers.
The custom Bundle ID maps to the upstream development channel: update checks and installation are disabled.
Start without hotkeys, permissions, enabled AI or clipboard recording. Enable clipboard recording explicitly for this test channel. Choose a shortcut that the installed app does not use. Hyper Key remaps physical keyboards globally: leave it off for coexistence tests.

## Signing

`compat/setup-signing.sh liwenqiang1990/tinycast` generates a new project-only identity named `SequoiaCast Test Signing` once, stored in `~/Library/Keychains/SequoiaCast-Test.keychain-db`. Its original encrypted PKCS#12 and random password are saved as dedicated generic-password records in the login Keychain under `org.sequoiacast.test.signing.p12` and `.password`. This script never exports any Keychain identity. Subsequent invocations reuse those exact project-only records.
Only the two project Secrets `SEQUOIACAST_SIGNING_P12_BASE64` and `SEQUOIACAST_SIGNING_P12_PASSWORD` reach the runner's temporary keychain, deleted at the end. Private key files never enter the repo or artifacts.
This is self-signed, not Developer ID notarized; Gatekeeper may require a one-time explicit approval in Privacy & Security. Never disable Gatekeeper globally.

## Manual builds

Once the compatibility workflow exists on the fork's default branch, select Actions → macOS 15 isolated test → Run workflow → `compat/v0.12.1-macos15-isolated`.
CLI: `gh workflow run macos15-test.yml --repo liwenqiang1990/tinycast --ref compat/v0.12.1-macos15-isolated`.
Only this workflow is enabled on the compatibility branch; upstream workflow sources are retained with `.disabled` suffixes. No release, tap, mirror, sync, website or messaging action runs.
The workflow uses the standard `macos-26` runner and contents:read token. ZIP artifacts expire after 14 days; download and retain locally. Logs include toolchain version, compiler output and recursive binary/signature audit.
Packaging uses ditto, then extraction, byte comparison, signature, architecture, minOS, resource and symlink verification.

## Local validation after download

Extract with `ditto -x -k archive.zip destination`; run `compat/verify-app.sh 'destination/SequoiaCast Test.app'`.
Install only the separate test app, retaining the original Tinycast.app. Launch, open Settings, assign an unused shortcut, and grant only SequoiaCast Test permissions if needed. Use fresh test snippets and quicklinks. Test a private pasteboard first; writing to the shared clipboard may also be recorded by the installed Tinycast.
Validate launch, Settings, global hotkey, clipboard read/write, snippet expansion, file search, a representative extension, then quit/relaunch. External AI only with explicit authorization and an already configured test credential. Cloud test success alone proves none of these GUI behaviors on macOS 15.

## Uninstall

Quit SequoiaCast Test and disable its own Launch at Login if enabled. Remove only SequoiaCast Test.app. Optionally remove the exact test-only data/cache/preferences/config paths listed above. Leave the existing Tinycast.app and all com.tinycast.* paths untouched. No TCC reset is needed. Keep the signing identity for future rebuilds; deleting it changes future permission identity.

## Additional API audit

The first cloud compile (Xcode 26.6 / macOS SDK 26.5) identified macOS 26-only NetworkListener/NetworkConnection, typed NotificationCenter tokens/messages, and POSIX standardized addchdir. The compatibility branch uses NWListener/NWConnection with loopback-only binding, the existing callback validation, bounded requests, timeout/cancel cleanup; classic notifications; and addchdir_np on Sequoia. This preserves MCP OAuth, locale updates, undo/redo and subprocess working directories without raising the deployment floor.
Local file-search harness passed outside the Codex sandbox; its initial UTType failures inside the sandbox were environmental. Local SwiftLint requires TOOLCHAIN_DIR=/Library/Developer/CommandLineTools and --no-cache in this restricted session.

Local CLT checks so far: Quick Actions, hotkey model, file search model and JavaScript module fixtures pass. The full Quicklinks harness cannot compile under local Swift 6.1.2 because its shipped source uses isolated deinit; it is assigned to the cloud toolchain rather than rewritten for an older compiler.
