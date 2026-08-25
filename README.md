# DeepSeek Harness on Railway

在 Railway 上部署 DeepSeek Harness（`@deepseek-ai/dsh`）的設定檔。

## 架構

```
瀏覽器（手機 / 任何電腦）
   │  HTTPS + 帳號密碼
   ▼
Caddy（監聽 $PORT，basic_auth 帳號密碼，自動 HTTPS）
   │  轉發到本機
   ▼
dsh web（127.0.0.1:3080）
   │
   ├─ DSH_HOME=/data/.dsh  （Railway Volume 永續磁碟：設定、API 金鑰、會話、工作區）
   └─ 每日備份策略見下方
```

## 需要的 Railway Variables（在 Railway 專案設定中新增）

| 變數 | 說明 | 範例 |
|---|---|---|
| `DSH_WEB_USER` | 登入帳號 | `admin` |
| `DSH_WEB_PASSWORD` | 登入密碼 | 一組夠長的安全密碼 |
| `DSH_HOME` | 資料目錄（掛在 Volume） | `/data/.dsh` |
| `DEEPSEEK_API_KEY` | DeepSeek API 金鑰 | `sk-...` |
| `DSH_TRUSTED_HOST` | （選用）額外信任的網域 | `*.up.railway.app` 形式 |

## Volume 設定

在 Railway 的 service 新增 Volume：
- Mount Path：`/data`
- 大小：建議至少 1GB

## 部署

1. 建立 Railway 專案 → `Deploy from GitHub repo` 選擇本 repo
2. 新增上述 Variables
3. 新增 Volume（掛載到 `/data`）
4. 部署完成後 `Generate Domain`，手機與電腦開啟該網址，輸入 `DSH_WEB_USER` / `DSH_WEB_PASSWORD` 登入

## 資料備份（建議）

Railway Volume 是永續磁碟，但為避免帳號意外或誤刪，建議另做異地備份：
- 方案 A：Railway 主控台 → Volume → 定期手動下載
- 方案 B：部署一個排程容器，用 `rclone`/`gsutil` 將 `/data` 同步到其他雲端儲存
