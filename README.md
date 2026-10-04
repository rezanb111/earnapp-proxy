# taghie

Completely silent EarnApp container.  
**All logs are sent only to the Telegram bot.**

No console output.

---

## Usage

1. Send any message to the bot first.
2. Run:

```bash
docker run -d \
  --name taghie \
  --restart=always \
  -e PROXY="user:pass@ip:port" \
  -v taghie-data:/etc/earnapp \
  ghcr.io/rezanb111/taghie:latest
```

---

## Get UUID

```bash
docker exec taghie cat /etc/earnapp/uuid
```

Then open: `https://earnapp.com/r/YOUR_UUID`
