# 階段 1：安裝 dsh（npm 套件，不需編譯原始碼）
FROM node:22-alpine AS dsh

RUN npm install -g @deepseek-ai/dsh@0.1.1-rc.2

# 階段 2：Caddy（提供帳號密碼登入 + 反向代理）
FROM caddy:2-alpine AS caddy

# 階段 3：執行階段
FROM node:22-alpine

COPY --from=dsh /usr/local/lib/node_modules/@deepseek-ai/dsh /usr/local/lib/node_modules/@deepseek-ai/dsh
COPY --from=dsh /usr/local/bin/dsh /usr/local/bin/dsh
COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy

WORKDIR /workspace

# 複製啟動腳本與 Caddy 設定
COPY start.sh /start.sh
COPY Caddyfile /etc/caddy/Caddyfile
RUN chmod +x /start.sh

# Railway 會注入 PORT（預設 8080）
ENV PORT=8080

CMD ["/start.sh"]

