# Go Simple Tunnel (GOST) through Cloudflare WARP on Docker

## Usage

### Start the container

To run a Go Simple Tunnel ([GOST](https://gost.run/en/)) through Cloudflare WARP on Docker, use 
a `docker-compose.yml` similar to the one provided below.

Bring it up with a standard `docker-compose up -d` command.

```yaml
version: '3'

x-socks-base: &socks-base
  image: threatpatrols/cfwarp-gost:latest
  restart: always
  cap_add:
    - NET_ADMIN
  sysctls:
    - net.ipv6.conf.all.disable_ipv6=0
    - net.ipv4.conf.all.src_valid_mark=1

services:

  socks-cloudflare-local:
    <<: *socks-base
    container_name: socks-cloudflare-local
    ports:
      - '127.0.0.1:1080:1080'

  socks-with-upstream:
    <<: *socks-base
    container_name: socks-with-upstream
    ports:
      - '127.0.0.1:1081:1080'
    environment:
      - GOST_FORWARD=socks5://<socks-server-ip-address>:<socks-server-port>
```

### Notes
- This sample `docker-compose.yml` should be modified to suit your situation.
- The `socks-with-upstream` section is optional, you can use a GOST SOCKS5 tunnel through Cloudflare WARP without an upstream proxy.
- If you plan to use the `socks-with-upstream` definition, pay attention to the `GOST_FORWARD` environment variable
- Credentials can be added for the upstream-proxy using standard `socks5://<username>:<password>@<socks-server-ip-address>:<socks-server-port>` notation.
- This `docker-compose.yml` example uses YAML Anchors to make the service definitions shorter without repeating etc, learn more here if unfamiliar https://docs.docker.com/compose/compose-file/10-fragments/


Test the two docker containers once compose-up is done:

```bash
curl --socks5 127.0.0.1:1080 "https://ipinfo.io/json"
curl --socks5 127.0.0.1:1081 "https://ipinfo.io/json"
```

### Configuration

You can configure the container through the following environment variables:

- `GOST_FORWARD`: Provides the main purpose for this container by making it possible to easily express GOST configurations such that external traffic is automatically transported over a Cloudflare WARP tunnel. 
  
- `WARP_START_DELAY`: The time to wait for the WARP daemon to start, in seconds. The default is 2 seconds. If the time is too short, it may cause the WARP daemon to not start before using the proxy, resulting in the proxy not working properly. If the time is too long, it may cause the container to take too long to start.

- `WARP_LICENSE_KEY`: The license key of the WARP client, which is optional. If you have subscribed to WARP+ service, you can fill in the key in this environment variable. If you have not subscribed to WARP+ service, you can ignore this environment variable.
  
Data persistence: Use the host volume `./data` to persist the data of the WARP client. You can change the location of this directory or use other types of volumes. If you modify the `WARP_LICENSE_KEY`, please delete the `./data` directory so that the client can re-detect and re-register again.

## Repos
* Github: https://github.com/threatpatrols/docker-cfwarp-gost
* DockerHub: https://hub.docker.com/repository/docker/threatpatrols/cfwarp-gost

NB: early releases of this project mistakenly referred to "Cloudflare WARP" as "Cloudflared" - the project and repos have been renamed accordingly since.

## Project Fork Credit

This Docker is heavily based on the work from **caomingjun** that has an awesome blog [post](https://blog.caomingjun.com/run-cloudflare-warp-in-docker/en) and [github](https://github.com/cmj2002/warp-docker) repo.
