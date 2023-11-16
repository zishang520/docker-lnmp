#!/bin/bash

# 使用uname命令获取架构信息
arch=$(uname -m)

# 判断架构类型
if [ "$arch" == "aarch64" ]; then
    echo "服务器架构是aarch64"
elif [ "$arch" == "x86_64" ]; then
    echo "服务器架构是x86-x64"
else
    echo "服务器架构未知"
fi