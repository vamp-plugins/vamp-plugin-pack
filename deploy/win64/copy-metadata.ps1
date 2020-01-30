
Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

mkdir -f out

dir -Attributes Directory | foreach {

    $dir = $_.BaseName
    $lib = $dir

    if ($dir -eq "constant-q-cpp") { $lib = "cqvamp" }
    if ($dir -eq "marsyas") { $lib = "mvamp" }
    if ($dir -eq "match-vamp") { $lib = "match-vamp-plugin" }
    if ($dir -eq "vamp-aubio-plugins") { $lib = "vamp-aubio" }
    if ($dir -eq "vamp-libxtract-plugins") { $lib = "vamp-libxtract" }
    if ($dir -eq "vamp-plugin-sdk") { $lib = "vamp-example-plugins" }
    if ($dir -eq "vamp-fanchirp") { $lib = "fanchirp" }
    if ($dir -eq "vamp-tempogram") { $lib = "tempogram" }
    if ($dir -eq "vamp-simple-cepstrum") { $lib = "simple-cepstrum" }

    ( "cat", "n3" ) | foreach {

        if (Test-Path -Path $dir/$lib.$_ -PathType Leaf) {
            cp $dir/$lib.$_ out/
        }
    }

    ( "README", "COPYING", "CITATION" ) | foreach {

        if (Test-Path -Path $dir/$_.md -PathType Leaf) {
            cp $dir/$_.md out/${lib}_$_.md
        } elseif  (Test-Path -Path $dir/$_.txt -PathType Leaf) {
            cp $dir/$_.txt out/${lib}_$_.txt
        } elseif  (Test-Path -Path $dir/$_ -PathType Leaf) {
            cp $dir/$_ out/${lib}_$_.txt
        }
    }
}

# oddments

cp marsyas/src/mvamp/mvamp.n3 out/ 
cp marsyas/src/mvamp/mvamp.cat out/ 

cp vamp-plugin-sdk/examples/vamp-example-plugins.n3 out/ 
cp vamp-plugin-sdk/examples/vamp-example-plugins.cat out/

cp ua-vamp-plugins/LICENSE out/ua-vamp-plugins_COPYING.txt 

del out/vamp-example-plugins_README.txt # it's about the SDK not the plugins
