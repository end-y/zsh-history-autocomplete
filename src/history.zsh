#!/bin/zsh

_hac_get_history_lines() {
    fc -l 1 | sed -E 's/^[[:space:]]*[0-9]+[[:space:]]*//'
}

_hac_frequency_map() {
    typeset -gA _hac_freq
    _hac_freq=()
    local cmd
    while IFS= read -r cmd; do
        if [[ -n "$cmd" ]]; then
            _hac_freq["$cmd"]=$(( ${_hac_freq["$cmd"]:-0} + 1 ))
        fi
    done < <(_hac_get_history_lines)
}

_hac_fuzzy_match() {
    local pattern="$1" text="$2"
    local plen=${#pattern} tlen=${#text}

    # Short patterns (<=2): match all chars in order
    if (( plen <= 2 )); then
        local i=0 j=0
        while (( i < plen && j < tlen )); do
            if [[ "${text:$j:1}" == "${pattern:$i:1}" ]]; then
                (( i++ ))
            fi
            (( j++ ))
        done
        (( i == plen ))
        return
    fi

    # Longer patterns: split into bigrams, each must appear in order
    local j=0
    local bi=0
    while (( bi < plen )); do
        local chunk_len=2
        if (( bi + chunk_len > plen )); then
            chunk_len=$((plen - bi))
        fi
        local chunk="${pattern:$bi:$chunk_len}"
        local clen=${#chunk}

        # Find chunk in text starting from position j
        local found=0
        while (( j + clen <= tlen )); do
            if [[ "${text:$j:$clen}" == "$chunk" ]]; then
                (( j += clen ))
                found=1
                break
            fi
            (( j++ ))
        done

        if (( !found )); then
            return 1
        fi

        (( bi += chunk_len ))
    done
    return 0
}

_hac_search_history() {
    local input_text="$1"
    local max_count="${2:-$ZSH_AUTOCOMPLETE_MAX_SUGGESTIONS}"
    local count=0

    _hac_frequency_map

    typeset -A seen
    local -a results
    local -a result_freqs
    local cmd

    while read -r cmd; do
        [[ -z "$cmd" ]] && continue
        [[ "$cmd" == "$input_text" ]] && continue
        [[ -n "${seen["$cmd"]}" ]] && continue

        local matched=0
        # Prefix match first
        if [[ "$cmd" == "$input_text"* ]]; then
            matched=1
        # Fuzzy match if enabled
        elif (( ZSH_AUTOCOMPLETE_FUZZY )) && _hac_fuzzy_match "$input_text" "$cmd"; then
            matched=1
        fi

        if (( matched )); then
            seen["$cmd"]=1
            results+=("$cmd")
            result_freqs+=(${_hac_freq["$cmd"]:-0})
        fi
    done < <(_hac_get_history_lines)

    # Sort by frequency (descending) - simple bubble sort since list is small
    local n=${#results}
    local swapped=1
    while (( swapped )); do
        swapped=0
        for (( i=1; i<n; i++ )); do
            if (( result_freqs[i] < result_freqs[i+1] )); then
                # Swap
                local tmp_cmd="${results[i]}"
                local tmp_freq=${result_freqs[i]}
                results[i]="${results[i+1]}"
                result_freqs[i]=${result_freqs[i+1]}
                results[i+1]="$tmp_cmd"
                result_freqs[i+1]=$tmp_freq
                swapped=1
            fi
        done
        (( n-- ))
    done

    # Return top results
    count=0
    for cmd in "${results[@]}"; do
        printf '%s\n' "$cmd"
        (( count++ ))
        (( count >= max_count )) && break
    done
}

_hac_prefix_search() {
    local input_text="$1"
    local cmd
    while read -r cmd; do
        if [[ -n "$cmd" && "$cmd" == "$input_text"* && "$cmd" != "$input_text" ]]; then
            printf '%s' "$cmd"
            return 0
        fi
    done < <(_hac_get_history_lines)
    return 1
}
