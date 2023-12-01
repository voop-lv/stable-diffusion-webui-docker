#!/bin/bash

set -Eeuo pipefail

SETTINGS_FILEPATH="/data/config/fooocus-mre/settings.json"
SDXL_STYLES="/data/config/fooocus-mre/sdxl_styles"
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

echo "[BOOTSTRAP] Validating sdxl_styles"
if ! checkDir $SDXL_STYLES; then 
    echo "[BOOTSTRAP] Failed to find sdxl_styles in the config path. Copying a fresh copy."
    cp -r -f -v /cleanConfig/sdxl_styles $SDXL_STYLES
    if checkDir $SDXL_STYLES; then
        echo "[BOOTSTRAP] Clean folder was copied"
    else
        echo "[BOOTSTRAP] Failed to copy. Exiting"
        exit 1 
    fi 
fi

echo "[BOOTSTRAP] Copying settings.json"
cp -r -f -v $SETTINGS_FILEPATH $ROOT_PAHT 

echo "[BOOTSTRAP] Applying Mounts"
bash /mount.sh

cd $ROOT_PAHT && \
    source fooocus_env/bin/activate && \
    python entry_with_update.py --listen ${CLI_ARGS}