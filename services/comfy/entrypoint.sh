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
mkdir -vp /data/models/onnx
mkdir -vp /data/models/insightface
mkdir -vp /data/models/Stable-diffusion-XL-Base

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
MOUNTS["${ROOT}/models/onnx"]="/data/models/onnx"
MOUNTS["${ROOT}/models/insightface"]="/data/models/insightface"

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

process_install_py() {
    local dir="$1"
    if [[ -f "${dir}/install.py" ]]; then
        python3 ${dir}/install.py
    fi
}

process_directory() {
    local dir="$1"
    if [[ -d "${dir}" ]]; then
        for sub_dir in "${dir}"/*; do
            if [[ -d "${sub_dir}" ]]; then
                install_requirements "${sub_dir}"
                process_install_py "${sub_dir}" || true
            fi
        done
    else
        echo "Error: ${dir} is not a directory."
    fi
}

copyFreshExtenstion() {
  echo Copying fresh copy of web-extensions core
  cp -r -f -v "/CLEAN_CONFIG/web/extensions/*" "${ROOT}/web/extensions/"
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

chmod -R 777 $ROOT/custom_nodes
process_directory "${ROOT}/custom_nodes"

WEB_EXTENSIONS="${ROOT}/web/extensions"

if [ -z "$(find "${WEB_EXTENSIONS}" -mindepth 1)" ]; then
  echo "[WARNING] Web Extensions are empty"
  copyFreshExtenstion
fi

if [ -f "/data/config/comfy/startup.sh" ]; then
  pushd ${ROOT}
  . /data/config/comfy/startup.sh
  popd
fi

exec "$@"
