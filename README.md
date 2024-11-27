# HAProxy - JA4H HTTP Client-Fingerprint - Lua Plugin

**WARNING: This plugin is still in early development! DO NOT USE IN PRODUCTION!**

## Intro

About JA4:

* [HAProxy Lua Plugin (JA4)](https://github.com/O-X-L/haproxy-ja4)
* [JA4+ Suite](https://github.com/FoxIO-LLC/ja4/blob/main/technical_details/README.md)
* [FoxIO Repository](https://github.com/FoxIO-LLC/ja4)
* [Cloudflare Blog](https://blog.cloudflare.com/ja4-signals)
* [FoxIO Blog](https://blog.foxio.io/ja4%2B-network-fingerprinting)
* [FoxIO JA4 Database](https://ja4db.com/)

About JA3:
* [HAProxy Lua Plugin (JA3N)](https://github.com/O-X-L/haproxy-ja3n)
* [Salesforce Repository](https://github.com/salesforce/ja3)
* [HAProxy Enterprise JA3 Fingerprint](https://customer-docs.haproxy.com/bot-management/client-fingerprinting/tls-fingerprint/)
* [JA3N](https://tlsfingerprint.io/norm_fp)

----

## Usage

* Add the LUA script `ja4h.lua` to your system

## Config

* Enable SSL/TLS capture with the global setting [tune.ssl.capture-buffer-size 96](https://www.haproxy.com/documentation/haproxy-configuration-manual/latest/#tune.ssl.capture-buffer-size)
* Load the LUA module with `lua-load /etc/haproxy/lua/ja4h.lua`
* Execute the LUA script on HTTP requests: `http-request lua.fingerprint_ja4h`
* Log the fingerprint: `http-request capture var(txn.fingerprint_ja4h) len 36`

----

## Contribute

If you have:

* Found an issue/bug - please [report it](https://github.com/O-X-L/haproxy-ja4h/issues/new)
* Have an idea on how to improve it - [feel free to start a discussion](https://github.com/O-X-L/haproxy-ja4h/discussions/new/choose)
* PRs are welcome

### Issues

* Have not yet found an option to access the request object `req`.

### Testing

* Create snakeoil certificate:

  ```bash
  openssl req -x509 -newkey rsa:4096 -sha256 -nodes -subj "/CN=HAProxy JA4H Test" -addext "subjectAltName = DNS:localhost,IP:127.0.0.1" -keyout /tmp/haproxy.key.pem -out /tmp/haproxy.crt.pem -days 30
  cat /tmp/haproxy.crt.pem /tmp/haproxy.key.pem > /tmp/haproxy.pem
  ```

* Link the LUA script: `ln -s $(pwd)/ja4h.lua /tmp/haproxy_ja4h.lua`
* You can run the `haproxy_example.cfg` manually like this: `haproxy -W -f haproxy_example.cfg`
* Access the test website: https://localhost:6969/


```bash

```
