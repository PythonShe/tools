中文 | [English](audio_en.md)

### 脚本列表

| 脚本 | 功能 | 输出格式 | 质量设置 |
|------|------|----------|----------|
| `lossless_to_flac.sh` | 多种无损格式转 FLAC | FLAC | 最高质量压缩 |
| `flac_to_aac.sh` | FLAC 转 AAC | M4A (AAC) | 320kbps, VBR 5 |
| `flac_to_mp3.sh` | FLAC 转 MP3 | MP3 | 320kbps CBR, q:a 0 |

### 支持的格式

**lossless_to_flac.sh** 支持以下无损格式：
- WAV
- APE
- ALAC (仅转换 M4A 中的 ALAC 编码，自动跳过 AAC)
- WavPack (WV)
- TTA

### 特性

- ✅ 批量转换当前目录下的所有匹配文件
- ✅ 自动跳过已存在的输出文件
- ✅ 保留原始元数据和封面图片
- ✅ 详细的转换进度提示
- ✅ 可选的源文件自动删除功能（默认保留）

### 使用方法

#### 方式一：直接运行脚本

```bash
cd /path/to/music/folder
bash /Users/zhengshe/Projects/Tools/bash_tools/audio/lossless_to_flac.sh
```

#### 方式二：安装到系统路径

将脚本复制到系统路径后可在任何目录直接使用：

```bash
# 安装脚本（需要管理员权限）
sudo cp bash_tools/audio/lossless_to_flac.sh /usr/local/bin/lossless_to_flac
sudo cp bash_tools/audio/flac_to_aac.sh /usr/local/bin/flac_to_aac
sudo cp bash_tools/audio/flac_to_mp3.sh /usr/local/bin/flac_to_mp3
sudo chmod +x /usr/local/bin/{lossless_to_flac,flac_to_aac,flac_to_mp3}

# 使用示例
cd /path/to/music/folder
lossless_to_flac  # 转换无损文件为 FLAC
flac_to_mp3       # 转换 FLAC 为 MP3
```

### 依赖

所有脚本依赖以下工具：
- `ffmpeg` - 音频转换
- `ffprobe` - 音频格式检测（lossless_to_flac.sh 需要）

macOS 安装：
```bash
brew install ffmpeg
```

Linux 安装：
```bash
# Debian/Ubuntu
sudo apt install ffmpeg

# Fedora/RHEL
sudo dnf install ffmpeg
```