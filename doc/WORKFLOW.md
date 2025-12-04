# Chezmoi Workflow Guide

This guide is intended for AI assistants working on projects that may require dotfile or shell configuration changes. **Review this before modifying any shell configs, installing tools, or adding environment variables.**

---

## Before Making Changes

### Files to Review First

Always read these files to understand the current setup before suggesting changes:

| File | Purpose | Review When |
|------|---------|-------------|
| `~/.local/share/chezmoi/dot_zshrc` | Interactive shell config (aliases, functions, plugins) | Adding aliases, functions, shell plugins |
| `~/.local/share/chezmoi/dot_zprofile` | Login shell config (env vars, PATH) | Adding environment variables, PATH modifications |
| `~/.local/share/chezmoi/Brewfile` | Homebrew packages manifest | Installing new CLI tools or apps |
| `~/.local/share/chezmoi/private_dot_gitconfig` | Git configuration | Changing git settings |
| `~/.local/share/chezmoi/private_dot_ssh/private_config` | SSH configuration | Adding SSH hosts or keys |

### Quick Review Commands

```bash
chezmoi cat ~/.zshrc       # View current zshrc content
chezmoi cat ~/.zprofile    # View current zprofile content
chezmoi managed            # List all managed files
chezmoi data               # View template variables
```

---

## What Goes Where

### `dot_zprofile` (Login Shell - runs once per session)

**Add here:**
- Environment variables (`export VAR=value`)
- PATH modifications (`export PATH="...:$PATH"`)
- Tool initialization that sets env vars (e.g., `eval "$(brew shellenv)"`)

**Current structure:**
```
1. Homebrew environment
2. OrbStack integration
3. 1Password SSH agent
4. Tool-specific PATH additions (postgresql, .local/bin)
5. Editor & Pager settings
```

### `dot_zshrc` (Interactive Shell - runs for each terminal)

**Add here:**
- Aliases
- Functions
- Shell plugins (OMZ plugins array)
- Completions
- Interactive tool loaders (nvm, etc.)

**Current structure:**
```
1. Oh My Zsh configuration & theme
2. Homebrew completions (BEFORE compinit)
3. OMZ plugins array
4. source oh-my-zsh.sh
5. Shell options (setopt)
6. Completion styles (zstyle)
7. Homebrew plugins (autosuggestions, syntax-highlighting LAST)
8. Tool loaders (nvm, 1password plugins)
9. Aliases & Functions
```

### `Brewfile` (Package Manifest)

**Add here:**
- CLI tools (`brew "toolname"`)
- GUI applications (`cask "appname"`)
- Taps for additional repositories

**Current categories:**
- CLI Tools: git, gh, chezmoi, shell enhancements, dev tools, database
- GUI Apps: 1password, iterm2, vscode, orbstack
- Optional (commented): productivity, communication, browsers, utilities

---

## Decision Guide: Ask the User When...

### Tool Installation

| Situation | Ask About |
|-----------|-----------|
| New CLI tool needed | "Should I add this to Brewfile for persistence, or install manually for this project only?" |
| Tool requires shell integration | "This needs a line in zshrc/zprofile. Want me to add it to chezmoi?" |
| Multiple installation methods exist | "Install via Homebrew, npm global, or project-local?" |

### Shell Configuration

| Situation | Ask About |
|-----------|-----------|
| Adding an alias | "Should this be a permanent alias in chezmoi, or project-specific?" |
| Adding a function | "Is this a general utility or project-specific? Where should it live?" |
| PATH modification needed | "Should this PATH change be permanent (chezmoi) or temporary?" |
| Environment variable needed | "Is this a personal preference, project requirement, or secret?" |

### Ambiguous Cases

| Situation | Ask About |
|-----------|-----------|
| Project needs specific tool version | "Use project-local version manager (nvm, pyenv) or system-wide?" |
| Config could go multiple places | "Should this be in zprofile (env var) or zshrc (alias/function)?" |
| Secret or API key needed | "This should use 1Password. Want me to show you how to set that up?" |

---

## What Should NOT Be Added to Chezmoi

- **Project-specific configs** - Keep in project directory (e.g., `.nvmrc`, `.node-version`)
- **Secrets/API keys** - Use 1Password integration, never hardcode
- **Temporary aliases** - Use shell session or project scripts
- **Machine-specific paths** - Use templates if truly needed
- **Large generated files** - Add to `.chezmoiignore`

---

## Making Changes (Step-by-Step)

### 1. Edit the Source File

```bash
chezmoi edit ~/.zshrc      # Opens in VS Code
# OR edit directly:
# ~/.local/share/chezmoi/dot_zshrc
```

### 2. Review Changes

```bash
chezmoi diff               # See what will change
```

### 3. Apply Changes

```bash
chezmoi apply -v           # Apply to home directory
source ~/.zshrc            # Reload shell (if needed)
```

### 4. Commit and Push

```bash
chezmoi cd                 # Enter source directory
git add .
git commit -m "feat: add new-tool integration"
git push
```

---

## Adding New Tools (Full Workflow)

### Example: Adding a new CLI tool with shell integration

```bash
# 1. Add to Brewfile
chezmoi edit ~/Brewfile
# Add: brew "newtool"

# 2. Install it
brew bundle --file=$(chezmoi source-path)/Brewfile

# 3. If shell integration needed, edit appropriate file:
chezmoi edit ~/.zshrc      # For aliases/functions
# OR
chezmoi edit ~/.zprofile   # For env vars/PATH

# 4. Review and apply
chezmoi diff
chezmoi apply -v

# 5. Commit
chezmoi cd && git add . && git commit -m "feat: add newtool" && git push
```

---

## Common Patterns in This Setup

### Adding an OMZ Plugin

Edit `dot_zshrc`, add to the `plugins=(...)` array:

```bash
plugins=(
    ...existing plugins...
    newplugin        # Add here
)
```

### Adding a Homebrew-sourced Plugin

Edit `dot_zshrc`, add after the "Homebrew Plugins" section:

```bash
# New plugin (add BEFORE syntax-highlighting)
source $(brew --prefix)/share/new-plugin/new-plugin.zsh

# Syntax highlighting (MUST be last)
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

### Adding a PATH Entry

Edit `dot_zprofile`:

```bash
# Tool name (brief description)
export PATH="/path/to/tool/bin:$PATH"
```

### Adding an Alias

Edit `dot_zshrc`, in the "Aliases & Functions" section:

```bash
# Description of what this does
alias shortname="full command here"
```

### Adding a Function

Edit `dot_zshrc`, in the "Aliases & Functions" section:

```bash
# Description of what this does
funcname() {
    # function body
}
```

---

## Secrets and Credentials

**Never hardcode secrets.** This setup uses 1Password:

- SSH keys: Managed via 1Password SSH agent
- Git signing: Via 1Password's `op-ssh-sign`
- CLI credentials: Via `op plugin run -- command`

If a tool needs an API key or credential:
1. Store it in 1Password
2. Access via `op read "op://vault/item/field"` in scripts
3. Or use 1Password CLI plugins for automatic injection

---

## Command Reference

| Task | Command |
|------|---------|
| See pending changes | `chezmoi diff` |
| Apply changes | `chezmoi apply -v` |
| Edit a managed file | `chezmoi edit <file>` |
| Add new file to chezmoi | `chezmoi add <file>` |
| Remove from management | `chezmoi forget <file>` |
| Jump to source directory | `chezmoi cd` |
| Check for issues | `chezmoi doctor` |
| View template data | `chezmoi data` |
| List managed files | `chezmoi managed` |
| Update external deps (OMZ) | `chezmoi update` |

---

## File Naming Conventions

When adding files to `~/.local/share/chezmoi/`:

| Prefix/Suffix | Effect |
|---------------|--------|
| `dot_` | Adds `.` prefix (e.g., `dot_zshrc` → `.zshrc`) |
| `private_` | Sets chmod 600 (owner read/write only) |
| `executable_` | Sets chmod 755 |
| `.tmpl` | Process as Go template |
| `run_once_` | Run script only on first apply |
| `run_onchange_` | Run script when content changes |

---

## Troubleshooting

```bash
chezmoi doctor             # Check configuration health
chezmoi diff               # See pending changes
chezmoi data               # View template variables
chezmoi source-path <file> # Find source for a managed file
```

### Force Re-run One-Time Scripts

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply -v
```
