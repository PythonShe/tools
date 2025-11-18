#!/bin/bash
# 视频格式转换为 MP4 (H.265 + AAC 320k)

# 检测系统类型并选择硬件编码器
detect_encoder() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - 使用 VideoToolbox 硬件加速
        echo "hevc_videotoolbox"
    else
        # Windows/Linux - 使用 NVENC 硬件加速
        echo "hevc_nvenc"
    fi
}

convert_to_mp4() {
    local input_file="$1"
    local output_file="$2"
    local encoder="$3"

    # 使用硬件编码器，保留所有流（视频、音频、字幕）
    ffmpeg -i "$input_file" -c:v "$encoder" -preset medium -crf 23 -c:a aac -b:a 320k -c:s mov_text -map 0 -movflags +faststart -map_metadata 0 "$output_file"
}

TARGET_PATH="$(pwd)"
ENCODER=$(detect_encoder)

echo "=================================================="
echo "开始转换视频到 MP4 (H.265 + AAC 320k)"
echo "硬件编码器: $ENCODER"
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
        extension="${filename##*.}"
        name="${filename%.*}"
        output_file="${name}.mp4"

        if [ -f "$output_file" ]; then
            echo "跳过（已存在）: $output_file"
            continue
        fi

        echo "正在转换文件: $input_file ..."

        convert_to_mp4 "$input_file" "$output_file" "$ENCODER"

        if [ $? -eq 0 ]; then
            echo "--- ✅ 转换成功: $output_file ---"
        else
            echo "--- ❌ 转换失败: $input_file 发生错误 ---"
        fi
    done
else
    # 批量处理所有支持格式的文件
    formats=("avi" "mkv" "mov" "wmv" "flv" "webm" "m4v" "mpg" "mpeg" "3gp")

    for format in "${formats[@]}"; do
        for file in *."$format"; do
            if [ -f "$file" ]; then
                filename=$(basename "$file" ."$format")
                output_file="${filename}.mp4"

                if [ -f "$output_file" ]; then
                    echo "跳过（已存在）: $output_file"
                    continue
                fi

                echo "正在转换文件: $file ..."

                convert_to_mp4 "$file" "$output_file" "$ENCODER"

                if [ $? -eq 0 ]; then
                    echo "--- ✅ 转换成功: $output_file ---"
                    # 如果需要自动删除原文件，取消注释下一行
                    # rm "$file"
                else
                    echo "--- ❌ 转换失败: $file 发生错误 ---"
                fi
            fi
        done
    done
fi

echo "=================================================="
echo "所有文件转换操作已完成！"
