FROM node:22-slim
WORKDIR /app
RUN npm install -g pnpm @deepseek-ai/dsh
EXPOSE 3080
CMD ["dsh", "web", "--host", "127.0.0.1", "--port", "3080"]