#!/bin/bash

# 数据库连接信息
DB_HOST="localhost"
DB_PORT="3306"
DB_USER="root"
DB_PASS="123456"
DB_NAME="leyu_music"

echo "正在检查数据库连接..."

# 检查数据库连接
if command -v mysql &> /dev/null; then
    echo "MySQL 客户端已安装"
else
    echo "MySQL 客户端未安装，请先安装 MySQL"
    exit 1
fi

# 检查数据库是否存在
echo "检查数据库 $DB_NAME 是否存在..."
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -e "USE $DB_NAME;" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "数据库 $DB_NAME 存在"
else
    echo "数据库 $DB_NAME 不存在，请先创建数据库"
    exit 1
fi

# 检查 t_song_comment 表是否存在
echo "检查表 t_song_comment 是否存在..."
TABLE_EXISTS=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -D $DB_NAME -se "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME' AND table_name='t_song_comment';" 2>/dev/null)

if [ "$TABLE_EXISTS" = "1" ]; then
    echo "表 t_song_comment 已存在"
    echo "表结构："
    mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -D $DB_NAME -e "DESCRIBE t_song_comment;" 2>/dev/null
else
    echo "表 t_song_comment 不存在，正在创建..."
    mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -D $DB_NAME < /workspace/docs/song_comment_tables.sql 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "表 t_song_comment 创建成功"
    else
        echo "表 t_song_comment 创建失败"
        exit 1
    fi
fi

# 检查 t_comment 表是否有 comment_type 字段
echo "检查表 t_comment 的 comment_type 字段..."
COLUMN_EXISTS=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -D $DB_NAME -se "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='$DB_NAME' AND table_name='t_comment' AND column_name='comment_type';" 2>/dev/null)

if [ "$COLUMN_EXISTS" = "1" ]; then
    echo "字段 t_comment.comment_type 已存在"
else
    echo "字段 t_comment.comment_type 不存在，正在添加..."
    mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -D $DB_NAME -e "ALTER TABLE t_comment ADD COLUMN comment_type TINYINT DEFAULT 1 COMMENT '评论类型 1-乐语留言 2-歌曲留言';" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "字段 t_comment.comment_type 添加成功"
    else
        echo "字段 t_comment.comment_type 添加失败"
    fi
fi

echo "数据库检查完成！"
