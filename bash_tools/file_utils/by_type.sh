#!/bin/bash
# 按文件类型组织文件 - 将文件按扩展名分类到不同文件夹

# 文件类型映射
get_file_category() {
    local extension="${1,,}"  # 转为小写

    case "$extension" in
        # 图片
        jpg|jpeg|png|gif|bmp|svg|webp|heic|heif|ico|tiff|tif|raw|cr2|nef|arw)
            echo "images"
            ;;
        # 视频
        mp4|avi|mkv|mov|wmv|flv|webm|m4v|mpg|mpeg|3gp|f4v|m2ts|ts)
            echo "videos"
            ;;
        # 音频
        mp3|flac|wav|aac|m4a|ogg|opus|wma|ape|alac|wv|tta|aiff)
            echo "audio"
            ;;
        # 文档
        pdf|doc|docx|txt|rtf|odt|pages|md|tex)
            echo "documents"
            ;;
        # 表格
        xls|xlsx|csv|ods|numbers)
            echo "spreadsheets"
            ;;
        # 演示文稿
        ppt|pptx|key|odp)
            echo "presentations"
            ;;
        # 压缩包
        zip|rar|7z|tar|gz|bz2|xz|tgz|tbz2|dmg|iso)
            echo "archives"
            ;;
        # 代码
        js|ts|py|java|cpp|c|h|hpp|go|rs|rb|php|swift|kt|sh|bash|zsh)
            echo "code"
            ;;
        # 网页
        html|htm|css|scss|sass|less)
            echo "web"
            ;;
        # 可执行文件
        exe|app|dmg|pkg|deb|rpm|apk)
            echo "applications"
            ;;
        # 字体
        ttf|otf|woff|woff2|eot)
            echo "fonts"
            ;;
        # 数据库
        db|sqlite|sql|mdb)
            echo "databases"
            ;;
        # 配置文件
        json|xml|yaml|yml|toml|ini|conf|config)
            echo "configs"
            ;;
        # 其他
        *)
            echo "others"
            ;;
    esac
}

# 组织单个文件
organize_file() {
    local file="$1"
    local target_base="$2"
    local dry_run="$3"

    # 跳过目录
    if [ -d "$file" ]; then
        return
    fi

    # 获取文件扩展名
    local filename=$(basename "$file")
    local extension="${filename##*.}"

    # 如果没有扩展名
    if [ "$filename" = "$extension" ]; then
        extension="no_extension"
    fi

    # 获取文件类型分类
    local category=$(get_file_category "$extension")
    local target_dir="${target_base}/${category}"
    local target_file="${target_dir}/$(basename "$file")"

    # 如果目标文件已存在，跳过
    if [ -f "$target_file" ] && [ "$file" != "$target_file" ]; then
        echo "跳过（目标已存在）: $file -> $target_file"
        return
    fi

    # 预览模式
    if [ "$dry_run" = true ]; then
        echo "[预览] $file -> $target_file"
        return
    fi

    # 创建目标目录
    mkdir -p "$target_dir"

    # 移动文件
    if mv "$file" "$target_file" 2>/dev/null; then
        echo "✅ 已移动: $file -> $target_file"
    else
        echo "❌ 移动失败: $file"
    fi
}

# 显示使用说明
show_usage() {
    cat << EOF
用法: $0 [选项] [目录]

选项:
  -p, --preview     预览模式，不实际移动文件，仅显示将要执行的操作
  -r, --recursive   递归处理子目录中的文件
  -h, --help        显示此帮助信息

参数:
  [目录]            要组织的目录，默认为当前目录

文件类型分类:
  images           - 图片 (jpg, png, gif, etc.)
  videos           - 视频 (mp4, mkv, avi, etc.)
  audio            - 音频 (mp3, flac, wav, etc.)
  documents        - 文档 (pdf, doc, txt, etc.)
  spreadsheets     - 表格 (xls, xlsx, csv, etc.)
  presentations    - 演示文稿 (ppt, pptx, key, etc.)
  archives         - 压缩包 (zip, rar, 7z, etc.)
  code             - 代码 (js, py, cpp, etc.)
  web              - 网页 (html, css, etc.)
  applications     - 应用程序 (exe, app, dmg, etc.)
  fonts            - 字体 (ttf, otf, woff, etc.)
  databases        - 数据库 (db, sqlite, sql, etc.)
  configs          - 配置文件 (json, xml, yaml, etc.)
  others           - 其他未分类文件

示例:
  $0                    # 组织当前目录的文件
  $0 -p                 # 预览模式
  $0 -r ~/Downloads     # 递归组织 Downloads 目录
  $0 --preview -r .     # 预览递归组织当前目录

EOF
}

# 默认参数
TARGET_PATH="$(pwd)"
DRY_RUN=false
RECURSIVE=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--preview)
            DRY_RUN=true
            shift
            ;;
        -r|--recursive)
            RECURSIVE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            if [ -d "$1" ]; then
                TARGET_PATH="$1"
            else
                echo "错误: 目录不存在: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

echo "=================================================="
echo "按文件类型组织文件"
echo "目标目录: $TARGET_PATH"
echo "递归模式: $RECURSIVE"
echo "预览模式: $DRY_RUN"
echo "--------------------------------------------------"

if [ "$DRY_RUN" = true ]; then
    echo "⚠️  预览模式 - 不会实际移动文件"
    echo "--------------------------------------------------"
fi

cd "$TARGET_PATH" || exit 1

FILE_COUNT=0

# 处理文件
if [ "$RECURSIVE" = true ]; then
    # 递归处理所有文件
    while IFS= read -r -d '' file; do
        organize_file "$file" "$TARGET_PATH" "$DRY_RUN"
        ((FILE_COUNT++))
    done < <(find . -type f ! -path "*/.*" -print0)
else
    # 仅处理当前目录
    for file in *; do
        if [ -f "$file" ]; then
            organize_file "$file" "$TARGET_PATH" "$DRY_RUN"
            ((FILE_COUNT++))
        fi
    done
fi

echo "=================================================="
if [ "$DRY_RUN" = true ]; then
    echo "预览完成！共检查 $FILE_COUNT 个文件"
    echo "提示: 去掉 -p 参数以实际执行移动操作"
else
    echo "组织完成！共处理 $FILE_COUNT 个文件"
fi
