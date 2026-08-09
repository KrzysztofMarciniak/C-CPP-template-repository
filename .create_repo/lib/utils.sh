#!/usr/bin/env bash
# .create_repo/lib/utils.sh
# Shared helpers used by every generator. Sourced by .create_repo.sh.

mkdirp() { mkdir -p "$1"; }

# ask "Prompt text" "default value"
ask() {
  local prompt="$1" default="$2" reply
  read -r -p "$prompt [$default]: " reply
  echo "${reply:-$default}"
}

# choose "Prompt text" opt1 opt2 opt3 ...
# Menu goes to stderr so it doesn't pollute $(choose ...) captures;
# the chosen option is printed to stdout.
choose() {
  local prompt="$1"; shift
  local opts=("$@") i=1 sel
  echo "$prompt" >&2
  for o in "${opts[@]}"; do
    echo "  $i) $o" >&2
    i=$((i + 1))
  done
  read -r -p "Choice [1]: " sel
  sel="${sel:-1}"
  echo "${opts[$((sel - 1))]}"
}

# render_template SRC DST
# Substitutes @@TOKEN@@ placeholders using currently-exported config vars.
render_template() {
  local src="$1" dst="$2" content
  mkdir -p "$(dirname "$dst")"
  content="$(cat "$src")"
  for token in PROJECT_NAME PROJECT_NAME_CANON AUTHOR YEAR LANG STD SRC_EXT CC BUILD LICENSE \
               TEST_FW CMAKE_LANG CMAKE_STD_NUM CMAKE_STD_VAR; do
    local val="${!token:-}"
    content="${content//@@${token}@@/$val}"
  done
  printf '%s\n' "$content" > "$dst"
  echo "  created $dst"
}
