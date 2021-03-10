if ! [[ -v _gitstatus_plugin_dir ]] ; then
  source "${0:A:h}/gitstatus/gitstatus.plugin.zsh"
fi

typeset -gA EUCLID

EUCLID=(
  [LOGO]="%%F{default}\ufa62%%f"
  [PATH]="%%F{green}%%~%%f "
  [VICMD]="%%F{214}\ufa62%%f"
  [ERROR]="%%F{red}\ufa62%%f"
  [REF]="\uf417 %%F{242}%s%%f"
  [EVEN]=""
  [AHEAD]="%%F{214}+%%f"
  [BEHIND]="%%F{214}-%%f"
  [DIVERGED]="%%F{214}!%%f"
  [CLEAN]=" %%F{green}\uf7d7%%f"
  [STAGED]=" %%F{green}\uf7d8%%f"
  [UNSTAGED]=" %%F{red}\uf7d8%%f"
  [CONFLICT]=" %%F{red}\uf7d7%%f"
  [STASH]=" %%F{blue}\uf461%%f"
)

euclid::logo() {
  case "$KEYMAP" in
    vicmd) printf "${EUCLID[VICMD]}" ;;
    *) printf "%%(?.${EUCLID[LOGO]}.${EUCLID[ERROR]})" ;;
  esac
}

euclid::path() {
  printf "${EUCLID[PATH]}"
}

gitstatus_stop 'euclid' && gitstatus_start 'euclid'

euclid::ref() {
  gitstatus_query 'euclid'
  if [[ "$VCS_STATUS_RESULT" != 'ok-sync' ]]; then
    return 0
  elif [[ -n "$VCS_STATUS_LOCAL_BRANCH" ]]; then
    printf "${EUCLID[REF]}" "$VCS_STATUS_LOCAL_BRANCH"
  else
    printf "${EUCLID[REF]}" "${VCS_STATUS_COMMIT[1,7]}"
  fi
}

euclid::tracking() {
  gitstatus_query 'euclid'
  if [[ "$VCS_STATUS_RESULT" != 'ok-sync' ]]; then
    return 0
  elif (( !VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )); then
    printf "${EUCLID[EVEN]}"
  elif (( !VCS_STATUS_COMMITS_AHEAD && VCS_STATUS_COMMITS_BEHIND )); then
    printf "${EUCLID[BEHIND]}"
  elif (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )); then
    printf "${EUCLID[AHEAD]}"
  elif (( VCS_STATUS_COMMITS_AHEAD && VCS_STATUS_COMMITS_BEHIND )); then
    printf "${EUCLID[DIVERGED]}"
  fi
}

euclid::staging() {
  gitstatus_query 'euclid'
  if [[ "$VCS_STATUS_RESULT" != 'ok-sync' ]]; then
    return 0
  elif (( VCS_STATUS_HAS_CONFLICTED )); then
    printf "${EUCLID[CONFLICT]}"
  elif (( !VCS_STATUS_HAS_UNSTAGED && !VCS_STATUS_HAS_STAGED )); then
    printf "${EUCLID[CLEAN]}"
  elif (( VCS_STATUS_HAS_STAGED )); then
    printf "${EUCLID[STAGED]}"
  else
    printf "${EUCLID[UNSTAGED]}"
  fi
}

euclid::stash() {
  gitstatus_query 'euclid'
  if [[ "$VCS_STATUS_RESULT" != 'ok-sync' ]]; then
    return 0
  elif (( VCS_STATUS_STASHES )); then
    printf "${EUCLID[STASH]}"
  fi
}

setopt prompt_subst transient_rprompt
PROMPT='$(euclid::logo)$(euclid::path)'
RPROMPT='$(euclid::ref)$(euclid::tracking)$(euclid::staging)$(euclid::stash)'
