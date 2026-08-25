FROM node:22-slim

WORKDIR /app

RUN npm install -g pnpm @deepseek-ai/dsh

RUN mkdir -p /root/.dsh

EXPOSE 3080

# Adicione --no-open para evitar tentativa de abrir navegador
CMD ["sh", "-c", "dsh web --host 127.0.0.1 --port 3080 --no-open"]