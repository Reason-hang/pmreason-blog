#!/bin/bash
# pmreason.top 一键激活脚本（支持 SUDO_PASSWORD 环境变量）

set -e

# 如果 HERMES_HOME 和 SUDO_PASSWORD 在 .env 里，自动读取
if [ -z "$SUDO_PASSWORD" ] && [ -f /home/hermes/.hermes/.env ]; then
    source /home/hermes/.hermes/.env 2>/dev/null || true
fi

SUDO="sudo"
if [ -n "$SUDO_PASSWORD" ]; then
    SUDO="echo \"$SUDO_PASSWORD\" | sudo -S -p ''"
fi

echo "📋 1. 复制 nginx 配置..."
eval $SUDO cp /home/hermes/blog/pmreason.nginx.conf /etc/nginx/conf.d/pmreason.top.conf

echo "📋 2. 测试 nginx 配置..."
eval $SUDO nginx -t

echo "📋 3. 重载 nginx..."
eval $SUDO nginx -s reload

echo "📋 4. 创建日志目录..."
mkdir -p /home/hermes/logs

echo ""
echo "✅ Nginx 配置完成！"
echo ""
echo "访问: https://pmreason.top"
echo "编辑: https://pmreason.top/editor/"
echo "  用户名: admin"
echo "  密码: test123"
echo ""
echo "⚠️  接下来做 Cloudflare 面板设置："
echo "   1. DNS → A记录 → 65.49.220.186（橙色云ON）"
echo "   2. SSL/TLS → Flexible"
