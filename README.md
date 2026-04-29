# 乐语匣子音乐平台

一个完整的音乐平台项目，包含管理后台、小程序端。

## 项目组成

| 项目 | 类型 | 技术栈 | 端口 |
|------|------|--------|------|
| leyu-admin-backend | 后端服务 | Spring Boot 3.2 + MyBatis-Plus + MySQL | 8080 |
| leyu-admin-web | 管理后台 | Vue.js (待开发) | 8081 |
| miniprogram | 微信小程序 | 原生小程序 | - |

## 快速部署指南

### 环境要求

- **Java 21** (后端，必须)
- **Maven 3.6+** (后端)
- **MySQL 8.0+** (数据库)
- **Node.js 16+** (管理后台)
- **微信开发者工具** (小程序)

### 步骤 1: 初始化数据库

```bash
# 登录 MySQL
mysql -u root -p

# 执行初始化脚本
source docs/database_init.sql
```

### 步骤 2: 启动后端服务

```bash
cd leyu-admin-backend

# 修改数据库配置 (如需要)
vi src/main/resources/application.yml

# 编译并运行
mvn spring-boot:run
```

后端启动成功后:
- API 服务: http://localhost:8080
- API 文档: http://localhost:8080/doc.html
- 默认管理员: `admin` / `admin123`

### 步骤 3: 运行小程序

1. 打开微信开发者工具
2. 导入 `miniprogram` 目录
3. 使用测试 AppID 或真实 AppID
4. 勾选「不校验合法域名」
5. 点击编译运行

## 已修复的问题

- ✅ 小程序 TabBar 图标缺失
- ✅ 数据库初始化脚本
- ✅ 后端项目升级到 Java 21 / Spring Boot 3.2
- ✅ javax.* → jakarta.* 包名迁移
- ✅ Spring Security 6 配置更新
- ✅ Swagger 2 → OpenAPI 3 注解迁移

## 目录结构

```
.
├── docs/                    # 文档
│   └── database_init.sql    # 数据库初始化脚本
├── leyu-admin-backend/      # 后端服务 (Spring Boot 3 + Java 21)
│   └── README.md            # 后端部署指南
├── leyu-admin-web/          # 管理后台 (待开发)
└── miniprogram/             # 微信小程序
    └── README.md            # 小程序开发指南
```
