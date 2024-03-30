#!/bin/bash

# check 輸入的參數是否正確
if [ $# -ne 1 ]; then
  echo "參數給定錯誤,Usage: $0 <server_name>"
  exit 1
fi

# 取使用者輸入參數
server_name=$1

# nginx配置文件位置
site_config="/etc/nginx/sites-available/${server_name}"

# check創建的server_name是否存在
if [ -e "${site_config}" ]; then
  echo "Error: Configuration file already exists for server_name ${server_name}"
  exit 1
fi

# 創建指定文件假設監聽8080給下一個restart_service.sh使用
cat > "${site_config}" << EOF
server {
    listen 8080;
    server_name ${server_name};

    location / {
        root /var/www/html/${server_name};
        index index.html index.htm;
    }
}
EOF

# 創建相關目錄
mkdir -p "/var/www/html/${server_name}"

# 啟用設定server ln到enabled
ln -s "${site_config}" "/etc/nginx/sites-enabled/${server_name}"

# check 語法並重啟
nginx -t && nginx -s reload

echo "${server_name} created and enabled."
