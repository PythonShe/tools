# APE 到 FLAC 批量转换脚本

convert_to_flac() {
    local input_file="$1"
    local output_file="$2"
    ffmpeg -i "$input_file" -acodec flac -map 0:a -map_metadata 0 -map 0:v? "$output_file"
}

TARGET_PATH="$(pwd)"

echo "=================================================="
echo "开始批量转换 APE 到 FLAC"
echo "目标目录 (TARGET_PATH): $TARGET_PATH"
echo "--------------------------------------------------"

for file in *.ape; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .ape)
        output_file="${filename}.flac"
        
        if [ -f "$output_file" ]; then
            echo "跳过（已存在）: $output_file"
            continue
        fi

        echo "正在转换文件: $file ..."
        
        convert_to_flac "$file" "$output_file"
       
        if [ $? -eq 0 ]; then
            echo "--- ✅ 转换成功: $output_file ---"
            # 如果需要自动删除，取消注释下一行
            # rm "$file"
        else
            echo "--- ❌ 转换失败: $file 发生错误 ---"
        fi
    fi
done

echo "=================================================="
echo "所有文件转换操作已完成！"