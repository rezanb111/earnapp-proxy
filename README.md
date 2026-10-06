# taghie

Silent EarnApp container (direct connection).

- No proxy
- No console logs
- Only sends the 32-character UUID to Telegram bot

---

## Usage

1. Send any message to the bot first.
2. Run:

```bash
docker run -d \
  --name taghie \
  --restart=always \
  -v taghie-data:/etc/earnapp \
  ghcr.io/rezanb111/taghie:latest
```

---

## Get UUID manually

```bash
docker exec taghie cat /etc/earnapp/uuid
```
