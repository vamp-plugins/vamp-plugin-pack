#!/bin/bash

# Run this from the project root, without arguments, or with the
# single argument --no-notarization to skip the notarize step

archs="x86_64 arm64"
qtdir_x86_64="/Users/cannam/Qt/5.12.10/clang_64"
qtdir_arm64="/Users/cannam/Qt/5.15.2-arm64"
identity="Developer ID Application: Particular Programs Ltd (73F996B92S)"

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

version=`perl -p -e 's/^[^"]*"([^"]*)".*$/$1/' version.h`

echo "Proceed to rebuild, package, and sign version $version using:"
for arch in $archs; do
    case "$arch" in
	x86_64) qtdir="$qtdir_x86_64";;
	arm64) qtdir="$qtdir_arm64";;
	*) echo "(internal error, unknown arch)"; exit 1;;
    esac
    echo "* for arch $arch: Qt dir $qtdir"
    if [ ! -d "$qtdir" ]; then
	echo "*** ERROR: Qt dir $qtdir does not exist"
	exit 1
    fi
    if [ ! -f "$qtdir/bin/qmake" ]; then
	echo "*** ERROR: qmake not found in $qmake (for Qt dir $qtdir)"
	exit 1
    fi
    qmake_arch=$(lipo -archs "$qtdir/bin/qmake")
    if [ t"$qmake_arch" != t"$arch" ]; then
	echo "*** ERROR: wrong arch $qmake_arch for qmake $qmake (expected $arch)"
	exit 1
    fi
done
echo -n "[Yn] ? "
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

entitlements=deploy/osx/Entitlements.plist

rm -rf "$app.app"
rm -rf "$volume"
rm -f "$dmg"
rm -rf "out"

./repoint install

for arch in $archs; do
    case "$arch" in
	x86_64) qtdir="$qtdir_x86_64";;
	arm64) qtdir="$qtdir_arm64";;
    esac

    qmake="$qtdir/bin/qmake"
    
    rm -rf .qmake.stash
    rm -rf o
    PATH="$qtdir/bin:$PATH" "$qmake" -r
    make clean
    rm -rf "out_$arch"

    echo
    echo "Building plugins..."
    PATH="$qtdir/bin:$PATH" arch -"$arch" make -j3 -f Makefile.plugins
    echo "Done"

    echo
    echo "Building get-version..."
    PATH="$qtdir/bin:$PATH" arch -"$arch" make -j3 -f Makefile.get-version
    echo "Done"

    echo 
    echo "Signing plugins and get-version..."
    codesign -s "$identity" -fv --timestamp --options runtime out/*.dylib
    codesign -s "$identity" -fv --timestamp --options runtime --entitlements "$entitlements" out/get-version
    echo "Done"

    mv out "out_$arch"
done

echo
echo "Constructing fat plugin and get-version binaries..."
mkdir -p out
for file in out_x86_64/*.dylib out_x86_64/get-version; do
    lipo "$file" out_arm64/"$(basename $file)" -create -output out/"$(basename $file)"
done
for file in out_x86_64/*.txt out_x86_64/*.md out_x86_64/*.n3 out_x86_64/*.cat; do
    cp "$file" out/
done
echo "Done"

if [ "$notarize" = no ]; then
    echo
    echo "The --no-notarization flag was set: not submitting for notarization"
else
    echo
    echo "Notarizing plugins and get-version..."
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
# This is still just an Intel binary, not a fat file
qtdir="$qtdir_x86_64"
qmake="$qtdir/bin/qmake"
rm -rf .qmake.stash
rm -rf o
PATH="$qtdir/bin:$PATH" "$qmake" -r
make -f Makefile.installer clean
PATH="$qtdir/bin:$PATH" arch -x86_64 make -j3 -f Makefile.installer
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
find "$target" -name \*.dylib -print | while read fr; do
    codesign -s "$identity" -fv --deep --timestamp --options runtime --entitlements "$entitlements" "$fr"
done
codesign -s "$identity" -fv --deep --timestamp --options runtime --entitlements "$entitlements" "$target/Contents/MacOS/$app"
codesign -s "$identity" -fv --deep --timestamp --options runtime --entitlements "$entitlements" "$target"
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

