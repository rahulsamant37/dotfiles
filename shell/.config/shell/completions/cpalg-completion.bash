# shellcheck shell=bash

_cpalg_nonempty_lines() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  grep -E -v '^[[:space:]]*($|#)' "$file" 2>/dev/null || true
}

_cpalg_complete_common() {
  local list_env_name="$1"
  local default_list_rel="$2"

  local cur prev repo src_dir list_file
  COMPREPLY=()

  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  repo="${CPALG_REPO:-$HOME/github/cp-algorithms}"
  src_dir="${CPALG_SRC:-$repo/src}"

  list_file="$src_dir/$default_list_rel"
  if [[ -n "${!list_env_name:-}" ]]; then
    list_file="${!list_env_name}"
  fi

  case "$prev" in
    --repo|--src)
      COMPREPLY=( $(compgen -d -- "$cur") )
      return
      ;;
    --list-file)
      COMPREPLY=( $(compgen -f -- "$cur") )
      return
      ;;
    -i|--index)
      local total i nums=()
      total="$(_cpalg_nonempty_lines "$list_file" | wc -l | tr -d ' ')"
      if [[ -z "$total" || "$total" -lt 1 ]]; then
        return
      fi
      for ((i = 1; i <= total; i++)); do
        nums+=("$i")
      done
      COMPREPLY=( $(compgen -W "${nums[*]}" -- "$cur") )
      return
      ;;
    -q|--query)
      return
      ;;
  esac

  local opts
  opts='-h --help -l --list -c --count -i --index -r --random -p --print --no-fzf -q --query --roadmap --weekly --edit-list --repo --src --list-file --'

  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return
  fi

  local suggestions=() line base
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    suggestions+=("$line")
    base="${line##*/}"
    base="${base%.md}"
    suggestions+=("$base")
    suggestions+=("${base//-/_}")
  done < <(_cpalg_nonempty_lines "$list_file")

  COMPREPLY=( $(compgen -W "${suggestions[*]}" -- "$cur") )
}

_cpalg_complete_read() {
  _cpalg_complete_common CPALG_READ_LIST essential_read_first_order.txt
}

_cpalg_complete_revise() {
  _cpalg_complete_common CPALG_REVISE_LIST essential_revise_later_order.txt
}

_cpalg_complete_hub() {
  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  if [[ "$COMP_CWORD" -eq 1 ]]; then
    COMPREPLY=( $(compgen -W 'read revise random-read random-revise roadmap weekly list-read list-revise help' -- "$cur") )
  fi
}

complete -F _cpalg_complete_read cpa-read
complete -F _cpalg_complete_read cp-read
complete -F _cpalg_complete_revise cpa-revise
complete -F _cpalg_complete_revise cp-revise
complete -F _cpalg_complete_hub cpa
