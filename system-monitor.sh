#!/bin/bash

# 🛠️ 环境变量，防止系统找不到命令
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 🔐 Bark 推送 Key 和图标 URL（请根据实际修改）
BARK_KEY="abc123"  # 替换为你的 Bark API Key
icon_url="https://th.bing.com/th/id/OIP.PnLgsfgLeK-s0mUrQOeonwAAAA?w=176&h=180&c=7&r=0&o=5&dpr=1.8&pid=1.7"

# 🔍 获取主机名
hostname=$(hostname)

# 🌐 1️⃣ 资源监控部分
MEMORY_THRESHOLD=60  # 内存使用率阈值（%） （请根据实际修改）
CPU_THRESHOLD=65     # CPU 使用率阈值（%） （请根据实际修改）

MEMORY_USAGE=$(free | awk '/Mem:/ {printf("%.0f", $3/$2 * 100)}')
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | awk -F. '{print $1}')

log_message=""

# 🔍 检查内存使用率
if [ "$MEMORY_USAGE" -ge "$MEMORY_THRESHOLD" ]; then
    log_message+="内存占用率: $MEMORY_USAGE% (超过 ${MEMORY_THRESHOLD}%)。"
fi

# 🔍 检查 CPU 使用率
if [ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ]; then
    log_message+="CPU 占用率: $CPU_USAGE% (超过 ${CPU_THRESHOLD}%)。"
fi

if [ -n "$log_message" ]; then
    log_message="【$hostname】$log_message"
    encoded_message=$(echo "$log_message" | jq -sRr @uri)
    curl -s "https://api.day.app/$BARK_KEY/$encoded_message?icon=$icon_url&isCritical=1" &>/dev/null
    echo "资源监控推送已发送"
fi

# 🌐 2️⃣ SSH 登录提醒部分
if [ -n "$SSH_CONNECTION" ]; then
    ssh_ip=$(echo $SSH_CONNECTION | awk '{print $1}')
    user_name=$(whoami)
    ssh_message="【$hostname】SSH 登录警告: 用户 $user_name 从 IP $ssh_ip 登录"
    encoded_ssh_message=$(echo "$ssh_message" | jq -sRr @uri)
    curl -s "https://api.day.app/$BARK_KEY/$encoded_ssh_message?icon=$icon_url&isCritical=1" &>/dev/null
    echo "SSH 登录提醒已发送"
fi
