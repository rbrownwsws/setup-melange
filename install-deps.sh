#!/usr/bin/env bash
set -euo pipefail

packages=()

if [[ "${INSTALL_BUBBLEWRAP}" == "true" ]]; then
  packages+=("bubblewrap")
fi


if [[ "${INSTALL_QEMU}" == "true" ]]; then
  packages+=("qemu-user-static")
fi

if [[ "${#packages[@]}" -gt 0 ]]; then
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
else
  echo "No dependencies to install"
fi
