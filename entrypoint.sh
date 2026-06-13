#!/bin/bash

# ---- 端口选择逻辑 ----
# 1. 优先读取 TTYD_PORT 环境变量
# 2. 如果没设置，尝试读取 PORT 环境变量 (通用标准)
# 3. 如果都没设置，默认回退到 7860
SERVER_PORT="${TTYD_PORT:-${PORT:-7860}}"

# ---- 密码检查逻辑 ----
if [ -z "$LOGIN_PASSWORD" ]; then
    echo "Error: You must set the LOGIN_PASSWORD environment variable." >&2
    exit 1
fi

# 设置 root 密码
echo "root:$LOGIN_PASSWORD" | chpasswd

# ---- 启动 ttyd ----
echo "Starting ttyd on port ${SERVER_PORT}..."

# -p 使用我们需要监听的端口
# -W 允许写入 (关键！否则无法输入)
exec ttyd -p "${SERVER_PORT}" -W login
