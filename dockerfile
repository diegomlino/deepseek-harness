FROM node:22-slim

# Instala Nginx
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instala o DeepSeek Harness
RUN npm install -g pnpm @deepseek-ai/dsh

RUN mkdir -p /root/.dsh

# Configura o Nginx como proxy reverso
RUN echo 'events { } http { server { listen 80; location / { proxy_pass http://127.0.0.1:3080; proxy_set_header Host $host; proxy_set_header X-Real-IP $remote_addr; } } }' > /etc/nginx/nginx.conf

EXPOSE 80

# Inicia o Nginx e o Harness juntos
CMD ["sh", "-c", "dsh web --host 127.0.0.1 --port 3080 --no-open & nginx -g 'daemon off;'"]