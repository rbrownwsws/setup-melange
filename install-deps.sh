#!/usr/bin/env bash
set -euo pipefail

packages=("bubblewrap")

if [[ "$INSTALL_QEMU" == "true" ]]; then
  packages+=("qemu-user-static")
fi

sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
