if [[ $# -ne 1 ]]; then
    echo "Usage: compress_mov_to_mp4 input.mov"
    return 1
fi

input_file="$1"
output_file="${input_file:r}.mp4"
input_dir="$(dirname "$input_file")"

start_time=$(date +%s)

# Create a horizontal split and run ffmpeg on the left, btop on the right
ffmpeg -i "$input_file" \
       -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
       -c:v libx264 \
       -preset slow \
       -crf 22 \
       -c:a aac \
       -b:a 128k \
       "$output_file"

wait

end_time=$(date +%s)
duration=$((end_time - start_time))

/Applications/kitty.app/Contents/MacOS/kitten notify "File compressed in $duration seconds"
