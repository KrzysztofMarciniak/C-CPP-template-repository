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

# pkg_exists NAME - true if pkg-config knows about NAME
pkg_exists() {
  command -v pkg-config >/dev/null 2>&1 && pkg-config --exists "$1" 2>/dev/null
}

# header_exists relative/path.h - true if the header shows up in a few
# common system include locations
header_exists() {
  local h="$1" d
  for d in /usr/include /usr/local/include /opt/homebrew/include; do
    [ -f "$d/$h" ] && return 0
  done
  return 1
}

# test_fw_available NAME - best-effort check for whether a test framework
# is already installed (pkg-config first, common headers as a fallback).
# Always "available" for TEST_FW=none, and unknown names are assumed
# available (nothing to check for) rather than blocking the user.
test_fw_available() {
  case "$1" in
    none)       return 0 ;;
    Unity)      header_exists "unity.h" || header_exists "unity/unity.h" ;;
    cmocka)     pkg_exists cmocka || header_exists "cmocka.h" ;;
    criterion)  pkg_exists criterion || header_exists "criterion/criterion.h" ;;
    Catch2)     pkg_exists catch2-with-main || pkg_exists catch2 \
                  || header_exists "catch2/catch_all.hpp" ;;
    GoogleTest) pkg_exists gtest || header_exists "gtest/gtest.h" ;;
    doctest)    header_exists "doctest/doctest.h" || header_exists "doctest.h" ;;
    *)          return 0 ;;
  esac
}

# render_template SRC DST
# Substitutes @@TOKEN@@ placeholders using currently-exported config vars.
render_template() {
  local src="$1" dst="$2" content
  mkdir -p "$(dirname "$dst")"
  content="$(cat "$src")"
  for token in PROJECT_NAME PROJECT_NAME_CANON AUTHOR YEAR LANG STD SRC_EXT CC BUILD LICENSE \
               TEST_FW CMAKE_LANG CMAKE_STD_NUM CMAKE_STD_VAR FLAGS_VAR \
               VSCODE_C_STD VSCODE_CPP_STD VSCODE_LANG_ID BUILD_CMD; do
    local val="${!token:-}"
    content="${content//@@${token}@@/$val}"
  done
  printf '%s\n' "$content" > "$dst"
  echo "  created $dst"
}
