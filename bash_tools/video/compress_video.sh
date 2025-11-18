#!/bin/bash
# 视频压缩工具 - 减小文件大小（H.265 + AAC 320k）

# 检测系统类型并选择硬件编码器
detect_encoder() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "hevc_videotoolbox"
    else
        echo "hevc_nvenc"
    fi
}

compress_video() {
    local input_file="$1"
    local output_file="$2"
    local encoder="$3"
    local crf="$4"

    # 使用更高的 CRF 值进行压缩（28-32），保留字幕
    ffmpeg -i "$input_file" -c:v "$encoder" -preset medium -crf "$crf" -c:a aac -b:a 320k -c:s mov_text -map 0 -movflags +faststart -map_metadata 0 "$output_file"
}

TARGET_PATH="$(pwd)"
ENCODER=$(detect_encoder)
CRF=28  # 默认 CRF 值，可根据需要调整（值越大压缩率越高，质量越低）

echo "=================================================="
echo "开始压缩视频 (H.265 + AAC 320k)"
echo "硬件编码器: $ENCODER"
echo "压缩等级 (CRF): $CRF"
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
        output_file="${name}_compressed.mp4"

        if [ -f "$output_file" ]; then
            echo "跳过（已存在）: $output_file"
            continue
        fi

        echo "正在压缩文件: $input_file ..."

        compress_video "$input_file" "$output_file" "$ENCODER" "$CRF"

        if [ $? -eq 0 ]; then
            original_size=$(du -h "$input_file" | cut -f1)
            compressed_size=$(du -h "$output_file" | cut -f1)
            echo "--- ✅ 压缩成功: $output_file ---"
            echo "    原始大小: $original_size → 压缩后: $compressed_size"
        else
            echo "--- ❌ 压缩失败: $input_file 发生错误 ---"
        fi
    done
else
    # 批量处理所有支持格式的文件
    formats=("mp4" "avi" "mkv" "mov" "wmv" "flv" "webm" "m4v" "mpg" "mpeg" "3gp")

    for format in "${formats[@]}"; do
        for file in *."$format"; do
            if [ -f "$file" ]; then
                filename=$(basename "$file" ."$format")
                output_file="${filename}_compressed.mp4"

                if [ -f "$output_file" ]; then
                    echo "跳过（已存在）: $output_file"
                    continue
                fi

                echo "正在压缩文件: $file ..."

                compress_video "$file" "$output_file" "$ENCODER" "$CRF"

                if [ $? -eq 0 ]; then
                    # 显示文件大小对比
                    original_size=$(du -h "$file" | cut -f1)
                    compressed_size=$(du -h "$output_file" | cut -f1)
                    echo "--- ✅ 压缩成功: $output_file ---"
                    echo "    原始大小: $original_size → 压缩后: $compressed_size"
                    # 如果需要自动删除原文件，取消注释下一行
                    # rm "$file"
                else
                    echo "--- ❌ 压缩失败: $file 发生错误 ---"
                fi
            fi
        done
    done
fi

echo "=================================================="
echo "所有文件压缩操作已完成！"
