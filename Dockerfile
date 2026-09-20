# 階段 1：Caddy 官方映像（提供帳號密碼登入 + 反向代理；binary 與 Alpine 相容）
FROM caddy:2-alpine AS caddy

# 階段 2：執行階段。Node 24 與本機安裝的版本一致（官方發佈檔亦以 Node 24 建置）
FROM node:24-alpine

# bash：harness 的 shell 工具需要它，Alpine 預設沒有；
# python3/make/g++/linux-headers：原生相依若無 musl 預建檔時可即地編譯。
RUN apk add --no-cache bash python3 make g++ linux-headers

# 安裝官方發佈的 dsh。npm 上的 alpha tag 就是 0.1.6-alpha.2，與本機同版。
RUN npm install -g @deepseek-ai/dsh@0.1.6-alpha.2

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


