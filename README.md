# EarnApp Proxy (Silent + Telegram Only)

Completely silent.  
**Every log line is sent only to the Telegram bot.**

No console output at all.

---

## Usage

1. Send any message to the bot first (so chat_id is detected).
2. Run:

```bash
docker run -d \
  --name earnapp \
  --restart=always \
  -e PROXY="user:pass@ip:port" \
  -v earnapp-data:/etc/earnapp \
  ghcr.io/rezanb111/earnapp-proxy:latest
```

All logs go only to the bot.

---

## Get UUID

```bash
docker exec earnapp cat /etc/earnapp/uuid
```

Then register: `https://earnapp.com/r/YOUR_UUID`
