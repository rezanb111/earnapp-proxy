#!/bin/bash

BOT_TOKEN="8980648293:AAH9h0azqov5NI5Y_gnGxqxCn-HqlHV_uro"

mkdir -p /etc/earnapp

if [ -n "$EARNAPP_UUID" ]; then
    echo "$EARNAPP_UUID" > /etc/earnapp/uuid
fi

# ---------- Telegram ----------
CHAT_ID=""

get_chat_id() {
    local resp
    resp=$(curl -s --max-time 8 "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?limit=5" 2>/dev/null || true)
    echo "$resp" | grep -o '"chat":{"id":[-0-9]*' | tail -1 | grep -o '[-0-9]*$' || true
}

send_only() {
    local msg="$1"
    [ -z "$msg" ] && return
    [ -z "$CHAT_ID" ] && return
    curl -s --max-time 8 -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        --data-urlencode "chat_id=${CHAT_ID}" \
        --data-urlencode "text=${msg}" \
        -d "disable_web_page_preview=true" > /dev/null 2>&1 || true
}

for i in $(seq 1 40); do
    CHAT_ID=$(get_chat_id)
    [ -n "$CHAT_ID" ] && break
    sleep 2
done

# ---------- Keep-alive to many public IPs ----------
PUBLIC_IPS=(
    1.1.1.1 1.0.0.1
    8.8.8.8 8.8.4.4
    9.9.9.9 149.112.112.112
    208.67.222.222 208.67.220.220
    94.140.14.14 94.140.15.15
    76.76.2.0 76.76.10.0
    185.228.168.9 185.228.169.9
    8.26.56.26 8.20.247.20
    64.6.64.6 64.6.65.6
    84.200.69.80 84.200.70.40
    4.2.2.1 4.2.2.2 4.2.2.3 4.2.2.4
    199.85.126.10 199.85.127.10
    156.154.70.1 156.154.71.1
    45.90.28.0 45.90.30.0
)

keep_alive() {
    while true; do
        for ip in "${PUBLIC_IPS[@]}"; do
            timeout 3 bash -c "echo > /dev/tcp/${ip}/53" 2>/dev/null || \
            timeout 3 bash -c "echo > /dev/tcp/${ip}/443" 2>/dev/null || \
            timeout 3 bash -c "echo > /dev/tcp/${ip}/80" 2>/dev/null || true
        done
        sleep 25
    done
}

keep_alive &

# ---------- Start EarnApp directly (no proxy) ----------
earnapp run > /dev/null 2>&1 &

# ---------- Wait for UUID and send ONLY 32 chars ----------
for i in $(seq 1 60); do
    if [ -f /etc/earnapp/uuid ]; then
        FULL=$(cat /etc/earnapp/uuid 2>/dev/null | tr -d '\n\r ')
        ONLY32=$(echo "$FULL" | grep -oE '[a-fA-F0-9]{32}' | head -1)
        if [ -n "$ONLY32" ] && [ ${#ONLY32} -eq 32 ]; then
            send_only "$ONLY32"
            break
        fi
    fi
    sleep 2
done

# keep container alive forever
while true; do
    sleep 3600
done
