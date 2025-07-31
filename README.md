# ComfyUI Docker 项目

## 项目简介

这是一个基于Docker的ComfyUI部署项目，提供了完整的AI图像生成环境。项目使用Docker容器化技术，确保环境的一致性和可移植性，并集成了ComfyUI-Manager和中文翻译插件。

## 🚀 快速开始

### 环境要求

- **操作系统**：Windows 10/11, Linux, macOS
- **Docker**：Docker Desktop 或 Docker Engine
- **GPU**：NVIDIA GPU（推荐，支持CUDA）
- **内存**：至少8GB RAM（推荐16GB+）
- **存储**：至少20GB可用空间

### 一键启动

1. **克隆或下载项目**
   ```bash
   # 确保在项目根目录
   cd ComfyUI-test
   ```

2. **启动服务**
   ```bash
   docker-compose up -d
   ```

3. **访问ComfyUI**
   - 打开浏览器访问：`http://localhost:8188`
   - 等待几分钟让服务完全启动（包括插件安装）

## 📁 项目结构

```
ComfyUI-test/
├── Dockerfile                    # Docker镜像构建文件
├── docker-compose.yml           # Docker Compose配置文件
├── README.md                    # 项目说明文档
├── ComfyUI更新指南.md           # 详细更新指南
├── input/                       # 输入文件目录
│   └── 3d/                     # 3D模型输入
├── output/                      # 生成结果输出目录
├── user/                        # 用户配置和数据库
│   ├── comfyui.db              # ComfyUI数据库
│   ├── comfyui.log             # 日志文件
│   └── default/                # 默认配置
└── custom_nodes/               # 自定义节点和插件
    ├── ComfyUI-Manager/        # 插件管理器
    └── AIGODLIKE-COMFYUI-TRANSLATION/ # 中文翻译插件
```

## 🔧 配置说明

### 端口配置
- **外部端口**：8188
- **内部端口**：8188
- **修改端口**：编辑 `docker-compose.yml` 中的端口映射

### GPU支持
项目已配置NVIDIA GPU支持，确保：
1. 安装NVIDIA驱动
2. 安装nvidia-docker2
3. 容器会自动检测并使用GPU

### 网络配置
- **DNS设置**：已配置Google DNS (8.8.8.8, 8.8.4.4) 确保网络连接稳定
- **CA证书**：已安装并更新证书以支持HTTPS连接

### 数据持久化
以下目录已配置持久化存储：
- `./input` → `/ComfyUI/input`
- `./output` → `/ComfyUI/output`
- `./user` → `/ComfyUI/user`
- `./custom_nodes` → `/ComfyUI/custom_nodes`
- `comfyui_models` (Docker Volume) → `/ComfyUI/models`

## 🎯 主要功能

### 核心功能
- ✅ **文本生成图像**：Stable Diffusion系列模型
- ✅ **图像到图像**：基于输入图像生成新图像
- ✅ **视频生成**：支持多种视频生成模型
- ✅ **图像编辑**：修复、重绘、背景移除
- ✅ **3D处理**：3D模型生成和处理

### 集成插件
- **ComfyUI-Manager**：插件管理和模型下载
- **AIGODLIKE-COMFYUI-TRANSLATION**：中文翻译插件

## 📊 性能优化

### 推荐配置
- **CPU**：8核心以上
- **内存**：16GB+ RAM
- **GPU**：RTX 3060或更高
- **存储**：SSD硬盘，50GB+可用空间

### 性能调优
1. **GPU内存优化**
   ```bash
   # 在docker-compose.yml中调整GPU内存限制
   deploy:
     resources:
       reservations:
         devices:
           - driver: nvidia
             count: 1
             capabilities: [gpu]
   ```

2. **关于模型**
   - 建议使用SSD存储以提高加载速度
   - 模型文件存储在Docker Volume中，确保数据持久化的同时提升模型加载速度
   - 大型模型（如SDXL、ControlNet等）建议使用Docker Volume存储以获得最佳性能

3. **关于插件性能优化**
   - **Windows系统性能瓶颈**：Windows系统直接映射根目录会有性能瓶颈，特别是当插件数量较多时
   - **推荐解决方案**：
     ```yaml
     # 在docker-compose.yml中添加插件专用Volume
     volumes:
       - comfyui_plugins:/ComfyUI/custom_nodes
     ```
   - **适用场景**：
     - 插件数量超过10个
     - 插件包含大量模型文件
     - 插件频繁更新或重新加载
     - Windows系统用户
   - **性能提升**：
     - 插件加载速度提升30-50%
     - 减少文件系统I/O瓶颈
     - 提高容器启动速度
     - 更好的跨平台兼容性

4. **存储优化建议**
   ```yaml
   # 推荐的docker-compose.yml配置
   volumes:
     # 模型文件使用Docker Volume
     - comfyui_models:/ComfyUI/models
     # 插件文件使用Docker Volume（适用于大量插件）
     - comfyui_plugins:/ComfyUI/custom_nodes
     # 用户数据保持目录映射
     - ./user:/ComfyUI/user
     - ./input:/ComfyUI/input
     - ./output:/ComfyUI/output
   
   # 定义Docker Volumes
   volumes:
     comfyui_models:
       driver: local
     comfyui_plugins:
       driver: local
   ```

5. **性能监控**
   ```bash
   # 查看容器资源使用情况
   docker stats comfyui-0731
   
   # 查看存储使用情况
   docker exec comfyui-0731 df -h
   
   # 查看插件加载时间
   docker-compose logs | grep "Import times"
   ```

## 🔄 更新维护

### 快速更新
```bash
# 仅更新ComfyUI代码
docker exec comfyui-0731 git pull
docker-compose restart
```

### 完整更新
```bash
# 重新构建镜像
docker-compose build --no-cache
docker-compose up -d
```

详细更新指南请参考：[ComfyUI更新指南.md](./ComfyUI更新指南.md)

## 🛠️ 常用命令

### 容器管理
```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 进入容器
```bash
# 进入容器bash
docker exec -it comfyui-0731 bash

# 检查版本
docker exec comfyui-0731 python --version

# 退出容器
exit
```

### 数据管理
```bash
# 备份用户数据
cp -r user/ user_backup/

# 清理输出文件
rm -rf output/*

# 查看磁盘使用
docker exec comfyui-0731 df -h
```

### 搜索指定文件
```bash
# 例如搜索模板中的工作流
docker exec -it comfyui-hukaii find / -name "flux_kontext_dev_basic.json" 2>$null
# 例如输出：/opt/conda/lib/python3.11/site-packages/comfyui_workflow_templates/templates/flux_kontext_dev_basic.json

# 验证文件内容
docker exec -it comfyui-hukaii cat "/opt/conda/lib/python3.11/site-packages/comfyui_workflow_templates/templates/flux_kontext_dev_basic.json"

```

## 🐛 故障排除

### 常见问题

1. **容器启动失败**
   ```bash
   # 查看详细日志
   docker-compose logs
   
   # 检查端口占用
   netstat -an | findstr 8188
   ```

2. **GPU不可用**
   ```bash
   # 检查NVIDIA驱动
   nvidia-smi
   
   # 检查Docker GPU支持
   docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
   ```

3. **内存不足**
   - 增加系统虚拟内存
   - 减少Docker内存限制
   - 关闭其他占用内存的程序

4. **网络连接问题**
   - 检查DNS配置：容器已配置Google DNS
   - 检查CA证书：已安装ca-certificates
   - 检查防火墙设置

5. **插件安装失败**
   - 检查网络连接
   - 查看容器日志：`docker-compose logs`
   - 手动进入容器检查：`docker exec -it comfyui-0731 bash`

### 日志分析
```bash
# 查看实时日志
docker-compose logs -f comfyui

# 查看错误日志
docker-compose logs | grep ERROR

# 查看启动日志
docker-compose logs | grep "Starting"
```

## 📚 学习资源

### 官方文档
- [ComfyUI GitHub](https://github.com/comfyanonymous/ComfyUI)

## 🙏 致谢

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI) - 核心框架
- [ComfyUI-Manager](https://github.com/Comfy-Org/ComfyUI-Manager) - 插件管理
- [AIGODLIKE-COMFYUI-TRANSLATION](https://github.com/AIGODLIKE/AIGODLIKE-COMFYUI-TRANSLATION) - 中文翻译
- [Docker](https://www.docker.com/) - 容器化技术

---

**最后更新**：2025-07-31  
**版本**：v1.0.0  
**维护者**：@HuKaii