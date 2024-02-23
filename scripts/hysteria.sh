#!/bin/sh

if [ -z "$HYSTERIA_NODE_ID" ]; then
  exit 1
fi

TLS_MODE=none

if [ -n "$LEGO_DOMAIN" ]; then
  while [ ! -f "/.lego/certificates/${LEGO_DOMAIN}.crt" ]; do
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
  cert: /.lego/certificates/${LEGO_DOMAIN}.crt
  key: /.lego/certificates/${LEGO_DOMAIN}.key
acl: 
  inline: 
    - reject(10.0.0.0/8)
    - reject(172.16.0.0/12)
    - reject(192.168.0.0/16)
    - reject(127.0.0.0/8)
    - reject(fc00::/7)
EOF

hysteria server -c /hysteria.yaml