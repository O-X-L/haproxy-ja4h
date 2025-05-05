# HAProxy - JA4H HTTP Client-Fingerprint - Lua Plugin

**WARNING: This plugin is still in early development! DO NOT USE IN PRODUCTION!**

----

## Intro

About JA4:

* [JA4+ Suite](https://github.com/FoxIO-LLC/ja4/blob/main/technical_details/README.md)
* [FoxIO Repository](https://github.com/FoxIO-LLC/ja4)
* [Cloudflare Blog](https://blog.cloudflare.com/ja4-signals)
* [FoxIO Blog](https://blog.foxio.io/ja4%2B-network-fingerprinting)
* [FoxIO JA4 Database](https://ja4db.com/)
* [JA4 HAProxy Lua Plugin](https://github.com/O-X-L/haproxy-ja4)

About JA3:
* [JA3N HAProxy Lua Plugin](https://github.com/O-X-L/haproxy-ja3n)
* [Salesforce Repository](https://github.com/salesforce/ja3)
* [HAProxy Enterprise JA3 Fingerprint](https://customer-docs.haproxy.com/bot-management/client-fingerprinting/tls-fingerprint/)
* [Why JA3 broke => JA3N](https://github.com/salesforce/ja3/issues/88)


----

## Usage

* Add the LUA script `ja4h.lua` to your system.

## Config

* Load the LUA module with `lua-load /etc/haproxy/lua/ja4h.lua`
* Execute the LUA script on HTTP requests: `http-request lua.fingerprint_ja4h`
* Log the fingerprint: `http-request capture var(txn.fingerprint_ja4h) len 51`

----

## Contribute

If you have:

* Found an issue/bug - please [report it](https://github.com/O-X-L/haproxy-ja4h/issues/new)
* Have an idea on how to improve it - [feel free to start a discussion](https://github.com/O-X-L/haproxy-ja4h/discussions/new/choose)
* PRs are welcome

### Issues

* Have not yet found an option to access the request object `req`.

----

## Contribute

If you have:

* Found an issue/bug - please [report it](https://github.com/O-X-L/haproxy-ja4h/issues/new)
* Have an idea on how to improve it - [feel free to start a discussion](https://github.com/O-X-L/haproxy-ja4h/discussions/new/choose)
* PRs are welcome

Please [read the JA4H TLS details](https://github.com/FoxIO-LLC/ja4/blob/main/technical_details/JA4H.md)!

Available HTTP-fetches are: [HAProxy HTTP fetches](https://github.com/haproxy/haproxy/blob/v3.1.0/src/http_fetch.c#L2256)

### Testing

Example:
```
FINGERPRINT
xxx

DEBUG
raw fingerprint: xxx 
```

#### Docker

If you prefer to use Docker, the manual steps can be skipped.
Run the docker container from the project root and access https://localhost:6969

```bash
docker compose -f test/docker-compose.yaml up --build --watch
```

`--watch` will automatically rebuild the container on changes

#### Local

* Run: `bash test/run.sh`
* Access the test website: https://localhost:6969/

Exit with `CTRL+C`
