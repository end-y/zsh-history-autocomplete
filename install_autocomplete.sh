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
            POSTDISPLAY=" » ${completion}"
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
        fi
    } || {
        BUFFER="$input_text"
        CURSOR=${#BUFFER}
    }
}

accept_and_execute() {
    local input_text="${BUFFER}"
    
    if [[ -n "${input_text// /}" ]]; then
        local suggestion=""
        
        {
            local history_entry
            while read -r history_entry; do
                if starts_with "$input_text" "$history_entry"; then
                    suggestion="$history_entry"
                    break
                fi
            done < <(fc -l -n 1)
            
            if [[ -n "$suggestion" && "$suggestion" != "$input_text" && -n "$POSTDISPLAY" ]]; then
                BUFFER="$suggestion"
            fi
        } || {
            BUFFER="$input_text"
        }
    fi
    
    zle accept-line
}

if [[ -o interactive ]]; then
    zle -N autocomplete_history
    zle -N accept_suggestion
    zle -N accept_and_execute

    add-zle-hook-widget -Uz line-pre-redraw autocomplete_history

    bindkey '^I' accept_suggestion
    bindkey '^M' accept_and_execute
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