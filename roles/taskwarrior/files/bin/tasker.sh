#!/bin/sh

script_path=`realpath $0`

function taskw_json () {
    local return=$1
    eval $return="$(task \
        rc.verbose= \
        rc.json.array=off \
        2 \
        export
    )"
}

function is_started () { 
    local return=$1
    local task=$2

    eval $return="$(
      task \
        rc.verbose= \
        active ${task} \
      | wc -l
    )"
}

function get_task () { 
    local return="${1}"
    local args="${@:2}"

    eval $return=$(
        task \
            rc.verbose= \
            rc.json.array=off \
            ${args} \
            export \
        | jq -r '. | [.id,.description] | join("\t")' \
        | column --table -s "\t" \
        | fzf \
            --reverse \
            --exit-0 \
            --delimiter "\t" \
            --with-nth 2 \
        | cut -f 1
    )
}

function quick_edit () { 
    local return="${1}"
    local args="${@:2}"
    local MYTEMP=$(mktemp)

    nvim -c "\
        set noshowmode \
        | set noruler \
        | set laststatus=0 \
        | set noshowcmd \
        | set cmdheight=1 \
        | nnoremap <ENTER> :x<ENTER> \
        | nnoremap <ESC><ESC> :q\!<ENTER> \
        | inoremap <ENTER> <ESC>:x<ENTER> \
    " $MYTEMP
    
    line="$(cat $MYTEMP)"
    eval $return="'$line'"

    rm $MYTEMP
}

cmd=$1
task=$2

case "${cmd}" in 
  now)
    [ -z "${task}" ] \
      && quick_edit task \
      || task="${@:2}"

    task add ${task} \
    | sed 's/Created task \([[:digit:]]\+\)\./\1/' \
    | xargs task start
  ;; 

  add)
    [ -z "${task}" ] \
      && quick_edit task \
      || task="${@:2}"

    task add ${task} 
  ;; 

  start)
    [ -z "${task}" ] && get_task task -ACTIVE

    is_started result "${task}"

    task "${task}" start
  ;; 

  # TODO: Start and stop do not work. Export dumps the entire DB
  # you can get the ids of filtered items and then xargs over them
  # with task X export

  stop)
    [ -z "${task}" ] && get_task task +ACTIVE

    is_started result "${task}"

    task "${task}" stop
  ;; 

  toggle)
    [ -z "${task}" ] && get_task task

    is_started result "${task}"

    (( ${result} == 0 )) \
      && task "${task}" start \
      || task "${task}" stop
  ;; 

  journal)
    fullpath="${HOME}/journal/$(date +"%Y-%m")/$(date +%F).md"
		mkdir -p "$(dirname ${fullpath})"
    overwrite="y"
 
    if [[ -f "${fullpath}" ]]; then 
      overwrite="n"
    # if [[ -f "${fullpath}" ]]; then
    #   while true; do 
    #     read -p "Entry exists. Overwrite? (y/n)" yn
    #     case $yn in
    #       [Yy]* ) overwrite="y"; break;;
    #       [Nn]* ) break;;
    #       * ) echo "Please answer yes or no.";;
    #     esac
    #   done
    # fi
    fi

    if [[ $overwrite == "y" ]]; then echo "
Summary
=======




Timesheet
=========

$(timew summary)




Completed
=========

$(task rc.verbose=label end.after:today completed)




Ongoing
==========

$(task rc.verbose=label started.after:today active)
" \
      | perl -0pe 's/^\s+|\s+$//g' \
      > "${fullpath}"
    fi

  nvim +4 -c "startinsert" "${fullpath}"
  ;; 

  summary)
    timew summary | less
  ;; 


  *)
    echo "add,now,start,stop,toggle,summary,journal" \
    | tr ',' '\n' \
    | fzf \
        --layout=reverse \
    | xargs "${script_path}"
  ;; 

esac