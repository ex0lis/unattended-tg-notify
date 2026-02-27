#!/bin/bash
set -e

SERVICE_UNIT="/etc/systemd/system/unattended-telegram.service"
PATH_UNIT="/etc/systemd/system/unattended-telegram.path"

if [ "$(id -u)" -ne 0 ]; then
    echo "This setup script must be run as root!"
    exit 1
fi

read -rp "Enter the full directory path where the script should be installed (e.g. /usr/local/bin/): " USER_PATH
USER_PATH="${USER_PATH%/}"
mkdir -p "$USER_PATH"

if [ -d "$USER_PATH" ]; then
    SCRIPT_PATH="$USER_PATH/unattended-tg-notify.sh"
fi

REPO_URL="https://raw.githubusercontent.com/ex0lis/unattended-tg-notify/refs/heads/main/unattended-tg-notify.sh"

echo "Downloading unattended-tg-notify.sh from repo..."

curl -fsSL "$REPO_URL" -o "$SCRIPT_PATH"

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Error: Failed to download the script."
    exit 1
fi

chmod 700 "$SCRIPT_PATH"
echo "Script installed at $SCRIPT_PATH."

read -rp "Enter your Telegram BOT_TOKEN: " BOT_TOKEN
read -rp "Enter your Telegram CHAT_ID: " CHAT_ID
read -rp "Enter a HOSTNAME label for this server: " HOSTNAME

# Inject variables into script
sed -i "s|^BOT_TOKEN=.*|BOT_TOKEN=\"$BOT_TOKEN\"|" "$SCRIPT_PATH"
sed -i "s|^CHAT_ID=.*|CHAT_ID=\"$CHAT_ID\"|" "$SCRIPT_PATH"
sed -i "s|^HOSTNAME=.*|HOSTNAME=\"$HOSTNAME\"|" "$SCRIPT_PATH"

cat > "$PATH_UNIT" <<EOF
[Unit]
Description=Watch unattended-upgrades completion stamp

[Path]
PathModified=/var/lib/apt/periodic/unattended-upgrades-stamp

[Install]
WantedBy=multi-user.target
EOF

echo "Path unit created at $PATH_UNIT"

cat > "$SERVICE_UNIT" <<EOF
[Unit]
Description=Send Telegram notifications for unattended-upgrades

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH
EOF

echo "Service unit created at $SERVICE_UNIT"

systemctl daemon-reload
systemctl enable unattended-telegram.path
systemctl start unattended-telegram.path

systemctl status unattended-telegram.path --no-pager
#systemctl status unattended-telegram.service --no-pager

echo
echo "Setup complete! To test, run:"
echo "sudo unattended-upgrades --dry-run -v"
