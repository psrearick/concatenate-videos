#!/bin/bash

# Usage: bash merge_videos.sh /path/to/input_dir output.mp4

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <input_dir> <output_file>"
    exit 1
fi

resolution="1920x1080"
if [ $# -ge 3 ]; then
    resolution="$3"
fi

input_dir="$1"
output_file="$2"
workdir="video_workdir_$$"
convert_dir="$workdir/converted"
norm_dir="$workdir/normalized"
final_dir="$workdir/final"
list_file="$workdir/list.txt"

fancy_echo() {
    # $1: message, $2: color code
    local color="${2:-36}" # default: cyan
    echo -e "\033[1;${color}m$1\033[0m"
}

fancy_echo "Step 0: Creating temporary directories..." 35

mkdir -p "$convert_dir" "$norm_dir" "$final_dir"

fancy_echo "Step 1: Converting all files to MP4..." 35

files=("$input_dir"/*)
total=${#files[@]}
count=0

for f in "${files[@]}"; do
    count=$((count + 1))
    base=$(basename "$f")
    out="$convert_dir/${base%.*}.mp4"
    fancy_echo "  [$count/$total] Converting $base to MP4..." 33
    ffmpeg -hide_banner -loglevel error -y -i "$f" \
    -c:v libx264 -preset veryfast -crf 23 \
    -c:a aac -ar 48000 -ac 2 \
    "$out" || fancy_echo "    Skipped $base (not a valid video file)." 31
done

fancy_echo "Step 2: Normalizing audio for all converted videos..." 35

conv_files=("$convert_dir"/*.mp4)
conv_total=${#conv_files[@]}
conv_count=0

for f in "${conv_files[@]}"; do
    conv_count=$((conv_count + 1))
    base=$(basename "$f")
    out="$norm_dir/$base"
    fancy_echo "  [$conv_count/$conv_total] Normalizing $base..." 33
    ffmpeg -hide_banner -loglevel error -y -i "$f" \
        -af loudnorm \
        -c:v copy -c:a aac -ar 48000 -ac 2 \
        "$out" || fancy_echo "    Skipped $base (could not normalize)." 31
done

fancy_echo "Step 3: Re-encoding normalized videos for concat compatibility..." 35

norm_files=("$norm_dir"/*.mp4)
norm_total=${#norm_files[@]}
norm_count=0

for f in "${norm_files[@]}"; do
    norm_count=$((norm_count + 1))
    base=$(basename "$f")
    out="$final_dir/$base"
    fancy_echo "  [$norm_count/$norm_total] Re-encoding $base..." 33
    ffmpeg -hide_banner -loglevel error -y -i "$f" \
        -vf "fps=30,scale=${resolution}:force_original_aspect_ratio=decrease,pad=${resolution}:(ow-iw)/2:(oh-ih)/2" \
        -c:v libx264 -preset fast -crf 23 -r 30 \
        -c:a aac -ar 48000 -ac 2 \
        -movflags +faststart \
        "$out" || fancy_echo "    Skipped $base (re-encode failed)." 31
done

fancy_echo "Step 4: Creating concat list file..." 35

ls "$final_dir"/*.mp4 | sort | awk '{print "file \x27"$0"\x27"} ' | sed "s|$workdir/||" > "$list_file"

fancy_echo "Concat list file contents:" 36
cat "$list_file"
echo

fancy_echo "Step 5: Concatenating all videos into $output_file..." 35
ffmpeg -hide_banner -loglevel error -y -f concat -safe 0 -i "$list_file" -c copy "$output_file"

fancy_echo "Step 6: Cleaning up temporary files..." 35
rm -rf "$workdir"

fancy_echo "All done! Merged video saved as $output_file" 32
