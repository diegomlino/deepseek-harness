FROM node:20-slim
WORKDIR /app
RUN npm install -g pnpm @deepseek-ai/dsh
EXPOSE 3080
CMD ["dsh", "web", "--host", "0.0.0.0", "--port", "3080"]