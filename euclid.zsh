typeset -g EUCLID="${0:A:h}"

euclid::optics() {
  case $# in
    1)
      local optics
      zstyle -s ":euclid:$1" "optics" optics
      echo -n "%F{${optics:-default}}"
      ;;
    2)
      zstyle ":euclid:$1*" "optics" "$2"
      ;;
    *)
      return 1
      ;;
  esac
}

euclid::data() {
  case $# in
    1)
      local data
      zstyle -s ":euclid:$1" "data" data
      echo -n "$data"
      ;;
    2)
      zstyle ":euclid:$1*" "data" "$2"
      ;;
    *)
      return 1
      ;;
  esac
}

euclid::fragment() {
  local id=$1
  shift
  euclid::optics "$id"
  printf "$(euclid::data "$id")" $@
  echo -n "%f"
}

function {
  local element
  for element ($EUCLID/elements/*) source $element
}

setopt prompt_subst transient_rprompt
PROMPT='$(euclid::logo)$(euclid::path)'
RPROMPT='$(euclid::git)'
