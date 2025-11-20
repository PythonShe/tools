[中文文档](file_utils.md) | English

# File Utilities

A collection of practical file management and organization scripts to help you quickly organize and manage files.

## Scripts

| Script | Description | Primary Use |
|--------|-------------|-------------|
| `by_date.sh` | Organize files by date | Move files to YYYY/MM folders based on modification date |
| `by_type.sh` | Organize files by type | Classify files by extension into category folders (images, videos, etc.) |
| `find_dup.sh` | Find duplicate files | Identify identical files using hash algorithms with interactive deletion |

## Features

- ✅ Preview mode to review operations before execution
- ✅ Automatically skip existing target files to avoid overwriting
- ✅ Support recursive processing of subdirectories
- ✅ Detailed progress indicators
- ✅ Cross-platform compatible (macOS, Linux)
- ✅ Intelligent file type recognition (14+ categories)

## Installation

### Install to System Path

After copying scripts to system path, you can use them from any directory:

```bash
# Install scripts (requires sudo)
sudo cp bash_tools/file_utils/by_date.sh /usr/local/bin/by_date
sudo cp bash_tools/file_utils/by_type.sh /usr/local/bin/by_type
sudo cp bash_tools/file_utils/find_dup.sh /usr/local/bin/find_dup

sudo chmod +x /usr/local/bin/{by_date,by_type,find_dup}
```

## Usage

### 1. by_date.sh - Organize Files by Date

Automatically organize files into `YYYY/MM` folders based on modification date.

**Options**:
```bash
-p, --preview     Preview mode, don't actually move files
-r, --recursive   Recursively process files in subdirectories
-h, --help        Show help information
```

**Examples**:
```bash
# Organize files in current directory
by_date

# Preview mode (no actual movement)
by_date -p

# Recursively organize specified directory
by_date -r ~/Downloads

# Preview recursive organization
by_date --preview --recursive ~/Pictures
```

**Output Example**:
```
Directory structure after organizing by date:
Downloads/
├── 2024/
│   ├── 01/
│   │   ├── document1.pdf
│   │   └── photo1.jpg
│   ├── 02/
│   │   └── video1.mp4
│   └── 03/
│       └── archive.zip
```

### 2. by_type.sh - Organize Files by Type

Intelligently classify files into different folders based on file extensions.

**Supported File Categories**:
- `images` - Images (jpg, png, gif, webp, heic, svg, etc.)
- `videos` - Videos (mp4, mkv, avi, mov, webm, etc.)
- `audio` - Audio (mp3, flac, wav, aac, m4a, etc.)
- `documents` - Documents (pdf, doc, txt, md, etc.)
- `spreadsheets` - Spreadsheets (xls, xlsx, csv, etc.)
- `presentations` - Presentations (ppt, pptx, key, etc.)
- `archives` - Archives (zip, rar, 7z, tar, etc.)
- `code` - Source code (js, py, cpp, java, go, etc.)
- `web` - Web files (html, css, scss, etc.)
- `applications` - Applications (exe, app, dmg, etc.)
- `fonts` - Fonts (ttf, otf, woff, etc.)
- `databases` - Databases (db, sqlite, sql, etc.)
- `configs` - Configuration files (json, xml, yaml, etc.)
- `others` - Other uncategorized files

**Options**:
```bash
-p, --preview     Preview mode, don't actually move files
-r, --recursive   Recursively process files in subdirectories
-h, --help        Show help information
```

**Examples**:
```bash
# Organize files in current directory
by_type

# Preview mode
by_type -p

# Recursively organize specified directory
by_type -r ~/Downloads

# Preview recursive organization
by_type --preview --recursive .
```

**Output Example**:
```
Directory structure after organizing by type:
Downloads/
├── images/
│   ├── photo1.jpg
│   ├── screenshot.png
│   └── logo.svg
├── videos/
│   ├── movie.mp4
│   └── clip.mkv
├── documents/
│   ├── report.pdf
│   └── notes.txt
└── archives/
    └── backup.zip
```

### 3. find_dup.sh - Find Duplicate Files

Identify files with identical content using hash algorithms (MD5 or SHA256), with support for interactive deletion.

**Options**:
```bash
-a, --algorithm   Specify hash algorithm (md5|sha256), default: md5
-m, --min-size    Set minimum file size (bytes), ignore smaller files, default: 0
-d, --delete      Enable interactive deletion mode, ask for each duplicate group
-s, --smart       Enable smart recognition mode, mark and sort files with (number) suffix
                  (When used with -d, prioritizes deletion of these suffixed files)
-o, --output      Output duplicate file list to specified file
-v, --verbose     Verbose mode, show all paths for each duplicate group
-h, --help        Show help information
```

**Examples**:
```bash
# Find duplicates in current directory
find_dup

# Verbose mode, show all duplicate file paths
find_dup -v

# Smart mode, mark files with (number) suffix as suspected duplicates
find_dup -s -v

# Use SHA256 algorithm (more secure, slightly slower)
find_dup -a sha256

# Ignore files smaller than 1MB
find_dup -m 1048576

# Find and interactively delete duplicates
find_dup -d

# Smart deletion mode (recommended): prioritize deletion of files with (number) suffix
find_dup -s -d

# Output results to file
find_dup -o duplicates.txt

# Combined: verbose search in Downloads, use SHA256, ignore small files
find_dup -v -a sha256 -m 102400 ~/Downloads
```

**Normal Mode Output Example**:
```
==================================================
Find Duplicate Files
Target Directory: /Users/username/Downloads
Hash Algorithm: MD5
Minimum File Size: 0B
Smart Mode: false
Delete Mode: false
--------------------------------------------------
Scanning files...
Scanned: 1523 files
--------------------------------------------------
Found 3 duplicate groups (8 files total)
Wasted space: 125.42MB
==================================================

Duplicate Group #1 (size: 45.23MB, 3 files):
  [1] /Users/username/Downloads/movie.mp4
  [2] /Users/username/Downloads/backup/movie.mp4
  [3] /Users/username/Downloads/old/movie.mp4

Duplicate Group #2 (size: 2.15MB, 2 files):
  [1] /Users/username/Downloads/photo.jpg
  [2] /Users/username/Downloads/photo_copy.jpg
```

**Smart Mode Output Example** (`-s -d`):
```
Duplicate Group #1 (size: 15.3MB, 3 files):
  [1] /Users/username/Downloads/document.pdf
  [2] /Users/username/Downloads/document (1).pdf [Suspected Duplicate]
  [3] /Users/username/Downloads/document (2).pdf [Suspected Duplicate]

Detected 2 files with (number) suffix as suspected duplicates

Deletion options:
  [s] Smart delete - Only delete files with (number) suffix (Recommended)
  [a] Delete all - Keep [1], delete all others
  [n] Skip this group
Choose [s/a/N]: s
  ✅ Deleted: /Users/username/Downloads/document (1).pdf
  ✅ Deleted: /Users/username/Downloads/document (2).pdf
```

## Running Scripts Directly (Without System Installation)

If not installed to system path, you can run scripts directly with bash:

```bash
# Organize by date
bash /path/to/Tools/bash_tools/file_utils/by_date.sh -p

# Organize by type
bash /path/to/Tools/bash_tools/file_utils/by_type.sh -r ~/Downloads

# Find duplicates
bash /path/to/Tools/bash_tools/file_utils/find_dup.sh -v
```

## Practical Use Cases

### Use Case 1: Organize Downloads Folder

```bash
cd ~/Downloads

# Preview organization by type
by_type -p

# Execute after confirmation
by_type

# Use smart mode to find and delete duplicate downloads (recommended)
find_dup -s -d
```

### Use Case 2: Organize Photo Library

```bash
cd ~/Pictures

# Use smart mode to find duplicate photos first
find_dup -s -v -m 10240  # Ignore files smaller than 10KB, mark suspected duplicates

# Smart delete duplicate photos
find_dup -s -d -m 10240

# Organize photos by date
by_date -r

# Or organize by type (images, videos, etc.)
by_type -r
```

### Use Case 3: Clean Up Project Folders

```bash
cd ~/Projects

# Organize code files by type
by_type -r

# Find duplicate dependencies or build artifacts
find_dup -m 1048576 -o duplicates_report.txt
```

## Requirements

These scripts are written in pure Bash and depend on standard tools (usually pre-installed):

- `find` - File searching
- `stat` - File information retrieval
- `md5` / `md5sum` - MD5 hash calculation (macOS / Linux)
- `shasum` / `sha256sum` - SHA256 hash calculation (macOS / Linux)

**Verify Dependencies**:
```bash
# macOS
which md5 shasum

# Linux
which md5sum sha256sum
```

## Important Notes

1. **Preview Mode**: Recommended to use `-p` parameter first to preview operations before execution
2. **Backup Important Data**: Always backup important data before moving or deleting files
3. **Duplicate Deletion**:
   - Normal mode (`-d`): Keeps the first file found and deletes other duplicates
   - Smart mode (`-s -d`): Prioritizes deletion of files with `(number)` suffix, more aligned with practical usage
4. **Smart Recognition**: The `-s` option recognizes system-generated duplicate filenames like `file (1).txt` and provides intelligent deletion suggestions
5. **Large Files**: Processing many files or large files may take some time for hash calculation
6. **File Permissions**: Ensure you have read/write permissions for target directories

## FAQ

**Q: Does organizing by date modify the original files?**

A: No. The script only moves files to new folders without modifying file content or metadata.

**Q: How do I undo file organization operations?**

A: The scripts don't currently provide undo functionality. Recommended to test with `-p` preview mode first or backup data before operations.

**Q: Should I choose MD5 or SHA256?**

A: MD5 is faster and suitable for most scenarios. SHA256 is more secure but slightly slower. If you need absolute accuracy (handling critical data), use SHA256.

**Q: Why are some files classified as others?**

A: The script includes mappings for common file types. If your file extension is not in the mapping list, you can edit the `get_file_category` function in `by_type.sh` to add custom mappings.

**Q: Can I customize file type classifications?**

A: Yes. Open the `by_type.sh` script, modify the case statement in the `get_file_category()` function to add or modify file extension mappings.

**Q: What's the difference between smart mode (-s) and normal mode?**

A: Smart mode automatically recognizes system-generated duplicate filenames (like `file (1).txt`) and marks them as `[Suspected Duplicate]`. In deletion mode, smart mode prioritizes deletion of these suffixed files while keeping the original, which better matches practical needs. Normal mode processes files by path order without distinction.

**Q: Does smart mode automatically delete files?**

A: No. Even in smart deletion mode (`-s -d`), the script asks for confirmation for each duplicate group. You can choose: `[s]` smart delete (only suffixed files), `[a]` delete all, or `[n]` skip. All operations require manual confirmation.
