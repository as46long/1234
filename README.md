# 乐语匣子 - 后端服务

## 环境要求

- **Java 21** (必须)
- **Maven 3.6+**
- **MySQL 8.0+**

## 技术栈

- Spring Boot 3.2.2
- MyBatis-Plus 3.5.5
- Spring Security 6
- JWT (jjwt 0.12.5)
- Knife4j (OpenAPI 3)

## 快速开始

### 1. 安装依赖

```bash
# macOS
brew install openjdk@21
brew install maven

# Ubuntu/Debian
sudo apt install openjdk-21-jdk maven

# CentOS/RHEL
sudo yum install java-21-openjdk-devel maven
```

### 2. 创建数据库

```bash
# 登录 MySQL
mysql -u root -p

# 执行初始化脚本
source docs/database_init.sql
```

或者手动创建:
```sql
CREATE DATABASE IF NOT EXISTS leyu_music DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 3. 修改配置

编辑 `src/main/resources/application.yml`，修改数据库连接信息:

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/leyu_music?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai
    username: root
    password: 你的密码
```

### 4. 编译运行

```bash
# 编译项目
mvn clean package -DskipTests

# 运行项目
java -jar target/leyu-admin-backend-1.0.0.jar
```

或者在开发环境直接运行:
```bash
mvn spring-boot:run
```

### 5. 访问服务

- 后端服务: http://localhost:8080
- API 文档: http://localhost:8080/doc.html

默认管理员账号: `admin` / `admin123`

## 项目结构

```
leyu-admin-backend/
├── src/main/java/com/leyu/
│   ├── config/          # 配置类
│   ├── controller/      # 控制器
│   ├── entity/          # 实体类
│   ├── mapper/          # MyBatis Mapper
│   ├── service/         # 服务层
│   ├── vo/              # 视图对象
│   ├── dto/             # 数据传输对象
│   ├── security/        # 安全相关
│   ├── utils/           # 工具类
│   └── recommendation/   # 推荐算法
└── src/main/resources/
    ├── application.yml  # 配置文件
    └── mapper/          # MyBatis XML
```

## 已适配 Java 21 的变更

- Spring Boot 3.2.2
- javax.* → jakarta.* 包名迁移
- Spring Security 6 新语法
- Swagger 2 → OpenAPI 3 注解
- jjwt 0.12.x 新 API

## 常见问题

### 1. Java 版本不正确

错误信息: `unsupported class file major version 65`

解决方案: 确保 Java 21 已安装并配置正确

```bash
java -version  # 应显示 21.x.x
```

### 2. Maven 未安装

错误信息: `mvn: command not found`

解决方案: 安装 Maven 3.6 或更高版本

### 3. 数据库连接失败

检查:
- MySQL 服务是否启动
- 数据库 `leyu_music` 是否存在
- 用户名密码是否正确
