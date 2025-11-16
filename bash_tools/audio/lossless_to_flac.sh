# 无损音频格式到 FLAC 批量转换脚本

is_alac() {
    local file="$1"
    local codec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null)
    [ "$codec" = "alac" ]
}

convert_to_flac() {
    local input_file="$1"
    local output_file="$2"
    ffmpeg -i "$input_file" -acodec flac -map 0:a -map_metadata 0 -map 0:v? "$output_file"
}

TARGET_PATH="$(pwd)"

echo "=================================================="
echo "开始批量转换无损音频到 FLAC"
echo "目标目录 (TARGET_PATH): $TARGET_PATH"
echo "支持格式: WAV, APE, M4A(ALAC), WV, TTA"
echo "--------------------------------------------------"

extensions=("wav" "ape" "m4a" "wv" "tta" "WAV" "APE" "M4A" "WV" "TTA")

for ext in "${extensions[@]}"; do
    for file in *."$ext"; do
        if [ -f "$file" ]; then
            if [[ "${ext,,}" == "m4a" ]]; then
                if ! is_alac "$file"; then
                    echo "跳过（非无损编码）: $file"
                    continue
                fi
            fi

            filename=$(basename "$file" ."$ext")
            output_file="${filename}.flac"

            if [ -f "$output_file" ]; then
                echo "跳过（已存在）: $output_file"
                continue
            fi

            echo "正在转换文件: $file ..."

            convert_to_flac "$file" "$output_file"

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

echo "=================================================="
echo "所有文件转换操作已完成！"
