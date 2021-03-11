if ! [[ -v _gitstatus_plugin_dir ]] ; then
  source "${0:A:h}/gitstatus/gitstatus.plugin.zsh"
fi

typeset -gA EUCLID

EUCLID=(
  [LOGO]="%%F{default}\ufa62%%f"
  [PATH]="%%F{green}%%~%%f "
  [VICMD]="%%F{214}\ufa62%%f"
  [ERROR]="%%F{red}\ufa62%%f"
  [TAG]="%%F{13}\uf412 %s%%f"
  [BRANCH]="%%F{13}\uf418 %s%%f"
  [COMMIT]="%%F{13}\uf417 %s%%f"
  [EVEN]=""
  [AHEAD]=" %%F{214}\uf44d%%f"
  [BEHIND]=" %%F{214}\uf48b%%f"
  [DIVERGED]=" %%F{214}\uf467%%f"
  [CLEAN]=" %%F{green}\uf7d7%%f"
  [STAGED]=" %%F{green}\uf7d8%%f"
  [UNSTAGED]=" %%F{red}\uf7d8%%f"
  [CONFLICT]=" %%F{red}\uf7d7%%f"
  [STASH]=" %%F{blue}\uf461%%f"
)

euclid::optics() {
  echo -n $EUCLID[$1]
}

euclid::logo() {
  case "$KEYMAP" in
    vicmd) printf "$(euclid::optics "VICMD")" ;;
    *) printf "%%(?.$(euclid::optics "LOGO").$(euclid::optics "ERROR"))" ;;
  esac
}

euclid::path() {
  printf "$(euclid::optics "PATH")"
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
