FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-server sudo gcc libc6-dev && \
    rm -rf /var/lib/apt/lists/*

COPY vault.c /tmp/vault.c
COPY setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh && /tmp/setup.sh && rm -f /tmp/vault.c /tmp/setup.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22
CMD ["/entrypoint.sh"]
