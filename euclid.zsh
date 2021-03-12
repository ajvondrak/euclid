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

euclid::fragment "logo" "\ufa62"
euclid::fragment "logo vicmd" $(euclid::fragment "logo")
euclid::fragment "logo error" $(euclid::fragment "logo")
euclid::fragment "path" "%%~ "

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
    printf "$(euclid::optics "TAG")" "$VCS_STATUS_TAG"
  elif [[ -n "$VCS_STATUS_LOCAL_BRANCH" ]]; then
    printf "$(euclid::optics "BRANCH")" "$VCS_STATUS_LOCAL_BRANCH"
  else
    printf "$(euclid::optics "COMMIT")" "${VCS_STATUS_COMMIT[1,7]}"
  fi
}

euclid::tracking() {
  local format
  if (( !VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )); then
    format=$(euclid::optics "EVEN")
  elif (( !VCS_STATUS_COMMITS_AHEAD && VCS_STATUS_COMMITS_BEHIND )); then
    format=$(euclid::optics "BEHIND")
  elif (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )); then
    format=$(euclid::optics "AHEAD")
  elif (( VCS_STATUS_COMMITS_AHEAD && VCS_STATUS_COMMITS_BEHIND )); then
    format=$(euclid::optics "DIVERGED")
  fi
  printf "$format" "$VCS_STATUS_COMMITS_AHEAD" "$VCS_STATUS_COMMITS_BEHIND"
}

euclid::staging() {
  if (( VCS_STATUS_HAS_CONFLICTED )); then
    printf $(euclid::optics "CONFLICT") "$VCS_STATUS_NUM_CONFLICTED"
  elif (( !VCS_STATUS_HAS_UNSTAGED &&
          !VCS_STATUS_HAS_STAGED &&
          !VCS_STATUS_HAS_UNTRACKED )); then
    format=$(euclid::optics "CLEAN")
  elif (( VCS_STATUS_HAS_STAGED )); then
    format=$(euclid::optics "STAGED")
  else
    format=$(euclid::optics "UNSTAGED")
  fi
  printf "$format" \
    "$VCS_STATUS_NUM_STAGED" \
    "$VCS_STATUS_NUM_UNSTAGED" \
    "$VCS_NUM_STATUS_UNTRACKED"
}

euclid::stash() {
  if (( VCS_STATUS_STASHES )); then
    printf "$(euclid::optics "STASH")" "$VCS_STATUS_STASHES"
  fi
}

setopt prompt_subst transient_rprompt
PROMPT='$(euclid::logo)$(euclid::path)'
RPROMPT='$(euclid::git)'
