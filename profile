# Source .bashrc if running bash and it exists
[ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

# Source .zshrc if running zsh and it exists
[ -n "$ZSH_VERSION" ] && [ -f "$HOME/.zshrc" ] && . "$HOME/.zshrc"

# vim: ft=sh
