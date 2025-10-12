FROM caddy:2-builder-alpine AS builder
RUN xcaddy build --with github.com/devetek/caddyserver-minifier
FROM caddy:2-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy