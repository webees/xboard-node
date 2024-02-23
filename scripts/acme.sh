#!/bin/sh

if [ -z "$ACME_DOMAIN" ]; then
  exit 1
fi

/root/.acme.sh/acme.sh --register-account -m $ACME_EMAIL

while [ ! -f "/root/.acme.sh/${ACME_DOMAIN}_ecc/${ACME_DOMAIN}.cer" ]; do
  /root/.acme.sh/acme.sh --issue --dns dns_dynv6 -d $ACME_DOMAIN
  sleep 5
done


