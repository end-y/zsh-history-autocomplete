#!/bin/zsh

[[ $- == *i* ]] || return 0

if [[ -o interactive ]]; then
    zmodload zsh/zle
    zmodload zsh/zleparameter
    autoload -Uz add-zle-hook-widget
fi

# Resolve the directory this script lives in
_HAC_DIR="${0:A:h}"

source "${_HAC_DIR}/config.zsh"
source "${_HAC_DIR}/history.zsh"
source "${_HAC_DIR}/highlight.zsh"
source "${_HAC_DIR}/suggestion.zsh"
source "${_HAC_DIR}/menu.zsh"

if [[ -o interactive ]]; then
    zle -N autocomplete_history
    zle -N accept_suggestion
    zle -N show_suggestions

    add-zle-hook-widget -Uz line-pre-redraw autocomplete_history

    bindkey '^I' accept_suggestion
    bindkey '^W' show_suggestions
fi
