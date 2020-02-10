#!/bin/bash

# Run this from the project root, without arguments, or with the
# single argument --no-notarization to skip the notarize step

set -e

notarize=yes
if [ "$1" = "--no-notarization" ]; then
    notarize=no
elif [ -n "$1" ]; then
    echo "Usage: $0 [--no-notarization]"
    exit 2
fi

set -u

app="Vamp Plugin Pack Installer"
identity="Developer ID Application: Chris Cannam"

version=`perl -p -e 's/^[^"]*"([^"]*)".*$/$1/' version.h`

qmake=$(grep '^# Command: ' Makefile | awk '{ print $3; }')

echo "Proceed to rebuild, package, and sign version $version using"
echo -n "qmake path \"$qmake\" [Yn] ? "
read yn
case "$yn" in "") ;; [Yy]) ;; *) exit 3;; esac
echo "Proceeding"

source="$app.app"
volume="$app"-"$version"
target="$volume"/"$app".app
dmg="$volume".dmg

if [ -d "$volume" ]; then
    echo "Target directory $volume already exists, not overwriting"
    exit 2
fi

if [ -f "$dmg" ]; then
    echo "Target disc image $dmg already exists, not overwriting"
    exit 2
fi

if [ "$notarize" = no ]; then
    echo
    echo "Note: The --no-notarization flag is set: won't be submitting for notarization"
fi

rm -rf "$app.app"
rm -rf "$volume"
rm -f "$dmg"

./repoint install
rm -rf .qmake.stash
"$qmake" -r
make clean
rm -rf out

echo
echo "Building plugins..."
make -j3 -f Makefile.plugins
echo "Done"

echo 
echo "Signing plugins..."
codesign -s "$identity" -fv --timestamp --options runtime out/*.dylib
echo "Done"

if [ "$notarize" = no ]; then
    echo
    echo "The --no-notarization flag was set: not submitting for notarization"
else
    echo
    echo "Notarizing plugins..."
    rm -f plugins.zip
    ditto -c -k out plugins.zip
    deploy/osx/notarize.sh plugins.zip
    echo "Done"
 
## No, it doesn't seem to be possible to pass a dylib to stapler   
#    echo
#    echo "Stapling plugins..."
#    xcrun stapler staple out/*.dylib
#    echo "Done"
fi

echo 
echo "Building installer..."
make -j3 -f Makefile.installer
echo "Done"

echo
echo "Deploying installer..."
deploy/osx/deploy.sh "$app" || exit 1
echo "Done"

echo
echo "Making target tree..."
mkdir "$volume" || exit 1

#cp README.md "$volume/README.txt"
#cp README.OSC "$volume/README-OSC.txt"
#cp COPYING "$volume/COPYING.txt"
#cp CHANGELOG "$volume/CHANGELOG.txt"
#cp CITATION "$volume/CITATION.txt"
cp -rp "$source" "$target"

# update file timestamps so as to make the build date apparent
find "$volume" -exec touch \{\} \;
echo "Done"

echo
echo "Signing installer..."
codesign -s "$identity" -fv --deep --timestamp --options runtime "$volume"
echo "Done"

echo
echo "Making dmg..."
rm -f "$dmg"
hdiutil create -srcfolder "$volume" "$dmg" -volname "$volume" -fs HFS+ && 
	rm -r "$volume"
echo "Done"

echo
echo "Signing dmg..."
codesign -s "$identity" -fv --timestamp "$dmg"
echo "Done"

if [ "$notarize" = no ]; then
    echo
    echo "The --no-notarization flag was set: not submitting for notarization"
else
    echo
    echo "Submitting disk image for notarization..."
    deploy/osx/notarize.sh "$dmg"
    echo "Done"

    echo
    echo "Stapling disk image..."
    xcrun stapler staple "$dmg"
    echo "Done"
fi

echo "Done"
