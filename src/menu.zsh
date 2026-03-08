#!/bin/zsh

show_suggestions() {
    local term_width=$(tput cols)
    local term_height=$(tput lines)
    local filter_text="$BUFFER"

    local -a suggestions
    local raw_suggestions
    raw_suggestions="$(_hac_search_history "$filter_text" "$ZSH_AUTOCOMPLETE_MAX_SUGGESTIONS")"

    if [[ -z "$raw_suggestions" ]]; then
        zle -M "No suggestions found."
        return
    fi

    suggestions=("${(@f)raw_suggestions}")
    suggestions=(${suggestions[@]:#})

    local count=${#suggestions}
    if [[ $count -eq 0 ]]; then
        zle -M "No suggestions found."
        return
    fi

    local selected_index=1
    local box_width=$term_width
    local box_x=0

    tput civis >/dev/tty
    tput sc >/dev/tty

    function _hac_draw_menu() {
        local box_lines=$((count + 3))  # +3 for top border, bottom border, search line
        local box_y=$((term_height - box_lines - 1))

        tput cup $box_y $box_x >/dev/tty

        # Top border
        echo -n "┌" >/dev/tty
        for ((i=1; i<box_width-1; i++)); do echo -n "─" >/dev/tty; done
        echo -n "┐" >/dev/tty

        # Search line
        tput cup $((box_y + 1)) $box_x >/dev/tty
        local search_display="search: ${filter_text}_"
        printf "%s %-$((box_width-3))s%s" "│" "$search_display" "│" >/dev/tty

        # Suggestions
        local i=1
        for suggestion in "${suggestions[@]}"; do
            tput cup $((box_y + 1 + i)) $box_x >/dev/tty
            local highlighted="$(_hac_highlight_command "$suggestion" "$filter_text")"
            if ((i == selected_index)); then
                printf "%s %-$((box_width-3))s%s" "│" "" "│" >/dev/tty
                tput cup $((box_y + 1 + i)) $((box_x + 2)) >/dev/tty
                echo -ne "\033[7m${highlighted}\033[0m" >/dev/tty
            else
                printf "%s %-$((box_width-3))s%s" "│" "" "│" >/dev/tty
                tput cup $((box_y + 1 + i)) $((box_x + 2)) >/dev/tty
                echo -ne "${highlighted}" >/dev/tty
            fi
            ((i++))
        done

        # Bottom border
        tput cup $((box_y + 1 + i)) $box_x >/dev/tty
        echo -n "└" >/dev/tty
        for ((i=1; i<box_width-1; i++)); do echo -n "─" >/dev/tty; done
        echo -n "┘" >/dev/tty
    }

    function _hac_cleanup_menu() {
        local box_lines=$((count + 3))
        tput rc >/dev/tty
        for ((i=0; i<=box_lines+2; i++)); do
            tput el >/dev/tty
            tput cuu1 >/dev/tty
        done
        tput cud1 >/dev/tty
        tput cnorm >/dev/tty
    }

    function _hac_refresh_suggestions() {
        local raw
        raw="$(_hac_search_history "$filter_text" "$ZSH_AUTOCOMPLETE_MAX_SUGGESTIONS")"

        local old_count=$count
        if [[ -z "$raw" ]]; then
            suggestions=()
            count=0
        else
            suggestions=("${(@f)raw}")
            suggestions=(${suggestions[@]:#})
            count=${#suggestions}
        fi

        selected_index=1

        # Clear old area
        local old_box_lines=$((old_count + 3))
        tput rc >/dev/tty
        for ((i=0; i<=old_box_lines+2; i++)); do
            tput el >/dev/tty
            tput cuu1 >/dev/tty
        done
        tput cud1 >/dev/tty
        tput sc >/dev/tty
    }

    # Make space for menu
    local box_lines=$((count + 3))
    local needed_space=$((box_lines + 1))
    for ((i=0; i<needed_space; i++)); do echo >/dev/tty; done

    _hac_draw_menu

    local key
    while true; do
        read -s -k1 key </dev/tty
        if [[ $key = $'\x1b' ]]; then
            read -s -k1 -t 0.1 key </dev/tty
            if [[ $key = '[' ]]; then
                read -s -k1 key </dev/tty
                case $key in
                    'A')  # Up
                        if ((selected_index > 1)); then
                            ((selected_index--))
                            _hac_draw_menu
                        fi
                        ;;
                    'B')  # Down
                        if ((selected_index < count)); then
                            ((selected_index++))
                            _hac_draw_menu
                        fi
                        ;;
                esac
            else
                # ESC alone - cancel
                _hac_cleanup_menu
                zle reset-prompt
                return
            fi
        elif [[ $key = $'\r' ]]; then
            # Enter - select
            if (( count > 0 )); then
                local selected="${suggestions[$selected_index]}"
                _hac_cleanup_menu
                BUFFER="$selected"
                CURSOR=${#BUFFER}
                region_highlight=()
                POSTDISPLAY=""
            else
                _hac_cleanup_menu
            fi
            break
        elif [[ $key = $'\x7f' || $key = $'\b' ]]; then
            # Backspace - remove last char from filter
            if [[ ${#filter_text} -gt 0 ]]; then
                filter_text="${filter_text:0:$((${#filter_text}-1))}"
                _hac_refresh_suggestions
                if (( count > 0 )); then
                    # Make space again
                    box_lines=$((count + 3))
                    needed_space=$((box_lines + 1))
                    for ((i=0; i<needed_space; i++)); do echo >/dev/tty; done
                    _hac_draw_menu
                else
                    # No results, still show empty search box
                    box_lines=3
                    for ((i=0; i<4; i++)); do echo >/dev/tty; done
                    _hac_draw_menu
                fi
            fi
        elif [[ $key =~ [[:print:]] ]]; then
            # Printable character - add to filter
            filter_text+="$key"
            _hac_refresh_suggestions
            if (( count > 0 )); then
                box_lines=$((count + 3))
                needed_space=$((box_lines + 1))
                for ((i=0; i<needed_space; i++)); do echo >/dev/tty; done
                _hac_draw_menu
            else
                box_lines=3
                for ((i=0; i<4; i++)); do echo >/dev/tty; done
                _hac_draw_menu
            fi
        fi
    done

    zle reset-prompt
}
