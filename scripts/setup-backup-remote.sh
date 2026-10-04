#!/usr/bin/env bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y restic rclone

install -d -m 0700 /etc/server-backup
install -d -m 0755 /usr/local/lib

cat > /etc/server-backup/remote.env.example <<'EOF'
RESTIC_REPOSITORY="rclone:gdrive:ServerBackup"
RESTIC_PASSWORD_FILE="/etc/server-backup/restic-password"
RCLONE_CONFIG="/etc/server-backup/rclone.conf"
RESTIC_KEEP_DAILY=30
EOF
chmod 0600 /etc/server-backup/remote.env.example

cat > /usr/local/lib/server-backup-remote.sh <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
ENV_FILE="/etc/server-backup/remote.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Remote backup is not configured yet."
  echo "Create $ENV_FILE from remote.env.example first."
  exit 2
fi

source "$ENV_FILE"

: "\${RESTIC_REPOSITORY:?RESTIC_REPOSITORY is required}"
: "\${RESTIC_PASSWORD_FILE:?RESTIC_PASSWORD_FILE is required}"
: "\${RCLONE_CONFIG:?RCLONE_CONFIG is required}"

if [[ ! -f "$RESTIC_PASSWORD_FILE" ]]; then
  echo "Missing restic password file: $RESTIC_PASSWORD_FILE"
  exit 2
fi

if [[ ! -f "$RCLONE_CONFIG" ]]; then
  echo "Missing rclone config: $RCLONE_CONFIG"
  exit 2
fi

if ! rclone --config "$RCLONE_CONFIG" lsd gdrive: >/dev/null; then
  echo "Google Drive connection failed."
  exit 1
fi

restic -r "$RESTIC_REPOSITORY" --password-file "$RESTIC_PASSWORD_FILE" \
  backup /etc/ssh /etc/fail2ban /etc/ufw /etc/docker /etc/systemd/system \
  /usr/local/lib/server-monitoring /usr/local/lib/server-backup.sh \
  /usr/local/lib/server-backup-remote.sh

restic -r "$RESTIC_REPOSITORY" --password-file "$RESTIC_PASSWORD_FILE" \
  forget --keep-daily "\${RESTIC_KEEP_DAILY:-30}" --prune

restic -r "$RESTIC_REPOSITORY" --password-file "$RESTIC_PASSWORD_FILE" check
EOF
chmod 0755 /usr/local/lib/server-backup-remote.sh

cat > /etc/systemd/system/server-backup-remote.service <<'EOF'
[Unit]
Description=Encrypted off-site server backup to Google Drive
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/lib/server-backup-remote.sh
EOF

cat > /etc/systemd/system/server-backup-remote.timer <<'EOF'
[Unit]
Description=Daily encrypted off-site server backup

[Timer]
OnCalendar=*-*-* 04:00:00 UTC
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload

echo "Remote backup tools installed."
echo "Configure Google Drive and the restic repository before enabling the timer."
