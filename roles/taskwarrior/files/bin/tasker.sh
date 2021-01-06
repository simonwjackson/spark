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

function get_active_tasks () { 
    local return="${1}"
    local args="${@:2}"

    eval $return=$(\
        task \
            rc.verbose= \
            rc.json.array=off \
            ${args} \
            export \
        | jq -r 'select(.id != 0 and (.focus > 0 or .start != null)) | [.id,.description] | join("\t")' \
        | column -s $'\t' \
        | fzf \
            --reverse \
            --exit-0 \
            --delimiter "\t" \
            --with-nth 2 \
        | cut -f 1 \
    )
}

function quick_edit () { 
    local return="${1}"
    local args="${@:2}"
    local MYTEMP=$(mktemp)

    nvim -c "\
        set noshowmode \
        | set noruler \
        | startinsert \
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

    new_task="focus:1 ${task}"

    # TODO: move to hook
    if echo "${task}" | grep -vqi "pro.*:"; then
      project=$(
        task \
          rc.verbose= \
          rc.json.array=off \
          export \
        | jq \
          --raw-output \
          'select(.project != null and .status == "pending") | .project' \
        | uniq \
        | sort \
        | fzf --reverse --bind 'ctrl-a:print-query'
      )
      
      new_task="project:'${project}' ${new_task}" 
    fi

     task add ${new_task} \
     | sed 's/Created task \([[:digit:]]\+\)\./\1/' \
     | xargs task start
  ;; 

  add)
    [ -z "${task}" ] \
      && quick_edit task \
      || task="${@:2}"

    # TODO: move to hook
    if echo "${task}" | grep -vqi "pro.*:"; then
      project=$(
        task \
          rc.verbose= \
          rc.json.array=off \
          export \
        | jq \
          --raw-output \
          'select(.project != null and .status == "pending") | .project' \
        | uniq \
        | sort \
        | fzf --reverse --bind 'ctrl-a:print-query'
      )

      task add project:"${project}" ${task} 
    else
      task add ${task} 
    fi
  ;; 

  start)
    [ -z "${task}" ] && get_active_tasks task

    "${script_path}" stop
    task "${task}" start
  ;; 

  stop)
    yes yes | task +ACTIVE stop
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

$(simple-daily-report)




Completed
=========

$(task rc.verbose=label rc.report.completed.columns=entry.age,project,tags,description rc.report.completed.labels=Age,Project,Tags,Description end.after:today completed)



Ongoing
==========

$(task rc.verbose=label rc.report.active.columns=entry.age,depends.indicator,project,tags,due,description rc.report.active.labels=Age,D,Project,Tags,Due,Description started.after:today active)
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
    echo "add,now,start,stop,summary,journal" \
    | tr ',' '\n' \
    | fzf \
        --layout=reverse \
    | xargs "${script_path}"
  ;; 

esac
