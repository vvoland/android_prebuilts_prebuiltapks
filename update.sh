#!/bin/bash
set -e
BASE=$(pwd)

echo -n "Keystore password: "
read -s PASSWORD

function sign
{
    jarsigner -verbose -keystore /data/passwords/keystore/woland.keystore "$1" woland <<< "$PASSWORD"
    rm "$BASE/$2" || true
    zipalign -v -p 4 "$1" "$BASE/$2"
}


function process
{
    dir="$1"
    BASE=$(pwd)
    cd "../$dir"
    ./gradlew assembleRelease > /dev/null
    apk=$(find . -name "*release*.apk" | head -n 1)
    if [ ! -z "$apk" ]
    then
        echo "    Signing $apk..."
        sign "$apk" "$2"
    fi
    cd "$BASE"
}


process "android_packages_apps_GmsCore" "GmsCore/com.google.android.gms.apk"
process "android_packages_apps_GsfProxy" "GsfProxy/com.google.android.gsf.apk"
process "android_packages_apps_FakeStore" "FakeStore/com.android.vending.apk"
process "IchnaeaNlpBackend" "MozillaNlpBackend/org.microg.nlp.backend.ichnaea.apk"
process "NominatimGeocoderBackend" "NominatimNlpBackend/org.microg.nlp.backend.nominatim.apk"
