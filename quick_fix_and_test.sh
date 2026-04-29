#!/bin/bash

# 快速修复和测试脚本

echo "=== 快速修复和测试 ==="

# 1. 执行数据库脚本
echo "1. 执行数据库脚本..."
if command -v mysql &> /dev/null; then
    mysql -u root -p123456 < /workspace/docs/ensure_database.sql
    if [ $? -eq 0 ]; then
        echo "✓ 数据库脚本执行成功"
    else
        echo "✗ 数据库脚本执行失败，请手动执行 /workspace/docs/ensure_database.sql"
    fi
else
    echo "⚠ MySQL客户端未安装，请手动执行SQL脚本"
fi

# 2. 重启后端服务
echo ""
echo "2. 重启后端服务..."
# 杀掉现有进程
pkill -f "spring-boot"
sleep 2

# 启动后端服务
cd /workspace/leyu-admin-backend
nohup mvn spring-boot:run > /tmp/backend.log 2>&1 &
echo "后端服务启动中，请稍等..."
sleep 15

# 3. 测试管理员登录
echo ""
echo "3. 测试管理员登录..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8080/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}')

echo "登录响应: $LOGIN_RESPONSE"

if echo "$LOGIN_RESPONSE" | grep -q '"code":200'; then
    echo "✓ 管理员登录成功"

    # 提取token
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

    if [ -n "$TOKEN" ]; then
        echo "✓ 获取Token成功"

        # 4. 测试管理员API
        echo ""
        echo "4. 测试管理员API访问..."
        API_RESULT=$(curl -s -X GET "http://localhost:8080/api/admin/songComment/list?pageNum=1&pageSize=10" \
          -H "Authorization: Bearer $TOKEN")

        echo "API响应: $API_RESULT"

        if echo "$API_RESULT" | grep -q '"code":200'; then
            echo "✓ 管理员API访问成功！"
        else
            echo "✗ 管理员API访问失败"
        fi

        # 5. 测试歌曲分类获取
        echo ""
        echo "5. 测试歌曲分类获取..."
        CATEGORY_RESULT=$(curl -s -X GET "http://localhost:8080/api/admin/songComment/categories" \
          -H "Authorization: Bearer $TOKEN")

        echo "分类响应: $CATEGORY_RESULT"
    else
        echo "✗ 无法获取Token"
    fi
else
    echo "✗ 管理员登录失败"
fi

# 6. 测试微信登录
echo ""
echo "6. 测试微信登录..."
WX_LOGIN_RESULT=$(curl -s -X POST "http://localhost:8080/api/user/wxLogin?code=test_code_12345")

echo "微信登录响应: $WX_LOGIN_RESULT"

if echo "$WX_LOGIN_RESULT" | grep -q '"code":200'; then
    echo "✓ 微信登录测试成功（模拟模式）"
else
    echo "⚠ 微信登录响应: $WX_LOGIN_RESULT"
fi

# 7. 显示访问地址
echo ""
echo "=== 访问地址 ==="
echo "管理后台: http://localhost:3000"
echo "后端API文档: http://localhost:8080/doc.html"
echo ""
echo "=== 管理员账户信息 ==="
echo "用户名: admin"
echo "密码: admin123"
echo ""
echo "=== 测试完成 ==="
echo "如果所有测试都通过，功能应该正常工作了！"
