FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="EarnApp Proxy Silent" \
      org.opencontainers.image.description="Completely silent EarnApp with SOCKS5 + Telegram logs only" \
      org.opencontainers.image.source="https://github.com/rezanb111/earnapp-proxy"

ENV DEBIAN_FRONTEND=noninteractive \
    EARNAPP_UUID="" \
    PROXY=""

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    proxychains4 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install EarnApp
RUN wget -qO /tmp/install.sh https://brightdata.com/static/earnapp/install.sh \
    && bash /tmp/install.sh -y \
    && rm -f /tmp/install.sh \
    && (earnapp stop || true)

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME ["/etc/earnapp"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
