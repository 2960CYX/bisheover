# 简栈博客系统 Docker 部署文档

## 项目结构

本项目包含前端Vue3项目（RuoYi-Vue3）和后端Spring Boot项目（RuoYi-Vue），使用Docker进行容器化部署。

## 快速开始

### 1. 环境要求

- Docker 20.10+
- Docker Compose 1.29+
- 4GB以上内存（推荐8GB）

### 2. 构建和启动

```bash
# 给部署脚本添加执行权限
chmod +x deploy.sh

# 构建镜像
./deploy.sh build

# 启动服务
./deploy.sh start
```

### 3. 访问服务

- 前端访问：http://localhost:8080
- MySQL端口：3306
- Redis端口：6379

### 4. 服务管理

```bash
# 查看服务状态
./deploy.sh status

# 查看日志
./deploy.sh logs

# 重启服务
./deploy.sh restart

# 停止服务
./deploy.sh stop

# 清理数据（谨慎操作）
./deploy.sh clean
```

## Docker配置说明

### Dockerfile

使用多阶段构建：
1. **前端构建阶段**：基于Node.js 18，构建Vue3项目
2. **后端构建阶段**：基于Maven和OpenJDK 8，构建Spring Boot项目
3. **运行阶段**：基于OpenJDK 8 JRE，运行构建好的应用

### docker-compose.yml

包含三个服务：
- **app**：主应用服务（端口8080）
- **mysql**：MySQL数据库（端口3306）
- **redis**：Redis缓存（端口6379）

### .dockerignore

排除不需要打包的文件：
- 项目文档（*.md, README等）
- node_modules目录
- 构建缓存和临时文件
- IDE配置文件
- Git相关文件

## 数据库初始化

SQL文件会自动初始化到MySQL容器中，包括：
- 系统基础数据表
- 博客相关表结构
- 初始数据

## 环境变量

可以在docker-compose.yml中配置：
- `SPRING_PROFILES_ACTIVE`：Spring环境配置
- `SERVER_PORT`：服务端口
- MySQL和Redis的连接配置

## 数据持久化

- MySQL数据：挂载到`mysql_data`卷
- Redis数据：挂载到`redis_data`卷
- 应用日志：挂载到本地`./logs`目录

## 故障排查

### 查看容器日志
```bash
docker-compose logs [服务名]
```

### 进入容器
```bash
docker-compose exec app bash
```

### 检查端口占用
```bash
netstat -an | grep 8080
```

### 重新构建镜像
```bash
docker-compose build --no-cache
```

## 性能优化

### 调整JVM参数
在docker-compose.yml中添加：
```yaml
environment:
  - JAVA_OPTS=-Xms512m -Xmx1024m -XX:+UseG1GC
```

### 调整MySQL配置
在docker-compose.yml中添加：
```yaml
command: 
  --max_connections=200
  --innodb_buffer_pool_size=256M
```

## 安全建议

1. 修改默认的数据库密码
2. 配置防火墙规则
3. 使用HTTPS（生产环境）
4. 定期备份数据
5. 更新基础镜像版本

## 更新部署

```bash
# 拉取最新代码
git pull

# 重新构建
./deploy.sh build

# 重启服务
./deploy.sh restart
```