#!/bin/zsh

echo "📌 Installing Zsh History Autocomplete..."

# Autocomplete script'inin yolu
AUTO_SCRIPT="$HOME/.zsh_history_autocomplete.sh"
ZSH_CONFIG="$HOME/.zshrc"

# Eğer script zaten varsa, kullanıcıya sor
if [[ -f "$AUTO_SCRIPT" ]]; then
    echo "❗ Zsh History Autocomplete is already installed."
    echo -n "Do you want to remove it? (y/N): "
    read REPLY
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Script dosyasını sil
        rm "$AUTO_SCRIPT"
        # .zshrc'den source satırını sil
        sed -i '' "/source.*${AUTO_SCRIPT//\//\\/}/d" "$ZSH_CONFIG"
        echo "🗑️  Uninstalled successfully."
        echo "🔄 Please restart your terminal for changes to take effect."
        exit 0
    fi
fi

# Autocomplete script'ini oluştur
cat << 'EOF' > "$AUTO_SCRIPT"
#!/bin/zsh

# Zsh'i interaktif moda geçir
[[ $- == *i* ]] || return 0

# Gerekli zsh modüllerini yükle
zmodload zsh/zle
zmodload zsh/zleparameter
autoload -Uz add-zle-hook-widget

# Altı çizili metin oluşturma fonksiyonu
underline() {
    local text="$1"
    echo "_${text}"  # Basit bir altı çizgi ekleyelim
}

# Ana autocomplete fonksiyonu
autocomplete_history() {
    local input_text="${BUFFER}"
    
    # Boş input kontrolü
    if [[ -z "${input_text// /}" ]]; then
        POSTDISPLAY=""
        return
    fi

    # En son kullanılan ve eşleşen komutu bul
    local suggestion=$(fc -l -n 1 | grep "^${input_text}" | tail -n 1)

    if [[ -n "$suggestion" && "$suggestion" != "$input_text" ]]; then
        # Mevcut yazılan kısım hariç geri kalanını göster
        local completion="${suggestion:${#input_text}}"
        POSTDISPLAY=" » ${completion}"
    else
        POSTDISPLAY=""
    fi
}

# Tab tuşuna basıldığında öneriyi kabul et
accept_suggestion() {
    local input_text="${BUFFER}"
    
    # Boş input kontrolü
    if [[ -z "${input_text// /}" ]]; then
        return
    fi
    
    local suggestion=$(fc -l -n 1 | grep "^${input_text}" | tail -n 1)
    
    if [[ -n "$suggestion" && "$suggestion" != "$input_text" ]]; then
        BUFFER="$suggestion"
        CURSOR=${#BUFFER}
    fi
}

# Enter tuşuna basıldığında öneriyi kabul et ve çalıştır
accept_and_execute() {
    local input_text="${BUFFER}"
    
    # Boş input kontrolü
    if [[ -n "${input_text// /}" ]]; then
        local suggestion=$(fc -l -n 1 | grep "^${input_text}" | tail -n 1)
        
        if [[ -n "$suggestion" && "$suggestion" != "$input_text" && -n "$POSTDISPLAY" ]]; then
            BUFFER="$suggestion"
        fi
    fi
    
    # Komutu çalıştır
    zle accept-line
}

# Widget'ları tanımla
zle -N autocomplete_history
zle -N accept_suggestion
zle -N accept_and_execute

# Her tuş vuruşunda çalıştır
add-zle-hook-widget -Uz line-pre-redraw autocomplete_history

# Tuş tanımlamaları
bindkey '^I' accept_suggestion
bindkey '^M' accept_and_execute    # Enter tuşu
EOF

# Zsh konfigürasyon dosyalarına ekle
if ! grep -q "source $AUTO_SCRIPT" "$ZSH_CONFIG"; then
    echo "source $AUTO_SCRIPT" >> "$ZSH_CONFIG"
    echo "✅ Updated $ZSH_CONFIG"
else
    echo "✅ $ZSH_CONFIG is already configured"
fi

# Script'e çalıştırma izni ver
chmod +x "$AUTO_SCRIPT"

# Script'i hemen çalıştır
source "$AUTO_SCRIPT"

echo "✅ Zsh History Autocomplete is now active"
echo "🔄 To make changes permanent, please restart your terminal or run:"
echo "source $AUTO_SCRIPT"