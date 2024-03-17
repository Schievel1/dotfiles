. "$HOME/.cargo/env"

export PAGER='moar'
export GPG_TTY=$TTY
export JAVA_HOME=/usr/lib/jvm/openjdk-bin-17/

#. /usr/share/zsh/site-functions/zsh-autosuggestions.zsh

export HISTFILE=~/.histfile
export HISTSIZE=1000000   # the number of items for the internal history list
export SAVEHIST=1000000   # maximum number of items for the history file
export DOOMDIR=~/.config/doom

export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git' 2> /dev/null"
