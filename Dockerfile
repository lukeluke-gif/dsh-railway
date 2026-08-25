# 階段 1：Caddy 官方映像（提供帳號密碼登入 + 反向代理；binary 與 Alpine 相容）
FROM caddy:2-alpine AS caddy

# 階段 2：執行階段（直接在最終映像安裝 dsh，確保 npm 依賴連結完整）
FROM node:22-alpine

# 安裝 dsh（npm 套件，不需編譯原始碼；自動安裝全部 @deepseek-ai/* 依賴）
RUN npm install -g @deepseek-ai/dsh@0.1.1-rc.2

# 從 Caddy 官方映像複製 binary
COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy

WORKDIR /workspace

# 複製啟動腳本與 Caddy 設定
COPY start.sh /start.sh
COPY Caddyfile /etc/caddy/Caddyfile
RUN chmod +x /start.sh

# Railway 會注入 PORT（預設 8080）
ENV PORT=8080

CMD ["/start.sh"]

