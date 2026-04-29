-- 手动执行数据库脚本
-- 如果MySQL客户端不可用，请将此内容复制到MySQL客户端中执行

USE leyu_music;

-- 检查表是否存在，如果不存在则创建
CREATE TABLE IF NOT EXISTS t_song_comment (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评论ID',
    song_id BIGINT NOT NULL COMMENT '歌曲ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    content TEXT NOT NULL COMMENT '评论内容',
    likes INT DEFAULT 0 COMMENT '点赞数',
    status TINYINT DEFAULT 1 COMMENT '状态 0-已封禁 1-正常',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_song_id (song_id),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='歌曲评论表';

-- 检查字段是否存在，如果不存在则添加
SET @column_exists = (
    SELECT COUNT(*)
    FROM information_schema.columns
    WHERE table_schema = 'leyu_music'
    AND table_name = 't_comment'
    AND column_name = 'comment_type'
);

SET @sql = IF(@column_exists = 0,
    'ALTER TABLE t_comment ADD COLUMN comment_type TINYINT DEFAULT 1 COMMENT ''评论类型 1-乐语留言 2-歌曲留言''',
    'SELECT ''字段已存在，无需添加'' AS message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 显示创建结果
SELECT 't_song_comment 表创建/检查完成' AS result;
SELECT COUNT(*) AS comment_count FROM t_song_comment;
SELECT COUNT(*) AS comment_type_field_exists FROM information_schema.columns WHERE table_schema = 'leyu_music' AND table_name = 't_comment' AND column_name = 'comment_type';
