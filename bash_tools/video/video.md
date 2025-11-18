中文 | [English](video_en.md)

# 视频处理工具集

一套基于 FFmpeg 的视频批量处理脚本，支持硬件加速编码。

## 脚本列表

| 脚本 | 功能 | 输出格式 | 质量设置 |
|------|------|----------|----------|
| `to_mp4.sh` | 多格式转 MP4 | MP4 (H.265) | CRF 23, AAC 320kbps |
| `compress_video.sh` | 视频压缩 | MP4 (H.265) | CRF 28, AAC 320kbps |
| `extract_audio.sh` | 提取音频 | M4A (AAC) | AAC 320kbps |
| `resize_video.sh` | 调整分辨率 | MP4 (H.265) | CRF 23, AAC 320kbps |
| `crop_video.sh` | 裁剪画面 | MP4 (H.265) | CRF 23, AAC 320kbps |
| `rotate_video.sh` | 旋转视频 | MP4 (H.265) | CRF 23, AAC 320kbps |
| `merge_videos.sh` | 合并视频 | MP4 (H.265) | CRF 23, AAC 320kbps |

## 硬件加速支持

脚本会自动检测系统类型并选择合适的硬件编码器：

- **macOS**: 使用 VideoToolbox (`hevc_videotoolbox`)
- **Windows/Linux**: 使用 NVENC (`hevc_nvenc`)

这大幅提升了编码速度，特别是处理大量视频时。

## 支持的格式

**输入格式**: AVI, MKV, MOV, WMV, FLV, WebM, M4V, MPG, MPEG, 3GP, MP4

**输出格式**:
- 视频: MP4 (H.265/HEVC)
- 音频: M4A (AAC 320kbps)

## 特性

- ✅ 支持批量处理或指定单个/多个文件
- ✅ 自动跳过已存在的输出文件
- ✅ 保留所有字幕轨道和元数据
- ✅ 硬件加速编码（macOS VideoToolbox / NVIDIA NVENC）
- ✅ 详细的处理进度提示
- ✅ 可选的源文件自动删除功能（默认保留）

## 安装说明

### 安装到系统路径

将脚本复制到系统路径后可在任何目录直接使用：

```bash
# 安装脚本（需要管理员权限）
sudo cp bash_tools/video/to_mp4.sh /usr/local/bin/to_mp4
sudo cp bash_tools/video/compress_video.sh /usr/local/bin/compress_video
sudo cp bash_tools/video/extract_audio.sh /usr/local/bin/extract_audio
sudo cp bash_tools/video/resize_video.sh /usr/local/bin/resize_video
sudo cp bash_tools/video/crop_video.sh /usr/local/bin/crop_video
sudo cp bash_tools/video/rotate_video.sh /usr/local/bin/rotate_video
sudo cp bash_tools/video/merge_videos.sh /usr/local/bin/merge_videos

sudo chmod +x /usr/local/bin/{to_mp4,compress_video,extract_audio,resize_video,crop_video,rotate_video,merge_videos}
```

## 使用方法

所有脚本都支持两种使用模式：

### 模式一：批量处理（无参数）

不带参数运行时，脚本会自动处理当前目录下所有支持格式的视频文件。

```bash
cd /path/to/video/folder
to_mp4              # 转换当前目录所有支持格式的视频
compress_video      # 压缩当前目录所有视频文件
extract_audio       # 提取当前目录所有视频的音频
resize_video        # 调整当前目录所有视频的分辨率
crop_video          # 裁剪当前目录所有视频
rotate_video        # 旋转当前目录所有视频
merge_videos        # 合并当前目录所有 MP4 文件（或使用 file_list.txt）
```

### 模式二：指定文件（带参数）

可以指定单个或多个文件进行处理，支持使用通配符。

```bash
# 处理单个文件
to_mp4 video.mkv
compress_video large_video.mp4
extract_audio movie.mp4

# 处理多个文件
to_mp4 video1.mkv video2.avi video3.mov
compress_video file1.mp4 file2.mp4 file3.mp4

# 使用通配符批量处理特定文件
to_mp4 *.mkv                    # 转换所有 MKV 文件
compress_video raw_*.mp4        # 压缩所有以 raw_ 开头的 MP4 文件
extract_audio episode_*.mp4     # 提取所有剧集的音频

# 合并指定的视频文件（按参数顺序合并）
merge_videos intro.mp4 main.mp4 outro.mp4
```

### 直接运行脚本（未安装到系统路径）

如果没有安装到系统路径，可以直接使用 bash 运行：

```bash
cd /path/to/video/folder

# 批量处理
bash /path/to/Tools/bash_tools/video/to_mp4.sh

# 指定文件
bash /path/to/Tools/bash_tools/video/to_mp4.sh video1.mkv video2.avi
```

## 脚本详解

### 1. to_mp4.sh - 格式转换

将各种视频格式批量转换为 MP4 (H.265)。

**默认参数**:
- 视频编码: H.265 (硬件加速)
- 音频编码: AAC 320kbps
- CRF: 23 (平衡质量与文件大小)
- 保留所有字幕和元数据

**使用示例**:
```bash
# 批量转换当前目录所有支持格式的视频
to_mp4

# 转换单个文件
to_mp4 video.mkv

# 转换多个文件
to_mp4 movie1.avi movie2.mkv movie3.mov

# 只转换所有 MKV 文件
to_mp4 *.mkv
```

### 2. compress_video.sh - 视频压缩

减小视频文件大小，适合节省存储空间。

**默认参数**:
- CRF: 28 (更高压缩率)
- 输出文件名: `原文件名_compressed.mp4`
- 显示压缩前后文件大小对比

**调整压缩率**: 修改脚本中的 `CRF` 变量
- 较低值 (23-25): 更高质量，较大文件
- 中等值 (28-30): 平衡质量与大小
- 较高值 (32-35): 更小文件，较低质量

**使用示例**:
```bash
# 压缩当前目录所有视频
compress_video

# 压缩单个大文件
compress_video large_video.mp4

# 压缩多个文件
compress_video video1.mp4 video2.mp4 video3.mp4

# 压缩所有以 raw_ 开头的文件
compress_video raw_*.mp4
```

### 3. extract_audio.sh - 提取音频

从视频中提取音频轨道为 AAC 格式。

**默认参数**:
- 音频编码: AAC 320kbps
- 输出格式: M4A
- 保留元数据

**使用示例**:
```bash
# 提取当前目录所有视频的音频
extract_audio

# 提取单个视频的音频
extract_audio movie.mp4

# 提取多个视频的音频
extract_audio video1.mp4 video2.mp4 video3.mp4

# 提取所有剧集的音频
extract_audio episode_*.mp4
```

### 4. resize_video.sh - 调整分辨率

批量调整视频分辨率。

**默认参数**:
- 分辨率: `1920:-1` (宽度 1920，高度自动)
- 输出文件名: `原文件名_resized.mp4`

**常用分辨率预设**:
```bash
# 编辑脚本中的 RESOLUTION 变量
RESOLUTION="3840:2160"   # 4K
RESOLUTION="2560:1440"   # 2K
RESOLUTION="1920:1080"   # 1080p
RESOLUTION="1280:720"    # 720p
RESOLUTION="854:480"     # 480p
RESOLUTION="1920:-1"     # 宽度 1920，高度自动计算
RESOLUTION="-1:1080"     # 高度 1080，宽度自动计算
```

**使用示例**:
```bash
# 调整当前目录所有视频的分辨率
resize_video

# 调整单个视频
resize_video 4k_video.mp4

# 调整多个视频
resize_video video1.mp4 video2.mp4 video3.mp4

# 调整所有 4K 视频
resize_video *_4k.mp4
```

### 5. crop_video.sh - 裁剪画面

裁剪视频画面的特定区域。

**默认参数**:
- 裁剪参数: `1920:1080:0:0` (宽:高:x:y)
- 输出文件名: `原文件名_cropped.mp4`

**参数说明**:
- `width`: 裁剪区域宽度
- `height`: 裁剪区域高度
- `x`: 起始 x 坐标（左上角）
- `y`: 起始 y 坐标（左上角）

**常用裁剪预设**:
```bash
# 16:9 居中裁剪
CROP_PARAMS="iw:iw*9/16:(iw-iw)/2:(ih-iw*9/16)/2"

# 1:1 正方形居中裁剪
CROP_PARAMS="min(iw\,ih):min(iw\,ih):(iw-min(iw\,ih))/2:(ih-min(iw\,ih))/2"

# 自定义裁剪（例如：1920x1080，从坐标 100,50 开始）
CROP_PARAMS="1920:1080:100:50"
```

**使用示例**:
```bash
# 裁剪当前目录所有视频
crop_video

# 裁剪单个视频
crop_video video.mp4

# 裁剪多个视频
crop_video video1.mp4 video2.mp4

# 裁剪所有录屏文件
crop_video screen_record_*.mp4
```

### 6. rotate_video.sh - 旋转视频

旋转或翻转视频方向。

**默认参数**:
- 旋转: `transpose=1` (顺时针 90 度)
- 输出文件名: `原文件名_rotated.mp4`

**旋转选项**:
```bash
ROTATION="transpose=1"                 # 顺时针 90 度
ROTATION="transpose=2"                 # 逆时针 90 度
ROTATION="transpose=1,transpose=1"     # 180 度
ROTATION="hflip"                       # 水平翻转
ROTATION="vflip"                       # 垂直翻转
```

**使用示例**:
```bash
# 旋转当前目录所有视频
rotate_video

# 旋转单个视频
rotate_video vertical_video.mp4

# 旋转多个视频
rotate_video video1.mp4 video2.mp4

# 旋转所有手机拍摄的视频
rotate_video phone_*.mp4
```

### 7. merge_videos.sh - 合并视频

将多个视频文件合并为一个。

**默认参数**:
- 输出文件名: `merged_output.mp4`
- 自动生成文件列表（包含当前目录所有 MP4 文件）

**使用方法一：指定文件（推荐）**

直接指定要合并的文件，按参数顺序合并：

```bash
# 合并指定的文件（按顺序）
merge_videos intro.mp4 main.mp4 outro.mp4

# 合并多个剧集
merge_videos episode_01.mp4 episode_02.mp4 episode_03.mp4

# 使用通配符（注意：按文件名排序）
merge_videos part_*.mp4
```

**使用方法二：使用文件列表**

1. 将要合并的视频文件放在同一目录
2. 运行脚本（无参数），会自动生成 `file_list.txt`
3. 根据需要编辑 `file_list.txt` 调整视频顺序
4. 按回车继续合并

**文件列表格式** (`file_list.txt`):
```
file 'video1.mp4'
file 'video2.mp4'
file 'video3.mp4'
```

## 自定义参数

所有脚本都可以通过编辑脚本文件中的变量来自定义参数：

```bash
# 例如修改 compress_video.sh 的压缩等级
CRF=30  # 修改为 30，增加压缩率

# 例如修改 resize_video.sh 的目标分辨率
RESOLUTION="1280:720"  # 修改为 720p
```

## 删除原文件

所有脚本默认保留原文件。如需自动删除原文件，取消注释以下行：

```bash
# rm "$file"  # 移除开头的 # 即可启用
```

## 依赖

所有脚本依赖 `ffmpeg` 工具：

**macOS 安装**:
```bash
brew install ffmpeg
```

**Linux 安装**:
```bash
# Debian/Ubuntu
sudo apt install ffmpeg

# Fedora/RHEL
sudo dnf install ffmpeg
```

**Windows 安装**:
从 [FFmpeg 官网](https://ffmpeg.org/download.html) 下载并添加到系统 PATH

## 硬件加速要求

### macOS
- macOS 10.13 或更高版本
- 支持 VideoToolbox 的 Mac（几乎所有现代 Mac）

### Windows/Linux (NVENC)
- NVIDIA GPU (GeForce GTX 600 系列或更新)
- 最新的 NVIDIA 驱动程序
- FFmpeg 编译时需包含 NVENC 支持

## 注意事项

1. **硬件加速编码器**可能在某些系统上不可用，此时 FFmpeg 会自动回退到软件编码
2. **字幕支持**: MP4 容器支持 `mov_text` 格式字幕，某些 SRT 或 ASS 字幕可能需要转换
3. **CRF 值**: 越小质量越高文件越大（0-51，推荐 18-28）
4. **批量处理**: 处理大量文件时建议使用硬件加速以提高速度

## 常见问题

**Q: 如何查看我的系统是否支持硬件加速？**

A: 运行以下命令检查：
```bash
# macOS (VideoToolbox)
ffmpeg -codecs | grep hevc_videotoolbox

# Windows/Linux (NVENC)
ffmpeg -codecs | grep hevc_nvenc
```

**Q: 为什么转换后文件更大？**

A: H.265 编码通常比 H.264 在相同质量下文件更小，但如果源文件已经是高压缩率的格式，重新编码可能会增大文件。可以调整 CRF 值或使用 `compress_video.sh`。

**Q: 如何保持原始视频质量？**

A: 设置较低的 CRF 值（如 18-20），或使用无损编码（不推荐，文件会非常大）。
