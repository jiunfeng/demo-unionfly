#!/bin/bash

# check Nginx 是否安裝
if [ -x "$(command -v nginx)" ]; then
    echo "Nginx is already installed."
else
    # 啟動安裝程序，ubuntu 使用 apt
    echo "Nginx is not installed. Begin installing Nginx..."
    apt-get update
    apt-get install nginx -y

    # check 安裝結果
    if [ -x "$(command -v nginx)" ]; then
        echo "Nginx installation successfully."
    else
        echo "Failed to install Nginx. check your system and try again."
        exit 1 #退出表失敗
    fi
fi
