# Cloudflare Warp with Gost SOCKS on Docker

## Usage

### Start the container

To run the WARP client in Docker, use the `docker-compose.yml` and run `docker-compose up -d`.

```yaml
version: '3'

x-socks-base: &socks-base
  image: cfwarp-gostsocks-docker:20240305z032831-dev
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

See if it works:

```bash
curl --socks5 127.0.0.1:1080 "https://ipinfo.io/json"
curl --socks5 127.0.0.1:1081 "https://ipinfo.io/json"
```

### Configuration

You can configure the container through the following environment variables:
  
- `WARP_START_DELAY`: The time to wait for the WARP daemon to start, in seconds. The default is 2 seconds. If the time is too short, it may cause the WARP daemon to not start before using the proxy, resulting in the proxy not working properly. If the time is too long, it may cause the container to take too long to start.

- `WARP_LICENSE_KEY`: The license key of the WARP client, which is optional. If you have subscribed to WARP+ service, you can fill in the key in this environment variable. If you have not subscribed to WARP+ service, you can ignore this environment variable.
  
Data persistence: Use the host volume `./data` to persist the data of the WARP client. You can change the location of this directory or use other types of volumes. If you modify the `WARP_LICENSE_KEY`, please delete the `./data` directory so that the client can detect and register again.


## Project Fork Credit

This Docker is based on the work from `caomingjun/warp` that maintains an awesome [blog post](https://blog.caomingjun.com/run-cloudflare-warp-in-docker/en).
