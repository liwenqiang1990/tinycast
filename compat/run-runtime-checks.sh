#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p Results
for harness in clipboard-test pasteboard-test snippets-test quicklink-test file-index-test hotkey-test notes-editor-test; do
    echo "Running $harness on $(sw_vers -productVersion)"
    "./$harness" 2>&1 | tee "Results/$harness.log"
done
echo 'All runtime checks passed. GUI and permission-dependent checks are separate.'
