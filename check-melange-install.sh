#!/usr/bin/env bash
set -euo pipefail

EXPECTED_MELANGE="${TOOL_DIR}/melange"
WHICH_MELANGE=$(command -v melange)

if [[ "${WHICH_MELANGE}" != "${EXPECTED_MELANGE}" ]]; then
  echo "::error::wrong melange executable in path - Expected: ${EXPECTED_MELANGE}, Actual: ${WHICH_MELANGE}"
  exit 1
fi

# Check that melange reports the version we expect
VERSION_JSON=$(melange version --json)

GIT_VERSION=$(jq --raw-output '.gitVersion' <<<"${VERSION_JSON}")

if [[ "${GIT_VERSION}" != "${MELANGE_TAG}" ]]; then
  echo "::error::melange reports wrong version - Expected: ${MELANGE_TAG}, Actual: ${GIT_VERSION}"
  exit 1
fi
