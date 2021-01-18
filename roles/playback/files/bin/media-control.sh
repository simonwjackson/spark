#!/bin/sh

mpvsocket="/tmp/mpv.socket" 
pianobarfifo="/tmp/pianobar.control" 
app=false

if [[ -n $(pidof pianobar) ]]; then	
  app="pianobar"
elif [[ -n $(pidof mpv) ]]; then
  app="mpv"
fi

case "$1" in 
  library)
    muzik library \
		| jq -r '.ids.youtube' \
		| internet-album --cache \
		| tr '\n' ' ' \
		| xargs mpv
		;; 
  search)
    muzik search \
		| jq -r '.ids.youtube' \
		| internet-album --cache \
		| tr '\n' ' ' \
		| xargs mpv
		;; 
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
		
	explain) 
		if [ "$app" = "pianobar" ]; then
			term-float "control-pianobar explain | fzf"
		fi
	;;

  # Skip song for 30 days
	tired) 
		if [ "$app" = "pianobar" ]; then
			echo -n 't' > "${pianobarfifo}"
		fi
		;;

	like) 
		if [ "$app" = "pianobar" ]; then
			control-pianobar love
		fi
		;;

	bookmark) 
		if [ "$app" = "pianobar" ]; then
			control-pianobar love
			sleep .25
			control-pianobar bookmark
			# youtube-dl \
			#   --format=bestaudio \
			#   --extract-audio \
			#   --audio-format vorbis \
			#   --output="${date_dir}/$(cat /tmp/pianobar.now-playing).%(ext)s" \
			#   ytsearch1:"$(cat /tmp/pianobar.now-playing)" 
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