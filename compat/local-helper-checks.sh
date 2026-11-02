#!/bin/bash
set -euo pipefail
app="${1:?usage: local-helper-checks.sh path-to-app}"
fixtures="${2:?pass the generated compatibility fixture directory}"
output="$fixtures/results"
mkdir -p "$output"
./compat/verify-app.sh "$app" > "$output/binary-audit.log" 2>&1
"$app/Contents/Helpers/ClipboardTextHelper" image "$fixtures/OCR.png" > "$output/ocr.txt"
grep -qi SequoiaCast "$output/ocr.txt"
"$app/Contents/Helpers/ClipboardTextHelper" thumbnail "$fixtures/OCR.png" "$output/thumbnail.png" 128
request="$(/usr/bin/plutil -convert json -o - - <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>scopes</key><array><string>$fixtures/files</string></array>
<key>ignorePatterns</key><array/>
<key>homeDirectory</key><string>$fixtures</string>
</dict></plist>
EOF
)"
"$app/Contents/Helpers/FileIndexHelper" "$output/index.bin" "$request" > "$output/index-progress.txt"
test -s "$output/index.bin"
"$app/Contents/Helpers/SequoiaCast Test Dictation.app/Contents/MacOS/SequoiaCast Test Dictation" < /dev/null
printf 'All three embedded helpers launch on %s; OCR, thumbnail generation and file crawl passed.\n' "$(sw_vers -productVersion)"
printf 'Dictation inference needs model weights and microphone testing; EOF launch only was checked.\n'
