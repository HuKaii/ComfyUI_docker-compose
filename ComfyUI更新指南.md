# ComfyUI Docker容器更新指南

## 概述

本文档介绍如何更新基于Docker的ComfyUI环境到最新版本。适用于使用Dockerfile和docker-compose.yml部署的ComfyUI容器。

## 更新方法

### 方法一：重新构建镜像（推荐）

这是最彻底的方法，会获取最新的ComfyUI代码和所有依赖。

#### 步骤：

1. **停止当前容器**
   ```bash
   docker-compose down
   ```

2. **重新构建镜像（不使用缓存）**
   ```bash
   docker-compose build --no-cache
   ```

3. **启动更新后的容器**
   ```bash
   docker-compose up -d
   ```

4. **验证容器状态**
   ```bash
   docker-compose ps
   ```

5. **查看启动日志**
   ```bash
   docker-compose logs --tail=20
   ```

#### 更新内容：
- ✅ ComfyUI核心：从GitHub获取最新代码
- ✅ ComfyUI-Manager插件：自动安装最新版本
- ✅ AIGODLIKE-COMFYUI-TRANSLATION插件：自动安装最新版本
- ✅ Python依赖：重新安装最新依赖包（包括uv、gitpython等）

### 方法二：仅更新ComfyUI代码（快速更新）

如果只需要更新ComfyUI核心代码，可以使用此方法：

#### 步骤详解：

1. **检查容器状态**
   ```bash
   docker-compose ps
   ```

2. **更新ComfyUI代码**
   ```bash
   docker exec comfyui-0731 git pull
   ```

3. **检查更新结果**
   ```bash
   # 查看最新提交
   docker exec comfyui-0731 git log --oneline -5
   
   # 查看当前版本
   docker exec comfyui-0731 git describe --tags
   ```

4. **重启容器（如果需要）**
   ```bash
   docker-compose restart
   ```

#### 方法二的优势：
✅ **速度快**：不需要重新构建整个镜像  
✅ **资源消耗少**：只更新代码，不重新安装依赖  
✅ **数据安全**：不会影响已安装的模型和配置  
✅ **适合频繁更新**：当ComfyUI有小的代码更新时使用  

#### 使用场景：
- ComfyUI有小的bug修复
- 新功能发布
- 不需要更新Python依赖的情况
- 快速测试最新代码

#### 注意事项：
⚠️ **局限性**：此方法只更新ComfyUI核心代码，不会更新：
- Python依赖包
- 插件代码
- 系统级依赖

### 方法三：更新特定插件

如果需要更新特定的插件：

```bash
# 更新ComfyUI-Manager插件
docker exec comfyui-0731 bash -c "cd custom_nodes/ComfyUI-Manager && git pull"

# 更新AIGODLIKE-COMFYUI-TRANSLATION插件
docker exec comfyui-0731 bash -c "cd custom_nodes/AIGODLIKE-COMFYUI-TRANSLATION && git pull"

# 重启容器
docker-compose restart
```

## 访问方式

更新完成后，通过以下方式访问ComfyUI：

- **浏览器访问**：`http://localhost:8188`
- **数据持久化**：您的模型、工作流、用户配置等数据都保持不变（通过volume挂载）

## 文件结构

```
ComfyUI-test/
├── Dockerfile                    # Docker镜像构建文件
├── docker-compose.yml           # Docker Compose配置文件
├── input/                       # 输入目录（持久化）
├── output/                      # 输出目录（持久化）
├── user/                        # 用户配置目录（持久化）
└── custom_nodes/               # 插件目录（持久化）
```

## 常用命令

### 容器管理
```bash
# 启动容器
docker-compose up -d

# 停止容器
docker-compose down

# 查看容器状态
docker-compose ps

# 查看容器日志
docker-compose logs -f

# 重启容器
docker-compose restart
```

### 镜像管理
```bash
# 重新构建镜像
docker-compose build

# 重新构建镜像（不使用缓存）
docker-compose build --no-cache

# 查看镜像
docker images

# 删除镜像
docker rmi comfyui:latest
```

### 进入容器
```bash
# 进入容器bash
docker exec -it comfyui-0731 bash

# 执行特定命令
docker exec comfyui-0731 python --version
```

## 注意事项

1. **数据安全**：更新过程中，通过volume挂载的数据（模型、配置等）不会丢失
2. **端口映射**：确保8188端口没有被其他服务占用
3. **GPU支持**：确保Docker支持GPU访问（需要nvidia-docker）
4. **网络连接**：更新过程需要稳定的网络连接来下载依赖
5. **DNS配置**：已配置Google DNS（8.8.8.8, 8.8.4.4）以确保网络连接稳定
6. **插件性能优化**：
   - Windows系统用户建议使用Docker Volume存储插件文件
   - 当插件数量超过10个时，使用Volume可提升30-50%的加载速度
   - 配置示例：
     ```yaml
     volumes:
       - comfyui_plugins:/ComfyUI/custom_nodes
     ```

## 性能优化配置

### 插件性能优化

对于大量插件或Windows系统用户，建议使用Docker Volume存储插件文件：

```yaml
# 在docker-compose.yml中修改
services:
  comfyui:
    volumes:
      # 使用Docker Volume存储插件
      - comfyui_plugins:/ComfyUI/custom_nodes
      # 其他目录保持不变
      - comfyui_models:/ComfyUI/models
      - ./input:/ComfyUI/input
      - ./output:/ComfyUI/output
      - ./user:/ComfyUI/user

volumes:
  comfyui_models:
    driver: local
  comfyui_plugins:
    driver: local
```

### 适用场景
- 插件数量超过10个
- Windows系统用户
- 插件包含大量模型文件
- 需要频繁更新插件

### 性能提升效果
- 插件加载速度提升30-50%
- 减少文件系统I/O瓶颈
- 提高容器启动速度
- 更好的跨平台兼容性

## 故障排除

### 常见问题

1. **构建失败**
   - 检查网络连接
   - 清理Docker缓存：`docker system prune -a`
   - 重新构建：`docker-compose build --no-cache`

2. **容器启动失败**
   - 查看日志：`docker-compose logs`
   - 检查端口占用：`netstat -an | findstr 8188`
   - 检查GPU驱动：`nvidia-smi`

3. **插件更新失败**
   - 手动进入容器更新：`docker exec -it comfyui-0731 bash`
   - 检查插件目录权限

4. **方法二更新失败**
   - 检查网络连接：`docker exec comfyui-0731 ping github.com`
   - 检查Git状态：`docker exec comfyui-0731 git status`
   - 强制更新：`docker exec comfyui-0731 git fetch --all && git reset --hard origin/master`

5. **网络连接问题**
   - 检查DNS配置：容器已配置Google DNS
   - 检查CA证书：已安装ca-certificates并更新证书
   - 检查防火墙设置

### 日志查看
```bash
# 查看实时日志
docker-compose logs -f

# 查看最近20行日志
docker-compose logs --tail=20

# 查看特定服务的日志
docker-compose logs comfyui
```

## 版本信息

- **基础镜像**：pytorch/pytorch:2.7.1-cuda12.8-cudnn9-runtime
- **ComfyUI**：最新版本（从GitHub获取）
- **端口**：8188（外部）-> 8188（内部）
- **GPU支持**：NVIDIA GPU（通过docker-compose.yml配置）
- **容器名称**：comfyui-0731
- **DNS配置**：Google DNS (8.8.8.8, 8.8.4.4)

## 快速参考

### 更新命令速查

| 更新类型 | 命令 | 说明 |
|---------|------|------|
| 完整更新 | `docker-compose build --no-cache && docker-compose up -d` | 重新构建镜像，更新所有内容 |
| 快速更新 | `docker exec comfyui-0731 git pull && docker-compose restart` | 仅更新ComfyUI代码 |
| 插件更新 | `docker exec comfyui-0731 bash -c "cd custom_nodes/插件名 && git pull"` | 更新特定插件 |

### 状态检查命令

```bash
# 检查容器状态
docker-compose ps

# 检查ComfyUI版本
docker exec comfyui-0731 git describe --tags

# 检查插件状态
docker exec comfyui-0731 ls -la custom_nodes/

# 查看容器日志
docker-compose logs --tail=20
```

---

*最后更新：2025-07-31* 