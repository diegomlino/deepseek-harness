FROM node:22-bookworm-slim

# Dependências necessárias para instalação/build
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        python3 \
        make \
        g++ \
    && rm -rf /var/lib/apt/lists/*

# O repositório utiliza pnpm 11.7.0
RUN npm install -g pnpm@11.7.0

WORKDIR /app

# O Dokploy já terá clonado o repositório.
# Aqui apenas copiamos esse código para a imagem.
COPY . .

# Instala exatamente as dependências registradas no lockfile
RUN pnpm install --frozen-lockfile

# Compila o DeepSeek Harness a partir do código-fonte
RUN pnpm run build

# Configuração padrão
ENV NODE_ENV=production
ENV DSH_HOME=/data/dsh
ENV PORT=7860

EXPOSE 7860

CMD ["pnpm", "dsh", "web", "--host", "0.0.0.0", "--port", "7860", "--no-open"]