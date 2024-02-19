FROM ghcr.io/xrayr-project/xrayr:v0.9.2

WORKDIR /

COPY scripts/xrayr.sh .

RUN chmod +x /xrayr.sh

ENTRYPOINT [ "/xrayr.sh" ]
