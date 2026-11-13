> This compatibility branch builds **SequoiaCast**, based on stable Tinycast v0.12.11, for Apple silicon Macs running macOS 15. **On macOS 15, Liquid Glass is replaced with native blur/material surfaces; Foundation Models on-device AI and the built-in Translate action are disabled.** Their unavailable provider, launcher, shortcut and translation settings entries are hidden. External AI providers, installed AI tools, the extension engine, launcher, hotkeys, clipboard, snippets, quicklinks and file search are retained. AI-based grammar correction, rewriting and summarization require a configured compatible provider. MCP OAuth, notifications and subprocess APIs were backported rather than removing their features. The app uses separate application/helper identities and data directories, disables automatic updates, and makes clipboard recording opt-in. See [compatibility build and validation](compat/README.md) for the detailed feature differences, fixed self-signing identity, manual workflow and actual test limits. Upstream instructions below describe the original macOS 26 channel and do not apply unchanged to this compatibility build.

Compatibility changes and current validation: [v0.12.11 audit](compat/UPGRADE-0.12.11.md).

<h1 align="center">
  <a href="https://tinycast.dev"><img src="docs/images/icon.png" alt="Tinycast app icon" width="128" height="128"></a><br>
  Tinycast
</h1>

<p align="center">
  A native macOS launcher for everyday productivity. Lightweight and open source.
</p>

<p align="center">
  <a href="https://tinycast.dev"><strong>Website</strong></a> ·
  <a href="#install"><strong>Install</strong></a> ·
  <a href="https://tinycast.dev/docs/"><strong>Docs</strong></a> ·
  <a href="https://tinycast.dev/support"><strong>Support</strong></a>
</p>

<p align="center">
  <a href="https://github.com/abue-ammar/tinycast/releases/latest"><picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/github/release/abue-ammar/tinycast.svg?variant=ghost&amp;font=geist-mono&amp;mode=dark&amp;label=RELEASE&amp;logo=lu:Tag&amp;valueColor=60A5FA" /><img alt="Latest release" src="https://shieldcn.dev/github/release/abue-ammar/tinycast.svg?variant=ghost&amp;font=geist-mono&amp;mode=light&amp;label=RELEASE&amp;logo=lu:Tag&amp;valueColor=2563EB" /></picture></a>
  <a href="https://github.com/abue-ammar/tinycast/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/github/downloads/abue-ammar/tinycast.svg?variant=ghost&amp;font=geist-mono&amp;mode=dark&amp;label=DOWNLOADS&amp;logo=lu:CloudDownload&amp;valueColor=A78BFA" /><img alt="Total downloads" src="https://shieldcn.dev/github/downloads/abue-ammar/tinycast.svg?variant=ghost&amp;font=geist-mono&amp;mode=light&amp;label=DOWNLOADS&amp;logo=lu:CloudDownload&amp;valueColor=7C3AED" /></picture></a>
  <a href="https://github.com/abue-ammar/tinycast/actions/workflows/release.yml"><picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/github/ci/abue-ammar/tinycast.svg?variant=ghost&amp;font=geist-mono&amp;mode=dark&amp;workflow=release.yml&amp;label=BUILD&amp;logo=lu:Hammer&amp;valueColor=4ADE80" /><img alt="Release build status" src="https://shieldcn.dev/github/ci/abue-ammar/tinycast.svg?variant=ghost&amp;font=geist-mono&amp;mode=light&amp;workflow=release.yml&amp;label=BUILD&amp;logo=lu:Hammer&amp;valueColor=16A34A" /></picture></a>
  <a href="https://discord.gg/v2Eeb4QQy3"><picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/badge/DISCORD-JOIN.svg?variant=ghost&amp;font=geist-mono&amp;mode=dark&amp;logo=discord&amp;valueColor=A5B4FC" /><img alt="Join the Tinycast Discord" src="https://shieldcn.dev/badge/DISCORD-JOIN.svg?variant=ghost&amp;font=geist-mono&amp;mode=light&amp;logo=discord&amp;valueColor=5865F2" /></picture></a>
  <br>
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/badge/MACOS-26%2B.svg?variant=ghost&amp;font=geist-mono&amp;mode=dark&amp;logo=apple" /><img alt="macOS 26 or later" src="https://shieldcn.dev/badge/MACOS-26%2B.svg?variant=ghost&amp;font=geist-mono&amp;mode=light&amp;logo=apple" /></picture>
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/badge/SWIFT-6.svg?variant=ghost&amp;font=geist-mono&amp;mode=dark&amp;logo=swift&amp;valueColor=FB923C" /><img alt="Swift 6" src="https://shieldcn.dev/badge/SWIFT-6.svg?variant=ghost&amp;font=geist-mono&amp;mode=light&amp;logo=swift&amp;valueColor=EA580C" /></picture>
  <a href="LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/badge/LICENSE-AGPL--3.0.svg?variant=ghost&amp;font=geist-mono&amp;mode=dark&amp;logo=lu:Scale" /><img alt="License: AGPL-3.0" src="https://shieldcn.dev/badge/LICENSE-AGPL--3.0.svg?variant=ghost&amp;font=geist-mono&amp;mode=light&amp;logo=lu:Scale" /></picture></a>
</p>

<p align="center">
  <img src="docs/screenshot.jpg" alt="Tinycast command palette">
</p>

Built with SwiftUI and AppKit. No dependencies, no Electron, no telemetry. It runs your Raycast
extensions, too.

[Explore all features →](https://tinycast.dev/#features)

For anything private, feel free to email [iabueammar@gmail.com](mailto:iabueammar@gmail.com).

## Install

On an Apple silicon Mac with macOS 26 or newer:

```sh
brew install --cask tinycast
brew install --cask tinycast@beta
```

- **DMG:** notarized, download from [Releases](https://github.com/abue-ammar/tinycast/releases). Drag `Tinycast.app` to `/Applications`.
- **Intel Mac:** install from [Homebrew tap](https://github.com/abue-ammar/homebrew-tinycast).

## Support

Tinycast is free and stays free. If it earns a place on your Mac, consider supporting its
development. Thank you!

<p align="center">
  <a href="https://tinycast.dev/support"><picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/badge/SUPPORT-CARD.svg?variant=outline&amp;size=lg&amp;font=geist-mono&amp;mode=dark&amp;logo=lu:CircleDollarSign&amp;logoColor=A78BFA&amp;valueColor=A78BFA" /><img alt="Support by card payment" src="https://shieldcn.dev/badge/SUPPORT-CARD.svg?variant=outline&amp;size=lg&amp;font=geist-mono&amp;mode=light&amp;logo=lu:CircleDollarSign&amp;logoColor=7C3AED&amp;valueColor=7C3AED" /></picture></a>
  <a href="https://tinycast.dev/support?method=crypto"><picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/badge/SUPPORT-CRYPTO.svg?variant=outline&amp;size=lg&amp;font=geist-mono&amp;mode=dark&amp;logo=lu:Bitcoin&amp;logoColor=FBBF24&amp;valueColor=FBBF24" /><img alt="Support with crypto" src="https://shieldcn.dev/badge/SUPPORT-CRYPTO.svg?variant=outline&amp;size=lg&amp;font=geist-mono&amp;mode=light&amp;logo=lu:Bitcoin&amp;logoColor=B45309&amp;valueColor=B45309" /></picture></a>
</p>

## License

Tinycast is licensed under the [AGPL-3.0 license](LICENSE).

## Contributors

- **Abue Ammar and upstream contributors** — original Tinycast application.
- **liwenqiang1990** — SequoiaCast compatibility channel maintainer and macOS 15 testing.
- **OpenAI Codex** — AI-assisted macOS 15 compatibility port, performance review, build automation and validation documentation.

This independently maintained compatibility build is not an official OpenAI or upstream release.
