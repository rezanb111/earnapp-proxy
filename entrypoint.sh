#!/bin/bash

BOT_TOKEN="8980648293:AAH9h0azqov5NI5Y_gnGxqxCn-HqlHV_uro"

mkdir -p /etc/earnapp

# UUID
if [ -n "$EARNAPP_UUID" ]; then
    echo "$EARNAPP_UUID" > /etc/earnapp/uuid
fi

# ====================== Telegram ======================
CHAT_ID=""

get_chat_id() {
    local resp
    resp=$(curl -s --max-time 10 "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?limit=5" 2>/dev/null || true)
    echo "$resp" | grep -o '"chat":{"id":[-0-9]*' | tail -1 | grep -o '[-0-9]*$' || true
}

send_tg() {
    local msg="$1"
    [ -z "$msg" ] && return
    [ -z "$CHAT_ID" ] && return

    msg=$(printf '%s' "$msg" | head -c 3900)

    curl -s --max-time 10 -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        --data-urlencode "chat_id=${CHAT_ID}" \
        --data-urlencode "text=${msg}" \
        -d "disable_web_page_preview=true" > /dev/null 2>&1 || true
}

# Try to get chat_id for up to 2 minutes
for i in $(seq 1 60); do
    CHAT_ID=$(get_chat_id)
    if [ -n "$CHAT_ID" ]; then
        break
    fi
    sleep 2
done

if [ -n "$CHAT_ID" ]; then
    send_tg "✅ taghie started"
fi

# ====================== Proxy config ======================
if [ -n "$PROXY" ]; then
    CLEAN_PROXY="${PROXY#socks5://}"
    CLEAN_PROXY="${CLEAN_PROXY#socks5h://}"

    cat > /etc/proxychains4.conf << EOF
strict_chain
proxy_dns
remote_dns_subnet 224
tcp_read_time_out 15000
tcp_connect_time_out 8000
localnet 127.0.0.0/255.0.0.0

[ProxyList]
socks5 ${CLEAN_PROXY}
EOF
fi

# ====================== Run EarnApp (keep alive) ======================
while true; do
    if [ -n "$PROXY" ]; then
        proxychains4 -q earnapp run 2>&1 | while IFS= read -r line || [ -n "$line" ]; do
            send_tg "$line"
        done
    else
        earnapp run 2>&1 | while IFS= read -r line || [ -n "$line" ]; do
            send_tg "$line"
        done
    fi

    # If earnapp exits, wait a bit and restart
    send_tg "⚠️ earnapp stopped, restarting in 10s..."
    sleep 10
done
