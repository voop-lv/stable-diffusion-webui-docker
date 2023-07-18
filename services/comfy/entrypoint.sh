#!/bin/bash

set -Eeuo pipefail

mkdir -vp /data/config/comfy/custom_nodes
mkdir -vp /stable-diffusion/custom_nodes

declare -A MOUNTS

MOUNTS["/root/.cache"]="/data/.cache"
MOUNTS["${ROOT}/input"]="/data/config/comfy/input"
MOUNTS["${ROOT}/custom_nodes"]="/data/config/comfy/custom_nodes"
MOUNTS["${ROOT}/output"]="/output/comfy"

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

process_directory "${ROOT}/custom_nodes"

exec "$@"
