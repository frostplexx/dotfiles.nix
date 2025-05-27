#!/usr/bin/env fish

function compress_mov_to_mp4
    if test (count $argv) -ne 1
        echo (set_color red)"Usage: compress_mov_to_mp4 input.mov"(set_color normal)
        return 1
    end

    set input_file $argv[1]
    set output_file (string replace -r '\.mov$' '.mp4' $input_file)
    set input_dir (dirname $input_file)
    set start_time (date +%s)

    # Get video duration in seconds
    set duration (ffprobe -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $input_file)

    # Target size in bits (10MB = 10 * 1024 * 1024 * 8 bits, with 5% buffer)
    set target_size_bits (math "10 * 1024 * 1024 * 8 * 0.95")

    # Audio bitrate in bits per second
    set audio_bitrate 128000

    # Calculate video bitrate (total - audio, with safety margin)
    set video_bitrate (math "($target_size_bits / $duration) - $audio_bitrate")

    # Ensure minimum video bitrate
    if test $video_bitrate -lt 100000
        set video_bitrate 100000
    end

    # Convert to kbps for ffmpeg
    set video_bitrate_k (math "round($video_bitrate / 1000)")

    echo -e (set_color cyan)"Input file: $input_file"(set_color normal)
    echo (set_color yellow)"Duration:"(set_color normal) $duration (set_color yellow)"seconds"(set_color normal)
    echo (set_color yellow)"Target video bitrate:"(set_color normal) $video_bitrate_k (set_color yellow)"kbps"(set_color normal)

    # Two-pass encoding for better quality at target bitrate
    echo (set_color green)"Pass 1/2: Analyzing video..."(set_color normal)
    ffmpeg -y -loglevel quiet -i $input_file \
        -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
        -c:v libx264 \
        -preset slow \
        -r 30 \
        -fflags +genpts \
        -b:v "$video_bitrate_k"k \
        -pass 1 \
        -an \
        -f null /dev/null

    echo (set_color green)"Pass 2/2: Encoding final video..."(set_color normal)
    ffmpeg -hide_banner -v quiet -stats -i $input_file \
        -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
        -c:v libx264 \
        -preset slow \
        -fflags +genpts \
        -b:v "$video_bitrate_k"k \
        -pass 2 \
        -c:a aac \
        -r 30 \
        -b:a 128k \
        -map_metadata -1 \
        -fflags +bitexact \
        "Compressed-$output_file"

    # Clean up pass files
    rm -f ffmpeg2pass-0.log ffmpeg2pass-0.log.mbtree

    # Check final file size (macOS compatible)
    set final_size (stat -f%z "Compressed-$output_file")
    set final_size_mb (math "$final_size / 1024 / 1024")

    set end_time (date +%s)
    set duration_time (math $end_time - $start_time)

    echo (set_color green)"Final file size:"(set_color normal) $final_size_mb (set_color green)"MB"(set_color normal)
    echo (set_color green)"Time taken:"(set_color normal) $duration_time (set_color green)"seconds"(set_color normal)

    /etc/profiles/per-user/daniel/bin/kitten notify "File compressed to $final_size_mb MB in $duration_time seconds"
end
