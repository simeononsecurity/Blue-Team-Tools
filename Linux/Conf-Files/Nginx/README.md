
## 18F FISMA Ready Nginx

The following was written against nginx stable 1.6.2 ([tarball](http://nginx.org/download/nginx-1.6.2.tar.gz)) (released 2014-08-05, [changelog](http://nginx.org/en/CHANGES-1.6)).

### Installation notes

The primary configuration command we use is:

```bash
./configure --prefix=/etc/nginx \
  --sbin-path=/usr/sbin/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --pid-path=/var/run/nginx.pid \
  --lock-path=/var/run/nginx.lock \
  --user=nginx \
  --group=nginx \
  --with-http_ssl_module \
  --with-http_spdy_module
```

### Contents

Nginx configuration files:

* `nginx.conf` - The main, server-wide nginx config settings.
* `vhosts/default.conf` - A working configuration for a test app serving up a static file, on HTTP and HTTPS (with a self-signed cert).
* `ssl/ssl.rules` - A set of SSL parameters appropriate for a vhost configuration file to `include`. Individual vhosts will still need to use their own `ssl_certificate` and `ssl_certificate_key` parameters, as `vhosts/default.conf` does.

These files expect that the directory structure will be preserved in `/etc/nginx`. In other words, `nginx.conf` should be at `/etc/nginx/nginx.conf`, and `ssl/ssl.rules` should be at `/etc/nginx/ssl/ssl.rules`.

And an additional helper script:

* `init.sh` - An init script for nginx, to allow nginx to start on boot, and to allow control of nginx with the `service` command. Expects certain paths to have been passed to nginx upon `./configure`.
