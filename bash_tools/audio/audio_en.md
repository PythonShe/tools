[中文文档](audio.md) | English

### Scripts

| Script | Description | Output Format | Quality Settings |
|--------|-------------|---------------|------------------|
| `lossless_to_flac.sh` | Convert lossless formats to FLAC | FLAC | Maximum Quality |
| `flac_to_aac.sh` | Convert FLAC to AAC | M4A (AAC) | 320kbps, VBR 5 |
| `flac_to_mp3.sh` | Convert FLAC to MP3 | MP3 | 320kbps CBR, q:a 0 |

### Supported Formats

**lossless_to_flac.sh** supports the following lossless formats:
- WAV
- APE
- ALAC (only converts ALAC-encoded M4A, automatically skips AAC)
- WavPack (WV)
- TTA

### Features

- ✅ Batch convert all matching files in the current directory
- ✅ Automatically skip existing output files
- ✅ Preserve original metadata and cover art
- ✅ Detailed conversion progress output
- ✅ Optional automatic source file deletion (disabled by default)

### Usage

#### Method 1: Run Script Directly

```bash
cd /path/to/music/folder
bash /Users/zhengshe/Projects/Tools/bash_tools/audio/lossless_to_flac.sh
```

#### Method 2: Install to System Path

After copying scripts to system path, you can use them from any directory:

```bash
# Install scripts (requires sudo)
sudo cp bash_tools/audio/lossless_to_flac.sh /usr/local/bin/lossless_to_flac
sudo cp bash_tools/audio/flac_to_aac.sh /usr/local/bin/flac_to_aac
sudo cp bash_tools/audio/flac_to_mp3.sh /usr/local/bin/flac_to_mp3
sudo cp bash_tools/audio/ape_to_flac.sh /usr/local/bin/ape_to_flac
sudo chmod +x /usr/local/bin/{lossless_to_flac,flac_to_aac,flac_to_mp3,ape_to_flac}

# Usage examples
cd /path/to/music/folder
lossless_to_flac  # Convert lossless files to FLAC
flac_to_mp3       # Convert FLAC to MP3
```

### Requirements

All scripts require the following tools:
- `ffmpeg` - Audio conversion
- `ffprobe` - Audio format detection (required by lossless_to_flac.sh)

**macOS:**
```bash
brew install ffmpeg
```

**Linux:**
```bash
# Debian/Ubuntu
sudo apt install ffmpeg

# Fedora/RHEL
sudo dnf install ffmpeg
```