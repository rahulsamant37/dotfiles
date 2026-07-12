_ensure_user_local_bin() {
	case ":$PATH:" in
		*":$HOME/.local/bin:"*) ;;
		*) export PATH="$HOME/.local/bin:$PATH" ;;
	esac
}

_ensure_user_local_bin

if [[ -n "${_OLD_VIRTUAL_PATH-}" ]]; then
	case ":$_OLD_VIRTUAL_PATH:" in
		*":$HOME/.local/bin:"*) ;;
		*) _OLD_VIRTUAL_PATH="$HOME/.local/bin:$_OLD_VIRTUAL_PATH" ;;
	esac
fi

typeset -ga precmd_functions
if (( ${precmd_functions[(I)_ensure_user_local_bin]} == 0 )); then
	precmd_functions+=(_ensure_user_local_bin)
fi

if [ -f "$HOME/.local/bin/env" ]; then
	. "$HOME/.local/bin/env"
fi

_ensure_user_local_bin

export QUICKREF_DIR="$HOME/github/quickref"
export QUICKREF_NO_PREVIEW=1

if [ -d "$QUICKREF_DIR/bin" ]; then
	case ":$PATH:" in
		*":$QUICKREF_DIR/bin:"*) ;;
		*) export PATH="$QUICKREF_DIR/bin:$PATH" ;;
	esac
fi

alias ref='qref'
alias qn='qnewref'

: "${CPALG_REPO:=$HOME/github/cp-algorithms}"
: "${CPALG_SRC:=$CPALG_REPO/src}"
export CPALG_REPO
export CPALG_SRC

alias cpr='cpa-read'
alias cpv='cpa-revise'

if [ -f "$HOME/.config/zsh/zsh.productive.zsh" ]; then
	. "$HOME/.config/zsh/zsh.productive.zsh"
fi

if [ -f "$HOME/.config/shell/completions/cpalg-completion.zsh" ]; then
	. "$HOME/.config/shell/completions/cpalg-completion.zsh"
fi

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias h='cd ~'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias q='exit'
alias c='clear'
alias b='btop'
alias ll='ls -laF'
alias gs='git status'
alias sn='shutdown now'
alias co='copilot'

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
if (( ${precmd_functions[(I)precmd_vcs_info]} == 0 )); then
	precmd_functions+=( precmd_vcs_info )
fi
setopt PROMPT_SUBST
zstyle ':vcs_info:git:*' formats ' %F{#9ece6a}(%b)%f'

# PROMPT='%F{#7aa2f7}%1~%f${vcs_info_msg_0_} %(?.%F{#9ece6a}.%F{#f7768e})❯%f '
eval "$(starship init zsh)"

# Competitive Companion target directory helper.
# Usage:
#   cct            -> set target to current directory
#   cct here       -> set target to current directory
#   cct show       -> show current pinned target/fallback hint
#   cct clear      -> clear pinned target
#   cct <path>     -> set target to a specific path
cct() {
	local state_dir="$HOME/.cp"
	local target_file="$state_dir/target_dir.txt"
	local arg="${1:-}"
	local arg2="${2:-}"
	mkdir -p "$state_dir"

	if [[ "$arg" == "-h" || "$arg" == "--help" || "$arg" == "help" ]]; then
		print "cct - Competitive Companion target manager"
		print ""
		print "Usage:"
		print "  cct                Set target to current directory"
		print "  cct here           Set target to current directory"
		print "  cct <path>         Set target to an existing directory"
		print "  cct pick [root]    Pick an existing directory via fzf"
		print "  cct show           Show current pinned target or fallback"
		print "  cct clear          Remove pinned target and use fallback"
		print "  cct --help         Show this help"
		print ""
		print "Listener resolution order:"
		print "  1) ~/.cp/target_dir.txt (pinned by cct)"
		print "  2) CC_PROBLEMS_DIR environment variable"
		print "  3) Listener default path from ~/.cp/listener.py"
		print ""
		print "Examples:"
		print "  cct here"
		print "  cct ~/github/acdladder-cpp/800"
		print "  cct pick ~/github"
		print "  cct show"
		print "  cct clear"
		return 0
	fi

	if [[ $# -eq 0 || "$arg" == "here" ]]; then
		if [[ $# -gt 1 ]]; then
			print "cct: too many arguments. Run 'cct --help'." >&2
			return 1
		fi

		print -r -- "$PWD" >| "$target_file"
		print "cct: target set to $PWD"
		return 0
	fi

	case "$arg" in
		show|status)
			if [[ $# -gt 1 ]]; then
				print "cct: too many arguments. Run 'cct --help'." >&2
				return 1
			fi

			if [[ -f "$target_file" ]]; then
				print "cct: pinned target $(<"$target_file")"
			elif [[ -n "$CC_PROBLEMS_DIR" ]]; then
				print "cct: no pinned target, env fallback CC_PROBLEMS_DIR=$CC_PROBLEMS_DIR"
			else
				print "cct: no pinned target, listener default will be used"
			fi
			return 0
			;;
		clear)
			if [[ $# -gt 1 ]]; then
				print "cct: too many arguments. Run 'cct --help'." >&2
				return 1
			fi

			rm -f "$target_file"
			print "cct: pinned target cleared"
			return 0
			;;
		pick)
			if [[ $# -gt 2 ]]; then
				print "cct: too many arguments. Run 'cct --help'." >&2
				return 1
			fi

			if ! command -v fzf >/dev/null 2>&1; then
				print "cct: fzf is not installed. Install it or pass a path directly." >&2
				return 1
			fi

			local pick_root
			pick_root="${arg2:-$HOME}"
			pick_root="${pick_root:A}"

			if [[ ! -d "$pick_root" ]]; then
				print "cct: root directory does not exist: $pick_root" >&2
				return 1
			fi

			local selected
			selected="$(
				find "$pick_root" -maxdepth 6 \
				\( -name .git -o -name node_modules -o -name .venv -o -name __pycache__ \) -prune -o \
				-type d -print 2>/dev/null |
				fzf --height=45% --layout=reverse --prompt='cct pick> ' \
					--header="Pick target directory (root: $pick_root)"
			)"
			selected="${selected%%$'\n'*}"

			if [[ -z "$selected" ]]; then
				print "cct: no directory selected"
				return 1
			fi

			if [[ ! -d "$selected" ]]; then
				print "cct: selected path is not a valid directory: $selected" >&2
				return 1
			fi

			print -r -- "$selected" >| "$target_file"
			print "cct: target set to $selected"
			return 0
			;;
	esac

	if [[ $# -ne 1 ]]; then
		print "cct: too many arguments. Run 'cct --help'." >&2
		return 1
	fi

	local target_path="${arg:A}"
	if [[ ! -e "$target_path" ]]; then
		print "cct: directory does not exist: $target_path" >&2
		return 1
	fi

	if [[ ! -d "$target_path" ]]; then
		print "cct: target exists but is not a directory: $target_path" >&2
		return 1
	fi

	print -r -- "$target_path" >| "$target_file"
	print "cct: target set to $target_path"
}

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Autosuggestion style (dim, not intrusive)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#414868'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# History (you currently have none configured)
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# --- Modern Developer Experience ---

# zoxide (Smarter cd)
eval "$(zoxide init zsh)"

# fzf (Fuzzy finder)
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# eza (ls replacement)
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias tree='eza --tree --icons'

# bat (cat replacement)
alias cat='bat --paging=never'
alias help='bat --plain --language=help'

# zellij (Terminal multiplexer)
alias zj='zellij'

# Preview file content with fzf + bat
alias preview='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'

# pnpm
export PNPM_HOME="/home/rahul/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

eval "$(~/.local/bin/direnv hook zsh)"

# Smart image viewer:
# Intelligently displays images directly in the terminal (if supported) or falls back to a GUI.
img() {
  if [ $# -eq 0 ]; then
    echo "Usage: img <image-file>..."
    return 1
  fi

  # Check if we are running inside Kitty terminal (even through tmux/screen)
  if [[ -n "$KITTY_WINDOW_ID" ]] && command -v kitty >/dev/null 2>&1; then
    kitty +kitten icat --align left "$@"
  elif command -v imv >/dev/null 2>&1; then
    imv "$@" >/dev/null 2>&1 &
  elif command -v feh >/dev/null 2>&1; then
    feh "$@" >/dev/null 2>&1 &
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$@" >/dev/null 2>&1 &
  else
    echo "Error: No suitable image viewer found (kitty icat, imv, feh, or xdg-open)."
    return 1
  fi
}
