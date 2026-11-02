# Validation record — 2026-11-02

Status: cloud build/checks passed; the final app was downloaded and run on the user's macOS 15.8.2.

## Reproducible source and delivery

- Upstream stable tag: `v0.12.1`.
- Exact baseline: `ead1f770401b34f69065e279704a119d04609986`.
- Fork: https://github.com/liwenqiang1990/tinycast
- Branch/default branch: `compat/v0.12.1-macos15-isolated`.
- Application source commit after privacy cleanup: `977fa55808582a9c97ef145e0c267019425824a2`.
- The linked workflow predates the email-only commit-history cleanup. Application/project source trees are identical before and after cleanup; later commits only add local validation scripts/reporting.
- Successful full workflow: https://github.com/liwenqiang1990/tinycast/actions/runs/41386041871
- Test ZIP artifact: https://github.com/liwenqiang1990/tinycast/actions/runs/41386041871/artifacts/13116516554
- Diagnostics: https://github.com/liwenqiang1990/tinycast/actions/runs/41386041871/artifacts/13116348701
- ZIP SHA256: `91871de6c918f5df3ab8bdd4540e861d26fcf56d2e9ccb4b567bbab6f5f40d54`.
- Tested application: `SequoiaCast Test.app`, version 0.12.1, build 7.

## Cloud evidence

Standard public-repository `macos-26` runner; Xcode 26.6 (17F113), macOS SDK 26.5, Swift 6.3.3.
Both Release and Debug compiled. **All 104 upstream harnesses passed** in 261 seconds; lint reported `lint-clean` (existing warnings remain). Settings-search/localization checks and generated-project consistency passed.

The main app and ClipboardTextHelper, FileIndexHelper, SequoiaCast Test Dictation were all inspected:

- arm64 only, Mach-O minOS 15.0; application and dictation Info.plist floors also 15.0.
- Distinct application/helper identifiers, all signed by the same fixed project identity.
- Certificate SHA256: `EF81CAEC250086EFF677EDA749840CDE5B3238E90FFE65D7F2FC7992EBB3E21F`.
- FoundationModels is weak-linked; unavailable framework types/calls are behind macOS 26 guards.
- Nested strict signatures, hardened runtime, required usage entitlements and no get-task-allow verified.
- Runtime JS, emoji packs, notices and symlinks checked.
- ditto packaging, extraction, byte comparison and another signature/binary audit passed.

## macOS 15.8.2 runtime evidence

Host: Apple silicon, macOS 15.8.2 (24H225), CLT Swift 6.1.2. No full Xcode was installed.

| Item | Actual result |
| --- | --- |
| Final app launch/relaunch | Build 7 launches and relaunches; no SequoiaCast crash report observed |
| Settings and fallback surfaces | General, Permissions, File Search, AI/providers, Quick Actions, Snippets, Quicklinks and editor panels opened |
| Global shortcut | Physical keyboard invocation from another app opened the launcher |
| Clipboard | Final target-15 binaries: clipboard-test 230/230, pasteboard-test 82/82, on private boards and temporary databases |
| Snippets | Final snippets-test passed, including actual NSTextView insertion/selection/keyword replacement paths. New `SequoiaCast Test Snippet` loaded from the test-only Markdown library and appeared in launcher search |
| Quicklinks | Final quicklink-test 124/124; created and saved `SequoiaCast Test Folder` through the final app's UI, pointing to the new fixture folder |
| File indexing/search | Final file-index-test passed; actual embedded helper created an index. With the required permission and an isolated fixture scope, the final launcher displayed `SequoiaCast-Search-Check.txt` in the fixture scope |
| Plugin UI | A newly written local, no-network fixture was discovered; JavaScriptCore executed React/@raycast/api Detail and the expected text rendered |
| Hotkey model | Final hotkey-test 1,627 passed, 0 failed |
| Notes | Final notes-editor-test passed, including editing/undo/redo |
| OCR and image helper | Final embedded helper recognized `SequoiaCast 0121 Runtime Check`; thumbnail PNG generated |
| Dictation helper | Final embedded app started and exited cleanly on stdin EOF; no model inference claim |
| API gating | On-device AI explains macOS 26 requirement and is absent from providers; external providers remain configurable. Translate row/language controls absent in Quick Actions |
| Coexistence | Original and independent test app ran simultaneously |

All seven final target-15 runtime harnesses passed locally. Detailed host validation logs are retained privately; cloud diagnostics are linked above.

## Explicit limits

- Shared/general clipboard capture/paste was not exercised while original Tinycast was recording; it could add fixture clips to the old history. Real clipboard operations were instead tested on private pasteboards.
- A physical global snippet keyword was not tested against an unrelated application. Actual keyword/selection/insertion code passed the executable harness; the library and launcher path were checked in the final GUI.
- External AI requests/account login were not exercised: existing private credentials were not copied. Cloud provider/MCP protocol harnesses passed; real third-party account/service behavior remains unverified.
- Dictation weights were not downloaded and microphone/model inference, camera, calendar, every window action and every third-party plugin were not exhaustively tested.
- Self-signed, not Developer ID notarized. A separately browser-downloaded copy may require a one-time Gatekeeper approval. No global security setting was disabled.

## Isolation and preservation

The test application and dictation helper use `org.sequoiacast.test` and `org.sequoiacast.test.dictation`. Application data is isolated by channel, and automatic updates are disabled. Testing used newly created fixtures. The existing application executable was verified unchanged; its private settings, clipboard history, permissions and Keychain identities were not reset, migrated or copied. Host paths, personal shortcut bindings, permission state and installed-application fingerprints are kept out of this public report.

## Resolved build/test diagnostics

1. Run 41382606855: actual macOS 26 availability errors in NetworkListener/NetworkConnection, typed notifications and standardized POSIX addchdir. All three helper targets compiled. The APIs were backported individually.
2. Run 41383174649: Release compile/sign commands succeeded; audit script failed on incorrect codesign certificate-extraction argument syntax. Locally reproduced and fixed.
3. Run 41384198420: cancelled after discovering the obsolete audit syntax, avoiding an unnecessary full compile.
4. Run 41384331401: Release+Debug, four binary audits and ZIP round trip passed; 102/104 tests passed. Fixed test preparation based on an arbitrary 150ms delay and a light-appearance pixel test that only counted bright ink.
5. Run 41385109055: cancelled while pending to upload the already audited ZIP earlier for parallel local testing.
6. Run 41385350421: audited app and seven target-15 harnesses packaged/uploaded; its old full-suite assertions failed. This was the first locally tested ZIP.
7. Run 41386041871: all build, signing, packaging, Debug, 104 tests and lint steps passed. This is the delivered app.

Historical d28b412 patch was checked against unmodified v0.12.1 files: its Theme/PopoverMenu/shortcut/extensions hunks do not apply. It was never blindly applied.
Initial local file-search UTType assertions failed only inside the Codex sandbox; the same harness passed on the real host outside the sandbox. Local CLT cannot compile isolated deinit/new SDK declarations; its production compiler refuses the experimental flag. Those were compiled in the cloud and executed locally instead.
