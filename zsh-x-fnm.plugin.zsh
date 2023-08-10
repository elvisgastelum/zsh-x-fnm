#!/usr/bin/env zsh
# shellcheck disable=SC1090

# Exit if the 'fnm' command can not be found
if ! (( $+commands[fnm] )); then
    echo "WARNING: 'fnm' command not found"
    return
fi

# This little script will automatically switch to the node version specified inin
# the .node-version or .nvmrc file in the current directory, but only reading the first line.
eval $(fnm env)
autoload -U add-zsh-hook
function _fnm_autoload_hook () {
    if [[ -f .node-version ]]; then
        local node_version=$(head -n 1 .node-version)
        elif [[ -f .nvmrc ]]; then
        local node_version=$(head -n 1 .nvmrc)
    fi
    
    if [[ -n $node_version ]]; then
        fnm use --silent-if-unchanged --install-if-missing --version-file-strategy recursive "$node_version"
    else
        local current_version=$(fnm current)
        local default_version=$(fnm exec --using=default node --version)
        
        if [[ $current_version != $default_version ]]; then
            fnm use --silent-if-unchanged default
        fi
    fi
}

add-zsh-hook chpwd _fnm_autoload_hook \
&& _fnm_autoload_hook

rehash

# Add fnm completions
fnm_completion="$(dirname "$(readlink -f "$0")")/_fnm"
fpath=($fnm_completion $fpath)
fnm completions --shell zsh > "$fnm_completion"

