#!/bin/bash

set -eu

app="$1"
if [ -z "$app" ]; then
	echo "Usage: $0 <appname>"
	echo "Provide appname without the .app extension, please"
	exit 2
fi

if [ -z "$QTDIR" ]; then
    echo "Error: QTDIR is not set"
    exit 2
fi

if [ ! -d "$QTDIR" ]; then
    echo "Error: QTDIR ($QTDIR) is not set to a directory that exists"
    exit 2
fi

macdeployqt="$QTDIR/bin/macdeployqt"

if [ ! -x "$macdeployqt" ]; then
    echo "Error: macdeployqt program not found in $macdeployqt"
    exit 1
fi

"$macdeployqt" "$app.app" 

# If this shows up it has all kinds of dependencies we don't want, so
# eliminate it
rm -f "$app.app"/Contents/PlugIns/platforminputcontexts/libqtvirtualkeyboardplugin.dylib

echo "Done"


