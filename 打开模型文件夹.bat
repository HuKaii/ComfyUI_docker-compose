@echo off
chcp 65001 >nul
echo 正在查找 ComfyUI 模型文件夹...

REM 查找 Docker Volume 的物理路径
for /f "tokens=*" %%i in ('docker volume inspect comfyui-test_comfyui_models --format "{{.Mountpoint}}" 2^>nul') do set VOLUME_PATH=%%i

if "%VOLUME_PATH%"=="" (
    echo 错误：找不到 comfyui-test_comfyui_models volume
    echo 请确保 Docker 正在运行且已创建该 volume
    pause
    exit /b 1
)

echo 找到模型文件夹路径: %VOLUME_PATH%

REM 将 Linux 路径转换为 WSL 路径
set WSL_PATH=%VOLUME_PATH:/var/lib/docker/volumes/=%
set WSL_PATH=%WSL_PATH:/_data=%
set WSL_PATH=\\wsl.localhost\docker-desktop\mnt\docker-desktop-disk\data\docker\volumes\%WSL_PATH%\_data

echo 转换后的 WSL 路径: %WSL_PATH%
echo 正在打开资源管理器...

REM 打开资源管理器
start "" "%WSL_PATH%"

echo 模型文件夹已打开！
pause 