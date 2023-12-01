#!/bin/bash

set -Eeuo pipefail

SETTINGS_FILEPATH="/data/config/fooocus-mre/settings.json"
ROOT_PAHT="/fooocus-ai"

checkDir() {
    [ -d "$@" ]
}

checkFile() {
    [ -f "$@" ]
}

mkdir -p /data/config/fooocus-mre

echo "[BOOTSTRAP] Validating settings.json"
if ! checkFile $SETTINGS_FILEPATH; then
    echo "[BOOTSTRAP] Failed to find settings.json in the config path. Copying a fresh copy."
    cp -r -f -v /cleanConfig/settings.json $SETTINGS_FILEPATH
    if checkFile $SETTINGS_FILEPATH; then
        echo "[BOOTSTRAP] Clean file was copied"
    else
        echo "[BOOTSTRAP] Failed to copy. Exiting"
        exit 1 
    fi
fi

echo "[BOOTSTRAP] Copying settings.json"
cp -r -f -v $SETTINGS_FILEPATH $ROOT_PAHT 

echo "[BOOTSTRAP] Applying Mounts"
bash /mount.sh