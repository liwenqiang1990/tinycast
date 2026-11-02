#!/bin/bash
set -euo pipefail
umask 077
work="$(mktemp -d)"
keychain="$work/smoke.keychain-db"
trap 'security delete-keychain "$keychain" >/dev/null 2>&1 || true; rm -rf "$work"' EXIT
security find-generic-password -s org.sequoiacast.test.signing.p12 -a 'SequoiaCast Test Signing' -w "$HOME/Library/Keychains/login.keychain-db" | base64 --decode > "$work/project.p12"
p12_password="$(security find-generic-password -s org.sequoiacast.test.signing.password -a 'SequoiaCast Test Signing' -w "$HOME/Library/Keychains/login.keychain-db")"
password="$(openssl rand -base64 32)"
security create-keychain -p "$password" "$keychain"
security unlock-keychain -p "$password" "$keychain"
security list-keychains -d user -s "$keychain" "$HOME/Library/Keychains/login.keychain-db"
security import "$work/project.p12" -k "$keychain" -P "$p12_password" -T /usr/bin/codesign >/dev/null
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$password" "$keychain" >/dev/null
printf 'int main(void) { return 0; }\n' > "$work/main.c"
xcrun clang -target arm64-apple-macos15.0 "$work/main.c" -o "$work/smoke"
codesign --force --sign 'SequoiaCast Test Signing' --keychain "$keychain" --timestamp=none --options runtime --identifier org.sequoiacast.test.smoke "$work/smoke"
codesign --verify --strict "$work/smoke"
codesign -dv --verbose=4 "$work/smoke" 2>&1
codesign -d --extract-certificates="$work/cert" "$work/smoke"
shasum -a 256 "$work/cert0"
"$work/smoke"
echo 'Project certificate signs and executes an arm64 macOS 15 binary.'
