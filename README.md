# unattended-tg-notify
Sends notifications and the latest unattended-upgrades run log directly to a Telegram chat or channel.

Setup is done via one-liner:

```
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/ex0lis/unattended-tg-notify/refs/heads/main/setup-unattended-tg-notify.sh)"
```

The script automates the setup of Telegram notifications for unattended-upgrades: every time unattended-upgrades runs, the system sends a message to your Telegram chat with the latest log of the unattended-upgrade.

**Step-by-Step Breakdown**

1) Asks where to install the main notification script (unattended-tg-notify.sh).
2) Fetches unattended-tg-notify.sh from this GitHub repository.
3) Asks for BOT_TOKEN, CHAT_ID, and machine HOSTNAME.
4) Creates systemd service unit (.service)
This service is triggered by a .path unit.
5) Creates systemd path unit (.path)\
Watches the file /var/lib/apt/periodic/unattended-upgrades-stamp, which unattended-upgrades touches after every run.\
When the file changes, systemd automatically triggers the .service.
7) Runs systemctl daemon-reload, enables and starts the path unit so it begins monitoring immediately.
8) Shows status of the .path and .service units.
9) Prints a message to the user explaining how to test the setup with:\ sudo unattended-upgrades --dry-run -v
