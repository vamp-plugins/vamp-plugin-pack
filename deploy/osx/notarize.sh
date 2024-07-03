#!/bin/bash

## NB to verify:
# spctl -a -v "/Applications/Application.app"

set -e

target="$1"

if [ ! -f "$target" ] || [ -n "$2" ]; then
    echo "Usage: $0 <target>"
    echo "  e.g. $0 MyApplication-1.0.target"
    exit 2
fi

set -u

user="appstore@particularprograms.co.uk"
team_id="73F996B92S"

echo
echo "Uploading for notarization..."

xcrun notarytool submit \
    "$target" \
    --apple-id "$user" \
    --team-id "$team_id" \
    --keychain-profile notarytool-cannam \
    --wait --progress

case "$target" in
    *dmg)
	echo
	echo "Stapling to package..."
	xcrun stapler staple "$target" || exit 1
	;;
    *)
	echo
	echo "Not stapling, target file type not supported for that"
	;;
esac

echo
echo "Done"


