#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image_name="cliap2-build:linux-amd64"
container_id=""

cleanup() {
  if [[ -n "${container_id}" ]]; then
    docker rm -f "${container_id}" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

cd "${repo_root}"
mkdir -p dist

docker build \
  --platform linux/amd64 \
  --build-arg TARGETARCH=amd64 \
  --target cliap2-builder \
  -t "${image_name}" \
  .

container_id="$(docker create "${image_name}")"
docker cp "${container_id}:/release/cliap2-amd64" "dist/cliap2-linux-amd64"
chmod +x "dist/cliap2-linux-amd64"

file "dist/cliap2-linux-amd64"
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "dist/cliap2-linux-amd64"
else
  shasum -a 256 "dist/cliap2-linux-amd64"
fi
