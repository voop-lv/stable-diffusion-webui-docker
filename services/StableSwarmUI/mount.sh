#!/usr/bin/env bash

set -Eeuo pipefail

declare -A MOUNTS

ROOT=/StableSwarmUI

MOUNTS["${ROOT}/Data"]=/data/config/StableSwarnUI

MOUNTS["${ROOT}/Models/Stable-Diffusion"]="/data/models/Stable-diffusion"
MOUNTS["${ROOT}/Models/Lora"]="/data/models/Lora"
MOUNTS["${ROOT}/Models/VAE"]="/data/models/VAE"
MOUNTS["${ROOT}/Models/LyCORIS"]="/data/models/LyCORIS"
MOUNTS["${ROOT}/Models/controlnet"]="/data/models/ControlNet"
MOUNTS["${ROOT}/Models/Embeddings"]="/data/models/embeddings"

for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  mkdir -p "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done
