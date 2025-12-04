# Chezmoi Workflow Guide

This guide outlines the proper workflow for managing dotfiles with chezmoi based on this repository's implementation.

---

## Daily Workflow

### Making Changes to Dotfiles

**Option A: Edit via chezmoi (recommended)**

```bash
chezmoi edit ~/.zshrc          # Opens dot_zshrc in VS Code
chezmoi diff                   # Review pending changes
chezmoi apply -v               # Apply changes
```

**Option B: Edit source directly**

```bash
# Edit files in ~/.local/share/chezmoi/ directly
chezmoi diff                   # See what would change
chezmoi apply -v               # Apply to home directory
```

### Adding New Dotfiles

```bash
chezmoi add ~/.config/someapp/config    # Adds to source state
chezmoi cd                              # Jump to source directory
git add . && git commit -m "feat: add someapp config"
git push
```

### Syncing Changes

Use this after `git pull` or on another machine:

```bash
chezmoi git pull               # Pull latest from remote
chezmoi diff                   # Review incoming changes
chezmoi apply -v               # Apply changes
```

---

## New Machine Setup

### Prerequisites

1. **1Password** must be installed and signed in (required for SSH/Git authentication)

### Installation

```bash
# Install chezmoi and apply dotfiles in one command
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply timu-insights
```

### What Happens Automatically

1. **Prompts** for user data (first run only):
   - Email address
   - Full name
   - GitHub username

2. **Homebrew packages** install via `run_once_install-packages.sh.tmpl`

3. **Oh My Zsh** downloads via `.chezmoiexternal.toml`

4. **Shell configs** applied to home directory

---

## Command Reference

| Task | Command |
|------|---------|
| See pending changes | `chezmoi diff` |
| Apply changes | `chezmoi apply -v` |
| Edit a managed file | `chezmoi edit <file>` |
| Add new file | `chezmoi add <file>` |
| Remove from management | `chezmoi forget <file>` |
| Jump to source dir | `chezmoi cd` |
| Check for issues | `chezmoi doctor` |
| View template data | `chezmoi data` |
| List managed files | `chezmoi managed` |
| Update external deps | `chezmoi update` |
| Re-run init prompts | `chezmoi init` |

---

## Git Workflow

The source directory is a git repository. Use the standard flow:

**edit → diff → apply → commit → push**

### Direct Git Commands

```bash
chezmoi cd                     # Enter source directory
git status                     # Check changes
git add .
git commit -m "chore: update zsh config"
git push
```

### Chezmoi Git Passthrough

```bash
chezmoi git -- status
chezmoi git -- add .
chezmoi git -- commit -m "message"
chezmoi git -- push
```

---

## File Naming Conventions

When adding files manually, use these prefixes:

| Prefix/Suffix | Effect |
|---------------|--------|
| `dot_` | Adds `.` prefix (e.g., `dot_zshrc` → `.zshrc`) |
| `private_` | Sets chmod 600 (owner read/write only) |
| `executable_` | Sets chmod 755 (executable) |
| `readonly_` | Sets read-only permissions |
| `.tmpl` | Process as template |
| `run_once_` | Run script only on first apply |
| `run_onchange_` | Run script when content changes |

### Examples

```
dot_zshrc                    → ~/.zshrc
private_dot_gitconfig        → ~/.gitconfig (chmod 600)
run_once_install.sh.tmpl     → Runs once, supports templates
```

---

## Troubleshooting

### Check Configuration Health

```bash
chezmoi doctor
```

### View What Chezmoi Knows About You

```bash
chezmoi data
```

### Force Re-run of One-Time Scripts

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply -v
```

### See Source Path for a File

```bash
chezmoi source-path ~/.zshrc
```

---

## External Dependencies

Oh My Zsh and plugins are managed via `.chezmoiexternal.toml` and refresh weekly. To force an update:

```bash
chezmoi update
```
