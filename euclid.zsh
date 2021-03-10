if ! [[ -v _gitstatus_plugin_dir ]] ; then
  source "${0:A:h}/gitstatus/gitstatus.plugin.zsh"
fi

typeset -gA EUCLID

EUCLID=(
  [LOGO]="%%F{default}\ufa62%%f"
  [PATH]="%%F{green}%%~%%f "
  [VICMD]="%%F{214}\ufa62%%f"
  [ERROR]="%%F{red}\ufa62%%f"
  [TAG]="\uf412 %%F{242}%s%%f"
  [BRANCH]="\uf418 %%F{242}%s%%f"
  [COMMIT]="\uf417 %%F{242}%s%%f"
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
  elif [[ -n "$VCS_STATUS_TAG" ]]; then
    printf "${EUCLID[TAG]}" "$VCS_STATUS_TAG"
  elif [[ -n "$VCS_STATUS_LOCAL_BRANCH" ]]; then
    printf "${EUCLID[BRANCH]}" "$VCS_STATUS_LOCAL_BRANCH"
  else
    printf "${EUCLID[COMMIT]}" "${VCS_STATUS_COMMIT[1,7]}"
  fi
}

euclid::tracking() {
  gitstatus_query 'euclid'
  local format
  if [[ "$VCS_STATUS_RESULT" != 'ok-sync' ]]; then
    return 0
  elif (( !VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )); then
    format="${EUCLID[EVEN]}"
  elif (( !VCS_STATUS_COMMITS_AHEAD && VCS_STATUS_COMMITS_BEHIND )); then
    format="${EUCLID[BEHIND]}"
  elif (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )); then
    format="${EUCLID[AHEAD]}"
  elif (( VCS_STATUS_COMMITS_AHEAD && VCS_STATUS_COMMITS_BEHIND )); then
    format="${EUCLID[DIVERGED]}"
  fi
  printf "$format" "$VCS_STATUS_COMMITS_AHEAD" "$VCS_STATUS_COMMITS_BEHIND"
}

euclid::staging() {
  gitstatus_query 'euclid'
  local format
  if [[ "$VCS_STATUS_RESULT" != 'ok-sync' ]]; then
    return 0
  elif (( VCS_STATUS_HAS_CONFLICTED )); then
    printf "${EUCLID[CONFLICT]}" "$VCS_STATUS_NUM_CONFLICTED"
  elif (( !VCS_STATUS_HAS_UNSTAGED && !VCS_STATUS_HAS_STAGED )); then
    format="${EUCLID[CLEAN]}"
  elif (( VCS_STATUS_HAS_STAGED )); then
    format="${EUCLID[STAGED]}"
  else
    format="${EUCLID[UNSTAGED]}"
  fi
  printf "$format" \
    "$VCS_STATUS_NUM_STAGED" \
    "$VCS_STATUS_NUM_UNSTAGED" \
    "$VCS_NUM_STATUS_UNTRACKED"
}

euclid::stash() {
  gitstatus_query 'euclid'
  if [[ "$VCS_STATUS_RESULT" != 'ok-sync' ]]; then
    return 0
  elif (( VCS_STATUS_STASHES )); then
    printf "${EUCLID[STASH]}" "$VCS_STATUS_STASHES"
  fi
}

setopt prompt_subst transient_rprompt
PROMPT='$(euclid::logo)$(euclid::path)'
RPROMPT='$(euclid::ref)$(euclid::tracking)$(euclid::staging)$(euclid::stash)'
