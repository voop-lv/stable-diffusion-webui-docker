#!/bin/bash

declare -A MOUNTS
ROOT_PAHT="/fooocus-ai"

mkdir /data/models/model_configs > /dev/null 2>&1
mkdir /data/models/prompt_expansion > /dev/null 2>&1
mkdir /data/models/clip_vision > /dev/null 2>&1
mkdir /output/fooocus > /dev/null 2>&1

if [ -z "$(ls -A /data/models/prompt_expansion)" ]; then
    cp -r -f -v /cleanConfig/prompt_expansion/* /data/models/prompt_expansion
fi

if [ -z "$(ls -A /data/models/model_configs)" ]; then
    cp -r -f -v /cleanConfig/model_configs/* /data/models/model_configs
fi

MOUNTS["${ROOT}/outputs"]="/output/fooocus"

MOUNTS["${ROOT}/models/checkpoints"]="/data/models/Stable-diffusion"
MOUNTS["${ROOT}/models/controlnet"]="/data/models/ControlNet"
MOUNTS["${ROOT}/models/loras"]="/data/models/Lora"
MOUNTS["${ROOT}/models/gligen"]="/data/models/GLIGEN"
MOUNTS["${ROOT}/models/embeddings"]="/data/models/embeddings"
MOUNTS["${ROOT}/models/vae"]="/data/models/VAE"
MOUNTS["${ROOT}/models/vae_approx"]="/data/models/VAE-approx"
MOUNTS["${ROOT}/models/clip_vision"]="/data/models/clip_vision"
MOUNTS["${ROOT}/models/hypernetworks"]="/data/models/hypernetworks"
MOUNTS["${ROOT}/models/upscale_models"]="/data/models/upscale_models"
MOUNTS["${ROOT}/models/configs"]="/data/models/model_configs"
MOUNTS["${ROOT}/models/prompt_expansion"]="/data/models/prompt_expansion"

for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  mkdir -p "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done