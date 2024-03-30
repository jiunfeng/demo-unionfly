#!/bin/bash

# 服務重啟
systemctl stop nginx
systemctl restart nginx &

# 為了測試 更改 /usr/lib/systemd/system/nginx.service
# ExecStart=/bin/bash -c "/bin/sleep 5 && /usr/sbin/nginx -g 'daemon on; master_process on;'"
# 啟動前延遲五秒讓健康檢查暫時失敗


# health check
health_check() {
  local url="http://localhost:8080"
  local timeout=1
  local attempts=60

  for ((i = 1; i <= attempts; i++)); do
    if curl -s --max-time ${timeout} "${url}"; then
      echo "nginx already restart"
      exit 0
    else
      echo "The ${i}th time health check failed"
      sleep 1
    fi
  done

  echo "service restart failed"
  exit 1
}

# 執行上方函數
health_check
