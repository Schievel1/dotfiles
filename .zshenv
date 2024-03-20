. "$HOME/.cargo/env"

export PAGER='moar'
export GPG_TTY=$TTY
export JAVA_HOME=/usr/lib/jvm/openjdk-bin-17/


#. /usr/share/zsh/site-functions/zsh-autosuggestions.zsh
export PATH="$HOME/.config/emacs/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/bin:$HOME/dev/platform-tools:$JAVA_HOME/bin:$PATH"
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
export PATH="$HOME/dev/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/bin:$PATH"
export XDG_CONFIG_HOME=~/.config
export HISTFILE=~/.histfile
export HISTSIZE=1000000   # the number of items for the internal history list
export SAVEHIST=1000000   # maximum number of items for the history file
export DOOMDIR=${XDG_CONFIG_HOME}/doom
