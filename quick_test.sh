#!/bin/bash

# 快速启动和测试脚本

echo "=== 乐语匣子歌曲留言功能快速测试 ==="

# 1. 检查后端服务状态
echo "1. 检查后端服务状态..."
if pgrep -f "spring-boot" > /dev/null; then
    echo "✓ 后端服务正在运行"
else
    echo "✗ 后端服务未运行"
    echo "正在启动后端服务..."
    cd /workspace/leyu-admin-backend
    nohup mvn spring-boot:run > /tmp/backend.log 2>&1 &
    echo "后端服务启动中，请稍等..."
    sleep 10
fi

# 2. 检查前端服务状态
echo "2. 检查前端服务状态..."
if pgrep -f "vite" > /dev/null; then
    echo "✓ 前端服务正在运行"
else
    echo "✗ 前端服务未运行"
    echo "正在启动前端服务..."
    cd /workspace/leyu-admin-web
    nohup npm run dev > /tmp/frontend.log 2>&1 &
    echo "前端服务启动中，请稍等..."
    sleep 5
fi

# 3. 检查数据库连接
echo "3. 检查数据库连接..."
if command -v mysql &> /dev/null; then
    echo "✓ MySQL 客户端已安装"

    # 检查数据库是否存在
    DB_EXISTS=$(mysql -u root -p123456 -e "USE leyu_music;" 2>&1 | grep -c "ERROR")
    if [ "$DB_EXISTS" -eq 0 ]; then
        echo "✓ 数据库 leyu_music 存在"

        # 检查表是否存在
        TABLE_EXISTS=$(mysql -u root -p123456 -D leyu_music -e "SHOW TABLES LIKE 't_song_comment';" 2>&1 | grep -c "t_song_comment")
        if [ "$TABLE_EXISTS" -gt 0 ]; then
            echo "✓ 表 t_song_comment 存在"
        else
            echo "✗ 表 t_song_comment 不存在，正在创建..."
            mysql -u root -p123456 -D leyu_music < /workspace/docs/song_comment_tables.sql
        fi
    else
        echo "✗ 数据库 leyu_music 不存在，请先创建数据库"
    fi
else
    echo "✗ MySQL 客户端未安装"
    echo "请手动执行 SQL 脚本：/workspace/manual_db_setup.sql"
fi

# 4. 测试后端API
echo "4. 测试后端API..."
sleep 5
API_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/admin/songComment/list?pageNum=1&pageSize=10)
if [ "$API_TEST" = "200" ] || [ "$API_TEST" = "401" ]; then
    echo "✓ 后端API可访问"
else
    echo "✗ 后端API访问失败 (HTTP $API_TEST)"
    echo "请检查后端服务状态"
fi

# 5. 检查端口占用
echo "5. 检查端口占用..."
if lsof -i :8080 > /dev/null 2>&1; then
    echo "✓ 端口8080 (后端) 正在使用"
else
    echo "✗ 端口8080 (后端) 未被使用"
fi

if lsof -i :3000 > /dev/null 2>&1; then
    echo "✓ 端口3000 (前端) 正在使用"
else
    echo "✗ 端口3000 (前端) 未被使用"
fi

# 6. 显示访问地址
echo ""
echo "=== 访问地址 ==="
echo "管理后台: http://localhost:3000"
echo "后端API文档: http://localhost:8080/doc.html"
echo "后端健康检查: http://localhost:8080/api/admin/songComment/list?pageNum=1&pageSize=10"

# 7. 显示日志查看命令
echo ""
echo "=== 查看日志 ==="
echo "后端日志: tail -f /tmp/backend.log"
echo "前端日志: tail -f /tmp/frontend.log"

echo ""
echo "=== 测试完成 ==="
echo "如果所有检查都通过，可以开始测试歌曲留言功能了！"
