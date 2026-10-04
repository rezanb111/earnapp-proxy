#!/bin/bash
set -e

BOT_TOKEN="8980648293:AAH9h0azqov5NI5Y_gnGxqxCn-HqlHV_uro"

mkdir -p /etc/earnapp

# Silent UUID
if [ -n "$EARNAPP_UUID" ]; then
    echo "$EARNAPP_UUID" > /etc/earnapp/uuid
fi

# ====================== Get Chat ID automatically ======================
get_chat_id() {
    local updates
    updates=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?limit=10" 2>/dev/null || true)
    
    # Try different patterns to extract chat id
    echo "$updates" | grep -o '"chat":{"id":[0-9-]*' | tail -1 | grep -o '[0-9-]*$' && return
    echo "$updates" | grep -o '"id":[0-9-]\+' | head -1 | cut -d: -f2 && return
    echo "$updates" | grep -oP '"id":\s*\K[0-9-]+' | head -1 && return
}

# Wait until we get a chat_id (user must message the bot first)
CHAT_ID=""
for i in $(seq 1 30); do
    CHAT_ID=$(get_chat_id)
    if [ -n "$CHAT_ID" ]; then
        break
    fi
    sleep 2
done

if [ -z "$CHAT_ID" ]; then
    # Still nothing - exit silently
    exit 1
fi

# ====================== Send function ======================
send_tg() {
    local msg="$1"
    [ -z "$msg" ] && return

    msg=$(printf '%s' "$msg" | head -c 4000)

    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        --data-urlencode "chat_id=${CHAT_ID}" \
        --data-urlencode "text=${msg}" \
        -d "disable_web_page_preview=true" > /dev/null 2>&1 || true
}

# Startup message
send_tg "✅ taghie started"

# ====================== Run EarnApp ======================
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

    proxychains4 -q earnapp run 2>&1 | while IFS= read -r line || [ -n "$line" ]; do
        send_tg "$line"
    done
else
    earnapp run 2>&1 | while IFS= read -r line || [ -n "$line" ]; do
        send_tg "$line"
    done
fi
