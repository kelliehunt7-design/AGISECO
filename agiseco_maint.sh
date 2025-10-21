#!/bin/bash

# -----------------------------
# AGISECO Auto-Update & Repair
# -----------------------------

REPO_DIR="/home/akay/AGISECO_REPO"
BINARY="$REPO_DIR/agiseco"
SERVICE="agiseco"

# Logging
LOGFILE="$REPO_DIR/agiseco_maint.log"
echo "[$(date)] Maintenance script started" >> $LOGFILE

cd $REPO_DIR || { echo "[$(date)] ERROR: Cannot access repo"; exit 1; }

# 1️⃣ Pull latest changes
if [ -d ".git" ]; then
    git fetch --all >> $LOGFILE 2>&1
    git reset --hard origin/main >> $LOGFILE 2>&1
    echo "[$(date)] Repo updated" >> $LOGFILE
fi

# 2️⃣ Rebuild binary
if command -v go >/dev/null 2>&1; then
    go mod tidy >> $LOGFILE 2>&1
    go build -o agiseco >> $LOGFILE 2>&1
    if [ $? -eq 0 ]; then
        echo "[$(date)] Build successful" >> $LOGFILE
    else
        echo "[$(date)] Build FAILED" >> $LOGFILE
        exit 1
    fi
else
    echo "[$(date)] Go not found, cannot build" >> $LOGFILE
    exit 1
fi

# 3️⃣ Restart systemd service
sudo systemctl daemon-reload >> $LOGFILE 2>&1
sudo systemctl restart $SERVICE >> $LOGFILE 2>&1
if systemctl is-active --quiet $SERVICE; then
    echo "[$(date)] Service restarted successfully" >> $LOGFILE
else
    echo "[$(date)] Service FAILED to start" >> $LOGFILE
fi

