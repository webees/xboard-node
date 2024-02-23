#!/bin/sh

if [ -z "$LEGO_DOMAIN" ]; then
  exit 1
fi

lego \
    --accept-tos \
    --dns $LEGO_DNS \
    --dns.resolvers 8.8.8.8:53 \
    --domains $LEGO_DOMAIN \
    --email $LEGO_EMAIL \
    run