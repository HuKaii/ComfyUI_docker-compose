# 使用PyTorch官方镜像作为基础镜像
FROM pytorch/pytorch:2.7.1-cuda12.8-cudnn9-runtime

# 设置工作目录
WORKDIR /ComfyUI

# 设置apt使用清华源
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

# 安装必要的系统依赖
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libgcc-s1 \
    libstdc++6 \
    libc6-dev \
    build-essential \
    pkg-config \
    cmake \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 更新CA证书
RUN update-ca-certificates

# 设置pip使用清华源
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn

# 安装ComfyUI-Manager所需的Python包
RUN pip install --no-cache-dir uv gitpython

# 克隆ComfyUI最新版本
RUN git clone https://github.com/comfyanonymous/ComfyUI .

# 安装ComfyUI依赖
RUN pip3 install --no-cache-dir -r requirements.txt

# 设置工作目录权限
RUN chmod -R 777 /ComfyUI

# 暴露ComfyUI默认端口
EXPOSE 8188
