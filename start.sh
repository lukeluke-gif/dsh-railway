#!/bin/sh
# DeepSeek Harness Railway 啟動腳本
set -e

echo "=============================================="
echo " DeepSeek Harness (Railway) 啟動"
echo "=============================================="

# --- 1. 檢查必要環境變數 ---
if [ -z "$DSH_WEB_USER" ] || [ -z "$DSH_WEB_PASSWORD" ]; then
  echo "錯誤：需要設定 DSH_WEB_USER 與 DSH_WEB_PASSWORD 環境變數（登入帳號/密碼）"
  exit 1
fi

# --- 2. 產生 Caddy basic_auth 的 bcrypt hash ---
HASH=$(caddy hash-password --plaintext "$DSH_WEB_PASSWORD")
if [ -z "$HASH" ]; then
  echo "錯誤：caddy hash-password 執行失敗"
  exit 1
fi

# --- 3. 動態生成 Caddyfile（直接內嵌 hash，避免特殊字元問題）---
PORT="${PORT:-8080}"
cat > /etc/caddy/Caddyfile <<EOF
:$PORT {
    encode zstd gzip

    basic_auth {
        $DSH_WEB_USER $HASH
    }

    reverse_proxy 127.0.0.1:3080
}
EOF
echo "Caddyfile 已生成（監聽 port $PORT）"

# --- 4. 準備 dsh 資料目錄（Volume 掛載點）---
export DSH_HOME="${DSH_HOME:-/data/.dsh}"
mkdir -p "$DSH_HOME"
echo "DSH_HOME = $DSH_HOME"

# --- 5. 計算 trusted-host（讓遠端瀏覽器可用完整 API）---
TRUSTED_ARGS=""
if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  TRUSTED_ARGS="$TRUSTED_ARGS --trusted-host $RAILWAY_PUBLIC_DOMAIN"
  echo "已加入 trusted-host: $RAILWAY_PUBLIC_DOMAIN"
fi
if [ -n "$DSH_TRUSTED_HOST" ]; then
  TRUSTED_ARGS="$TRUSTED_ARGS --trusted-host $DSH_TRUSTED_HOST"
  echo "已加入 trusted-host: $DSH_TRUSTED_HOST"
fi

# --- 6. 啟動 Caddy（背景）：監聽 $PORT 提供帳號密碼 + 轉發到 127.0.0.1:3080 ---
echo "啟動 Caddy..."
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
CADDY_PID=$!
sleep 1

# --- 7. 啟動 dsh（前景）---
echo "啟動 dsh web..."
# shellcheck disable=SC2086
exec dsh web --port 3080 --no-open $TRUSTED_ARGS
