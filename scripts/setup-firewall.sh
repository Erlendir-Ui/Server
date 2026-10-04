#!/usr/bin/env bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y ufw
SSH_PORT="$(sshd -T 2>/dev/null | awk '$1 == "port" {print $2; exit}')"
SSH_PORT="\${SSH_PORT:-22}"
ufw default deny incoming
ufw default allow outgoing
ufw allow "\${SSH_PORT}/tcp" comment 'SSH'
ufw --force enable
ufw status verbose
echo "Firewall enabled; SSH TCP/\${SSH_PORT} is allowed."
