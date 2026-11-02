swiftc() {
    command xcrun swiftc -target arm64-apple-macosx15.0 "$@" || return $?
    local previous='' argument output=''
    for argument in "$@"; do
        if [ "$previous" = -o ]; then output="$argument"; break; fi
        previous="$argument"
    done
    test -n "$output" || return 1
    cp "$output" "$SEQUOIACAST_RUNTIME_DIR/$(basename "$output")"
}
export -f swiftc
