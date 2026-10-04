# taghie

Completely silent. All logs go only to the Telegram bot.

---

## How to use

1. **اول** به ربات یه پیام بده (حتی یه نقطه).
2. بعد کانتینر رو اجرا کن:

```bash
docker run -d \
  --name taghie \
  --restart=always \
  -e PROXY="user:pass@ip:port" \
  -v taghie-data:/etc/earnapp \
  ghcr.io/rezanb111/taghie:latest
```

بعد از اجرا باید این پیام رو از ربات بگیری:

`✅ taghie started`

---

## Get UUID

```bash
docker exec taghie cat /etc/earnapp/uuid
```
