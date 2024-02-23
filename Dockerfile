FROM ghcr.io/cedar2025/hysteria:v1.0.7 AS hysteria
FROM ghcr.io/wyx2685/xrayr:master AS xrayr
FROM goacme/lego:v4.15 AS lego

FROM alpine

ARG SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64 \
    OVERMIND_URL=https://github.com/DarthSim/overmind/releases/download/v2.4.0/overmind-v2.4.0-linux-amd64.gz

ENV OVERMIND_CAN_DIE=lego,hysteria,xrayr \
    OVERMIND_PROCFILE=/Procfile \

    XBOARD_API_HOST=https://api.host.com \
    XBOARD_API_KEY=88888888 \

    HYSTERIA_NODE_ID= \
    XRAYR_NODE_ID= \

    LEGO_DNS=rfc2136 \
    LEGO_DOMAIN= \
    LEGO_EMAIL=hi@gmail.com \

    RFC2136_NAMESERVER=ns1.dynv6.com \
    RFC2136_TSIG_ALGORITHM=hmac-sha512 \ 
    RFC2136_TSIG_KEY= \
    RFC2136_TSIG_SECRET= \
    RFC2136_TTL=60

COPY --from=lego /lego /usr/local/bin/lego
COPY --from=hysteria /usr/local/bin/hysteria /usr/local/bin/hysteria
COPY --from=xrayr /usr/local/bin/XrayR /usr/local/bin/XrayR

COPY config/crontab \
     config/Procfile \
     scripts/lego.sh \
     scripts/hysteria.sh \
     scripts/xrayr.sh \
     /

RUN apk add --no-cache \
        curl \
        ca-certificates \
        tzdata \
        tmux \

        && rm -rf /var/cache/apk/* \
        && curl -fsSL "$SUPERCRONIC_URL" -o /usr/local/bin/supercronic \
        && curl -fsSL "$OVERMIND_URL" | gunzip -c - > /usr/local/bin/overmind \

        && chmod +x /usr/local/bin/lego \
        && chmod +x /usr/local/bin/supercronic \
        && chmod +x /usr/local/bin/overmind \
        && chmod +x /usr/local/bin/hysteria \
        && chmod +x /usr/local/bin/XrayR \

        && chmod +x /lego.sh \
        && chmod +x /hysteria.sh \
        && chmod +x /xrayr.sh

ENTRYPOINT [ "overmind", "start" ]
