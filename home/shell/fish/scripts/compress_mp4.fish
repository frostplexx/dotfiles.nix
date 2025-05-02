#!/usr/bin/env fish

function compress_mov_to_mp4
    if test (count $argv) -ne 1
        echo "Usage: compress_mov_to_mp4 input.mov"
        return 1
    end
    
    set input_file $argv[1]
    set output_file (string replace -r '\.mov$' '.mp4' $input_file)
    set input_dir (dirname $input_file)
    set start_time (date +%s)
    
    # Create a horizontal split and run ffmpeg on the left, btop on the right
    ffmpeg -i $input_file \
           -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
           -c:v libx264 \
           -preset slow \
           -crf 22 \
           -c:a aac \
           -b:a 128k \
           $output_file
    
    set end_time (date +%s)
    set duration (math $end_time - $start_time)
    
    /Applications/kitty.app/Contents/MacOS/kitten notify "File compressed in $duration seconds"
end
