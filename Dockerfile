FROM ghcr.io/cedar2025/hysteria:862f66a AS hysteria
FROM ghcr.io/wyx2685/xrayr:v0.9.2-20240326 AS xrayr

FROM debian:stable-slim

ARG SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64
ARG OVERMIND_URL=https://github.com/DarthSim/overmind/releases/download/v2.5.1/overmind-v2.5.1-linux-amd64.gz

ENV TZ="Asia/Shanghai" \

    OVERMIND_CAN_DIE=caddy,acme,hysteria,xrayr \

    XBOARD_API_HOST=https://api.host.com \
    XBOARD_API_KEY=88888888 \

    HYSTERIA_NODE_ID= \
    XRAYR_NODE_ID= \

    ##############
    ## caddy.sh ##
    ##############
    CADDY_DOMAIN= \
    CADDY_PORT= \
    CADDY_PROXY_PORT= \

    #############
    ## acme.sh ##
    #############
    ACME_EMAIL=hi@gmail.com \
    ACME_DOMAIN= \
    ACME_DNS=dns_dynv6 \
    DYNV6_TOKEN=

COPY --from=hysteria /usr/local/bin/hysteria /usr/local/bin/hysteria
COPY --from=xrayr /usr/local/bin/XrayR /usr/local/bin/XrayR

COPY scripts/overmind.sh \
     scripts/supercronic.sh \
     scripts/caddy.sh \
     scripts/acme.sh \
     scripts/hysteria.sh \
     scripts/xrayr.sh \
     /

RUN apt update && apt install -y --no-install-recommends \
        debian-keyring \
        debian-archive-keyring \
        apt-transport-https \
        gnupg \
        git \
        sudo \
        nano \
        curl \
        tmux \
        tzdata \
        ca-certificates \
        && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
        && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list \
        && apt update && apt install -y caddy \
        && apt clean && rm -rf /var/lib/apt/lists/* \

        && git clone --depth 1 https://github.com/acmesh-official/acme.sh.git acme \
        && cd /acme && ./acme.sh --install --nocron --accountemail $ACME_EMAIL && rm -rf acme \

        && curl -fsSL "$SUPERCRONIC_URL" -o /usr/local/bin/supercronic \
        && curl -fsSL "$OVERMIND_URL" | gunzip -c - > /usr/local/bin/overmind \

        && chmod +x /usr/local/bin/supercronic \
        && chmod +x /usr/local/bin/overmind \
        && chmod +x /usr/local/bin/hysteria \
        && chmod +x /usr/local/bin/XrayR \

        && chmod +x /overmind.sh \
        && chmod +x /supercronic.sh \
        && chmod +x /caddy.sh \
        && chmod +x /acme.sh \
        && chmod +x /hysteria.sh \
        && chmod +x /xrayr.sh

ENTRYPOINT [ "/overmind.sh" ]
