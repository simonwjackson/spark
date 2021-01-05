#!/bin/sh

mpvsocket="/tmp/mpv.socket" 
pianobarfifo="/tmp/pianobar.ctl" 
app=false

if ps -e | grep pianobar; then
  app="pianobar"
elif ps -e | grep mpv; then
  app="mpv"
fi

case "$1" in 
	toggle) 
		if [ "$app" = "pianobar" ]; then
			echo -n 'p' > "${pianobarfifo}"
		elif [ "$app" = "mpv" ]; then
			echo '{ "command": ["cycle", "pause"] }' | socat - "${mpvsocket}"
		#else 
		#	curl "https://autoremotejoaomgcd.appspot.com/sendmessage?key=$AUTOREMOTE_KEY&message=media=:=toggle"
		fi 
		;; 

	prev) 
		if [ "$app" = "mpv" ]; then
			echo '{ "command": ["playlist-prev"] }' | socat - ${mpvsocket}
		#else 
		#	curl "https://autoremotejoaomgcd.appspot.com/sendmessage?key=$AUTOREMOTE_KEY&message=media=:=prev"
		fi 
		;; 

	next) 
		if [ "$app" = "pianobar" ]; then
			echo -n 'n' > "${pianobarfifo}"
		elif [ "$app" = "mpv" ]; then
			echo '{ "command": ["playlist-next"] }' | socat - ${mpvsocket}
		else 
			curl "https://autoremotejoaomgcd.appspot.com/sendmessage?key=$AUTOREMOTE_KEY&message=media=:=next"
		fi
		;; 
		
	seek)
		echo "{ \"command\": [\"seek\", \"${2}\"] }" | socat - ${mpvsocket}
		;;

    # Skip song for 30 days
	tired) 
		if [ "$app" = "pianobar" ]; then
			echo -n 't' > "${pianobarfifo}"
		fi
		;;

	love) 
		if [ "$app" = "pianobar" ]; then
			echo -n '+' > "${pianobarfifo}"
            date_with_week_num=$(date +"%Y-%m.w%W")
			music_dir="${HOME}/new-music"
			date_dir="${music_dir}/${date_with_week_num}"
			mkdir -p "${date_dir}"
			cat /tmp/pianobar.nowplaying >> "${date_dir}/${date_with_week_num}.txt"
			# Uniqe lines
			awk '!seen[$0]++' "${date_dir}/${date_with_week_num}.txt"
			youtube-dl \
			  --format=bestaudio \
			  --extract-audio \
			  --audio-format vorbis \
			  --output="${date_dir}/$(cat /tmp/pianobar.nowplaying).%(ext)s" \
			  ytsearch1:"$(cat /tmp/pianobar.nowplaying)" 
		fi
		;;

	ban) 
		if [ "$app" = "pianobar" ]; then
			echo -n '-' > "${pianobarfifo}"
		fi
		;;		
	*)
		echo "prev\nnext\nseek" \
			| fzf \
				--inline-info \
				--layout=reverse \
			| xargs -I %a "${file}" %a

esac