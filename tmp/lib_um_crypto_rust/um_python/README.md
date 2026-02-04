# um-python

Kuwo音乐文件解密库 - Python绑定版本

## 简介

`um-python` 是一个用于解密Kuwo音乐文件的Python库，基于Rust高性能实现。

## 功能特性

- 🔒 支持Kuwo音乐文件解密
- 🚀 基于Rust的高性能实现
- 🐍 提供Python友好的API接口
- 📦 跨平台支持（Windows、macOS、Linux）

## 安装

### 从PyPI安装（推荐）

```bash
pip install um-python
```

### 从源码安装

```bash
# 需要安装Rust和maturin
pip install maturin
pip install .
```

## 快速开始

```python
import um_python

# 创建Kuwo头部解析器
header_data = b'...'  # Kuwo文件头部数据
header = um_python.KuwoHeader(header_data)

# 创建解密器
decipher = um_python.KuwoDecipher(header, None)

# 解密数据
encrypted_data = b'...'  # 加密的音乐数据
decrypted_data = decipher.decrypt(encrypted_data, 0)

print("解密成功！")
```

## API参考

### KuwoHeader

Kuwo文件头部解析器

```python
header = um_python.KuwoHeader(header_data)
print(f"质量ID: {header.quality_id}")
print(f"资源ID: {header.resource_id}")
print(f"版本号: {header.version}")
```

### KuwoDecipher

Kuwo文件解密器

```python
# 创建解密器
decipher = um_python.KuwoDecipher(header, ekey=None)

# 解密数据
decrypted = decipher.decrypt(data, offset)

# 原地解密
decrypted = decipher.decrypt_inplace(data, offset)
```

### create_v2_cipher

创建V2版本解密器

```python
decipher = um_python.create_v2_cipher(ekey)
```

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request！

## 支持

如有问题请访问：[项目主页](https://github.com/yourusername/um-python)