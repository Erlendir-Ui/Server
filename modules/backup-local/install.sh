#!/usr/bin/env bash
set -Eeuo pipefail
if [[ "${EUID}" -ne 0 ]]; then echo "Run as root: sudo ./modules/backup-local/install.sh"; exit 1; fi
BACKUP_ROOT="/var/backups/server"
install -d -m 0700 "${BACKUP_ROOT}"
cat > /usr/local/lib/server-backup.sh <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
BACKUP_ROOT="/var/backups/server"
RETENTION_COUNT="${BACKUP_RETENTION_COUNT:-3}"
STAMP="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
TARGET="${BACKUP_ROOT}/${STAMP}"
install -d -m 0700 "${TARGET}"
tar --ignore-failed-read -czf "${TARGET}/etc-config.tar.gz" /etc/ssh /etc/fail2ban /etc/ufw /etc/systemd/system /usr/local/lib/server-monitoring /usr/local/lib/server-backup.sh
dpkg-query -W -f='${Package}\t${Version}\n' > "${TARGET}/packages.tsv"
chmod 0600 "${TARGET}"/*
find "${BACKUP_ROOT}" -mindepth 1 -maxdepth 1 -type d -printf "%T@ %p\n" | sort -nr | tail -n +$((RETENTION_COUNT + 1)) | cut -d" " -f2- | xargs -r rm -rf --
echo "Backup created: ${TARGET}"
EOF
chmod 0755 /usr/local/lib/server-backup.sh
cat > /etc/systemd/system/server-backup.service <<'EOF'
[Unit]
Description=Local server configuration backup
[Service]
Type=oneshot
ExecStart=/usr/local/lib/server-backup.sh
EOF
cat > /etc/systemd/system/server-backup.timer <<'EOF'
[Unit]
Description=Run local server backup daily
[Timer]
OnCalendar=*-*-* 03:30:00 UTC
Persistent=true
[Install]
WantedBy=timers.target
EOF
systemctl daemon-reload
systemctl enable --now server-backup.timer
echo "Local backup module installed."