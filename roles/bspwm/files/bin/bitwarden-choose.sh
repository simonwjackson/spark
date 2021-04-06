#!/bin/sh

immediate=0

while :; do
  case $1 in
    -i|--immediate)
      shift
      immediate=1
      break
    ;;
    *)
      break
    ;; 
  esac
  shift
done

DOMAIN="$(
  echo "$@" \
  | sed -e 's/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/'
)"

bw list items \
| jq -r '.[]?
  | select(.login.uris[]?.uri
      | contains("'${DOMAIN}'")
    )
  | [.name, .login.username, .login.password] 
  | join("^^^")' \
| column \
  --separator "^^^" \
  --table \
| fzf \
  --delimiter "   *" \
  --bind 'ctrl-u:execute^awk "{print \$2}" <(echo {..}) < /dev/tty > /dev/tty 2>&1^+abort' \
  --bind 'ctrl-p:execute^awk "{print \$3}" <(echo {..}) < /dev/tty > /dev/tty 2>&1^+abort' \
  --with-nth 1,2 \
  $([ "${immediate}" == "1" ] && echo --select-1) \
  --exit-0 \
| awk '{print $2" "$3}'
