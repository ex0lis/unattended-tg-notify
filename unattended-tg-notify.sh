#!/bin/bash
BOT_TOKEN="YOUR TELEGRAM BOT TOKEN"
CHAT_ID="YOUR CHAT/CHANNEL ID"
LOG="/var/log/unattended-upgrades/unattended-upgrades.log"
HOSTNAME="YOUR MACHINE NAME"

if [ ! -f "$LOG" ]; then
    echo "Unattended-upgrades log not found!"
    exit 1
fi

START_LINE=$(grep -n "Starting unattended upgrades script" "$LOG" | tail -n1 | cut -d: -f1)

if [ -z "$START_LINE" ]; then
    RUN_LOG="No unattended-upgrades run found."
else
    RUN_LOG=$(tail -n +$START_LINE "$LOG")
fi

if echo "$RUN_LOG" | grep -q "ERROR"; then
    SUBJECT="❌ ${HOSTNAME} - Upgrade failed"
else
    SUBJECT="✅ ${HOSTNAME} - Upgrade completed"
fi

MESSAGE=$(printf "*%s*\n\`\`\`\n%s\n\`\`\`" "$SUBJECT" "$RUN_LOG")

output=$(curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d parse_mode=Markdown \
    --data-urlencode "text=$MESSAGE" 2>&1)

if [ $? -ne 0 ] || echo "$output" | grep -q '"error_code"'; then
    echo "❌ Failed to send Telegram message:"
    echo "$output"
else
    echo "✅ Telegram message sent successfully."
fi
