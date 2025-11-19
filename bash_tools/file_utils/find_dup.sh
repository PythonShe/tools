#!/bin/bash
# 查找重复文件 - 使用哈希算法识别内容相同的文件

# 计算文件哈希值（跨平台兼容）
calculate_hash() {
    local file="$1"
    local algorithm="$2"

    if command -v md5sum &> /dev/null; then
        # Linux
        if [ "$algorithm" = "sha256" ]; then
            sha256sum "$file" | awk '{print $1}'
        else
            md5sum "$file" | awk '{print $1}'
        fi
    elif command -v md5 &> /dev/null; then
        # macOS
        if [ "$algorithm" = "sha256" ]; then
            shasum -a 256 "$file" | awk '{print $1}'
        else
            md5 -q "$file"
        fi
    else
        echo "错误: 未找到哈希计算工具" >&2
        exit 1
    fi
}

# 格式化文件大小
format_size() {
    local size=$1
    if [ $size -lt 1024 ]; then
        echo "${size}B"
    elif [ $size -lt 1048576 ]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $size/1024}")KB"
    elif [ $size -lt 1073741824 ]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $size/1048576}")MB"
    else
        echo "$(awk "BEGIN {printf \"%.2f\", $size/1073741824}")GB"
    fi
}

# 获取文件大小（字节）
get_file_size() {
    local file="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        stat -f %z "$file"
    else
        stat -c %s "$file"
    fi
}

# 显示使用说明
show_usage() {
    cat << EOF
用法: $0 [选项] [目录]

选项:
  -a, --algorithm   哈希算法 (md5|sha256)，默认: md5
  -m, --min-size    最小文件大小（字节），忽略更小的文件，默认: 0
  -d, --delete      交互式删除重复文件（保留第一个）
  -o, --output      输出重复文件列表到文件
  -v, --verbose     详细模式，显示所有重复文件的路径
  -h, --help        显示此帮助信息

参数:
  [目录]            要搜索的目录，默认为当前目录

示例:
  $0                        # 查找当前目录的重复文件
  $0 -v ~/Downloads         # 详细模式查找 Downloads 目录
  $0 -a sha256 -m 1048576   # 使用 SHA256，忽略小于 1MB 的文件
  $0 -d                     # 交互式删除重复文件
  $0 -o duplicates.txt      # 输出结果到文件

EOF
}

# 默认参数
TARGET_PATH="$(pwd)"
ALGORITHM="md5"
MIN_SIZE=0
DELETE_MODE=false
OUTPUT_FILE=""
VERBOSE=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--algorithm)
            ALGORITHM="$2"
            if [[ "$ALGORITHM" != "md5" && "$ALGORITHM" != "sha256" ]]; then
                echo "错误: 不支持的哈希算法: $ALGORITHM"
                exit 1
            fi
            shift 2
            ;;
        -m|--min-size)
            MIN_SIZE="$2"
            shift 2
            ;;
        -d|--delete)
            DELETE_MODE=true
            shift
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
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
echo "查找重复文件"
echo "目标目录: $TARGET_PATH"
echo "哈希算法: ${ALGORITHM^^}"
echo "最小文件大小: $(format_size $MIN_SIZE)"
echo "删除模式: $DELETE_MODE"
echo "--------------------------------------------------"

# 使用关联数组存储哈希值和文件路径
declare -A hash_map
declare -A duplicate_groups
total_files=0
duplicate_count=0
wasted_space=0

echo "正在扫描文件..."

# 查找所有文件并计算哈希
while IFS= read -r -d '' file; do
    # 获取文件大小
    size=$(get_file_size "$file")

    # 跳过小于最小大小的文件
    if [ $size -lt $MIN_SIZE ]; then
        continue
    fi

    ((total_files++))

    # 计算哈希值
    hash=$(calculate_hash "$file" "$ALGORITHM")

    # 如果哈希值已存在，说明找到重复文件
    if [ -n "${hash_map[$hash]}" ]; then
        # 第一次发现重复时，记录原始文件
        if [ -z "${duplicate_groups[$hash]}" ]; then
            duplicate_groups[$hash]="${hash_map[$hash]}"
            ((duplicate_count++))
        fi
        # 添加重复文件
        duplicate_groups[$hash]+=$'\n'"$file"
        ((duplicate_count++))
        ((wasted_space += size))
    else
        hash_map[$hash]="$file"
    fi

    # 显示进度
    if [ $((total_files % 100)) -eq 0 ]; then
        echo -ne "\r已扫描: $total_files 个文件..."
    fi
done < <(find "$TARGET_PATH" -type f ! -path "*/.*" -print0)

echo -e "\r已扫描: $total_files 个文件    "
echo "--------------------------------------------------"

# 如果没有找到重复文件
if [ ${#duplicate_groups[@]} -eq 0 ]; then
    echo "✅ 未发现重复文件！"
    exit 0
fi

echo "发现 ${#duplicate_groups[@]} 组重复文件（共 $duplicate_count 个文件）"
echo "可节省空间: $(format_size $wasted_space)"
echo "=================================================="

# 准备输出
output_content=""

# 显示重复文件
group_num=0
for hash in "${!duplicate_groups[@]}"; do
    ((group_num++))
    files="${duplicate_groups[$hash]}"
    file_array=()

    # 读取文件列表
    while IFS= read -r line; do
        file_array+=("$line")
    done <<< "$files"

    # 获取文件大小
    file_size=$(get_file_size "${file_array[0]}")

    echo ""
    echo "重复组 #$group_num (大小: $(format_size $file_size), 共 ${#file_array[@]} 个文件):"

    output_content+="重复组 #$group_num (大小: $(format_size $file_size), 共 ${#file_array[@]} 个文件):"$'\n'

    if [ "$VERBOSE" = true ] || [ "$DELETE_MODE" = true ]; then
        for i in "${!file_array[@]}"; do
            echo "  [$((i+1))] ${file_array[$i]}"
            output_content+="  [$((i+1))] ${file_array[$i]}"$'\n'
        done
    else
        echo "  [1] ${file_array[0]}"
        echo "  ... (使用 -v 查看所有 ${#file_array[@]} 个文件)"
        output_content+="  [1] ${file_array[0]}"$'\n'
        output_content+="  ... (共 ${#file_array[@]} 个文件)"$'\n'
    fi

    # 删除模式
    if [ "$DELETE_MODE" = true ]; then
        echo ""
        echo -n "是否删除重复文件？(保留 [1]，删除其他) [y/N]: "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            for i in "${!file_array[@]}"; do
                if [ $i -gt 0 ]; then
                    if rm "${file_array[$i]}" 2>/dev/null; then
                        echo "  ✅ 已删除: ${file_array[$i]}"
                    else
                        echo "  ❌ 删除失败: ${file_array[$i]}"
                    fi
                fi
            done
        fi
    fi
done

# 输出到文件
if [ -n "$OUTPUT_FILE" ]; then
    echo "$output_content" > "$OUTPUT_FILE"
    echo ""
    echo "结果已保存到: $OUTPUT_FILE"
fi

echo ""
echo "=================================================="
echo "扫描完成！"
