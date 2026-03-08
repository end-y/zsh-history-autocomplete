#!/bin/zsh

autocomplete_history() {
    POSTDISPLAY=""
    region_highlight=()
    local input_text="${BUFFER}"

    if [[ -z "${input_text// /}" ]]; then
        return
    fi

    local suggestion
    suggestion="$(_hac_prefix_search "$input_text")"

    if [[ -n "$suggestion" ]]; then
        local completion="${suggestion:${#input_text}}"
        POSTDISPLAY="${completion}"
        region_highlight+=("${#BUFFER} $((${#BUFFER} + ${#completion})) ${ZSH_AUTOCOMPLETE_GHOST_COLOR}")
    fi
}

accept_suggestion() {
    local input_text="${BUFFER}"

    if [[ -z "${input_text// /}" ]]; then
        return
    fi

    local suggestion
    suggestion="$(_hac_prefix_search "$input_text")"

    if [[ -n "$suggestion" ]]; then
        BUFFER="$suggestion"
        CURSOR=${#BUFFER}
        region_highlight=()
        POSTDISPLAY=""
    fi
}
