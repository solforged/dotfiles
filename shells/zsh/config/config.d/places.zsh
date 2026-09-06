# Read the place registry once; prompt updates use shell values only.
if command -v places >/dev/null 2>&1; then
  typeset -gA _places_places
  while IFS=$'\t' read -r place_name place_path place_description place_exists; do
    _places_places[$place_name]=$place_path
    hash -d "$place_name=$place_path"
  done < <(places list --tsv)
  unset place_name place_path place_description place_exists

  _places_update_path() {
    local name root best=""
    export PLACE_PATH="${PWD/#$HOME/~}"
    for name root in ${(kv)_places_places}; do
      if [[ "$PWD" == "$root" || "$PWD" == "$root"/* ]] && (( ${#root} > ${#best} )); then
        best=$root
        PLACE_PATH="~${name}${PWD#$root}"
      fi
    done
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook chpwd _places_update_path
  _places_update_path

  p() {
    if (( $# == 0 )); then
      command places list
    elif (( $# == 1 )); then
      local destination
      destination=$(command places path "$1") || return
      builtin cd -- "$destination"
    else
      print -u2 'Usage: p [place]'
      return 1
    fi
  }
  alias work='places workspace'
  alias role='places role'
fi
