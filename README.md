# Demo-unionfly
aws &amp; shell script test for unionfly

## Terraform on AWS
連線至DMZ-EC2 install mysql-client 驗證連線
- main.tf
  - 過 terraform 建立 2 台 EC2，1 台 RDS，其中 1 台 EC2 擺放在 DMZ 並提供 22/80/443 給特定 IP 存取，另 1 台 EC2 與 RDS 擺放在內網段並提供給 DMZ 網段存取
- backend.tf
  - terraform backend 使用 S3
- connection_info.txt
  - 連線資訊透過 local_file 保存至 root.path 
## Terraform variables demo
以創建AWS S3 EC2為範例展示 string/number/bool/list/set/map 的使用方式
- string-S3名稱
- number-EC2數量
- bool-EC2監控是否啟用
- list-環境列表
- set-安全組IP列表
- map-S3 tags
## Shell script
### 以docker container ubuntu 22.04 驗證，並安裝相關工具 systemctl ,curl,etc.
- install_nginx.sh
  - 腳本裡需判斷 nginx 是否已安裝，true 則輸出 nginx 已安裝 ，false 則進行安裝並在成功後輸出 nginx 安裝成功
- create_server.sh
  - 撰寫 1 個腳本產生 nginx site config，並透過參數指定 server_name，腳本擺放 nginx 預設位置並啟用它
- restart_service.sh
  - 撰寫 1 個腳本使用 systemd 重啟服務，並使用 curl 調用 localhost:8080 做健康檢查（請求 1 秒逾時，執行 60 次），檢查成功後輸出 服務已重啟 ，檢查失敗則輸出 服務重啟失敗