#!/usr/bin/env bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive
. /etc/os-release
if [[ "${ID}" != "ubuntu" && "${ID}" != "debian" ]]; then echo "Unsupported OS: ${PRETTY_NAME:-${ID}}"; exit 1; fi
apt-get update
apt-get upgrade -y
apt-get install -y ca-certificates curl git gnupg jq openssl rsync sudo unzip vim wget
apt-get install -y unattended-upgrades
dpkg-reconfigure -f noninteractive unattended-upgrades || true
echo "System packages are ready."
