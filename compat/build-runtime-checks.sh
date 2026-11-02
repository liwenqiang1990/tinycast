#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export SEQUOIACAST_RUNTIME_DIR="${1:?usage: build-runtime-checks.sh output-directory}"
mkdir -p "$SEQUOIACAST_RUNTIME_DIR"
export BASH_ENV="$PWD/compat/runtime-compiler-env.sh"
for harness in clipboard-test pasteboard-test snippets-test quicklink-test file-index-test hotkey-test notes-editor-test; do
    ./Scripts/run-tests.sh "$harness" 2>&1 | tee "diagnostics/runtime-$harness.log"
    binary="$SEQUOIACAST_RUNTIME_DIR/$harness"
    codesign --force --sign 'SequoiaCast Test Signing' \
        --keychain "$RUNNER_TEMP/sequoiacast-signing.keychain-db" \
        --identifier "org.sequoiacast.test.validation.$harness" \
        --options runtime --timestamp=none "$binary"
    test "$(lipo -archs "$binary")" = arm64
    test "$(xcrun vtool -show-build-version "$binary" | awk '/minos/{print $2}')" = 15.0
    codesign --verify --strict "$binary"
done
cp compat/run-runtime-checks.sh "$SEQUOIACAST_RUNTIME_DIR/run.sh"
