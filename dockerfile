FROM node:22-slim

WORKDIR /app

RUN npm install -g pnpm @deepseek-ai/dsh

RUN mkdir -p /root/.dsh

EXPOSE 3080

# Usa 0.0.0.0 para aceitar conexões externas
CMD ["sh", "-c", "dsh web --host 0.0.0.0 --port 3080 --no-open"]