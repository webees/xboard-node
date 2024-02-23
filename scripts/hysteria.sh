#!/bin/sh

if [ -z "$HYSTERIA_NODE_ID" ]; then
  exit 1
fi

TLS_MODE=none

if [ -n "$ACME_DOMAIN" ]; then
  while [ ! -f "/root/.acme.sh/${ACME_DOMAIN}_ecc/${ACME_DOMAIN}.cer" ]; do
      sleep 5
  done
  TLS_MODE=tls
fi

cat > /hysteria.yaml <<EOF
v2board:
  apiHost: $XBOARD_API_HOST
  apiKey: $XBOARD_API_KEY
  nodeID: $HYSTERIA_NODE_ID
auth:
  type: v2board
${TLS_MODE}:
  cert: /root/.acme.sh/${ACME_DOMAIN}_ecc/${ACME_DOMAIN}.cer
  key: /root/.acme.sh/${ACME_DOMAIN}_ecc/${ACME_DOMAIN}.key
acl: 
  inline: 
    - reject(10.0.0.0/8)
    - reject(172.16.0.0/12)
    - reject(192.168.0.0/16)
    - reject(127.0.0.0/8)
    - reject(fc00::/7)
EOF

hysteria server -c /hysteria.yaml