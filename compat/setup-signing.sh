#!/bin/bash
set -euo pipefail
umask 077
repo="${1:?usage: setup-signing.sh owner/repo}"
keychain="$HOME/Library/Keychains/SequoiaCast-Test.keychain-db"
service='org.sequoiacast.test.signing'
account='SequoiaCast Test Signing'
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
if security find-generic-password -s "$service.p12" -a "$account" >/dev/null 2>&1; then
    security find-generic-password -s "$service.p12" -a "$account" -w > "$work/identity.base64"
    p12_password="$(security find-generic-password -s "$service.password" -a "$account" -w)"
else
    password="$(openssl rand -base64 32)"
    p12_password="$(openssl rand -base64 32)"
    export SEQUOIACAST_P12_PASSWORD="$p12_password"
    openssl req -x509 -newkey rsa:3072 -days 3650 \
        -passout env:SEQUOIACAST_P12_PASSWORD -keyout "$work/key.pem" -out "$work/cert.pem" \
        -subj '/CN=SequoiaCast Test Signing' \
        -addext 'basicConstraints=critical,CA:false' \
        -addext 'keyUsage=critical,digitalSignature' \
        -addext 'extendedKeyUsage=critical,codeSigning' 2>/dev/null
    openssl pkcs12 -export -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -macalg sha1 -inkey "$work/key.pem" -in "$work/cert.pem" \
        -name "$account" -out "$work/identity.p12" \
        -passin env:SEQUOIACAST_P12_PASSWORD -passout env:SEQUOIACAST_P12_PASSWORD
    if [ -e "$keychain" ]; then
        echo 'Project keychain exists but its saved PKCS#12 record is missing; restore the record before continuing.' >&2
        exit 1
    fi
    security create-keychain -p "$password" "$keychain"
    security set-keychain-settings -lut 300 "$keychain"
    security unlock-keychain -p "$password" "$keychain"
    security import "$work/identity.p12" -k "$keychain" -P "$p12_password" -T /usr/bin/codesign >/dev/null
    base64 -i "$work/identity.p12" > "$work/identity.base64"
    security add-generic-password -s "$service.p12" -a "$account" -w "$(cat "$work/identity.base64")" >/dev/null
    security add-generic-password -s "$service.password" -a "$account" -w "$p12_password" >/dev/null
    security lock-keychain "$keychain"
fi
gh secret set SEQUOIACAST_SIGNING_P12_BASE64 --repo "$repo" < "$work/identity.base64"
printf '%s' "$p12_password" | gh secret set SEQUOIACAST_SIGNING_P12_PASSWORD --repo "$repo"
security find-certificate -c "$account" -p "$keychain" | openssl x509 -noout -fingerprint -sha256
echo 'Project signing identity preserved in its dedicated keychain; Actions Secrets configured.'
