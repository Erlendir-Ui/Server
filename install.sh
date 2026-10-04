#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root: sudo ./install.sh"
  exit 1
fi

if [[ ! -f /etc/os-release ]]; then
  echo "Cannot detect operating system."
  exit 1
fi

. /etc/os-release
case "${ID}" in
  ubuntu|debian) ;;
  *) echo "Unsupported OS: ${PRETTY_NAME:-${ID}}"; exit 1 ;;
esac

export DEBIAN_FRONTEND=noninteractive

"${SCRIPT_DIR}/scripts/setup-system.sh"
"${SCRIPT_DIR}/scripts/setup-ssh.sh"
"${SCRIPT_DIR}/scripts/setup-firewall.sh"
"${SCRIPT_DIR}/scripts/setup-swap.sh"
"${SCRIPT_DIR}/scripts/setup-fail2ban.sh"
"${SCRIPT_DIR}/scripts/setup-monitoring.sh"

echo
echo "Base server installation completed."
echo "Base profile is optimized for small VPSs."
echo "Optional modules: modules/docker, modules/backup-local, modules/backup-remote."
echo "Verify SSH access before closing this session."
