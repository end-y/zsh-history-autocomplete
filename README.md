# Zsh History Autocomplete

A simple and lightweight autocomplete plugin for Zsh that suggests commands from your history as you type.

## Features

- 🚀 Real-time command suggestions from your history
- 💡 Shows suggestions in subtle gray color
- 📝 Interactive suggestion menu with arrow keys
- ⌨️ Works with spaces and complex commands
- ⚡ Fast and lightweight
- 🎯 Key bindings:
  - `Tab` to accept suggestion
  - `Ctrl + W` to show interactive suggestion menu
  - Continue typing to ignore suggestion

## Installation

### Quick Install

```bash
curl -o- https://raw.githubusercontent.com/end-y/zsh-history-autocomplete/main/install_autocomplete.sh | zsh
```

### Manual Installation

1. Download the installation script:

```bash
curl -O https://raw.githubusercontent.com/end-y/zsh-history-autocomplete/main/install_autocomplete.sh
```

2. Make it executable and run:

```bash
chmod +x install_autocomplete.sh
./install_autocomplete.sh
```

3. Restart your terminal or run:

```bash
source ~/.zsh_history_autocomplete.sh
```

## Uninstallation

Run the installation script and select 'y' when prompted to remove:

```bash
./install_autocomplete.sh
```

Or manually:

1. Remove the autocomplete script:

```bash
rm ~/.zsh_history_autocomplete.sh
```

2. Remove the source line from your `.zshrc`:

```bash
sed -i '' '/source.*zsh_history_autocomplete.sh/d' ~/.zshrc
```

## Requirements

- Zsh shell
- Basic Unix utilities (grep, sed)

## License

MIT License - feel free to use and modify as you like!
