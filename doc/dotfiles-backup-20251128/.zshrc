# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ------------------------------
# 🌍 XDG Base Directory Variables
# ------------------------------
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# ------------------------------
# 🛤️ PATH Configuration
# ------------------------------
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# ------------------------------
# 🍺 Homebrew Completions
# ------------------------------
if command -v brew >/dev/null 2>&1; then
  FPATH="$(brew --prefix)/share/zsh-completions:${FPATH}"
fi

# ------------------------------
# 💫 Oh My Zsh Initialization
# ------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    1password
    aliases
    alias-finder
    brew
    git
    gh
    iterm2
    macos
    postgres
    sudo
    textmate
    vscode
    z
)

source "$ZSH/oh-my-zsh.sh"

# ------------------------------
# 📜 History Configuration
# ------------------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="${XDG_STATE_HOME}/zsh/history"

setopt SHARE_HISTORY          # Share history across sessions
setopt HIST_IGNORE_DUPS       # Don't record consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate entries
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt HIST_VERIFY            # Show expanded history before executing
setopt HIST_REDUCE_BLANKS     # Remove extra blanks from commands
setopt APPEND_HISTORY         # Append rather than overwrite

# ------------------------------
# ⚙️ Shell Options
# ------------------------------
setopt interactivecomments    # Allow comments in interactive shell
setopt auto_cd                # cd by typing directory name
setopt extendedglob           # Extended globbing patterns
setopt completeinword         # Complete from cursor position

# ------------------------------
# 📝 Editor & Pager
# ------------------------------
export EDITOR="code -w"
export PAGER="less -R"

# ------------------------------
# 📦 Version Managers
# ------------------------------
# fnm (Fast Node Manager)
eval "$(fnm env --use-on-cd --shell zsh)"

# ------------------------------
# 🔌 Additional Sources
# ------------------------------
source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source ~/.config/op/plugins.sh

# ------------------------------
# 🔧 CLI Completions
# (Explicit fallbacks if OMZ plugins don't load them)
# ------------------------------

# GitHub CLI completions
if command -v gh >/dev/null 2>&1; then
  if ! whence -w _gh >/dev/null 2>&1; then
    eval "$(gh completion -s zsh)"
    compdef _gh gh
  fi
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ------------------------------
# ✨ Visual Enhancements
# (syntax-highlighting must be last)
# ------------------------------
[[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

[[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ------------------------------
# 🔧 App Integrations
# ------------------------------
[[ -f "$HOME/Library/Application Support/Code/shell_integration/zsh/profile.zsh" ]] && \
  source "$HOME/Library/Application Support/Code/shell_integration/zsh/profile.zsh"

# ------------------------------
# 🐘 PostgreSQL Helpers
# ------------------------------
pgup()     { brew services start postgresql@17; }
pgdown()   { brew services stop postgresql@17; }
pgstatus() { brew services list | command grep postgresql@17; }
alias psql17="psql --host=localhost --port=5432"

# ------------------------------
# 🤖 Custom Functions
# ------------------------------

# Launch Codex in the repo root (if git repo) or current dir
codexr() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  cd "$root" && codex
}

# Run Codex with a one-shot prompt
cx() { codex "$*"; }

# ------------------------------
# 🛠️ Utilities
# ------------------------------
# Fast manual rebuild of completion cache
alias rebuild-completions='rm -f "$HOME/.zcompdump-$ZSH_VERSION" && compinit -d "$HOME/.zcompdump-$ZSH_VERSION" && echo "✅ completions rebuilt"'
