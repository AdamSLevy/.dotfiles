compdef '_dispatch which which' vim-which
compdef '_dispatch which which' cat-which

# Terraform completion
autoload -U +X bashcompinit && bashcompinit
# complete -o nospace -C /opt/local/bin/terraform terraform

# colored completion output for directories
zstyle ':completion:*:default' list-colors ${(s.:.)LSCOLORS}

# sort completions for files by access time. Follow symlinks for timestamp info.
zstyle ':completion:*' file-sort access follow

# group the different type of matches under their descriptions
zstyle ':completion:*' group-name ''

zstyle ':completion:*:*:-command-:*:*' group-order 'alias' 'builtins' 'functions' 'commands'

# zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-/]=* r:|=*' 'l:|=* r:|=*'

# zstyle ':completion:*' accept-exact false

# format descriptions, messages, and warnings
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'

# complete options if arg starts with -
# zstyle ':completion:*' complete-options true

# vim: ft=zsh sw=2 ts=2 et
