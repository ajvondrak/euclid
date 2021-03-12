if ! [[ -v _gitstatus_plugin_dir ]] ; then
  source "${0:A:h}/gitstatus/gitstatus.plugin.zsh"
fi

euclid::optics() {
  case $# in
    1)
      local optics
      zstyle -s ":euclid:optics" "$1" optics
      echo -n "$optics"
      ;;
    2)
      zstyle ":euclid:optics" "$1" "$2"
      ;;
    *)
      return 1
      ;;
  esac
}

euclid::optics "reset" "%f"
euclid::optics "logo" "%F{default}"
euclid::optics "logo vicmd" "%F{214}"
euclid::optics "logo error" "%F{red}"
euclid::optics "path" "%F{green}"
euclid::optics "tag" "%F{13}"
euclid::optics "branch" "%F{13}"
euclid::optics "commit" "%F{13}"
euclid::optics "even" ""
euclid::optics "ahead" "%F{214}"
euclid::optics "behind" "%F{214}"
euclid::optics "diverged" "%F{214}"
euclid::optics "clean" "%F{green}"
euclid::optics "staged" "%F{green}"
euclid::optics "unstaged" "%F{red}"
euclid::optics "conflict" "%F{red}"
euclid::optics "stash" "%F{blue}"

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

euclid::fragment "logo" "\ufa62"
euclid::fragment "logo vicmd" $(euclid::fragment "logo")
euclid::fragment "logo error" $(euclid::fragment "logo")
euclid::fragment "path" "%%~ "
euclid::fragment "tag" "\uf412 %s"
euclid::fragment "branch" "\uf418 %s"
euclid::fragment "commit" "\uf417 %s"
euclid::fragment "even" ""
euclid::fragment "ahead" " \uf44d"
euclid::fragment "behind" " \uf48b"
euclid::fragment "diverged" " \uf467"
euclid::fragment "clean" " \uf7d7"
euclid::fragment "staged" " \uf7d8"
euclid::fragment "unstaged" " \uf7d8"
euclid::fragment "conflict" " \uf7d7"
euclid::fragment "stash" " \uf461"

euclid::element() {
  local id=$1
  shift
  euclid::optics "$id"
  printf "$(euclid::fragment "$id")" $@
  euclid::optics "reset"
}

euclid::logo() {
  if [[ $KEYMAP = "vicmd" ]]; then
    euclid::element "logo vicmd"
  else
    echo -n "%(?.$(euclid::optics "logo").$(euclid::optics "logo error"))"
    echo -n "%(?.$(euclid::fragment "logo").$(euclid::fragment "logo error"))"
    euclid::optics "reset"
  fi
}

euclid::path() {
  euclid::element "path"
}

gitstatus_stop 'euclid' && gitstatus_start 'euclid'

euclid::git() {
  gitstatus_query 'euclid'
  [[ $VCS_STATUS_RESULT == "ok-sync" ]] || return
  euclid::ref
  euclid::tracking
  euclid::staging
  euclid::stash
}

euclid::ref() {
  if [[ -n "$VCS_STATUS_TAG" ]]; then
    euclid::element "tag" "$VCS_STATUS_TAG"
  elif [[ -n "$VCS_STATUS_LOCAL_BRANCH" ]]; then
    euclid::element "branch" "$VCS_STATUS_LOCAL_BRANCH"
  else
    euclid::element "commit" "${VCS_STATUS_COMMIT[1,7]}"
  fi
}

euclid::tracking() {
  local ahead=$VCS_STATUS_COMMITS_AHEAD behind=$VCS_STATUS_COMMITS_BEHIND

  if (( !ahead && !behind )); then
    euclid::element "even" $ahead $behind
  elif (( !ahead && behind )); then
    euclid::element "behind" $ahead $behind
  elif (( ahead && !behind )); then
    euclid::element "ahead" $ahead $behind
  elif (( ahead && behind )); then
    euclid::element "diverged" $ahead $behind
  fi
}

euclid::staging() {
  local staged unstaged untracked conflicts
  staged=$VCS_STATUS_NUM_STAGED
  unstaged=$VCS_STATUS_NUM_UNSTAGED
  untracked=$VCS_STATUS_NUM_UNTRACKED
  conflicts=$VCS_STATUS_NUM_CONFLICTED

  if (( conflicts )); then
    euclid::element "conflict" $conflicts
  elif (( !staged && !unstaged && !untracked )); then
    euclid::element "clean" $staged $unstaged $untracked
  elif (( staged )); then
    euclid::element "staged" $staged $unstaged $untracked
  else
    euclid::element "unstaged" $staged $unstaged $untracked
  fi
}

euclid::stash() {
  if (( VCS_STATUS_STASHES )); then
    euclid::element "stash" "$VCS_STATUS_STASHES"
  fi
}

setopt prompt_subst transient_rprompt
PROMPT='$(euclid::logo)$(euclid::path)'
RPROMPT='$(euclid::git)'
