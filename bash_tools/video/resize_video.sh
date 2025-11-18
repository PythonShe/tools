#!/bin/bash
# 视频分辨率调整工具 - 支持常见分辨率预设（H.265 + AAC 320k）

# 检测系统类型并选择硬件编码器
detect_encoder() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "hevc_videotoolbox"
    else
        echo "hevc_nvenc"
    fi
}

resize_video() {
    local input_file="$1"
    local output_file="$2"
    local encoder="$3"
    local resolution="$4"

    # 调整分辨率，保留字幕和元数据
    ffmpeg -i "$input_file" -vf "scale=$resolution" -c:v "$encoder" -preset medium -crf 23 -c:a aac -b:a 320k -c:s mov_text -map 0 -movflags +faststart -map_metadata 0 "$output_file"
}

# 分辨率预设
# 可选值:
# - 4K: 3840:2160
# - 2K: 2560:1440
# - 1080p: 1920:1080
# - 720p: 1280:720
# - 480p: 854:480
# 使用 -1 保持宽高比，例如 "1920:-1" 或 "-1:1080"
RESOLUTION="1920:-1"  # 默认调整为宽度 1920，高度自动计算

TARGET_PATH="$(pwd)"
ENCODER=$(detect_encoder)

echo "=================================================="
echo "开始调整视频分辨率 (H.265 + AAC 320k)"
echo "硬件编码器: $ENCODER"
echo "目标分辨率: $RESOLUTION"
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
        output_file="${name}_resized.mp4"

        if [ -f "$output_file" ]; then
            echo "跳过（已存在）: $output_file"
            continue
        fi

        echo "正在调整分辨率: $input_file ..."

        resize_video "$input_file" "$output_file" "$ENCODER" "$RESOLUTION"

        if [ $? -eq 0 ]; then
            echo "--- ✅ 调整成功: $output_file ---"
        else
            echo "--- ❌ 调整失败: $input_file 发生错误 ---"
        fi
    done
else
    # 批量处理所有支持格式的文件
    formats=("mp4" "avi" "mkv" "mov" "wmv" "flv" "webm" "m4v" "mpg" "mpeg" "3gp")

    for format in "${formats[@]}"; do
        for file in *."$format"; do
            if [ -f "$file" ]; then
                filename=$(basename "$file" ."$format")
                output_file="${filename}_resized.mp4"

                if [ -f "$output_file" ]; then
                    echo "跳过（已存在）: $output_file"
                    continue
                fi

                echo "正在调整分辨率: $file ..."

                resize_video "$file" "$output_file" "$ENCODER" "$RESOLUTION"

                if [ $? -eq 0 ]; then
                    echo "--- ✅ 调整成功: $output_file ---"
                    # 如果需要自动删除原文件，取消注释下一行
                    # rm "$file"
                else
                    echo "--- ❌ 调整失败: $file 发生错误 ---"
                fi
            fi
        done
    done
fi

echo "=================================================="
echo "所有文件分辨率调整操作已完成！"
