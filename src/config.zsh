#!/bin/zsh

# Max suggestions in menu and inline
: ${ZSH_AUTOCOMPLETE_MAX_SUGGESTIONS:=5}

# Fuzzy matching (0=prefix only, 1=fuzzy)
: ${ZSH_AUTOCOMPLETE_FUZZY:=1}

# Highlight colors
: ${ZSH_AUTOCOMPLETE_CMD_COLOR:=$'\033[1;32m'}    # bold green for commands
: ${ZSH_AUTOCOMPLETE_ARG_COLOR:=$'\033[0;37m'}    # white for arguments
: ${ZSH_AUTOCOMPLETE_MATCH_COLOR:=$'\033[1;33m'}  # bold yellow for matched chars
: ${ZSH_AUTOCOMPLETE_GHOST_COLOR:="fg=242"}       # dim for inline ghost text
: ${ZSH_AUTOCOMPLETE_RESET_COLOR:=$'\033[0m'}
