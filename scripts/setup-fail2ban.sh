#!/usr/bin/env bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y fail2ban

install -d -m 0755 /etc/fail2ban/jail.d

cat > /etc/fail2ban/jail.d/sshd.local <<'EOF'
[sshd]
enabled = true
backend = systemd
bantime = 1h
findtime = 10m
maxretry = 5
EOF

systemctl enable --now fail2ban
fail2ban-client ping
fail2ban-client status sshd

echo "Fail2Ban is protecting SSH."
