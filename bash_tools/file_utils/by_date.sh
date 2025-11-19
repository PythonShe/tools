#!/bin/bash
# 按日期组织文件 - 将文件按修改日期移动到 YYYY/MM 格式的文件夹

# 获取文件修改日期（跨平台兼容）
get_file_date() {
    local file="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        stat -f "%Sm" -t "%Y/%m" "$file"
    else
        # Linux
        date -r "$file" "+%Y/%m"
    fi
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

    # 获取文件日期
    local date_folder=$(get_file_date "$file")
    local target_dir="${target_base}/${date_folder}"
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
echo "按日期组织文件"
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
