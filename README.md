# 🚀 Dotfiles - Modern Developer Experience

A curated collection of configuration files (dotfiles) optimized for productivity, speed, and a modern CLI experience. This setup is managed using **GNU Stow** and **mise**.

## 🛠 Core Tools & Tech Stack

This environment relies on several modern CLI tools that replace traditional counterparts:

| Tool | Purpose | Modern Alternative To... |
| :--- | :--- | :--- |

| [**pnpm**](https://pnpm.io/) | Fast package manager | `npm`, `yarn` |
| [**GNU Stow**](https://www.gnu.org/software/stow/) | Symlink manager | Manual copy-pasting |
| [**zoxide**](https://github.com/ajeetdsouza/zoxide) | Smarter navigation | `cd` |
| [**fzf**](https://github.com/junegunn/fzf) | Fuzzy finder | `grep`, `find`, `Ctrl+R` |
| [**zellij**](https://zellij.dev/) | Terminal multiplexer | `tmux`, `screen` |
| [**eza**](https://github.com/eza-community/eza) | File listing | `ls` |
| [**bat**](https://github.com/sharkdp/bat) | Syntax highlighting | `cat` |
| [**git-delta**](https://github.com/dandavison/delta) | Syntax-highlighting diffs | Standard `git diff` |

---

## 📥 Installation

### 1. Install Dependencies

#### **Arch Linux (Pacman)**
```bash
sudo pacman -S --noconfirm zsh zoxide fzf ripgrep zellij eza bat git-delta stow
```

#### **Ubuntu/Debian (Apt)**
```bash
# Note: Some tools like zellij may need their own repos or manual install
sudo apt install zsh stow fzf ripgrep bat
# Symlink batcat to bat
mkdir -p ~/.local/bin && ln -s /usr/bin/batcat ~/.local/bin/bat
```

### 2. Clone the Repository
```bash
git clone https://github.com/rahulsamant37/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Deploy Configurations (using Stow)
GNU Stow creates symlinks from the folders in this repo to your home directory.

```bash
# Stow individual components
stow zsh
stow git
stow kitty
stow nvim
stow shell
```

---

## ⚙️ Post-Installation Setup

### Change Default Shell
```bash
chsh -s $(which zsh)
```



---

## 📁 Repository Structure
```text
~/dotfiles/
├── zsh/        # .zshrc configuration
├── git/        # .gitconfig (with delta pager)
├── kitty/      # Kitty terminal emulator config
├── nvim/       # Neovim configuration
├── shell/      # Shared shell completions/scripts
└── README.md   # This file
```

---

## ⌨️ Custom Aliases
| Alias | Command | Description |
| :--- | :--- | :--- |
| `ls` | `eza --icons` | List files with icons |
| `ll` | `eza -la --icons` | Detailed list with git info |
| `tree` | `eza --tree` | Visual directory tree |
| `cat` | `bat --paging=never` | View file with highlighting |
| `zj` | `zellij` | Start terminal multiplexer |
| `preview`| `fzf --preview ...` | Fuzzy find with file preview |

---

## 📜 Maintenance
To add a new configuration (e.g., `tmux`):
1. Create a folder: `mkdir -p ~/dotfiles/tmux`
2. Move your config: `mv ~/.tmux.conf ~/dotfiles/tmux/`
3. Symlink it: `cd ~/dotfiles && stow tmux`
