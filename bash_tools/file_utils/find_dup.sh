#!/bin/bash
# 查找重复文件 - 使用哈希算法识别内容相同的文件

# 计算文件哈希值（跨平台兼容）
calculate_hash() {
    local file="$1"
    local algorithm="$2"

    # 检查文件是否存在且可读
    if [ ! -f "$file" ]; then
        echo "错误: 文件不存在: $file" >&2
        return 1
    fi

    if [ ! -r "$file" ]; then
        echo "错误: 文件不可读: $file" >&2
        return 1
    fi

    if command -v md5sum &> /dev/null; then
        # Linux
        if [ "$algorithm" = "sha256" ]; then
            sha256sum "$file" 2>/dev/null | awk '{print $1}'
        else
            md5sum "$file" 2>/dev/null | awk '{print $1}'
        fi
    elif command -v md5 &> /dev/null; then
        # macOS
        if [ "$algorithm" = "sha256" ]; then
            shasum -a 256 "$file" 2>/dev/null | awk '{print $1}'
        else
            md5 -q "$file" 2>/dev/null
        fi
    else
        echo "错误: 未找到哈希计算工具" >&2
        return 1
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

    # 检查文件是否存在
    if [ ! -f "$file" ]; then
        echo "0"
        return 1
    fi

    local size
    if [[ "$OSTYPE" == "darwin"* ]]; then
        size=$(stat -f %z "$file" 2>/dev/null)
    else
        size=$(stat -c %s "$file" 2>/dev/null)
    fi

    # 检查是否成功获取大小
    if [ -z "$size" ]; then
        echo "0"
        return 1
    fi

    echo "$size"
    return 0
}

# 检测文件名是否包含重复文件后缀 (数字)
# 例如: "file (1).txt", "document (2).pdf"
is_duplicate_suffix() {
    local file="$1"
    local basename=$(basename "$file")

    # 匹配模式: 文件名 (数字).扩展名 或 文件名 (数字)
    if [[ "$basename" =~ \([0-9]+\)(\.[^.]+)?$ ]]; then
        return 0  # 是重复文件
    else
        return 1  # 不是重复文件
    fi
}

# 提取重复文件后缀中的数字
# 返回: 如果是重复文件返回数字，否则返回 0
get_duplicate_number() {
    local file="$1"
    local basename=$(basename "$file")

    if [[ "$basename" =~ \(([0-9]+)\)(\.[^.]+)?$ ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo "0"
    fi
}

# 获取不带重复后缀的基础文件名
# 例如: "file (1).txt" -> "file.txt"
get_base_filename() {
    local file="$1"
    local basename=$(basename "$file")
    local dirname=$(dirname "$file")

    # 移除 (数字) 部分
    if [[ "$basename" =~ ^(.+)\ \([0-9]+\)(\.[^.]+)?$ ]]; then
        local name="${BASH_REMATCH[1]}"
        local ext="${BASH_REMATCH[2]}"
        echo "${dirname}/${name}${ext}"
    else
        echo "$file"
    fi
}

# 对文件数组进行排序，将非重复文件排在前面
# 参数: 文件路径数组（通过引用传递）
sort_files_by_duplicate_suffix() {
    local -n arr=$1
    local -a original_files=()
    local -a duplicate_files=()

    # 分离原始文件和重复文件
    for file in "${arr[@]}"; do
        if is_duplicate_suffix "$file"; then
            duplicate_files+=("$file")
        else
            original_files+=("$file")
        fi
    done

    # 对重复文件按数字排序
    if [ ${#duplicate_files[@]} -gt 0 ]; then
        IFS=$'\n' duplicate_files=($(
            for f in "${duplicate_files[@]}"; do
                num=$(get_duplicate_number "$f")
                echo "$num|$f"
            done | sort -t'|' -k1 -n | cut -d'|' -f2-
        ))
        unset IFS
    fi

    # 合并：原始文件在前，重复文件在后
    arr=("${original_files[@]}" "${duplicate_files[@]}")
}

# 显示使用说明
show_usage() {
    cat << EOF
用法: $0 [选项] [目录]

选项:
  -a, --algorithm   指定哈希算法 (md5|sha256)，默认: md5
  -m, --min-size    设置最小文件大小（字节），忽略更小的文件，默认: 0
  -d, --delete      启用交互式删除模式，逐组询问是否删除重复文件
  -s, --smart       启用智能识别模式，将带 (数字) 后缀的文件标注并排序
                    （配合 -d 使用时，会优先建议删除这些带后缀的文件）
  -o, --output      将重复文件列表输出到指定文件
  -v, --verbose     详细模式，显示每组重复文件的所有路径
  -h, --help        显示此帮助信息

参数:
  [目录]            要搜索的目录，默认为当前目录

示例:
  $0                        # 查找当前目录的重复文件
  $0 -v ~/Downloads         # 详细模式，显示 Downloads 目录中所有重复文件路径
  $0 -s                     # 智能模式，标注带 (数字) 后缀的疑似重复文件
  $0 -d                     # 交互式删除，逐组询问（默认保留第一个文件）
  $0 -s -d                  # 智能删除，优先建议删除带 (数字) 后缀的文件
  $0 -a sha256 -m 1048576   # 使用 SHA256 算法，忽略小于 1MB 的文件
  $0 -o duplicates.txt      # 将结果保存到 duplicates.txt 文件

EOF
}

# 默认参数
TARGET_PATH="$(pwd)"
ALGORITHM="md5"
MIN_SIZE=0
DELETE_MODE=false
SMART_MODE=false
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
            # 验证最小大小是否为有效数字
            if ! [[ "$MIN_SIZE" =~ ^[0-9]+$ ]]; then
                echo "错误: 最小文件大小必须是有效的数字: $MIN_SIZE" >&2
                exit 1
            fi
            shift 2
            ;;
        -d|--delete)
            DELETE_MODE=true
            shift
            ;;
        -s|--smart)
            SMART_MODE=true
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
echo "智能模式: $SMART_MODE"
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
    # 跳过空文件名
    if [ -z "$file" ]; then
        continue
    fi

    # 获取文件大小
    size=$(get_file_size "$file")
    if [ $? -ne 0 ]; then
        # 文件不存在或无法访问，跳过
        continue
    fi

    # 跳过小于最小大小的文件
    if [ $size -lt $MIN_SIZE ]; then
        continue
    fi

    ((total_files++))

    # 计算哈希值
    hash=$(calculate_hash "$file" "$ALGORITHM" 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$hash" ]; then
        # 计算哈希失败，跳过此文件
        continue
    fi

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
done < <(find "$TARGET_PATH" -type f ! -path "*/.*" -print0 2>/dev/null)

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

    # 如果启用智能模式，对文件进行排序
    if [ "$SMART_MODE" = true ]; then
        sort_files_by_duplicate_suffix file_array
    fi

    # 获取文件大小
    file_size=$(get_file_size "${file_array[0]}")

    echo ""
    echo "重复组 #$group_num (大小: $(format_size $file_size), 共 ${#file_array[@]} 个文件):"

    output_content+="重复组 #$group_num (大小: $(format_size $file_size), 共 ${#file_array[@]} 个文件):"$'\n'

    if [ "$VERBOSE" = true ] || [ "$DELETE_MODE" = true ]; then
        for i in "${!file_array[@]}"; do
            local marker=""
            # 在智能模式下标注重复后缀文件
            if [ "$SMART_MODE" = true ] && is_duplicate_suffix "${file_array[$i]}"; then
                marker=" [疑似重复]"
            fi
            echo "  [$((i+1))] ${file_array[$i]}${marker}"
            output_content+="  [$((i+1))] ${file_array[$i]}${marker}"$'\n'
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

        # 统计带重复后缀的文件
        local has_duplicate_suffix=false
        local duplicate_suffix_indices=()

        if [ "$SMART_MODE" = true ]; then
            for i in "${!file_array[@]}"; do
                if is_duplicate_suffix "${file_array[$i]}"; then
                    has_duplicate_suffix=true
                    duplicate_suffix_indices+=("$i")
                fi
            done
        fi

        # 根据智能模式选择提示信息
        if [ "$SMART_MODE" = true ] && [ "$has_duplicate_suffix" = true ]; then
            echo "检测到 ${#duplicate_suffix_indices[@]} 个带 (数字) 后缀的疑似重复文件"
            echo ""
            echo "删除选项:"
            echo "  [s] 智能删除 - 仅删除带 (数字) 后缀的文件（推荐）"
            echo "  [a] 全部删除 - 保留 [1]，删除其他所有文件"
            echo "  [n] 跳过此组"
            echo -n "请选择 [s/a/N]: "
            read -r response

            case "$response" in
                [Ss])
                    # 智能删除：只删除带后缀的文件
                    for i in "${duplicate_suffix_indices[@]}"; do
                        local target_file="${file_array[$i]}"
                        # 删除前检查文件是否仍然存在
                        if [ ! -f "$target_file" ]; then
                            echo "  ⚠️  文件已不存在: $target_file"
                            continue
                        fi
                        # 检查文件权限
                        if [ ! -w "$target_file" ]; then
                            echo "  ❌ 无权限删除: $target_file"
                            continue
                        fi
                        if rm "$target_file" 2>/dev/null; then
                            echo "  ✅ 已删除: $target_file"
                        else
                            echo "  ❌ 删除失败: $target_file"
                        fi
                    done
                    ;;
                [Aa])
                    # 普通删除：保留第一个，删除其他
                    for i in "${!file_array[@]}"; do
                        if [ $i -gt 0 ]; then
                            local target_file="${file_array[$i]}"
                            # 删除前检查文件是否仍然存在
                            if [ ! -f "$target_file" ]; then
                                echo "  ⚠️  文件已不存在: $target_file"
                                continue
                            fi
                            # 检查文件权限
                            if [ ! -w "$target_file" ]; then
                                echo "  ❌ 无权限删除: $target_file"
                                continue
                            fi
                            if rm "$target_file" 2>/dev/null; then
                                echo "  ✅ 已删除: $target_file"
                            else
                                echo "  ❌ 删除失败: $target_file"
                            fi
                        fi
                    done
                    ;;
                *)
                    echo "  ⏭️  已跳过此组"
                    ;;
            esac
        else
            # 普通删除模式
            echo -n "是否删除重复文件？(保留 [1]，删除其他) [y/N]: "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                for i in "${!file_array[@]}"; do
                    if [ $i -gt 0 ]; then
                        local target_file="${file_array[$i]}"
                        # 删除前检查文件是否仍然存在
                        if [ ! -f "$target_file" ]; then
                            echo "  ⚠️  文件已不存在: $target_file"
                            continue
                        fi
                        # 检查文件权限
                        if [ ! -w "$target_file" ]; then
                            echo "  ❌ 无权限删除: $target_file"
                            continue
                        fi
                        if rm "$target_file" 2>/dev/null; then
                            echo "  ✅ 已删除: $target_file"
                        else
                            echo "  ❌ 删除失败: $target_file"
                        fi
                    fi
                done
            else
                echo "  ⏭️  已跳过此组"
            fi
        fi
    fi
done

# 输出到文件
if [ -n "$OUTPUT_FILE" ]; then
    # 检查输出目录是否存在
    output_dir=$(dirname "$OUTPUT_FILE")
    if [ ! -d "$output_dir" ]; then
        echo ""
        echo "错误: 输出目录不存在: $output_dir" >&2
    elif [ -f "$OUTPUT_FILE" ] && [ ! -w "$OUTPUT_FILE" ]; then
        echo ""
        echo "错误: 无权限写入文件: $OUTPUT_FILE" >&2
    else
        if echo "$output_content" > "$OUTPUT_FILE" 2>/dev/null; then
            echo ""
            echo "结果已保存到: $OUTPUT_FILE"
        else
            echo ""
            echo "错误: 无法写入文件: $OUTPUT_FILE" >&2
        fi
    fi
fi

echo ""
echo "=================================================="
echo "扫描完成！"
