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

euclid::optics "LOGO" "%%F{default}\ufa62%%f"
euclid::optics "PATH" "%%F{green}%%~%%f "
euclid::optics "VICMD" "%%F{214}\ufa62%%f"
euclid::optics "ERROR" "%%F{red}\ufa62%%f"
euclid::optics "TAG" "%%F{13}\uf412 %s%%f"
euclid::optics "BRANCH" "%%F{13}\uf418 %s%%f"
euclid::optics "COMMIT" "%%F{13}\uf417 %s%%f"
euclid::optics "EVEN" ""
euclid::optics "AHEAD" " %%F{214}\uf44d%%f"
euclid::optics "BEHIND" " %%F{214}\uf48b%%f"
euclid::optics "DIVERGED" " %%F{214}\uf467%%f"
euclid::optics "CLEAN" " %%F{green}\uf7d7%%f"
euclid::optics "STAGED" " %%F{green}\uf7d8%%f"
euclid::optics "UNSTAGED" " %%F{red}\uf7d8%%f"
euclid::optics "CONFLICT" " %%F{red}\uf7d7%%f"
euclid::optics "STASH" " %%F{blue}\uf461%%f"

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

euclid::logo() {
  if [[ $KEYMAP = "vicmd" ]]; then
    euclid::optics "logo vicmd"
    printf "$(euclid::fragment "logo vicmd")"
    euclid::optics "reset"
  else
    echo -n "%(?.$(euclid::optics "logo").$(euclid::optics "logo error"))"
    echo -n "%(?.$(euclid::fragment "logo").$(euclid::fragment "logo error"))"
    euclid::optics "reset"
  fi
}

euclid::path() {
  euclid::optics "path"
  printf "$(euclid::fragment "path")"
  euclid::optics "reset"
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
    euclid::optics "tag"
    printf "$(euclid::fragment "tag")" "$VCS_STATUS_TAG"
    euclid::optics "reset"
  elif [[ -n "$VCS_STATUS_LOCAL_BRANCH" ]]; then
    euclid::optics "branch"
    printf "$(euclid::fragment "branch")" "$VCS_STATUS_LOCAL_BRANCH"
    euclid::optics "reset"
  else
    euclid::optics "commit"
    printf "$(euclid::fragment "commit")" "${VCS_STATUS_COMMIT[1,7]}"
    euclid::optics "reset"
  fi
}

euclid::tracking() {
  local format
  if (( !VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )); then
    euclid::optics "even"
    format=$(euclid::fragment "even")
  elif (( !VCS_STATUS_COMMITS_AHEAD && VCS_STATUS_COMMITS_BEHIND )); then
    euclid::optics "behind"
    format=$(euclid::fragment "behind")
  elif (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )); then
    euclid::optics "ahead"
    format=$(euclid::fragment "ahead")
  elif (( VCS_STATUS_COMMITS_AHEAD && VCS_STATUS_COMMITS_BEHIND )); then
    euclid::optics "diverged"
    format=$(euclid::fragment "diverged")
  fi
  printf "$format" "$VCS_STATUS_COMMITS_AHEAD" "$VCS_STATUS_COMMITS_BEHIND"
  euclid::optics "reset"
}

euclid::staging() {
  if (( VCS_STATUS_HAS_CONFLICTED )); then
    euclid::optics "conflict"
    printf "$(euclid::fragment "conflict")" "$VCS_STATUS_NUM_CONFLICTED"
  elif (( !VCS_STATUS_HAS_UNSTAGED &&
          !VCS_STATUS_HAS_STAGED &&
          !VCS_STATUS_HAS_UNTRACKED )); then
    euclid::optics "clean"
    format=$(euclid::fragment "clean")
  elif (( VCS_STATUS_HAS_STAGED )); then
    euclid::optics "staged"
    format=$(euclid::fragment "staged")
  else
    euclid::optics "unstaged"
    format=$(euclid::fragment "unstaged")
  fi
  printf "$format" \
    "$VCS_STATUS_NUM_STAGED" \
    "$VCS_STATUS_NUM_UNSTAGED" \
    "$VCS_NUM_STATUS_UNTRACKED"
  euclid::optics "reset"
}

euclid::stash() {
  if (( VCS_STATUS_STASHES )); then
    euclid::optics "stash"
    printf "$(euclid::fragment "stash")" "$VCS_STATUS_STASHES"
    euclid::optics "reset"
  fi
}

setopt prompt_subst transient_rprompt
PROMPT='$(euclid::logo)$(euclid::path)'
RPROMPT='$(euclid::git)'
