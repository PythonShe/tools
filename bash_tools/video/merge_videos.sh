#!/bin/bash
# 视频合并工具 - 将多个视频文件合并为一个（H.265 + AAC 320k）

# 检测系统类型并选择硬件编码器
detect_encoder() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "hevc_videotoolbox"
    else
        echo "hevc_nvenc"
    fi
}

merge_videos() {
    local file_list="$1"
    local output_file="$2"
    local encoder="$3"

    # 使用 concat 协议合并视频，保留字幕和元数据
    ffmpeg -f concat -safe 0 -i "$file_list" -c:v "$encoder" -preset medium -crf 23 -c:a aac -b:a 320k -c:s mov_text -movflags +faststart -map_metadata 0 "$output_file"
}

TARGET_PATH="$(pwd)"
ENCODER=$(detect_encoder)
OUTPUT_FILE="merged_output.mp4"
FILE_LIST="file_list.txt"
TEMP_FILE_LIST=false

echo "=================================================="
echo "视频合并工具 (H.265 + AAC 320k)"
echo "硬件编码器: $ENCODER"
echo "目标目录 (TARGET_PATH): $TARGET_PATH"
echo "--------------------------------------------------"

# 如果指定了文件参数，使用这些文件进行合并
if [ $# -gt 0 ]; then
    echo "使用命令行指定的文件进行合并"
    FILE_LIST=".temp_merge_list_$$.txt"
    TEMP_FILE_LIST=true

    # 创建临时文件列表
    for input_file in "$@"; do
        if [ ! -f "$input_file" ]; then
            echo "警告: 文件不存在，已跳过: $input_file"
            continue
        fi
        echo "file '$input_file'" >> "$FILE_LIST"
    done

    if [ ! -s "$FILE_LIST" ]; then
        echo "错误: 没有有效的视频文件"
        rm -f "$FILE_LIST"
        exit 1
    fi

    echo "要合并的文件:"
    cat "$FILE_LIST"
    echo ""
else
    # 检查是否存在文件列表
    if [ ! -f "$FILE_LIST" ]; then
        echo "创建文件列表: $FILE_LIST"
        echo "请在 $FILE_LIST 中按顺序列出要合并的视频文件"
        echo "格式示例:"
        echo "file 'video1.mp4'"
        echo "file 'video2.mp4'"
        echo "file 'video3.mp4'"
        echo ""

        # 自动生成当前目录下所有 MP4 文件的列表
        for file in *.mp4; do
            if [ -f "$file" ] && [ "$file" != "$OUTPUT_FILE" ]; then
                echo "file '$file'" >> "$FILE_LIST"
            fi
        done

        if [ -s "$FILE_LIST" ]; then
            echo "已自动生成文件列表，包含以下文件:"
            cat "$FILE_LIST"
            echo ""
            echo "如需修改顺序，请编辑 $FILE_LIST 文件后重新运行脚本"
            echo "按回车键继续合并，或按 Ctrl+C 取消..."
            read
        else
            echo "当前目录没有找到 MP4 文件"
            exit 1
        fi
    fi
fi

if [ -f "$OUTPUT_FILE" ]; then
    echo "输出文件已存在: $OUTPUT_FILE"
    echo "请删除或重命名后重试"
    [ "$TEMP_FILE_LIST" = true ] && rm -f "$FILE_LIST"
    exit 1
fi

echo "开始合并视频..."
echo "--------------------------------------------------"

merge_videos "$FILE_LIST" "$OUTPUT_FILE" "$ENCODER"

if [ $? -eq 0 ]; then
    echo "--- ✅ 合并成功: $OUTPUT_FILE ---"
    output_size=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo "    输出文件大小: $output_size"

    # 如果是临时文件列表，直接删除
    if [ "$TEMP_FILE_LIST" = true ]; then
        rm -f "$FILE_LIST"
    else
        # 询问是否删除文件列表
        echo ""
        echo "是否删除临时文件列表 $FILE_LIST? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            rm "$FILE_LIST"
            echo "已删除: $FILE_LIST"
        fi
    fi
else
    echo "--- ❌ 合并失败 ---"
    [ "$TEMP_FILE_LIST" = true ] && rm -f "$FILE_LIST"
    exit 1
fi

echo "=================================================="
echo "视频合并操作已完成！"
