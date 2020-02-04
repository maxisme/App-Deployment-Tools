#ffmpeg -i $1 -r 10 -f image2pipe -vcodec ppm - | convert -delay 5 -loop 0 - output.gif
ffmpeg -i "$1" -f gif - | gifsicle --optimize=3 --delay=3 > $1.gif
