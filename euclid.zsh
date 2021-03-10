if ! [[ -v _gitstatus_plugin_dir ]] ; then
  source "${0:A:h}/gitstatus/gitstatus.plugin.zsh"
fi

typeset -gA EUCLID

EUCLID=(
  [LOGO]="%F{default}\ufa62%f"
  [PATH]="%F{green}%~%f"
  [VICMD]="%F{214}\ufa62%f"
  [ERROR]="%F{red}\ufa62%f"
  [REF]="\uf417 %%F{242}%s%%f"
  [EVEN]=""
  [AHEAD]="%F{214}+%f"
  [BEHIND]="%F{214}-%f"
  [DIVERGED]="%F{214}!%f"
  [CLEAN]="%F{green}\uf7d7%f"
  [STAGED]="%F{green}\uf7d8%f"
  [UNSTAGED]="%F{red}\uf7d8%f"
  [DIRTY]="%F{red}\uf7d7%f"
  [CONFLICT]="%F{red}\ufbdf%f"
  [STASH]="%F{blue}\uf461%f"
)
