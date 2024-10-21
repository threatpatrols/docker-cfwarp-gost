
# Cloudflare WARP
FROM debian:stable-slim AS cloudflare-warp

# download the cloudflare-warp deb package
RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl ca-certificates gnupg lsb-release && \
    \
    curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list && \
    \
    mkdir -p /tmp/cloudflare-warp && cd /tmp/cloudflare-warp && \
    \
    apt-get update && \
    apt show cloudflare-warp && \
    apt-get download --print-uris cloudflare-warp && \
    apt-get download cloudflare-warp || true && \
    mv cloudflare-warp_*.deb cloudflare-warp.deb


# GOST
FROM debian:stable-slim AS gost-download

# https://github.com/ginuerzh/gost/releases
ARG GOST_PACKAGE_URL="https://github.com/ginuerzh/gost/releases/download/v2.12.0/gost_2.12.0_linux_amd64.tar.gz"

# download and install gost
RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl ca-certificates && \
    \
    mkdir -p /tmp/gost && \
    cd /tmp/gost && \
    curl -L "${GOST_PACKAGE_URL}" -o gost-linux-amd64.tar.gz && \
    tar -zxf gost-linux-amd64.tar.gz

RUN \
    chmod 755 /tmp/gost/gost && \
    /tmp/gost/gost -V


# https://hub.docker.com/_/debian/tags
FROM debian:stable-slim

# Hello
LABEL maintainer="Nicholas de Jong <ndejong@threatpatrols.com>"
LABEL source="https://github.com/threatpatrols/docker-cfwarp-gost"

# copy-install gost binary
COPY --from=gost-download /tmp/gost/gost /usr/local/bin/gost
COPY --from=cloudflare-warp /tmp/cloudflare-warp/cloudflare-warp.deb /tmp/cloudflare-warp/cloudflare-warp.deb

# install prerequisites and cloudflare-warp
RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl ca-certificates systemd-resolved sudo procps iputils-ping inetutils-traceroute && \
    apt install -y /tmp/cloudflare-warp/cloudflare-warp.deb && \
    \
    printf " >> %s\n" "$(warp-cli --accept-tos --version)" && \
    printf " >> %s\n" "$(gost -V)" && \
    \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# NB: perform these COPY/RUN layers after the RUN layer above so edits/changes have short dev-build times
COPY scripts /scripts
COPY entrypoint.sh healthchecks.sh ./
RUN chmod 755 /entrypoint.sh /healthchecks.sh /scripts/*.sh

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=5 \
  CMD "/healthchecks.sh"

ENTRYPOINT ["/entrypoint.sh"]
