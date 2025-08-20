#!/bin/zsh

echo "📌 Installing Zsh History Autocomplete..."

AUTO_SCRIPT="$HOME/.zsh_history_autocomplete.sh"
ZSH_CONFIG="$HOME/.zshrc"

if [[ -f "$AUTO_SCRIPT" ]]; then
    echo "❗ Zsh History Autocomplete is already installed."
    echo -n "Do you want to remove it? (y/N): "
    read REPLY
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$AUTO_SCRIPT"
        sed -i '' "/source.*${AUTO_SCRIPT//\//\\/}/d" "$ZSH_CONFIG"
        echo "🗑️  Uninstalled successfully."
        echo "🔄 Please restart your terminal for changes to take effect."
        exit 0
    fi
fi


cat << 'EOF' > "$AUTO_SCRIPT"
#!/bin/zsh

[[ $- == *i* ]] || return 0

if [[ -o interactive ]]; then
    zmodload zsh/zle
    zmodload zsh/zleparameter
    autoload -Uz add-zle-hook-widget
fi

starts_with() {
    [[ "$2" == "$1"* ]]
}

get_suggestions() {
    local input_text="$BUFFER"
    local count=0
    local commands=(${(f)"$(history -n -r 1)"})
    local unique_commands=()
    
    typeset -A seen 
    for cmd in $commands; do
        if [[ -z "$input_text" ]] || [[ "$cmd" == "$input_text"* && "$cmd" != "$input_text" ]]; then
            if [[ -z ${seen[$cmd]} ]]; then
                seen[$cmd]=1
                unique_commands+=("'$cmd'")
                ((count++))
                [[ $count -ge 3 ]] && break
            fi
        fi
    done
    
    printf '%s\n' "${unique_commands[@]}"
}

show_suggestions() {
    local term_width=$(tput cols)
    local term_height=$(tput lines)
    
    local suggestions=("${(@f)$(get_suggestions)}")
    local selected_index=1
    local count=${#suggestions}
    
    local box_lines=$((count + 2))
    local needed_space=$((box_lines + 1))
    
    for ((i=0; i<needed_space; i++)); do
        echo
    done
    
    local box_width=$term_width
    local box_x=0
    local box_y=$((term_height - box_lines - 1))
    
    tput civis
    
    trap 'tput cnorm; return' INT TERM EXIT
    
    tput sc
    
    function draw_menu() {
        tput cup $box_y $box_x
        
        echo -n "┌"
        for ((i=1; i<box_width-1; i++)); do
            echo -n "─"
        done
        echo -n "┐"
        
        local i=1
        for suggestion in "${suggestions[@]}"; do
            tput cup $((box_y + i)) $box_x
            if ((i == selected_index)); then
                printf "%s \033[7m%-$((box_width-3))s\033[0m%s" "│" "$suggestion" "│"
            else
                printf "%s %-$((box_width-3))s%s" "│" "$suggestion" "│"
            fi
            ((i++))
        done
        
        tput cup $((box_y + i)) $box_x
        echo -n "└"
        for ((i=1; i<box_width-1; i++)); do
            echo -n "─"
        done
        echo -n "┘"
    }
    
    draw_menu
    
    local key
    while true; do
        read -s -k1 key
        if [[ $key = $'\x1b' ]]; then
            read -s -k1 key
            if [[ $key = '[' ]]; then
                read -s -k1 key
                case $key in
                    'A')
                        if ((selected_index > 1)); then
                            ((selected_index--))
                            draw_menu
                        fi
                        ;;
                    'B')
                        if ((selected_index < count)); then
                            ((selected_index++))
                            draw_menu
                        fi
                        ;;
                esac
            fi
        elif [[ $key = $'\r' ]]; then
            local selected="${suggestions[$selected_index]}"
            selected="${selected#\'}"
            selected="${selected%\'}"
            
            tput rc
            for ((i=0; i<=box_lines+1; i++)); do
                tput el
                tput cuu1
            done
            tput cud1
            
            BUFFER="$selected"
            CURSOR=${#BUFFER}
            region_highlight=()
            POSTDISPLAY=""
            tput cnorm
            break
        fi
    done
    
    trap - INT TERM EXIT
    
    zle reset-prompt
}

autocomplete_history() {
    POSTDISPLAY=""
    local input_text="${BUFFER}"
    
    if [[ -z "${input_text// /}" ]]; then
        return
    fi

    local suggestion=""
    local history_entry
    
    {
        while read -r history_entry; do
            if starts_with "$input_text" "$history_entry"; then
                suggestion="$history_entry"
                break
            fi
        done < <(fc -l -n 1)

        if [[ -n "$suggestion" && "$suggestion" != "$input_text" ]]; then
            local completion="${suggestion:${#input_text}}"
            POSTDISPLAY="${completion}"
            # İmlecin sağındaki öneriyi soluk göster (POSTDISPLAY kısmı)
            region_highlight+=("${#BUFFER} $((${#BUFFER} + ${#completion})) fg=242")
        fi
    } || {
        POSTDISPLAY=""
    }
}

accept_suggestion() {
    local input_text="${BUFFER}"
    
    if [[ -z "${input_text// /}" ]]; then
        return
    fi
    
    local suggestion=""
    
    {
        local history_entry
        while read -r history_entry; do
            if starts_with "$input_text" "$history_entry"; then
                suggestion="$history_entry"
                break
            fi
        done < <(fc -l -n 1)
        
        if [[ -n "$suggestion" && "$suggestion" != "$input_text" ]]; then
            BUFFER="$suggestion"
            CURSOR=${#BUFFER}
            region_highlight=()
            POSTDISPLAY=""
        fi
    } || {
        BUFFER="$input_text"
        CURSOR=${#BUFFER}
    }
}


if [[ -o interactive ]]; then
    zle -N autocomplete_history
    zle -N accept_suggestion
    zle -N show_suggestions

    add-zle-hook-widget -Uz line-pre-redraw autocomplete_history

    bindkey '^I' accept_suggestion
    bindkey '^W' show_suggestions
fi
EOF

if ! grep -q "source $AUTO_SCRIPT" "$ZSH_CONFIG"; then
    echo "source $AUTO_SCRIPT" >> "$ZSH_CONFIG"
    echo "✅ Updated $ZSH_CONFIG"
else
    echo "✅ $ZSH_CONFIG is already configured"
fi

chmod +x "$AUTO_SCRIPT"
source "$AUTO_SCRIPT"

echo "✅ Zsh History Autocomplete is now active"
echo "🔄 To make changes permanent, please restart your terminal or run:"
echo "source $AUTO_SCRIPT"

