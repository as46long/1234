#!/bin/bash

# 快速诊断和修复403错误

echo "=== 管理员权限问题诊断 ==="

# 1. 检查后端服务状态
echo "1. 检查后端服务..."
if pgrep -f "spring-boot" > /dev/null; then
    echo "✓ 后端服务正在运行"
else
    echo "✗ 后端服务未运行，请先启动后端服务"
    exit 1
fi

# 2. 测试管理员登录
echo "2. 测试管理员登录..."
LOGIN_RESULT=$(curl -s -X POST http://localhost:8080/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}')

echo "登录响应: $LOGIN_RESULT"

# 检查是否登录成功
if echo "$LOGIN_RESULT" | grep -q '"code":200'; then
    echo "✓ 管理员登录成功"

    # 提取token
    TOKEN=$(echo "$LOGIN_RESULT" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

    if [ -n "$TOKEN" ]; then
        echo "✓ 获取Token成功: ${TOKEN:0:30}..."

        # 3. 测试API访问
        echo "3. 测试管理员API访问..."
        API_RESULT=$(curl -s -X GET "http://localhost:8080/api/admin/songComment/list?pageNum=1&pageSize=10" \
          -H "Authorization: Bearer $TOKEN")

        echo "API响应: $API_RESULT"

        if echo "$API_RESULT" | grep -q '"code":200'; then
            echo "✓ API访问成功，问题已解决！"
            echo ""
            echo "请使用以下信息访问管理后台："
            echo "用户名: admin"
            echo "密码: admin123"
            echo "Token: $TOKEN"
            echo ""
            echo "在前端登录时，请确保使用 admin/admin123"
        else
            echo "✗ API访问失败"
            echo "错误详情: $API_RESULT"
            echo ""
            echo "可能的解决方案："
            echo "1. 检查数据库表是否已创建"
            echo "2. 查看后端日志: tail -f /workspace/leyu-admin-backend/logs/spring.log"
            echo "3. 检查Spring Security配置"
        fi
    else
        echo "✗ 无法从登录响应中提取Token"
    fi
else
    echo "✗ 管理员登录失败"
    echo "错误: $LOGIN_RESULT"
    echo ""
    echo "请检查："
    echo "1. 数据库中是否存在admin账户"
    echo "2. admin账户密码是否为admin123"
    echo "3. 数据库连接是否正常"
    echo ""
    echo "可以尝试重置管理员密码："
    echo "执行SQL: UPDATE t_admin SET password = '\$2a\$10\$UMJqo3WtbiBxgATqrn58Se5.tZdR3d6VV3MtcDgM7xssKPcdcXW8G' WHERE username = 'admin';"
fi

# 4. 检查数据库连接
echo ""
echo "4. 检查数据库连接..."
if command -v mysql &> /dev/null; then
    DB_CHECK=$(mysql -u root -p123456 -D leyu_music -e "SELECT COUNT(*) FROM t_admin WHERE username='admin';" 2>/dev/null | tail -1)
    if [ "$DB_CHECK" = "1" ]; then
        echo "✓ 数据库中存在admin账户"
    else
        echo "✗ 数据库中不存在admin账户，正在创建..."

        # 重新执行数据库初始化脚本
        mysql -u root -p123456 -D leyu_music -e "
        INSERT INTO t_admin (username, password, role, status)
        VALUES ('admin', '\$2a\$10\$UMJqo3WtbiBxgATqrn58Se5.tZdR3d6VV3MtcDgM7xssKPcdcXW8G', 'ADMIN', 1)
        ON DUPLICATE KEY UPDATE role='ADMIN', status=1;
        " 2>/dev/null

        if [ $? -eq 0 ]; then
            echo "✓ admin账户创建成功"
        else
            echo "✗ admin账户创建失败"
        fi
    fi
else
    echo "⚠ MySQL客户端未安装，无法检查数据库"
fi

echo ""
echo "=== 诊断完成 ==="
