#!/bin/bash
# 视频裁剪工具 - 裁剪画面区域（H.265 + AAC 320k）

# 检测系统类型并选择硬件编码器
detect_encoder() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "hevc_videotoolbox"
    else
        echo "hevc_nvenc"
    fi
}

crop_video() {
    local input_file="$1"
    local output_file="$2"
    local encoder="$3"
    local crop_params="$4"

    # 裁剪视频，保留字幕和元数据
    ffmpeg -i "$input_file" -vf "crop=$crop_params" -c:v "$encoder" -preset medium -crf 23 -c:a aac -b:a 320k -c:s mov_text -map 0 -movflags +faststart -map_metadata 0 "$output_file"
}

# 裁剪参数格式: width:height:x:y
# width: 裁剪区域宽度
# height: 裁剪区域高度
# x: 起始 x 坐标（从左上角开始）
# y: 起始 y 坐标（从左上角开始）
#
# 常用预设:
# - 16:9 居中裁剪: "iw:iw*9/16:(iw-iw)/2:(ih-iw*9/16)/2"
# - 1:1 正方形居中: "min(iw\,ih):min(iw\,ih):(iw-min(iw\,ih))/2:(ih-min(iw\,ih))/2"
# - 移除黑边（自动检测）: 使用 cropdetect 过滤器
CROP_PARAMS="1920:1080:0:0"  # 默认裁剪参数

TARGET_PATH="$(pwd)"
ENCODER=$(detect_encoder)

echo "=================================================="
echo "开始裁剪视频 (H.265 + AAC 320k)"
echo "硬件编码器: $ENCODER"
echo "裁剪参数: $CROP_PARAMS (width:height:x:y)"
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
        output_file="${name}_cropped.mp4"

        if [ -f "$output_file" ]; then
            echo "跳过（已存在）: $output_file"
            continue
        fi

        echo "正在裁剪视频: $input_file ..."

        crop_video "$input_file" "$output_file" "$ENCODER" "$CROP_PARAMS"

        if [ $? -eq 0 ]; then
            echo "--- ✅ 裁剪成功: $output_file ---"
        else
            echo "--- ❌ 裁剪失败: $input_file 发生错误 ---"
        fi
    done
else
    # 批量处理所有支持格式的文件
    formats=("mp4" "avi" "mkv" "mov" "wmv" "flv" "webm" "m4v" "mpg" "mpeg" "3gp")

    for format in "${formats[@]}"; do
        for file in *."$format"; do
            if [ -f "$file" ]; then
                filename=$(basename "$file" ."$format")
                output_file="${filename}_cropped.mp4"

                if [ -f "$output_file" ]; then
                    echo "跳过（已存在）: $output_file"
                    continue
                fi

                echo "正在裁剪视频: $file ..."

                crop_video "$file" "$output_file" "$ENCODER" "$CROP_PARAMS"

                if [ $? -eq 0 ]; then
                    echo "--- ✅ 裁剪成功: $output_file ---"
                    # 如果需要自动删除原文件，取消注释下一行
                    # rm "$file"
                else
                    echo "--- ❌ 裁剪失败: $file 发生错误 ---"
                fi
            fi
        done
    done
fi

echo "=================================================="
echo "所有视频裁剪操作已完成！"
