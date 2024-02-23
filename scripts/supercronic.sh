#!/bin/sh

cat > /crontab <<EOF
@daily echo "TEST"
EOF

supercronic /crontab