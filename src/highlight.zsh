#!/bin/zsh

_hac_highlight_command() {
    local text="$1"
    local search_term="$2"
    local cmd_part="${text%% *}"
    local arg_part="${text#* }"

    if [[ "$text" == "$cmd_part" ]]; then
        arg_part=""
    fi

    local result=""

    if [[ -n "$search_term" && $ZSH_AUTOCOMPLETE_FUZZY -eq 1 ]]; then
        # Highlight matched characters in the command
        result+="${ZSH_AUTOCOMPLETE_CMD_COLOR}"
        local si=0 slen=${#search_term}
        local full_text="$text"
        local hi=0

        for (( hi=0; hi<${#full_text}; hi++ )); do
            local char="${full_text:$hi:1}"
            if (( si < slen )) && [[ "$char" == "${search_term:$si:1}" ]]; then
                result+="${ZSH_AUTOCOMPLETE_MATCH_COLOR}${char}${ZSH_AUTOCOMPLETE_CMD_COLOR}"
                (( si++ ))
            elif (( hi < ${#cmd_part} )); then
                result+="${char}"
            else
                if (( hi == ${#cmd_part} )); then
                    result+="${ZSH_AUTOCOMPLETE_ARG_COLOR}"
                fi
                result+="${char}"
            fi
        done
    else
        result+="${ZSH_AUTOCOMPLETE_CMD_COLOR}${cmd_part}"
        if [[ -n "$arg_part" ]]; then
            result+="${ZSH_AUTOCOMPLETE_ARG_COLOR} ${arg_part}"
        fi
    fi

    result+="${ZSH_AUTOCOMPLETE_RESET_COLOR}"
    printf '%s' "$result"
}
