function compress_to_webp
    if test (count $argv) -ne 1
        echo (set_color red)"Usage: compress_to_webp <input>"(set_color normal)
        return 1
    end

    set input_file $argv[1]
    set output_file (string replace -r '\.png$' '' $input_file)
    ffmpeg -hide_banner -loglevel error -i $input_file -c:v libwebp -quality 50 $output_file--WebP.webp
end
