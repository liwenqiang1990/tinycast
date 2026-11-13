# v0.12.11 compatibility audit (in progress)

Baseline: `v0.12.11`, `58168bf7e0b721f7c5fbfc7f4e8a068a48cff446`.
Branch: `compat/v0.12.11-macos15-isolated`. Existing stable builds are unchanged.

| Previous change | Upstream evidence / disposition |
| --- | --- |
| Localization performance | Upstream added `LocalizedStringResource.resolved()` to avoid uncached table parsing, with a nine-language harness. Retain that fix. Upstream project.yml still lacks binary strings encoding; retain our binary resource setting and artifact audit for interpolation/plural fallbacks. |
| Glass fallback | Still required. Adapt new compact bar container/buttons and root palette background; preserve upstream menu clipping and editor/dialog background fixes. |
| Foundation Models / Translation | Still unavailable on macOS 15; retain provider/action availability gates and weak linking. |
| Notification and spawn backports | Still required; retain classic notifications and guarded addchdir_np. |
| MCP OAuth | Retain loopback NWListener implementation. New OpenCode MCP bridge also needs NWListener/NWConnection; preserve authorization, request limits and cleanup. |
| App identity and signing | Retain org.sequoiacast.test and fixed signing certificate; map new URL scheme build setting to sequoiacast-test (Dev: sequoiacast-test-dev). |
| Updates | New upstream updater still resolves custom IDs to development; keep updates disabled. Upstream publishing/triage workflows remain disabled, including new issue-link workflow. |
| Animation/focus | Adopt upstream Motion preference and focus/compact-bar changes. No previous speculative input-method or animation performance patch existed to remove. |

Upstream documentation and release workflow now request Xcode 27 on an upstream-specific
`xcode-27` runner. Our public hosted macos-26 workflow inventories installed Xcodes and
selects the latest released 26/27 toolchain. Compilation must establish whether the available
SDK suffices; no successful build is claimed yet.

Storage inspection: ClipboardStore's schema is unchanged (new capture generation prevents
late writes); ChatHistoryStore adds conversation_presets with CREATE TABLE IF NOT EXISTS.
New chat presets/settings are additive. Synthetic upgrade/downgrade tests and GUI validation
remain pending; user data has not been read or migrated. The prior validation report describes
0.12.1 only until superseded by a verified 0.12.11 report.
