#!/bin/bash

# -----------------------------
# AGISECO Self-Healing Script
# -----------------------------

REPO_DIR="/home/akay/AGISECO_REPO"
BINARY="$REPO_DIR/agiseco"
SERVICE="agiseco"
LOGFILE="$REPO_DIR/agiseco_selfheal.log"

echo "[$(date)] Self-healing script started" >> $LOGFILE

cd $REPO_DIR || { echo "[$(date)] ERROR: Cannot access repo"; exit 1; }

# Telegram notifier function
notify() {
    local msg="$1"
    echo "[$(date)] $msg" >> $LOGFILE
    if [ ! -z "$AGISECO_TELEGRAM_TOKEN" ] && [ ! -z "$AGISECO_CHAT_ID" ]; then
        curl -s -X POST "https://api.telegram.org/bot$AGISECO_TELEGRAM_TOKEN/sendMessage" \
            -d chat_id="$AGISECO_CHAT_ID" \
            -d text="$msg" >/dev/null 2>&1
    fi
}

# 1️⃣ Check for missing binary
if [ ! -f "$BINARY" ]; then
    notify "⚠️ AGISECO binary missing! Rebuilding..."
    go mod tidy >> $LOGFILE 2>&1
    go build -o agiseco >> $LOGFILE 2>&1
    if [ $? -eq 0 ]; then
        notify "✅ AGISECO rebuilt successfully."
    else
        notify "❌ AGISECO rebuild FAILED!"
        exit 1
    fi
fi

# 2️⃣ Check for missing or corrupted modules
for mod in modules/*; do
    if [ ! -f "$mod/$mod.go" ] && [[ $(basename $mod) != "experimental" ]]; then
        notify "⚠️ Module $(basename $mod) missing. Resetting..."
        mkdir -p "$mod"
        cat <<EOL > "$mod/$(basename $mod).go"
package $(basename $mod)
import "fmt"
func Init() { fmt.Println("✅ Module loaded: $(basename $mod)") }
EOL
        notify "✅ Module $(basename $mod) reset."
    fi
done

# 3️⃣ Pull latest code
if [ -d ".git" ]; then
    git fetch --all >> $LOGFILE 2>&1
    git reset --hard origin/main >> $LOGFILE 2>&1
    notify "📥 Repo synced with remote."
fi

# 4️⃣ Build binary
go build -o agiseco >> $LOGFILE 2>&1
if [ $? -eq 0 ]; then
    notify "✅ Binary build successful."
else
    notify "❌ Binary build FAILED!"
    exit 1
fi

# 5️⃣ Restart systemd service
sudo systemctl daemon-reload >> $LOGFILE 2>&1
sudo systemctl restart $SERVICE >> $LOGFILE 2>&1
if systemctl is-active --quiet $SERVICE; then
    notify "⚡ AGISECO restarted successfully."
else
    notify "❌ AGISECO service FAILED to start!"
fi
