#!/bin/bash
# 视频旋转工具 - 旋转视频方向（H.265 + AAC 320k）

# 检测系统类型并选择硬件编码器
detect_encoder() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "hevc_videotoolbox"
    else
        echo "hevc_nvenc"
    fi
}

rotate_video() {
    local input_file="$1"
    local output_file="$2"
    local encoder="$3"
    local rotation="$4"

    # 旋转视频，保留字幕和元数据
    ffmpeg -i "$input_file" -vf "$rotation" -c:v "$encoder" -preset medium -crf 23 -c:a aac -b:a 320k -c:s mov_text -map 0 -movflags +faststart -map_metadata 0 "$output_file"
}

# 旋转参数:
# - 顺时针 90 度: "transpose=1"
# - 逆时针 90 度: "transpose=2"
# - 180 度: "transpose=1,transpose=1" 或 "hflip,vflip"
# - 水平翻转: "hflip"
# - 垂直翻转: "vflip"
ROTATION="transpose=1"  # 默认顺时针旋转 90 度

TARGET_PATH="$(pwd)"
ENCODER=$(detect_encoder)

echo "=================================================="
echo "开始旋转视频 (H.265 + AAC 320k)"
echo "硬件编码器: $ENCODER"
echo "旋转参数: $ROTATION"
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
        output_file="${name}_rotated.mp4"

        if [ -f "$output_file" ]; then
            echo "跳过（已存在）: $output_file"
            continue
        fi

        echo "正在旋转视频: $input_file ..."

        rotate_video "$input_file" "$output_file" "$ENCODER" "$ROTATION"

        if [ $? -eq 0 ]; then
            echo "--- ✅ 旋转成功: $output_file ---"
        else
            echo "--- ❌ 旋转失败: $input_file 发生错误 ---"
        fi
    done
else
    # 批量处理所有支持格式的文件
    formats=("mp4" "avi" "mkv" "mov" "wmv" "flv" "webm" "m4v" "mpg" "mpeg" "3gp")

    for format in "${formats[@]}"; do
        for file in *."$format"; do
            if [ -f "$file" ]; then
                filename=$(basename "$file" ."$format")
                output_file="${filename}_rotated.mp4"

                if [ -f "$output_file" ]; then
                    echo "跳过（已存在）: $output_file"
                    continue
                fi

                echo "正在旋转视频: $file ..."

                rotate_video "$file" "$output_file" "$ENCODER" "$ROTATION"

                if [ $? -eq 0 ]; then
                    echo "--- ✅ 旋转成功: $output_file ---"
                    # 如果需要自动删除原文件，取消注释下一行
                    # rm "$file"
                else
                    echo "--- ❌ 旋转失败: $file 发生错误 ---"
                fi
            fi
        done
    done
fi

echo "=================================================="
echo "所有视频旋转操作已完成！"
