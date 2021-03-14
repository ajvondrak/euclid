typeset -g EUCLID="${0:A:h}"

euclid::elements() {
  local element
  local -a elements

  for element in $@; do
    element=$(euclid::element $element)
    [[ -n $element ]] && elements+=$element
  done

  echo -n "${(j: :)elements}"
}

euclid::element() {
  case $# in
    1)
      local element
      zstyle -s ":euclid:elements" "$1" element
      $element
      ;;
    2)
      zstyle ":euclid:elements" "$1" "$2"
      ;;
    *)
      return 1
      ;;
  esac
}

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
  local name=$1
  local data
  shift
  data=$(printf "$(euclid::data "$name")" $@)
  if [[ -n $data ]]; then
    euclid::optics "$name"
    echo -n "$data"
    echo -n "%f"
  fi
}

function {
  autoload -Uz add-zsh-hook
  setopt localoptions extendedglob
  local file
  for file ($EUCLID/data/**/* $EUCLID/elements/**/*) source $file
}

setopt prompt_subst
PROMPT='$(euclid::elements "logo" "path")'
RPROMPT='$(euclid::elements "git:ref" "git:tracking" "git:index" "git:stash")'
