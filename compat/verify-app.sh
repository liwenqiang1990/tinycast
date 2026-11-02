#!/bin/bash
set -euo pipefail
app="${1:?usage: verify-app.sh path-to-app}"
plist="$app/Contents/Info.plist"
read_plist() { /usr/libexec/PlistBuddy -c "Print :$2" "$1"; }
[ "$(read_plist "$plist" CFBundleIdentifier)" = org.sequoiacast.test ]
[ "$(read_plist "$plist" CFBundleExecutable)" = 'SequoiaCast Test' ]
[ "$(read_plist "$plist" LSMinimumSystemVersion)" = 15.0 ]
[ "$(read_plist "$plist" CFBundleURLTypes:0:CFBundleURLSchemes:0)" = sequoiacast-test ]
helper="$app/Contents/Helpers/SequoiaCast Test Dictation.app"
[ "$(read_plist "$helper/Contents/Info.plist" CFBundleIdentifier)" = org.sequoiacast.test.dictation ]
[ "$(read_plist "$helper/Contents/Info.plist" LSMinimumSystemVersion)" = 15.0 ]
[ -x "$app/Contents/Helpers/ClipboardTextHelper" ]
[ -x "$app/Contents/Helpers/FileIndexHelper" ]
[ -x "$helper/Contents/MacOS/SequoiaCast Test Dictation" ]
count=0
cert_dir="$(mktemp -d)"
trap 'rm -rf "$cert_dir"' EXIT
codesign -d --extract-certificates="$cert_dir/main" "$app" 2>/dev/null
main_cert="$(shasum -a 256 "$cert_dir/main0" | awk '{print $1}')"
[ "$main_cert" = "$(cat "$(dirname "$0")/signing-certificate.sha256")" ]
while IFS= read -r -d '' binary; do
    file -b "$binary" | grep -q 'Mach-O' || continue
    count=$((count + 1))
    echo "Binary: ${binary#"$app"/}"
    [ "$(lipo -archs "$binary")" = arm64 ]
    minimum="$(xcrun vtool -show-build-version "$binary" | awk '/minos/{print $2}')"
    echo "Architecture: arm64; minOS: $minimum"
    [ "$minimum" = 15.0 ]
    codesign --verify --strict "$binary"
    signature="$(codesign -dv --verbose=4 "$binary" 2>&1)"
    echo "$signature" | grep -E '^(Identifier|Authority|CDHash|Runtime Version|TeamIdentifier)='
    echo "$signature" | grep -q 'Authority=SequoiaCast Test Signing'
    echo "$signature" | grep -q 'runtime'
    echo "$signature" | grep -q '^Identifier=org.sequoiacast.test'
    codesign -d --extract-certificates="$cert_dir/nested" "$binary" 2>/dev/null
    [ "$(shasum -a 256 "$cert_dir/nested0" | awk '{print $1}')" = "$main_cert" ]
    otool -L "$binary"
    if otool -l "$binary" | awk '/cmd LC_LOAD_DYLIB/{strong=1;next} /cmd LC_/{strong=0} strong && /FoundationModels.framework/{bad=1} END {exit !bad}'; then
        echo 'FoundationModels must be weak-linked on macOS 15.' >&2
        exit 1
    fi
done < <(find "$app" -type f -print0)
[ "$count" -ge 4 ]
echo "Verified $count Mach-O files; certificate SHA256: $main_cert"
codesign --verify --deep --strict "$app"
[ -s "$app/Contents/Resources/RaycastRuntime.generated.js" ]
[ -d "$app/Contents/Resources/EmojiKeywords" ]
[ -s "$app/Contents/Resources/NOTICE.md" ]
while IFS= read -r -d '' link; do
    [ -e "$link" ] || { echo "Broken symlink: $link" >&2; exit 1; }
done < <(find "$app" -type l -print0)
echo 'Bundle, resources, nested signatures and links verified.'
entitlements="$cert_dir/entitlements.plist"
codesign -d --entitlements - --xml "$app" > "$entitlements" 2>/dev/null
if /usr/libexec/PlistBuddy -c 'Print :com.apple.security.get-task-allow' "$entitlements" >/dev/null 2>&1; then
    echo 'Release must not carry get-task-allow.' >&2
    exit 1
fi
for entitlement in com.apple.security.cs.allow-jit com.apple.security.automation.apple-events com.apple.security.device.camera com.apple.security.device.audio-input com.apple.security.personal-information.calendars; do
    [ "$(read_plist "$entitlements" "$entitlement")" = true ]
done
echo 'Release entitlements verified.'
