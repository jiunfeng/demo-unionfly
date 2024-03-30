# demo-unionfly
aws &amp; shell script test for unionfly

## Terraform on AWS

## shell script
### 以docker container ubuntu 22.04 驗證，並安裝相關工具 systemctl ,curl,etc.
- install_nginx.sh
  - 腳本裡需判斷 nginx 是否已安裝，true 則輸出 nginx 已安裝 ，false 則進行安裝並在成功後輸出 nginx 安裝成功
- create_server.sh
  - 撰寫 1 個腳本產生 nginx site config，並透過參數指定 server_name，腳本擺放 nginx 預設位置並啟用它
- restart_service.sh
  - 撰寫 1 個腳本使用 systemd 重啟服務，並使用 curl 調用 localhost:8080 做健康檢查（請求 1 秒逾時，執行 60 次），檢查成功後輸出 服務已重啟 ，檢查失敗則輸出 服務重啟失敗