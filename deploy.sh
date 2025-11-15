#!/bin/bash

# 简栈博客系统 Docker 部署脚本
# 支持构建、启动、停止、重启等操作

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 函数：输出信息
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 函数：检查Docker和Docker Compose
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker 未安装，请先安装 Docker"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
}

# 函数：构建镜像
build() {
    info "开始构建 Docker 镜像..."
    docker-compose build --no-cache
    info "Docker 镜像构建完成"
}

# 函数：启动服务
start() {
    info "开始启动服务..."
    docker-compose up -d
    info "服务启动完成"
    
    info "等待服务启动..."
    sleep 30
    
    # 检查服务状态
    if docker-compose ps | grep -q "Up"; then
        info "服务运行正常"
        info "前端访问地址: http://localhost:8080"
        info "MySQL 端口: 3306"
        info "Redis 端口: 6379"
    else
        error "服务启动失败，请检查日志"
        docker-compose logs
    fi
}

# 函数：停止服务
stop() {
    info "停止服务..."
    docker-compose down
    info "服务已停止"
}

# 函数：重启服务
restart() {
    info "重启服务..."
    docker-compose restart
    info "服务重启完成"
}

# 函数：查看日志
logs() {
    docker-compose logs -f
}

# 函数：查看状态
status() {
    docker-compose ps
}

# 函数：清理数据
clean() {
    warn "此操作将删除所有数据，包括数据库和Redis数据"
    read -p "确定要继续吗? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        docker-compose down -v
        docker system prune -f
        info "数据已清理"
    else
        info "取消清理操作"
    fi
}

# 主函数
main() {
    case "${1:-help}" in
        build)
            check_docker
            build
            ;;
        start)
            check_docker
            start
            ;;
        stop)
            check_docker
            stop
            ;;
        restart)
            check_docker
            restart
            ;;
        logs)
            check_docker
            logs
            ;;
        status)
            check_docker
            status
            ;;
        clean)
            check_docker
            clean
            ;;
        help|*)
            echo "使用方法: $0 {build|start|stop|restart|logs|status|clean|help}"
            echo ""
            echo "命令说明:"
            echo "  build   - 构建 Docker 镜像"
            echo "  start   - 启动所有服务"
            echo "  stop    - 停止所有服务"
            echo "  restart - 重启所有服务"
            echo "  logs    - 查看服务日志"
            echo "  status  - 查看服务状态"
            echo "  clean   - 清理所有数据和镜像"
            echo "  help    - 显示帮助信息"
            ;;
    esac
}

# 执行主函数
main "$@"