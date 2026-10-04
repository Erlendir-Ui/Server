#!/usr/bin/env bash
set -Eeuo pipefail

install -d -m 0755 /usr/local/lib/server-monitoring

cat > /usr/local/lib/server-monitoring/healthcheck.sh <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

failed=0

check_service() {
  local service="$1"
  if systemctl is-active --quiet "$service"; then
    echo "OK   $service"
  else
    echo "FAIL $service"
    failed=1
  fi
}

check_service ssh
check_service fail2ban

if ufw status | grep -q "Status: active"; then
  echo "OK   ufw"
else
  echo "FAIL ufw"
  failed=1
fi

if df -P / | awk 'NR==2 {gsub("%","",$5); exit ($5 < 90)}'; then
  echo "OK   disk usage < 90%"
else
  echo "FAIL disk usage >= 90%"
  failed=1
fi

if swapon --show --noheadings | grep -q .; then
  echo "OK   swap"
else
  echo "WARN no active swap"
fi

exit "$failed"
EOF

chmod 0755 /usr/local/lib/server-monitoring/healthcheck.sh

cat > /etc/systemd/system/server-healthcheck.service <<'EOF'
[Unit]
Description=Server infrastructure health check
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/lib/server-monitoring/healthcheck.sh
EOF

cat > /etc/systemd/system/server-healthcheck.timer <<'EOF'
[Unit]
Description=Run server health check periodically

[Timer]
OnBootSec=5min
OnUnitActiveSec=15min
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now server-healthcheck.timer

echo "Lightweight monitoring foundation installed."
