# Zsh History Autocomplete

A lightweight Zsh plugin that suggests commands from your history as you type, with fuzzy matching, frequency-based sorting, and an interactive search menu.

## Features

- **Inline ghost text** — shows the most likely completion in dim text as you type
- **Fuzzy matching** — type `npi` to find `npm install`, characters are matched in order
- **Frequency-based sorting** — most used commands appear first
- **Interactive menu** (`Ctrl+W`) — browse, search, and filter suggestions with arrow keys
- **Live filtering** — type inside the menu to narrow down results
- **Syntax highlighting** — commands in green, arguments in white, matched characters in yellow
- **Configurable** — adjust suggestion count, toggle fuzzy matching, customize colors

## Key Bindings

| Key | Action |
|-----|--------|
| `Tab` | Accept the inline suggestion |
| `Ctrl+W` | Open interactive suggestion menu |
| `↑` / `↓` | Navigate menu items |
| `Enter` | Select highlighted item |
| `ESC` | Close the menu |
| Type in menu | Filter suggestions live |
| `Backspace` | Remove filter characters |

## Installation

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/end-y/zsh-history-autocomplete/main/install.sh | bash
```

### Uninstallation

```bash
curl -fsSL https://raw.githubusercontent.com/end-y/zsh-history-autocomplete/main/install.sh | bash -s -- -d
```

## Configuration

Add these to your `.zshrc` **before** the source line to customize:

```bash
# Max number of suggestions (default: 5)
ZSH_AUTOCOMPLETE_MAX_SUGGESTIONS=5

# Enable fuzzy matching (default: 1, set 0 for prefix-only)
ZSH_AUTOCOMPLETE_FUZZY=1
```

## Project Structure

```
src/
  config.zsh       — Default settings (colors, limits, flags)
  history.zsh      — History reading, frequency sorting, fuzzy matching
  highlight.zsh    — Syntax highlighting for menu items
  suggestion.zsh   — Inline ghost text (POSTDISPLAY)
  menu.zsh         — Interactive Ctrl+W menu with search
  init.zsh         — Entry point, loads all modules
install.sh         — Installer / uninstaller
```

## Requirements

- Zsh shell

## License

MIT License - feel free to use and modify as you like!
