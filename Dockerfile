FROM caddy:2-alpine AS caddy

FROM node:22-bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        python3 \
        make \
        g++ \
        bash \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g pnpm@11.7.0

# Copia o Caddy para a imagem do Harness
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy

WORKDIR /app

COPY . .

RUN pnpm install --frozen-lockfile

RUN pnpm run build

COPY Caddyfile /etc/caddy/Caddyfile
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV NODE_ENV=production
ENV DSH_HOME=/data/dsh

EXPOSE 7860

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]