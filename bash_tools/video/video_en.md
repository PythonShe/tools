[中文](video.md) | English

# Video Processing Tools

A collection of FFmpeg-based batch video processing scripts with hardware acceleration support.

## Script List

| Script | Function | Output Format | Quality Settings |
|--------|----------|---------------|------------------|
| `to_mp4.sh` | Convert to MP4 | MP4 (H.265) | CRF 23, AAC 320kbps |
| `compress_video.sh` | Video Compression | MP4 (H.265) | CRF 28, AAC 320kbps |
| `extract_audio.sh` | Extract Audio | M4A (AAC) | AAC 320kbps |
| `resize_video.sh` | Resize Resolution | MP4 (H.265) | CRF 23, AAC 320kbps |
| `crop_video.sh` | Crop Video | MP4 (H.265) | CRF 23, AAC 320kbps |
| `rotate_video.sh` | Rotate Video | MP4 (H.265) | CRF 23, AAC 320kbps |
| `merge_videos.sh` | Merge Videos | MP4 (H.265) | CRF 23, AAC 320kbps |

## Hardware Acceleration Support

Scripts automatically detect the system type and select the appropriate hardware encoder:

- **macOS**: Uses VideoToolbox (`hevc_videotoolbox`)
- **Windows/Linux**: Uses NVENC (`hevc_nvenc`)

This significantly improves encoding speed, especially when processing large numbers of videos.

## Supported Formats

**Input Formats**: AVI, MKV, MOV, WMV, FLV, WebM, M4V, MPG, MPEG, 3GP, MP4

**Output Formats**:
- Video: MP4 (H.265/HEVC)
- Audio: M4A (AAC 320kbps)

## Features

- ✅ Support batch processing or specify individual/multiple files
- ✅ Automatically skip existing output files
- ✅ Preserve all subtitle tracks and metadata
- ✅ Hardware-accelerated encoding (macOS VideoToolbox / NVIDIA NVENC)
- ✅ Detailed processing progress indicators
- ✅ Optional automatic source file deletion (disabled by default)

## Installation

### Install to System Path

Copy scripts to system path for use from any directory:

```bash
# Install scripts (requires admin privileges)
sudo cp bash_tools/video/to_mp4.sh /usr/local/bin/to_mp4
sudo cp bash_tools/video/compress_video.sh /usr/local/bin/compress_video
sudo cp bash_tools/video/extract_audio.sh /usr/local/bin/extract_audio
sudo cp bash_tools/video/resize_video.sh /usr/local/bin/resize_video
sudo cp bash_tools/video/crop_video.sh /usr/local/bin/crop_video
sudo cp bash_tools/video/rotate_video.sh /usr/local/bin/rotate_video
sudo cp bash_tools/video/merge_videos.sh /usr/local/bin/merge_videos

sudo chmod +x /usr/local/bin/{to_mp4,compress_video,extract_audio,resize_video,crop_video,rotate_video,merge_videos}
```

## Usage

All scripts support two modes of operation:

### Mode 1: Batch Processing (No Arguments)

Run without arguments to automatically process all supported video files in the current directory.

```bash
cd /path/to/video/folder
to_mp4              # Convert all supported video formats
compress_video      # Compress all videos in current directory
extract_audio       # Extract audio from all videos
resize_video        # Resize all videos
crop_video          # Crop all videos
rotate_video        # Rotate all videos
merge_videos        # Merge all MP4 files (or use file_list.txt)
```

### Mode 2: Specify Files (With Arguments)

Specify individual or multiple files to process, supports wildcards.

```bash
# Process a single file
to_mp4 video.mkv
compress_video large_video.mp4
extract_audio movie.mp4

# Process multiple files
to_mp4 video1.mkv video2.avi video3.mov
compress_video file1.mp4 file2.mp4 file3.mp4

# Use wildcards to batch process specific files
to_mp4 *.mkv                    # Convert all MKV files
compress_video raw_*.mp4        # Compress all files starting with raw_
extract_audio episode_*.mp4     # Extract audio from all episodes

# Merge specified video files (in argument order)
merge_videos intro.mp4 main.mp4 outro.mp4
```

### Run Scripts Directly (Not Installed to System Path)

If not installed to system path, run directly with bash:

```bash
cd /path/to/video/folder

# Batch processing
bash /path/to/Tools/bash_tools/video/to_mp4.sh

# Specify files
bash /path/to/Tools/bash_tools/video/to_mp4.sh video1.mkv video2.avi
```

## Script Details

### 1. to_mp4.sh - Format Conversion

Batch convert various video formats to MP4 (H.265).

**Default Parameters**:
- Video Codec: H.265 (hardware accelerated)
- Audio Codec: AAC 320kbps
- CRF: 23 (balanced quality and file size)
- Preserve all subtitles and metadata

**Usage Examples**:
```bash
# Batch convert all supported formats in current directory
to_mp4

# Convert a single file
to_mp4 video.mkv

# Convert multiple files
to_mp4 movie1.avi movie2.mkv movie3.mov

# Convert only MKV files
to_mp4 *.mkv
```

### 2. compress_video.sh - Video Compression

Reduce video file size, ideal for saving storage space.

**Default Parameters**:
- CRF: 28 (higher compression)
- Output Filename: `original_name_compressed.mp4`
- Display before/after file size comparison

**Adjust Compression**: Modify the `CRF` variable in the script
- Lower values (23-25): Higher quality, larger files
- Medium values (28-30): Balanced quality and size
- Higher values (32-35): Smaller files, lower quality

**Usage Examples**:
```bash
# Compress all videos in current directory
compress_video

# Compress a single large file
compress_video large_video.mp4

# Compress multiple files
compress_video video1.mp4 video2.mp4 video3.mp4

# Compress all files starting with raw_
compress_video raw_*.mp4
```

### 3. extract_audio.sh - Extract Audio

Extract audio tracks from videos to AAC format.

**Default Parameters**:
- Audio Codec: AAC 320kbps
- Output Format: M4A
- Preserve metadata

**Usage Examples**:
```bash
# Extract audio from all videos in current directory
extract_audio

# Extract audio from a single video
extract_audio movie.mp4

# Extract audio from multiple videos
extract_audio video1.mp4 video2.mp4 video3.mp4

# Extract audio from all episodes
extract_audio episode_*.mp4
```

### 4. resize_video.sh - Adjust Resolution

Batch resize video resolution.

**Default Parameters**:
- Resolution: `1920:-1` (width 1920, height auto)
- Output Filename: `original_name_resized.mp4`

**Common Resolution Presets**:
```bash
# Edit the RESOLUTION variable in the script
RESOLUTION="3840:2160"   # 4K
RESOLUTION="2560:1440"   # 2K
RESOLUTION="1920:1080"   # 1080p
RESOLUTION="1280:720"    # 720p
RESOLUTION="854:480"     # 480p
RESOLUTION="1920:-1"     # Width 1920, height auto-calculated
RESOLUTION="-1:1080"     # Height 1080, width auto-calculated
```

**Usage Examples**:
```bash
# Resize all videos in current directory
resize_video

# Resize a single video
resize_video 4k_video.mp4

# Resize multiple videos
resize_video video1.mp4 video2.mp4 video3.mp4

# Resize all 4K videos
resize_video *_4k.mp4
```

### 5. crop_video.sh - Crop Video

Crop specific regions of the video frame.

**Default Parameters**:
- Crop Parameters: `1920:1080:0:0` (width:height:x:y)
- Output Filename: `original_name_cropped.mp4`

**Parameter Explanation**:
- `width`: Crop region width
- `height`: Crop region height
- `x`: Starting x coordinate (from top-left)
- `y`: Starting y coordinate (from top-left)

**Common Crop Presets**:
```bash
# 16:9 centered crop
CROP_PARAMS="iw:iw*9/16:(iw-iw)/2:(ih-iw*9/16)/2"

# 1:1 square centered crop
CROP_PARAMS="min(iw\,ih):min(iw\,ih):(iw-min(iw\,ih))/2:(ih-min(iw\,ih))/2"

# Custom crop (e.g., 1920x1080 starting at coordinates 100,50)
CROP_PARAMS="1920:1080:100:50"
```

**Usage Examples**:
```bash
# Crop all videos in current directory
crop_video

# Crop a single video
crop_video video.mp4

# Crop multiple videos
crop_video video1.mp4 video2.mp4

# Crop all screen recordings
crop_video screen_record_*.mp4
```

### 6. rotate_video.sh - Rotate Video

Rotate or flip video orientation.

**Default Parameters**:
- Rotation: `transpose=1` (clockwise 90 degrees)
- Output Filename: `original_name_rotated.mp4`

**Rotation Options**:
```bash
ROTATION="transpose=1"                 # Clockwise 90 degrees
ROTATION="transpose=2"                 # Counter-clockwise 90 degrees
ROTATION="transpose=1,transpose=1"     # 180 degrees
ROTATION="hflip"                       # Horizontal flip
ROTATION="vflip"                       # Vertical flip
```

**Usage Examples**:
```bash
# Rotate all videos in current directory
rotate_video

# Rotate a single video
rotate_video vertical_video.mp4

# Rotate multiple videos
rotate_video video1.mp4 video2.mp4

# Rotate all phone-recorded videos
rotate_video phone_*.mp4
```

### 7. merge_videos.sh - Merge Videos

Merge multiple video files into one.

**Default Parameters**:
- Output Filename: `merged_output.mp4`
- Auto-generate file list (includes all MP4 files in current directory)

**Method 1: Specify Files (Recommended)**

Directly specify files to merge in the order provided:

```bash
# Merge specified files (in order)
merge_videos intro.mp4 main.mp4 outro.mp4

# Merge multiple episodes
merge_videos episode_01.mp4 episode_02.mp4 episode_03.mp4

# Use wildcards (note: sorted by filename)
merge_videos part_*.mp4
```

**Method 2: Use File List**

1. Place videos to merge in the same directory
2. Run the script (no arguments), it will auto-generate `file_list.txt`
3. Edit `file_list.txt` to adjust video order if needed
4. Press Enter to continue merging

**File List Format** (`file_list.txt`):
```
file 'video1.mp4'
file 'video2.mp4'
file 'video3.mp4'
```

## Customization

All scripts can be customized by editing variables in the script files:

```bash
# Example: Modify compression level in compress_video.sh
CRF=30  # Change to 30 for higher compression

# Example: Modify target resolution in resize_video.sh
RESOLUTION="1280:720"  # Change to 720p
```

## Delete Original Files

All scripts preserve original files by default. To enable automatic deletion, uncomment this line:

```bash
# rm "$file"  # Remove the # to enable
```

## Dependencies

All scripts require the `ffmpeg` tool:

**macOS Installation**:
```bash
brew install ffmpeg
```

**Linux Installation**:
```bash
# Debian/Ubuntu
sudo apt install ffmpeg

# Fedora/RHEL
sudo dnf install ffmpeg
```

**Windows Installation**:
Download from [FFmpeg official website](https://ffmpeg.org/download.html) and add to system PATH

## Hardware Acceleration Requirements

### macOS
- macOS 10.13 or later
- Mac with VideoToolbox support (almost all modern Macs)

### Windows/Linux (NVENC)
- NVIDIA GPU (GeForce GTX 600 series or newer)
- Latest NVIDIA drivers
- FFmpeg compiled with NVENC support

## Notes

1. **Hardware encoders** may not be available on some systems; FFmpeg will automatically fall back to software encoding
2. **Subtitle support**: MP4 container supports `mov_text` format subtitles; some SRT or ASS subtitles may need conversion
3. **CRF values**: Lower values = higher quality and larger files (range 0-51, recommended 18-28)
4. **Batch processing**: Hardware acceleration is recommended when processing many files for better speed

## FAQ

**Q: How to check if my system supports hardware acceleration?**

A: Run these commands:
```bash
# macOS (VideoToolbox)
ffmpeg -codecs | grep hevc_videotoolbox

# Windows/Linux (NVENC)
ffmpeg -codecs | grep hevc_nvenc
```

**Q: Why is the converted file larger?**

A: H.265 encoding is usually smaller than H.264 at the same quality, but if the source is already highly compressed, re-encoding may increase file size. Try adjusting the CRF value or use `compress_video.sh`.

**Q: How to maintain original video quality?**

A: Use a lower CRF value (e.g., 18-20), or use lossless encoding (not recommended, files will be very large).
