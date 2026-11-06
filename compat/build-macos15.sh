#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${RUNNER_TEMP:?Run this script on the GitHub runner}"
mkdir -p diagnostics dist
xcodebuild -version | tee diagnostics/toolchain.txt
xcrun --sdk macosx --show-sdk-version >> diagnostics/toolchain.txt
swift --version >> diagnostics/toolchain.txt
git rev-parse HEAD > diagnostics/commit.txt
xcodegen generate
if ! git diff --exit-code -- Tinycast.xcodeproj Tinycast/Features/Dictation/Helper/Info.plist > diagnostics/project-drift.txt; then
    echo 'Generated Xcode project differs from the committed project.' >&2
    exit 1
fi
xcodebuild -project Tinycast.xcodeproj -scheme Tinycast -configuration Release \
    -derivedDataPath "$RUNNER_TEMP/DerivedData" -resultBundlePath "$RUNNER_TEMP/Build.xcresult" \
    ARCHS=arm64 ONLY_ACTIVE_ARCH=NO MACOSX_DEPLOYMENT_TARGET=15.0 \
    CODE_SIGNING_ALLOWED=NO MARKETING_VERSION=0.12.1 CURRENT_PROJECT_VERSION="$GITHUB_RUN_NUMBER" \
    build 2>&1 | tee diagnostics/build.log
app="$RUNNER_TEMP/DerivedData/Build/Products/Release/SequoiaCast.app"
identity='SequoiaCast Test Signing'
keychain="$RUNNER_TEMP/sequoiacast-signing.keychain-db"
codesign --force --sign "$identity" --keychain "$keychain" --options runtime --timestamp=none \
    --identifier org.sequoiacast.test.clipboard-text "$app/Contents/Helpers/ClipboardTextHelper"
codesign --force --sign "$identity" --keychain "$keychain" --options runtime --timestamp=none \
    --identifier org.sequoiacast.test.file-index "$app/Contents/Helpers/FileIndexHelper"
codesign --force --sign "$identity" --keychain "$keychain" --options runtime --timestamp=none \
    "$app/Contents/Helpers/SequoiaCast Dictation.app"
codesign --force --sign "$identity" --keychain "$keychain" --options runtime --timestamp=none \
    --entitlements Tinycast/Tinycast.entitlements "$app"
plutil -p "$app/Contents/Info.plist" > diagnostics/app-info.txt
plutil -p "$app/Contents/Helpers/SequoiaCast Dictation.app/Contents/Info.plist" > diagnostics/helper-info.txt
bash -x ./compat/verify-app.sh "$app" 2>&1 | tee diagnostics/binary-audit.txt
stage="$RUNNER_TEMP/ValidationBundle"
mkdir -p "$stage"
./compat/build-runtime-checks.sh "$stage/Validation"
archive='dist/SequoiaCast-0.12.1-sequoia.3-macos15-arm64.zip'
ditto -c -k --keepParent --sequesterRsrc "$app" "$archive"
ditto -c -k --keepParent --sequesterRsrc "$stage/Validation" 'dist/SequoiaCast-0.12.1-macos15-validation.zip'
mkdir -p "$RUNNER_TEMP/roundtrip"
ditto -x -k "$archive" "$RUNNER_TEMP/roundtrip"
./compat/verify-app.sh "$RUNNER_TEMP/roundtrip/SequoiaCast.app" > diagnostics/zip-audit.txt
diff -qr "$app" "$RUNNER_TEMP/roundtrip/SequoiaCast.app" > diagnostics/zip-content-diff.txt
shasum -a 256 dist/*.zip | tee dist/SHA256SUMS.txt
