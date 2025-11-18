#!/bin/bash
# 从视频中提取音频为 AAC 格式 (320k)

extract_audio() {
    local input_file="$1"
    local output_file="$2"

    # 提取音频流，使用 AAC 320k 编码
    ffmpeg -i "$input_file" -vn -c:a aac -b:a 320k -map_metadata 0 "$output_file"
}

TARGET_PATH="$(pwd)"

echo "=================================================="
echo "开始提取视频音频 (AAC 320k)"
echo "目标目录 (TARGET_PATH): $TARGET_PATH"
echo "--------------------------------------------------"

# 如果指定了文件参数，只处理指定文件
if [ $# -gt 0 ]; then
    for input_file in "$@"; do
        if [ ! -f "$input_file" ]; then
            echo "文件不存在: $input_file"
            continue
        fi

        filename=$(basename "$input_file")
        name="${filename%.*}"
        output_file="${name}.m4a"

        if [ -f "$output_file" ]; then
            echo "跳过（已存在）: $output_file"
            continue
        fi

        echo "正在提取音频: $input_file ..."

        extract_audio "$input_file" "$output_file"

        if [ $? -eq 0 ]; then
            echo "--- ✅ 提取成功: $output_file ---"
        else
            echo "--- ❌ 提取失败: $input_file 发生错误 ---"
        fi
    done
else
    # 批量处理所有支持格式的文件
    formats=("mp4" "avi" "mkv" "mov" "wmv" "flv" "webm" "m4v" "mpg" "mpeg" "3gp")

    for format in "${formats[@]}"; do
        for file in *."$format"; do
            if [ -f "$file" ]; then
                filename=$(basename "$file" ."$format")
                output_file="${filename}.m4a"

                if [ -f "$output_file" ]; then
                    echo "跳过（已存在）: $output_file"
                    continue
                fi

                echo "正在提取音频: $file ..."

                extract_audio "$file" "$output_file"

                if [ $? -eq 0 ]; then
                    echo "--- ✅ 提取成功: $output_file ---"
                else
                    echo "--- ❌ 提取失败: $file 发生错误 ---"
                fi
            fi
        done
    done
fi

echo "=================================================="
echo "所有音频提取操作已完成！"
