#!/bin/bash

set -Eeuo pipefail

declare -A MOUNTS

ROOT=/stable-diffusion/src

# cache
MOUNTS["/root/.cache"]=/data/.sygil_cache
# ui specific
MOUNTS["${PWD}/models/realesrgan"]=/data/models/RealESRGAN
MOUNTS["${PWD}/models/ldsr"]=/data/models/LDSR
MOUNTS["${PWD}/models/custom"]=/data/models/Stable-diffusion

# hack
MOUNTS["${PWD}/models/gfpgan/GFPGANv1.3.pth"]=/data/models/GFPGAN/GFPGANv1.4.pth
MOUNTS["${PWD}/models/gfpgan/GFPGANv1.4.pth"]=/data/models/GFPGAN/GFPGANv1.4.pth
MOUNTS["${PWD}/gfpgan/weights"]=/data/.sygil_cache


for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  mkdir -p "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done

# streamlit config
ln -sf /docker/userconfig_streamlit.yaml /stable-diffusion/configs/webui/userconfig_streamlit.yaml