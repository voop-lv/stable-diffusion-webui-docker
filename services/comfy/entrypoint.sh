#!/bin/bash

set -Eeuo pipefail

mkdir -vp /data/config/comfy/custom_nodes
mkdir -vp /data/config/comfy/web-extensions
mkdir -vp /stable-diffusion/custom_nodes

mkdir -vp /data/models/upscale_models
mkdir -vp /data/models/GLIGEN
mkdir -vp /data/models/CLIPEncoder
mkdir -vp /data/models/sams
mkdir -vp /data/models/seecoders
mkdir -vp /data/models/mmdets
mkdir -vp /data/models/Stable-diffusion-XL-Base

mkdir -vp ${ROOT}/STARUP_TEMP/web-extensions

declare -A MOUNTS

MOUNTS["/root/.cache"]="/data/.cache"
MOUNTS["${ROOT}/input"]="/data/config/comfy/input"
MOUNTS["${ROOT}/custom_nodes"]="/data/config/comfy/custom_nodes"
MOUNTS["${ROOT}/output"]="/output/comfy"

MOUNTS["${ROOT}/models/vae_approx"]="/data/models/VAE-approx"
MOUNTS["${ROOT}/models/vae"]="/data/models/VAE"
MOUNTS["${ROOT}/models/loras"]="/data/models/Lora"
MOUNTS["${ROOT}/models/gligen"]="/data/models/GLIGEN"
MOUNTS["${ROOT}/models/controlnet"]="/data/models/ControlNet"
MOUNTS["${ROOT}/models/hypernetworks"]="/data/models/hypernetworks"
MOUNTS["${ROOT}/models/upscale_models"]="/data/models/upscale_models"
MOUNTS["${ROOT}/models/embeddings"]="/data/models/embeddings"
MOUNTS["${ROOT}/models/checkpoints"]="/data/models/Stable-diffusion"
MOUNTS["${ROOT}/models/sams"]="/data/models/sams"
MOUNTS["${ROOT}/models/seecoders"]="/data/models/seecoders"
MOUNTS["${ROOT}/models/mmdets"]="/data/models/mmdets"
MOUNTS["${ROOT}/web/extensions"]="/data/config/comfy/web-extensions"

cp -r -f ${ROOT}/web/extensions/* ${ROOT}/STARUP_TEMP/web-extensions

install_requirements() {
    local dir="$1"
    if [[ -f "${dir}/requirements.txt" ]]; then
        echo "Installing requirements for ${dir}..."
        pip install -r "${dir}/requirements.txt"
        echo "Requirements installed for ${dir}."
    else
        echo "No requirements.txt found in ${dir}. Skipping."
    fi
}

process_directory() {
    local dir="$1"
    if [[ -d "${dir}" ]]; then
        for sub_dir in "${dir}"/*; do
            if [[ -d "${sub_dir}" ]]; then
                install_requirements "${sub_dir}"
            fi
        done
    else
        echo "Error: ${dir} is not a directory."
    fi
}


for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  if [ ! -f "$from_path" ]; then
    mkdir -vp "$from_path"
  fi
  mkdir -vp "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done

if [ -f "/data/config/comfy/startup.sh" ]; then
  pushd ${ROOT}
  . /data/config/comfy/startup.sh
  popd
fi

process_directory "${ROOT}/custom_nodes"
if [ ! -f "${ROOT}/web/extensions/core" ]; then
  echo Copying fresh copy of web-extensions core
  cp -r -f -v ${ROOT}/STARUP_TEMP/web-extensions/* ${ROOT}/web/extensions/
fi

rm -rf ${ROOT}/STARUP_TEMP

if [ -f "/data/config/comfy/startup.sh" ]; then
  pushd ${ROOT}
  . /data/config/comfy/startup.sh
  popd
fi

exec "$@"
