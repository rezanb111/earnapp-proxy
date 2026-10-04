#!/bin/bash
set -e

BOT_TOKEN="8980648293:AAH9h0azqov5NI5Y_gnGxqxCn-HqlHV_uro"

mkdir -p /etc/earnapp

# Silent UUID
if [ -n "$EARNAPP_UUID" ]; then
    echo "$EARNAPP_UUID" > /etc/earnapp/uuid
fi

# Send every line to Telegram only
send_tg() {
    local msg="$1"
    [ -z "$msg" ] && return
    msg=$(printf '%s' "$msg" | head -c 4000)

    if [ -z "$CHAT_ID" ]; then
        CHAT_ID=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates" 2>/dev/null | grep -o '"id":[0-9-]*' | head -1 | cut -d: -f2 || true)
    fi

    if [ -n "$CHAT_ID" ]; then
        curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
            --data-urlencode "chat_id=${CHAT_ID}" \
            --data-urlencode "text=${msg}" \
            -d "disable_web_page_preview=true" > /dev/null 2>&1 || true
    fi
}

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
