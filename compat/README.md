# SequoiaCast — Tinycast 0.12.11 on macOS 15

Release `v0.12.11-sequoia.1` ships build 13. See [the upgrade audit and validation](UPGRADE-0.12.11.md), including test coverage and limits.
The [previous validation record](VALIDATION.md) describes v0.12.1 and does not establish v0.12.11 compatibility.

- Baseline: upstream tag `v0.12.11`, commit `58168bf7e0b721f7c5fbfc7f4e8a068a48cff446`.
- Branch: `compat/v0.12.11-macos15-isolated`.
- App: `SequoiaCast.app`, ID `org.sequoiacast.test`.
- Dictation app: `SequoiaCast Dictation.app`, ID `org.sequoiacast.test.dictation`.
- Native command-line helpers: ClipboardTextHelper and FileIndexHelper, embedded and signed separately.
- Upstream now requests Xcode 27. The compatibility workflow selects an available released Xcode 26/27 on a standard hosted runner; the first compile used Xcode 26.6 / Swift 6.3.3. See the audit for compiler adaptations and final results. No full Xcode is installed locally.
- All targets deploy to macOS 15.0, with arm64-only output. Project is generated from project.yml.
- Historical d28b412 patch was inspected only; its 0.9-era UI hunks do not cover this tree's newer AI, translation, dictation, file indexing or additional glass surfaces.

## Compatibility behavior

The unavailable features below are gated by OS version, not deleted from the macOS 26 code paths.

| Feature | Behavior on macOS 15 |
| --- | --- |
| Liquid Glass | Replaced with AppKit `NSVisualEffectView` and SwiftUI ultra-thin material with borders. Native macOS 26 glass rendering and interactive glass effects are unavailable. |
| Foundation Models on-device AI | Disabled: the on-device provider is hidden from the provider list, its model route is disabled, and direct requests fail with a macOS 26 requirement. FoundationModels is weak-linked and its types/calls are confined to available functions. This does not disable system-wide Apple Intelligence features in other apps. |
| Built-in Translate | Disabled: launcher entry, hotkey action/controls, Quick Actions row, target-language controls and translation settings-search entries are hidden or excluded. Execution is guarded. The upstream direct `TranslationSession(installedSource:target:)` API requires macOS 26; a macOS 15 UI-owned `translationTask` session would require a different panel lifecycle. No external translation service is substituted automatically. |
| External AI and installed AI tools | Retained with isolated Keychain services. Grammar correction, rewriting, summarization and custom AI actions remain available when a compatible provider is configured; they cannot fall back to the disabled local model on macOS 15. Real third-party requests/account login remain unverified. |
| Launcher, hotkeys, clipboard, snippets, quicklinks, file search and extension engine | Retained. Clipboard recording defaults off in this parallel test channel and can be enabled explicitly. A representative local React extension was tested; not every third-party extension was verified. |
| MCP OAuth, notifications and subprocess working directories | Retained through `NWListener`/`NWConnection`, classic notification observers and the macOS 15 `addchdir_np` spawn path. These API backports preserve features rather than removing them. |
| Dictation | Core ML helper retained; it does not use the new SpeechAnalyzer API. Helper launch was tested, but model download, microphone capture and inference remain unverified. |

Automatic updates are disabled by the isolated application identity to prevent replacement by the upstream macOS 26 package. This is a coexistence safeguard, not an OS API limitation. The published package is arm64-only; Intel is not included. Builds use a fixed self-signed certificate and are not Apple Developer ID notarized. See [the validation record](VALIDATION.md) for the distinction between cloud compilation, local executable checks and interactive testing.

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

## Installing and upgrading

Release packages from `v0.12.1-sequoia.2` contain `SequoiaCast.app` and the renamed `SequoiaCast Dictation.app` helper. The internal bundle IDs, data paths, URL scheme and fixed signing certificate intentionally retain their existing values. Renaming them would create a different application identity and could strand existing settings or permission grants.

Quit the running app before replacing it. For future manual upgrades, replace `SequoiaCast.app` in the same installation directory with the newly extracted copy. Preferences, shortcut bindings, clipboard history, snippets, quicklinks and other channel data live outside the app bundle and are retained. Do not reset permissions, delete data directories or run an uninstall with `--zap` as part of an upgrade. A path change or macOS security decision can still require renewed permission approval; persistent data does not need migration.

When moving from `SequoiaCast Test.app`, quit it, install `SequoiaCast.app` once, and keep only one runnable copy of this channel. Remove the old application bundle after confirming the new one opens; leave its `org.sequoiacast.test` data intact. The original Tinycast application and `com.tinycast.*` data remain separate.

Homebrew packages are provided by the dedicated `liwenqiang1990/sequoiacast` tap. Install with:

```sh
brew tap liwenqiang1990/sequoiacast
brew trust --cask liwenqiang1990/sequoiacast/sequoiacast
brew install --cask liwenqiang1990/sequoiacast/sequoiacast
brew update
brew upgrade --cask liwenqiang1990/sequoiacast/sequoiacast
```

Quit SequoiaCast before upgrading. The cask pins a version and SHA256, requires Apple silicon and macOS 15+, and installs only `SequoiaCast.app`. It does not declare `auto_updates`, because this channel's in-app updater is disabled. It has no `zap` or commands that delete user data, change permissions, remove quarantine, or terminate apps. A manually installed copy at Homebrew's target location may need to be moved aside before the first brew install; do not use `--force` to overwrite an unknown application. Self-signing and Gatekeeper limitations still apply.

## Signing

`compat/setup-signing.sh liwenqiang1990/tinycast` generates a new project-only identity named `SequoiaCast Test Signing` once, stored in `~/Library/Keychains/SequoiaCast-Test.keychain-db`. Its original encrypted PKCS#12 and random password are saved as dedicated generic-password records in the login Keychain under `org.sequoiacast.test.signing.p12` and `.password`. This script never exports any Keychain identity. Subsequent invocations reuse those exact project-only records.
Only the two project Secrets `SEQUOIACAST_SIGNING_P12_BASE64` and `SEQUOIACAST_SIGNING_P12_PASSWORD` reach the runner's temporary keychain, deleted at the end. Private key files never enter the repo or artifacts.
This is self-signed, not Developer ID notarized; Gatekeeper may require a one-time explicit approval in Privacy & Security. Never disable Gatekeeper globally.

## Manual builds

Select Actions → macOS 15 build → Run workflow → `compat/v0.12.11-macos15-isolated`.
CLI: `gh workflow run macos15-test.yml --repo liwenqiang1990/tinycast --ref compat/v0.12.11-macos15-isolated`.
Only this workflow is enabled on the compatibility branch; upstream workflow sources are retained with `.disabled` suffixes. No release, tap, mirror, sync, website or messaging action runs.
The workflow uses the standard `macos-26` runner and contents:read token. ZIP artifacts expire after 14 days; download and retain locally. Logs include toolchain version, compiler output and recursive binary/signature audit.
Packaging uses ditto, then extraction, byte comparison, signature, architecture, minOS, resource and symlink verification.

## Local validation after download

Extract with `ditto -x -k archive.zip destination`; run `compat/verify-app.sh 'destination/SequoiaCast.app'`.
Install only the separate test app, retaining the original Tinycast.app. Launch, open Settings, assign an unused shortcut, and grant only SequoiaCast permissions if needed. Use fresh test snippets and quicklinks. Test a private pasteboard first; writing to the shared clipboard may also be recorded by the installed Tinycast.
Validate launch, Settings, global hotkey, clipboard read/write, snippet expansion, file search, a representative extension, then quit/relaunch. External AI only with explicit authorization and an already configured test credential. Cloud test success alone proves none of these GUI behaviors on macOS 15.

## Uninstall

Quit SequoiaCast and disable its own Launch at Login if enabled. Remove only SequoiaCast.app. Optionally remove the exact test-only data/cache/preferences/config paths listed above. Leave the existing Tinycast.app and all com.tinycast.* paths untouched. No TCC reset is needed. Keep the signing identity for future rebuilds; deleting it changes future permission identity.

## Additional API audit

The first cloud compile (Xcode 26.6 / macOS SDK 26.5) identified macOS 26-only NetworkListener/NetworkConnection, typed NotificationCenter tokens/messages, and POSIX standardized addchdir. The compatibility branch uses NWListener/NWConnection with loopback-only binding, the existing callback validation, bounded requests, timeout/cancel cleanup; classic notifications; and addchdir_np on Sequoia. This preserves MCP OAuth, locale updates, undo/redo and subprocess working directories without raising the deployment floor.
Local file-search harness passed outside the Codex sandbox; its initial UTType failures inside the sandbox were environmental. Local SwiftLint requires TOOLCHAIN_DIR=/Library/Developer/CommandLineTools and --no-cache in this restricted session.

Local CLT checks so far: Quick Actions, hotkey model, file search model and JavaScript module fixtures pass. The full Quicklinks harness cannot compile under local Swift 6.1.2 because its shipped source uses isolated deinit; it is assigned to the cloud toolchain rather than rewritten for an older compiler.

The Actions artifact also includes a separate validation ZIP with ten cloud-compiled, project-signed macOS 15 harnesses. The application ZIP contains only the application. `Validation/run.sh` runs them locally using fresh temporary databases and private pasteboards, writing only diagnostic logs under Validation/Results. They cover clipboard storage/read-write, snippets, Quicklinks, file indexing, hotkey logic, Notes undo/redo, OpenCode MCP, AI chat and update policy, without reading the existing Tinycast store. Global shortcuts and permission-dependent insertion still require the GUI checks.

Homebrew 7 validation: the cask loaded successfully, passed style checks, fetched and verified the released ZIP, installed into an isolated validation directory, and passed the installed-bundle signature/architecture/minimum-OS audit. The validation installation was removed without a data purge. This did not replace or launch the user's existing app. On older Homebrew versions without `brew trust`, omit that command; if a future tap update prompts for renewed trust, review the cask before trusting it again.
