# Validation record — 2026-11-02

Status: the replacement cloud build/checks passed. Build 8 was downloaded and its package and seven executable harnesses passed on macOS 15.8.2. Interactive application checks below were performed on build 7, whose application/project source is unchanged.

## Reproducible source and delivery

- Upstream stable tag: `v0.12.1`.
- Exact baseline: `ead1f770401b34f69065e279704a119d04609986`.
- Fork: https://github.com/liwenqiang1990/tinycast
- Branch/default branch: `compat/v0.12.1-macos15-isolated`.
- Current cloud build source commit: `b63e2ba0be95a7de21031abcbc7d2133ca85c994`.
- This run uses the sanitized commit history. Later documentation/ignore-rule changes do not affect application or build source.
- Successful full workflow: https://github.com/liwenqiang1990/tinycast/actions/runs/41438965770
- Test ZIP artifact: https://github.com/liwenqiang1990/tinycast/actions/runs/41438965770/artifacts/13139570881
- Diagnostics: https://github.com/liwenqiang1990/tinycast/actions/runs/41438965770/artifacts/13140875837
- ZIP SHA256: `56fb7744825afeb4ac046c3528477443c7ea9057ac22aebe4b8ce445ba69a5c9`.
- Tested application: `SequoiaCast Test.app`, version 0.12.1, build 8.

## Cloud evidence

Standard public-repository `macos-26` runner; Xcode 26.6 (17F113), macOS SDK 26.5, Swift 6.3.3.
Both Release and Debug compiled. **All 104 upstream harnesses passed** in the replacement run; lint reported `lint-clean` (existing warnings remain). Settings-search/localization checks and generated-project consistency passed.

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
| Final app launch/relaunch | Build 7 was tested interactively; build 8 was downloaded and its executable runtime harnesses and package audited |
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

All seven target-15 runtime harnesses also passed locally from the replacement build 8 package. Detailed host validation logs are retained privately; cloud diagnostics are linked above.

## Explicit limits

- Shared/general clipboard capture/paste was not exercised while original Tinycast was recording; it could add fixture clips to the old history. Real clipboard operations were instead tested on private pasteboards.
- A physical global snippet keyword was not tested against an unrelated application. Actual keyword/selection/insertion code passed the executable harness; the library and launcher path were checked in the final GUI.
- External AI requests/account login were not exercised: existing private credentials were not copied. Cloud provider/MCP protocol harnesses passed; real third-party account/service behavior remains unverified.
- Dictation weights were not downloaded and microphone/model inference, camera, calendar, every window action and every third-party plugin were not exhaustively tested.
- Self-signed, not Developer ID notarized. A separately browser-downloaded copy may require a one-time Gatekeeper approval. No global security setting was disabled.

## Isolation and preservation

The test application and dictation helper use `org.sequoiacast.test` and `org.sequoiacast.test.dictation`. Application data is isolated by channel, and automatic updates are disabled. Testing used newly created fixtures. The existing application executable was verified unchanged; its private settings, clipboard history, permissions and Keychain identities were not reset, migrated or copied. Host paths, personal shortcut bindings, permission state and installed-application fingerprints are kept out of this public report.

## Resolved build/test diagnostics

Earlier build attempts exposed API availability, certificate extraction syntax and two upstream harness timing/appearance assumptions. Those issues were corrected before delivery. Superseded Actions runs were removed after the replacement run and download were verified; their detailed evidence is retained privately.

The replacement run passed Release, Debug, nested binary audits, packaging round trip, all 104 harnesses and lint. Application/project/build-script content was preserved through the privacy history rewrite.

## Public-data hygiene

Compatibility commits use a generic contributor name and GitHub noreply address. Public reports omit workstation paths and personal configuration. Private signing material, exported settings/history and local diagnostics are excluded by ignore rules. Older GitHub objects/cached views may remain addressable by superseded SHA; their server-side removal requires GitHub Support assessment.

Historical d28b412 patch was checked against unmodified v0.12.1 files: its Theme/PopoverMenu/shortcut/extensions hunks do not apply. It was never blindly applied.
Initial local file-search UTType assertions failed only inside the Codex sandbox; the same harness passed on the real host outside the sandbox. Local CLT cannot compile isolated deinit/new SDK declarations; its production compiler refuses the experimental flag. Those were compiled in the cloud and executed locally instead.

## Renamed release — v0.12.1-sequoia.2

The new release application is `SequoiaCast.app`, with `SequoiaCast Dictation.app` embedded. Build 9 retains the original `org.sequoiacast.test` main/helper identities, data roots, URL scheme and byte-identical fixed certificate. Both old and new main apps satisfy the old designated signing requirement. The internal identity and certificate names intentionally retain their original values to preserve continuity.

- Source/tag target: `0853a4508884e19bc95df2a8a6abf7edd672d178`.
- Successful Release/Debug, 104 harnesses and lint: https://github.com/liwenqiang1990/tinycast/actions/runs/41452691705
- Application and separate validation ZIP artifact: https://github.com/liwenqiang1990/tinycast/actions/runs/41452691705/artifacts/13145877598
- Diagnostics: https://github.com/liwenqiang1990/tinycast/actions/runs/41452691705/artifacts/13146283053
- Application ZIP SHA256: `c48a9e50f6c98524ddfdc04a3c3ef70a65668f9a2f8232df763a75b7744f304b`.
- On macOS 15.8.2: nested signature/architecture/minOS/resource audits, seven isolated runtime harnesses, OCR, thumbnail, file-index helper and renamed dictation-helper EOF launch passed. No dictation inference claim.
- Full interactive GUI checks and permission retention after the initial application name/path change were not repeated; earlier build 7 interactive evidence above remains separately identified.

[Release](https://github.com/liwenqiang1990/tinycast/releases/tag/v0.12.1-sequoia.2) and [Homebrew tap](https://github.com/liwenqiang1990/homebrew-sequoiacast) use the same application ZIP. The cask pins its hash and requires arm64/macOS 15+. It uses brew-managed updates because in-app updating remains disabled. Upgrade instructions preserve user data; no automated permission reset, quarantine removal, app termination or data purge is configured.

Homebrew 7.0.11: cask style/load, real release download/SHA256 check, isolated installation, installed-app audit and removal of the validation installation completed. A local pre-existing core mirror returned 404 during the cleanup command; no global mirror configuration was changed. The validation app and Caskroom record were confirmed absent afterward. No user store was purged. The full GUI upgrade/permission-persistence sweep remains unverified.

## Localization performance follow-up (pending application validation)

On macOS 15.8.2, an interactive typing sample showed repeated localization-table
loading and XML property-list parsing on the main thread during view updates.
A standalone lookup benchmark using the shipped English and Simplified Chinese
`Localizable.strings` and `Localizable.stringsdict` reproduced the resource cost:
1,000 Chinese label lookups took approximately 1.55 seconds with the shipped XML
resources and 0.04 seconds with equivalent binary property lists. This is a
resource microbenchmark, not an application frame-rate measurement.

The project now requests binary strings output for both configurations. The
packaging audit rejects nonbinary `.strings` or `.stringsdict` resources. Text,
plural rules, application identity, signing and data paths are unchanged.
The new build requires cloud validation and an interactive typing comparison
before this can be reported as a verified application-level fix. Raw local
process samples are not published.
