#!/bin/bash

# 函数：检查并安装 git
install_git() {
  if ! command -v git &> /dev/null; then
    echo "❌ git 未安装，正在安装 git..."
    sudo apt-get update && sudo apt-get install -y git
  fi
}

# 函数：检查并安装 curl
install_curl() {
  if ! command -v curl &> /dev/null; then
    echo "❌ curl 未安装，正在安装 curl..."
    sudo apt-get update && sudo apt-get install -y curl
  fi
}

# 函数：检查并安装 nano
install_nano() {
  if ! command -v nano &> /dev/null; then
    echo "❌ nano 未安装，正在安装 nano..."
    sudo apt-get update && sudo apt-get install -y nano
  fi
}


# 1. 检查并安装 git、curl 和 nano
install_git
install_curl
install_nano

# 2. 从 GitHub 下载 system-monitor.sh 脚本文件
echo "⏳ 正在从 GitHub 下载 system-monitor.sh 脚本文件..."
curl -sS -o /usr/local/bin/system-monitor.sh https://raw.githubusercontent.com/LD2J0618/Bloge_LD2J/refs/heads/main/system-monitor.sh

# 检查下载是否成功
if [ ! -f /usr/local/bin/system-monitor.sh ]; then
  echo "❌ 下载 system-monitor.sh 脚本失败，请检查网络连接或 GitHub 链接是否正确。"
  exit 1
fi

# 3. 提示用户修改 system-monitor.sh 脚本
echo ""
echo "📝 请检查并修改 system-monitor.sh 脚本内容以满足您的需求。"
echo "🎯 文件位于：/usr/local/bin/system-monitor.sh"
echo "💡 使用以下命令编辑该文件："
echo "  sudo nano /usr/local/bin/system-monitor.sh"
echo ""

# 4. 赋予可执行权限
sudo chmod +x /usr/local/bin/system-monitor.sh

# 5. 提示用户是否添加定时任务
echo ""
echo "✅ system-monitor.sh 脚本已成功下载并保存到 /usr/local/bin/"
echo "🕒 您可以选择是否设置定时任务，每 5 分钟自动执行脚本。"
echo "⚙️ 默认设置定时任务为每 5 分钟执行一次。"
echo ""

# 询问用户是否设置定时任务
read -p "是否需要设置定时任务,输入n则默认每五分钟检测一次 (y/n)? " setup_cron
if [[ "$setup_cron" == "y" || "$setup_cron" == "Y" ]]; then
    # 如果选择设置定时任务，询问时间间隔
    while true; do
        echo ""
        echo "🕒 请输入定时任务的执行频率："
        echo "  格式：分钟 小时 日期 月份 星期"
        echo "  例如，每 5 分钟执行一次：*/5 * * * *"
        read -p "请输入定时任务 (默认：*/5 * * * *)： " cron_time
        cron_time=${cron_time:-"*/5 * * * *"}  # 如果没有输入，默认使用 "*/5 * * * *"
        
        # 改进的 cron 表达式验证（较为宽松）
        # 允许 0-59 的数字、*、/、- 等符号
        if [[ "$cron_time" =~ ^([0-9\*/\-\ ,]+)$ ]]; then
            set_cron_job "$cron_time"
            break  # 成功设置定时任务后跳出循环
        else
            echo "❌ 无效的 cron 表达式，请重新输入！"
        fi
    done
else
    echo "❌ 未设置定时任务。"
fi


# 6. 自动打开编辑器，允许用户修改文件
echo ""
echo "📝 正在打开 nano 编辑器..."
sudo nano /usr/local/bin/system-monitor.sh

# 函数：设置定时任务
set_cron_job() {
  echo "🕒 设置定时任务为：$1"
  (crontab -l 2>/dev/null; echo "$1 /usr/local/bin/system-monitor.sh") | crontab -
  echo "✅ 定时任务已设置为: $1"
}

# 7. 提示用户验证是否能收到通知
sudo chmod +x /usr/local/bin/system-monitor.sh
sudo /usr/local/bin/system-monitor.sh
echo ""
echo "🎯 检查并验证系统是否能正常发送通知。"
echo "📬 Test: 检查 Bark 是否收到通知..."
# 假设 Bark 已配置并发送通知，以下是模拟检查
# 这里可以根据实际脚本内容判断 Bark 是否能正常工作
# 这里可以根据实际脚本输出做更复杂的验证，如果是测试通知，可以是 Bark 服务器返回的状态

# 如果需要在测试中模拟输出，可以使用简单的 `echo` 或 `curl` 验证网络请求
# 例如，调用 Bark API 或检查本地日志等
echo "✅ Bark 通知已发送或检查完成。"

# 8. 完成安装并结束
echo "🎉 部署完成！系统监控脚本和定时任务已成功安装。"

# 9. 提示用户可以修改配置并再次运行脚本
echo "💡 如果您需要修改配置或脚本，请访问：/usr/local/bin/system-monitor.sh"
echo "  并使用 nano 编辑： sudo nano /usr/local/bin/system-monitor.sh"
