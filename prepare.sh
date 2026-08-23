#!/usr/bin/env bash
set -euo pipefail

if [[ "${RUNNER_OS}" != "Linux" ]]; then
  echo "::error::Unsupported RUNNER_OS \"${RUNNER_OS}\""
  exit 1
fi

if [[ $(lsb_release --short --id 2>/dev/null) != "Ubuntu" ]]; then
  echo "::error::This action only supports Ubuntu"
  exit 1
fi

case "${RUNNER_ARCH}" in
  X64) MELANGE_ARCH=amd64;;
  ARM64) MELANGE_ARCH=arm64;;

  *)
    echo "::error::Unsupported RUNNER_ARCH \"${RUNNER_ARCH}\""
    exit 1
    ;;
esac

# WARNING: It is important that we are careful with this.
#          Malicious "versions" with newlines etc. may be used to manipulate PATH in dangerous ways.
if [[ ! "${INSTALL_MELANGE_VERSION:-}" =~ ^(v?[0-9]+\.[0-9]+\.[0-9]+)?$ ]]; then
  echo "::error::Invalid melange-version: ${INSTALL_MELANGE_VERSION}"
  exit 1
fi

if [[ -n "${INSTALL_MELANGE_VERSION:-}" ]]; then
  # Normalise version
  MELANGE_VERSION="${INSTALL_MELANGE_VERSION#v}"
else
  # Use default melange version for this version of the action
  MELANGE_VERSION=$(cat "${GITHUB_ACTION_PATH}/melange-version")
fi

MELANGE_TAG="v${MELANGE_VERSION}"

TOOL_HOME="${RUNNER_TOOL_CACHE}/melange"
TOOL_DIR="${TOOL_HOME}/${MELANGE_VERSION}/${MELANGE_ARCH}"
TOOL_SENTINEL="${TOOL_DIR}.complete"

skip_install="false"
if [[ -f "${TOOL_SENTINEL}" ]]; then
  skip_install="true"
fi

echo "melange-arch=${MELANGE_ARCH}" >> "${GITHUB_OUTPUT}"
echo "melange-version=${MELANGE_VERSION}" >> "${GITHUB_OUTPUT}"
echo "melange-tag=${MELANGE_TAG}" >> "${GITHUB_OUTPUT}"

echo "tool-home=${TOOL_HOME}" >> "${GITHUB_OUTPUT}"
echo "tool-dir=${TOOL_DIR}" >> "${GITHUB_OUTPUT}"
echo "tool-sentinel=${TOOL_SENTINEL}" >> "${GITHUB_OUTPUT}"

echo "skip-install=${skip_install}" >> "${GITHUB_OUTPUT}"
