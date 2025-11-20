中文 | [English](file_utils_en.md)

# 文件组织工具集

一套实用的文件管理和组织脚本，帮助快速整理和管理文件。

## 脚本列表

| 脚本 | 功能 | 主要用途 |
|------|------|----------|
| `by_date.sh` | 按日期组织文件 | 将文件按修改日期移动到 YYYY/MM 格式的文件夹 |
| `by_type.sh` | 按类型分类文件 | 将文件按扩展名分类到对应文件夹（如 images、videos 等） |
| `find_dup.sh` | 查找重复文件 | 使用哈希算法识别内容相同的文件，支持交互式删除 |

## 特性

- ✅ 支持预览模式，可在实际操作前查看将要执行的操作
- ✅ 自动跳过已存在的目标文件，避免覆盖
- ✅ 支持递归处理子目录
- ✅ 详细的处理进度提示
- ✅ 跨平台兼容（macOS、Linux）
- ✅ 智能文件类型识别（14+ 种分类）

## 安装说明

### 安装到系统路径

将脚本复制到系统路径后可在任何目录直接使用：

```bash
# 安装脚本（需要管理员权限）
sudo cp bash_tools/file_utils/by_date.sh /usr/local/bin/by_date
sudo cp bash_tools/file_utils/by_type.sh /usr/local/bin/by_type
sudo cp bash_tools/file_utils/find_dup.sh /usr/local/bin/find_dup

sudo chmod +x /usr/local/bin/{by_date,by_type,find_dup}
```

## 使用方法

### 1. by_date.sh - 按日期组织文件

将文件按修改日期自动整理到 `YYYY/MM` 格式的文件夹中。

**命令选项**:
```bash
-p, --preview     预览模式，不实际移动文件
-r, --recursive   递归处理子目录中的文件
-h, --help        显示帮助信息
```

**使用示例**:
```bash
# 组织当前目录的文件
by_date

# 预览模式（不实际移动）
by_date -p

# 递归组织指定目录
by_date -r ~/Downloads

# 预览递归组织
by_date --preview --recursive ~/Pictures
```

**输出示例**:
```
按日期组织文件后的目录结构：
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

### 2. by_type.sh - 按类型分类文件

将文件按扩展名智能分类到不同文件夹。

**支持的文件类型分类**:
- `images` - 图片（jpg, png, gif, webp, heic, svg 等）
- `videos` - 视频（mp4, mkv, avi, mov, webm 等）
- `audio` - 音频（mp3, flac, wav, aac, m4a 等）
- `documents` - 文档（pdf, doc, txt, md 等）
- `spreadsheets` - 表格（xls, xlsx, csv 等）
- `presentations` - 演示文稿（ppt, pptx, key 等）
- `archives` - 压缩包（zip, rar, 7z, tar 等）
- `code` - 代码（js, py, cpp, java, go 等）
- `web` - 网页（html, css, scss 等）
- `applications` - 应用程序（exe, app, dmg 等）
- `fonts` - 字体（ttf, otf, woff 等）
- `databases` - 数据库（db, sqlite, sql 等）
- `configs` - 配置文件（json, xml, yaml 等）
- `others` - 其他未分类文件

**命令选项**:
```bash
-p, --preview     预览模式，不实际移动文件
-r, --recursive   递归处理子目录中的文件
-h, --help        显示帮助信息
```

**使用示例**:
```bash
# 组织当前目录的文件
by_type

# 预览模式
by_type -p

# 递归组织指定目录
by_type -r ~/Downloads

# 预览递归组织
by_type --preview --recursive .
```

**输出示例**:
```
按类型组织文件后的目录结构：
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

### 3. find_dup.sh - 查找重复文件

使用哈希算法（MD5 或 SHA256）识别内容完全相同的文件，支持交互式删除重复文件。

**命令选项**:
```bash
-a, --algorithm   指定哈希算法（md5|sha256），默认: md5
-m, --min-size    设置最小文件大小（字节），忽略更小的文件，默认: 0
-d, --delete      启用交互式删除模式，逐组询问是否删除重复文件
-s, --smart       启用智能识别模式，将带 (数字) 后缀的文件标注并排序
                  （配合 -d 使用时，会优先建议删除这些带后缀的文件）
-o, --output      将重复文件列表输出到指定文件
-v, --verbose     详细模式，显示每组重复文件的所有路径
-h, --help        显示帮助信息
```

**使用示例**:
```bash
# 查找当前目录的重复文件
find_dup

# 详细模式，显示所有重复文件路径
find_dup -v

# 智能模式，标注带 (数字) 后缀的疑似重复文件
find_dup -s -v

# 使用 SHA256 算法（更安全，速度稍慢）
find_dup -a sha256

# 忽略小于 1MB 的文件
find_dup -m 1048576

# 查找并交互式删除重复文件
find_dup -d

# 智能删除模式（推荐）：优先建议删除带 (数字) 后缀的文件
find_dup -s -d

# 将结果输出到文件
find_dup -o duplicates.txt

# 组合使用：详细查找 Downloads 目录，使用 SHA256，忽略小文件
find_dup -v -a sha256 -m 102400 ~/Downloads
```

**普通模式输出示例**:
```
==================================================
查找重复文件
目标目录: /Users/username/Downloads
哈希算法: MD5
最小文件大小: 0B
智能模式: false
删除模式: false
--------------------------------------------------
正在扫描文件...
已扫描: 1523 个文件
--------------------------------------------------
发现 3 组重复文件（共 8 个文件）
可节省空间: 125.42MB
==================================================

重复组 #1 (大小: 45.23MB, 共 3 个文件):
  [1] /Users/username/Downloads/movie.mp4
  [2] /Users/username/Downloads/backup/movie.mp4
  [3] /Users/username/Downloads/old/movie.mp4

重复组 #2 (大小: 2.15MB, 共 2 个文件):
  [1] /Users/username/Downloads/photo.jpg
  [2] /Users/username/Downloads/photo_copy.jpg
```

**智能模式输出示例** (`-s -d`):
```
重复组 #1 (大小: 15.3MB, 共 3 个文件):
  [1] /Users/username/Downloads/document.pdf
  [2] /Users/username/Downloads/document (1).pdf [疑似重复]
  [3] /Users/username/Downloads/document (2).pdf [疑似重复]

检测到 2 个带 (数字) 后缀的疑似重复文件

删除选项:
  [s] 智能删除 - 仅删除带 (数字) 后缀的文件（推荐）
  [a] 全部删除 - 保留 [1]，删除其他所有文件
  [n] 跳过此组
请选择 [s/a/N]: s
  ✅ 已删除: /Users/username/Downloads/document (1).pdf
  ✅ 已删除: /Users/username/Downloads/document (2).pdf
```

## 直接运行脚本（未安装到系统路径）

如果没有安装到系统路径，可以直接使用 bash 运行：

```bash
# 按日期组织
bash /path/to/Tools/bash_tools/file_utils/by_date.sh -p

# 按类型组织
bash /path/to/Tools/bash_tools/file_utils/by_type.sh -r ~/Downloads

# 查找重复文件
bash /path/to/Tools/bash_tools/file_utils/find_dup.sh -v
```

## 实用场景

### 场景 1：整理下载文件夹

```bash
cd ~/Downloads

# 先预览按类型组织的效果
by_type -p

# 确认无误后执行
by_type

# 使用智能模式查找并删除重复下载的文件（推荐）
find_dup -s -d
```

### 场景 2：整理照片库

```bash
cd ~/Pictures

# 使用智能模式先查找重复照片
find_dup -s -v -m 10240  # 忽略小于 10KB 的文件，标注疑似重复

# 智能删除重复照片
find_dup -s -d -m 10240

# 按拍摄日期组织照片
by_date -r

# 或按类型分类（图片、视频等）
by_type -r
```

### 场景 3：清理项目文件夹

```bash
cd ~/Projects

# 按文件类型分类代码文件
by_type -r

# 查找重复的依赖包或构建产物
find_dup -m 1048576 -o duplicates_report.txt
```

## 依赖

这些脚本使用纯 Bash 编写，依赖以下标准工具（通常已预装）：

- `find` - 文件搜索
- `stat` - 文件信息获取
- `md5` / `md5sum` - MD5 哈希计算（macOS / Linux）
- `shasum` / `sha256sum` - SHA256 哈希计算（macOS / Linux）

**验证依赖**:
```bash
# macOS
which md5 shasum

# Linux
which md5sum sha256sum
```

## 注意事项

1. **预览模式**: 首次使用建议先使用 `-p` 参数预览，确认操作无误后再执行
2. **备份重要数据**: 在移动或删除文件前，建议先备份重要数据
3. **重复文件删除**:
   - 普通模式 (`-d`): 保留找到的第一个文件，删除其他重复文件
   - 智能模式 (`-s -d`): 优先建议删除带 `(数字)` 后缀的文件，更符合实际使用习惯
4. **智能识别**: `-s` 选项会识别 `file (1).txt` 这样的系统自动命名重复文件，并提供智能删除建议
5. **大文件处理**: 处理大量文件或大文件时，哈希计算可能需要一些时间
6. **文件权限**: 确保对目标目录有读写权限

## 常见问题

**Q: 按日期组织会修改原始文件吗？**

A: 不会。脚本只移动文件到新文件夹，不会修改文件内容或元数据。

**Q: 如何撤销文件组织操作？**

A: 目前脚本不提供撤销功能。建议在首次使用时先用 `-p` 预览模式测试，或在操作前备份数据。

**Q: MD5 和 SHA256 应该选哪个？**

A: MD5 速度快，适合大多数场景。SHA256 更安全但稍慢，如果要确保绝对准确（处理关键数据），推荐使用 SHA256。

**Q: 为什么有些文件被分类到 others？**

A: 脚本包含了常见的文件类型映射。如果你的文件扩展名不在映射列表中，可以编辑 `by_type.sh` 脚本中的 `get_file_category` 函数添加自定义映射。

**Q: 可以自定义文件类型分类吗？**

A: 可以。打开 `by_type.sh` 脚本，修改 `get_file_category()` 函数中的 case 语句，添加或修改文件扩展名映射。

**Q: 智能模式 (-s) 和普通模式有什么区别？**

A: 智能模式会自动识别系统命名的重复文件（如 `file (1).txt`）并将它们标注为 `[疑似重复]`。在删除模式下，智能模式会优先建议删除这些带后缀的文件，保留原始文件，更符合实际需求。普通模式则不做区分，按文件路径顺序处理。

**Q: 智能模式会自动删除文件吗？**

A: 不会。即使在智能删除模式 (`-s -d`) 下，脚本仍然会逐组询问，你可以选择：`[s]` 智能删除（仅删除带后缀的）、`[a]` 全部删除、或 `[n]` 跳过。所有操作都需要手动确认。
