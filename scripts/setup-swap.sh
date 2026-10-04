#!/usr/bin/env bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive
SWAPFILE="/swapfile"
TARGET_MB=1024
existing_mb="$(awk '/^SwapTotal:/ {printf "%d\\n", $2 / 1024}' /proc/meminfo 2>/dev/null || echo 0)"
if (( existing_mb >= 512 )); then
  echo "Swap is already available: ${existing_mb} MiB."
  swapon --show || true
  exit 0
fi
if [[ -f "${SWAPFILE}" ]]; then
  echo "Swapfile ${SWAPFILE} already exists but is not active."
else
  echo "Creating ${TARGET_MB} MiB swapfile..."
  fallocate -l "${TARGET_MB}M" "${SWAPFILE}" 2>/dev/null || dd if=/dev/zero of="${SWAPFILE}" bs=1M count="${TARGET_MB}" status=progress
  chmod 600 "${SWAPFILE}"
  mkswap "${SWAPFILE}"
fi
swapon "${SWAPFILE}" 2>/dev/null || true
grep -qE "^[[:space:]]*/swapfile[[:space:]]+none[[:space:]]+swap[[:space:]]" /etc/fstab || echo "${SWAPFILE} none swap sw 0 0" >> /etc/fstab
swapon --show
echo "Swap configuration completed."