#!/bin/sh

cat > /Procfile <<EOF
acme: /acme.sh
caddy: /caddy.sh
xrayr: /xrayr.sh
hysteria: /hysteria.sh
supercronic: /supercronic.sh
EOF

overmind start