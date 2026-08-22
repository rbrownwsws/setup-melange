#!/usr/bin/env bash
set -euo pipefail

MELANGE_REPO="github.com/chainguard-dev/melange"

archive_name="melange_${MELANGE_VERSION}_linux_${MELANGE_ARCH}.tar.gz"

dl_dir=$(mktemp -d --tmpdir="${RUNNER_TEMP}")
archive_path="${dl_dir}/${archive_name}"

echo "Downloading melange ${MELANGE_VERSION}"
gh release download --repo "${MELANGE_REPO}" "${MELANGE_TAG}" --pattern "${archive_name}*" --dir "${dl_dir}"

for file in "${archive_path}"*; do
  echo "Verifying Release Asset: ${archive_name}"
  gh release verify-asset --repo "${MELANGE_REPO}" "${MELANGE_TAG}" "${file}"
done

sigstore_sig="${archive_path}.sig"
sigstore_crt="${archive_path}.crt"
sigstore_bundle="${archive_path}.sigstore.json"

cosign_args=()
cosign_args+=(--certificate-oidc-issuer "https://token.actions.githubusercontent.com")
cosign_args+=(--certificate-identity "https://github.com/chainguard-dev/melange/.github/workflows/release.yaml@refs/heads/main")

if [[ -f "${sigstore_bundle}" ]]; then
  cosign_args+=(--bundle "${sigstore_bundle}")
elif [[ -f "${sigstore_sig}" && -f "${sigstore_crt}" ]]; then
  cosign_args+=(--signature "${sigstore_sig}")
  cosign_args+=(--certificate "${sigstore_crt}")
else
  echo "::error::Could not find sigstore signatures!"
  exit 1
fi

echo "Verifying Cosign Signature"
cosign verify-blob \
  "${cosign_args[@]}" \
  "${archive_path}"

echo "Installing melange ${MELANGE_VERSION}"
mkdir -p "${TOOL_DIR}"
tar xf "${archive_path}" --strip-components=1 -C "${TOOL_DIR}"
chmod +x "${TOOL_DIR}/melange"
touch "${TOOL_SENTINEL}"
