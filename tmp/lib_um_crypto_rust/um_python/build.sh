#!/bin/bash

# um_python 一键构建脚本
# 自动构建并安装Python扩展模块

set -e

echo "=== um_python 构建脚本 ==="
echo

# 检查依赖
echo "1. 检查依赖..."

# 检查Rust
if ! command -v cargo &> /dev/null; then
    echo "✗ 未找到Rust，请先安装Rust:"
    echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

# 检查Python
if ! command -v python3 &> /dev/null; then
    echo "✗ 未找到Python3"
    exit 1
fi

echo "✓ 依赖检查通过"
echo

# 创建虚拟环境
echo "2. 创建虚拟环境..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "✓ 虚拟环境创建成功"
else
    echo "✓ 虚拟环境已存在"
fi

# 激活虚拟环境
source venv/bin/activate

# 安装maturin和twine（用于发布）
if ! command -v maturin &> /dev/null; then
    echo "⚠ 安装maturin..."
    pip install maturin
fi

if ! command -v twine &> /dev/null; then
    echo "⚠ 安装twine..."
    pip install twine
fi

echo "✓ 虚拟环境设置完成"
echo

# 构建
echo "3. 构建Python扩展模块..."
# 启用ABI3向前兼容性以支持Python 3.13
export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1
maturin build --release

if [ $? -ne 0 ]; then
    echo "✗ 构建失败"
    exit 1
fi

echo "✓ 构建成功"
echo

# 安装
echo "4. 安装模块..."
WHEEL_FILE=$(find ../target/wheels -name "um_python-*.whl" | head -1)

if [ -z "$WHEEL_FILE" ]; then
    echo "✗ 未找到wheel文件"
    exit 1
fi

echo "找到wheel文件: $WHEEL_FILE"

# 在虚拟环境中安装
pip install "$WHEEL_FILE"

if [ $? -ne 0 ]; then
    echo "✗ 安装失败"
    exit 1
fi

echo "✓ 安装成功"
echo

# 基本验证
echo "5. 验证模块..."
python -c "
import um_python
print('✓ um_python模块导入成功')
print('版本:', um_python.__version__)
print('✅ 模块验证完成')
"

echo

# 发布选项
echo "6. 发布选项（可选）..."
echo "   1) 仅构建"
echo "   2) 构建并上传到PyPI测试服务器"
echo "   3) 构建并上传到PyPI正式服务器"
read -p "请选择操作 (1-3, 默认1): " choice

case "${choice:-1}" in
    1)
        echo "✓ 构建完成，wheel文件位置: ../target/wheels/"
        ;;
    2)
        echo "上传到PyPI测试服务器..."
        twine upload --repository-url https://test.pypi.org/legacy/ ../target/wheels/um_python-*.whl
        echo "✓ 已上传到PyPI测试服务器"
        ;;
    3)
        echo "上传到PyPI正式服务器..."
        twine upload ../target/wheels/um_python-*.whl
        echo "✓ 已上传到PyPI正式服务器"
        ;;
    *)
        echo "✓ 构建完成"
        ;;
esac

echo
echo "使用方法："
echo "  1. 激活虚拟环境："
echo "     source venv/bin/activate"
echo "  2. 运行示例："
echo "     python example_usage.py"
echo "     python example_usage.py <input_file> [output_file] [ekey]"
echo
echo "示例："
echo "  source venv/bin/activate"
echo "  python example_usage.py song.mflac song.flac"
echo
echo "发布说明："
echo "  1. 本地发布：使用上述发布选项"
echo "  2. 确保已配置PyPI账户："
echo "     ~/.pypirc 文件包含API令牌"
echo
echo "退出虚拟环境："
echo "  deactivate"
echo
echo "=== 构建完成 ==="