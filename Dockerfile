# 使用Node.js镜像构建前端
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend

# 设置npm国内镜像源
RUN npm config set registry https://registry.npmmirror.com

# 复制前端package.json并安装依赖
COPY new-version/admin/RuoYi-Vue3/package.json ./
RUN npm install

# 复制前端源码并构建
COPY new-version/admin/RuoYi-Vue3/ ./
RUN npm run build:prod

# 使用Maven镜像构建Java后端
FROM maven:3.8.6-openjdk-8 AS backend-builder

WORKDIR /app/backend

# 设置Maven国内镜像源
RUN sed -i 's|https://repo.maven.apache.org/maven2|https://maven.aliyun.com/repository/central|g' /usr/share/maven/conf/settings.xml

# 复制后端pom.xml
COPY new-version/api/RuoYi-Vue/pom.xml ./
COPY new-version/api/RuoYi-Vue/ruoyi-admin/pom.xml ./ruoyi-admin/
COPY new-version/api/RuoYi-Vue/ruoyi-common/pom.xml ./ruoyi-common/
COPY new-version/api/RuoYi-Vue/ruoyi-framework/pom.xml ./ruoyi-framework/
COPY new-version/api/RuoYi-Vue/ruoyi-generator/pom.xml ./ruoyi-generator/
COPY new-version/api/RuoYi-Vue/ruoyi-quartz/pom.xml ./ruoyi-quartz/
COPY new-version/api/RuoYi-Vue/ruoyi-system/pom.xml ./ruoyi-system/

# 复制源码
COPY new-version/api/RuoYi-Vue/ruoyi-admin/src ./ruoyi-admin/src
COPY new-version/api/RuoYi-Vue/ruoyi-admin/src/main/resources ./ruoyi-admin/src/main/resources
COPY new-version/api/RuoYi-Vue/ruoyi-common/src ./ruoyi-common/src
COPY new-version/api/RuoYi-Vue/ruoyi-framework/src ./ruoyi-framework/src
COPY new-version/api/RuoYi-Vue/ruoyi-generator/src ./ruoyi-generator/src
COPY new-version/api/RuoYi-Vue/ruoyi-quartz/src ./ruoyi-quartz/src
COPY new-version/api/RuoYi-Vue/ruoyi-system/src ./ruoyi-system/src

# 构建后端项目
RUN mvn clean package -DskipTests

# 最终运行阶段
FROM openjdk:8-jre-alpine

# 安装必要的工具
RUN apk add --no-cache curl bash

WORKDIR /app

# 创建必要的目录
RUN mkdir -p /app/frontend/dist /app/backend /app/sql /app/config /app/logs

# 复制构建好的前端文件
COPY --from=frontend-builder /app/frontend/dist/* /app/frontend/dist/

# 复制构建好的后端jar包
COPY --from=backend-builder /app/backend/ruoyi-admin/target/ruoyi-admin.jar /app/backend/

# 复制SQL文件
COPY new-version/*.sql /app/sql/
COPY new-version/api/RuoYi-Vue/sql/*.sql /app/sql/

# 复制配置文件
COPY new-version/api/RuoYi-Vue/ruoyi-admin/src/main/resources/application.yml /app/config/
COPY new-version/api/RuoYi-Vue/ruoyi-admin/src/main/resources/application-druid.yml /app/config/
COPY new-version/api/RuoYi-Vue/ruoyi-admin/src/main/resources/logback.xml /app/config/

# 创建启动脚本
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'echo "正在启动简栈博客系统..."' >> /app/start.sh && \
    echo 'echo "Java版本: $(java -version)"' >> /app/start.sh && \
    echo 'echo "启动后端服务..."' >> /app/start.sh && \
    echo 'java -jar /app/backend/ruoyi-admin.jar --spring.config.location=/app/config/ --logging.config=/app/config/logback.xml' >> /app/start.sh && \
    chmod +x /app/start.sh

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD curl -f http://localhost:8080/login || exit 1

# 设置工作目录和启动命令
WORKDIR /app
CMD ["./start.sh"]