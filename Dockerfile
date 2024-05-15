
# https://hub.docker.com/_/debian/tags
FROM debian:stable

# Hello
LABEL maintainer="Nicholas de Jong <ndejong@threatpatrols.com>"
LABEL source="https://github.com/threatpatrols/docker-cfwarp-gost"

# https://github.com/ginuerzh/gost/releases
ARG GOST_PACKAGE_URL="https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz"

# install prerequisites and cloudflare-warp
RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl gnupg lsb-release && \
    \
    curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list && \
    apt-get update && \
    apt-get install -y cloudflare-warp && \
    mkdir -p /root/.local/share/warp && \
    echo -n 'yes' > /root/.local/share/warp/accepted-tos.txt && \
    echo -n 'yes' > /root/.local/share/warp/accepted-teams-tos.txt && \
    warp-cli --version && \
    \
    apt-get clean && \
    apt-get autoremove -y


# download and install gost
RUN \
    mkdir -p /tmp/gost && \
    cd /tmp/gost && \
    curl -L "$GOST_PACKAGE_URL" -o gost-linux-amd64.gz && \
    gunzip gost-linux-amd64.gz && \
    chmod 755 /tmp/gost/gost-linux-amd64 && \
    mv /tmp/gost/gost-linux-amd64 /usr/local/bin/gost && \
    cd / && \
    rm -Rf /tmp/gost && \
    gost -V


HEALTHCHECK --interval=45s --timeout=3s --start-period=20s --retries=1 \
  CMD curl -fsS "https://cloudflare.com/cdn-cgi/trace" | grep -qE "warp=(plus|on)" || exit 1


COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
