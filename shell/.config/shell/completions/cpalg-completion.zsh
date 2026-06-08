#compdef cpa-read cpa-revise cp-read cp-revise cpa

_cpalg_nonempty_lines() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  grep -E -v '^[[:space:]]*($|#)' "$file" 2>/dev/null
}

_cpalg_list_file_path() {
  local list_env_name="$1"
  local default_list_rel="$2"
  local repo src_dir override

  repo="${CPALG_REPO:-$HOME/github/cp-algorithms}"
  src_dir="${CPALG_SRC:-$repo/src}"
  override="${(P)list_env_name}"

  if [[ -n "$override" ]]; then
    print -r -- "$override"
  else
    print -r -- "$src_dir/$default_list_rel"
  fi
}

_cpalg_complete_common() {
  local list_env_name="$1"
  local default_list_rel="$2"
  local list_file prev cur

  cur="${words[CURRENT]}"
  prev="${words[CURRENT-1]}"

  list_file="$(_cpalg_list_file_path "$list_env_name" "$default_list_rel")"

  case "$prev" in
    --repo|--src)
      _path_files -/
      return
      ;;
    --list-file)
      _path_files
      return
      ;;
    -i|--index)
      local total i
      local -a idxs
      total="$(_cpalg_nonempty_lines "$list_file" | wc -l | tr -d ' ')"
      if [[ -z "$total" || "$total" -lt 1 ]]; then
        return
      fi
      idxs=()
      for ((i = 1; i <= total; i++)); do
        idxs+=("$i")
      done
      compadd -- "$idxs[@]"
      return
      ;;
    -q|--query)
      return
      ;;
  esac

  local -a opts suggestions
  opts=(
    -h --help
    -l --list
    -c --count
    -i --index
    -r --random
    -p --print
    --no-fzf
    -q --query
    --roadmap
    --weekly
    --edit-list
    --repo
    --src
    --list-file
    --
  )

  if [[ "$cur" == -* ]]; then
    compadd -- "$opts[@]"
    return
  fi

  suggestions=()
  local line base
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    suggestions+=("$line")
    base="${line:t:r}"
    suggestions+=("$base")
    suggestions+=("${base//-/_}")
  done < <(_cpalg_nonempty_lines "$list_file")

  compadd -- "$suggestions[@]"
}

_cpa_read_complete() {
  _cpalg_complete_common CPALG_READ_LIST essential_read_first_order.txt
}

_cpa_revise_complete() {
  _cpalg_complete_common CPALG_REVISE_LIST essential_revise_later_order.txt
}

_cpa_hub_complete() {
  if (( CURRENT == 2 )); then
    compadd -- read revise random-read random-revise roadmap weekly list-read list-revise help
    return
  fi
}

compdef _cpa_read_complete cpa-read
compdef _cpa_read_complete cp-read
compdef _cpa_revise_complete cpa-revise
compdef _cpa_revise_complete cp-revise
compdef _cpa_hub_complete cpa
