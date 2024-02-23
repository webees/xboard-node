#!/bin/sh

if [ -z "$CADDY_PORT" ]; then
  exit 1
fi

cat > /Caddyfile <<EOF
{
  auto_https off
  admin off
  persist_config off

  log {
    output stdout
    format console
  }
}

${CADDY_DOMAIN}:${CADDY_PORT} {
  encode gzip

  header / {
    Strict-Transport-Security "max-age=31536000;"
    X-XSS-Protection "1; mode=block"
    X-Frame-Options "DENY"
    X-Robots-Tag "noindex, nofollow"
    X-Content-Type-Options "nosniff"
    -Server
    -X-Powered-By
    -Last-Modified
  }

  route /health {
    respond "Hello, world!"
  }

  reverse_proxy localhost:${CADDY_PROXY_PORT} {
    header_up X-Real-IP {remote_host}
  }
}
EOF

caddy run --config /Caddyfile