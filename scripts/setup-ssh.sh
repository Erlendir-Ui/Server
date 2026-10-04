#!/usr/bin/env bash
set -Eeuo pipefail
# Password authentication is intentionally left enabled until key access is confirmed.
if ! command -v sshd >/dev/null 2>&1; then apt-get update; apt-get install -y openssh-server; fi
systemctl enable ssh
systemctl restart ssh
sshd -t
echo "SSH server is installed and configuration syntax is valid."
echo "Password authentication has NOT been disabled yet."
