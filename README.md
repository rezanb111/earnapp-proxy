# taghie

Completely silent EarnApp.  
All logs go **only** to Telegram bot.

---

## How to run (Important)

You **must** give your Telegram Chat ID.

### 1. Get your Chat ID

- Open Telegram and search for `@userinfobot`
- Start it and it will give you your Chat ID (a number like `123456789`)

### 2. Run the container

```bash
docker run -d \
  --name taghie \
  --restart=always \
  -e CHAT_ID="YOUR_CHAT_ID" \
  -e PROXY="user:pass@ip:port" \
  -v taghie-data:/etc/earnapp \
  ghcr.io/rezanb111/taghie:latest
```

---

### Example:

```bash
docker run -d \
  --name taghie \
  --restart=always \
  -e CHAT_ID="123456789" \
  -e PROXY="myuser:mypass@1.2.3.4:1080" \
  -v taghie-data:/etc/earnapp \
  ghcr.io/rezanb111/taghie:latest
```

After starting, you should receive this message in the bot:

`✅ taghie started successfully`

---

## Get UUID

```bash
docker exec taghie cat /etc/earnapp/uuid
```
