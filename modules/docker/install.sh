#!/usr/bin/env bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive
if [[ "${EUID}" -ne 0 ]]; then echo "Run as root: sudo ./modules/docker/install.sh"; exit 1; fi
. /etc/os-release
if command -v docker >/dev/null 2>&1; then
  docker --version
  docker compose version || true
  exit 0
fi
apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://download.docker.com/linux/${ID}/gpg" -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
ARCH="$(dpkg --print-architecture)"
CODENAME="${VERSION_CODENAME:-}"
if [[ -z "${CODENAME}" ]]; then CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME}")"; fi
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${ID} ${CODENAME} stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker
docker --version
docker compose version