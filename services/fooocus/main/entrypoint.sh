#!/bin/bash

set -Eeuo pipefail

SDXL_STYLES="/data/config/fooocus/sdxl_styles"
ROOT_PAHT="/fooocus-ai"

checkDir() {
    [ -d "$@" ]
}

checkFile() {
    [ -f "$@" ]
}

mkdir -p /data/config/fooocus
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

echo "[BOOTSTRAP] Applying Mounts"
bash /mount.sh

cd $ROOT_PAHT && \
    #source fooocus_env/bin/activate && \
    python entry_with_update.py --listen ${CLI_ARGS}