# shellcheck disable=all

# Add custom functions to fpath before conf.d loads
if [[ -d "${ZDOTDIR}/functions" ]]; then
  fpath=( "${ZDOTDIR}/functions" $fpath )
fi

# source configs in .zsh/configs
if [[ -d "${ZDOTDIR}/conf.d" ]]; then
  for config in ${ZDOTDIR}/conf.d/*.zsh; do
    source $config
  done
fi

# source aliases in .zsh/aliases
if [[ -d "${ZDOTDIR}/aliases" ]]; then
  for alias in ${ZDOTDIR}/aliases/*.zsh; do
    source $alias
  done
fi
