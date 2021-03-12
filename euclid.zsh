typeset -g EUCLID="${0:A:h}"

euclid::optics() {
  case $# in
    1)
      local optics
      zstyle -s ":euclid:optics" "$1" optics
      echo -n "%F{${optics:-default}}"
      ;;
    2)
      zstyle ":euclid:optics" "$1" "$2"
      ;;
    *)
      return 1
      ;;
  esac
}

euclid::fragment() {
  case $# in
    1)
      local fragment
      zstyle -s ":euclid:fragments" "$1" fragment
      echo -n "$fragment"
      ;;
    2)
      zstyle ":euclid:fragments" "$1" "$2"
      ;;
    *)
      return 1
      ;;
  esac
}

euclid::element() {
  local id=$1
  shift
  euclid::optics "$id"
  printf "$(euclid::fragment "$id")" $@
  echo -n "%f"
}

function {
  local element
  for element ($EUCLID/elements/*) source $element
}

setopt prompt_subst transient_rprompt
PROMPT='$(euclid::logo)$(euclid::path)'
RPROMPT='$(euclid::git)'
