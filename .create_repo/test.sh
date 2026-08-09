#!/usr/bin/env bash
# .create_repo/test.sh
# Scaffolds a throwaway project for every (build system x language) pair
# this tool supports - 5 build systems x 2 languages = 10 cases - builds
# each one, runs the resulting binary, and checks its output. Meant to
# catch template/generator bugs before they ship.
#
# This tests the *scaffolder*, not a project you've already generated -
# run it from a clone of this repo, not from inside a scaffolded project.
#
# Usage: .create_repo/test.sh [--keep]
#   --keep   don't delete the temp directory for a case that passes
#            (failing cases are always kept, so you can go poke at them)
#
# Requires: cc/c++ and make for every case; cmake for the cmake case;
# autoreconf/automake/autoconf for the autoconf case. A case whose tools
# aren't installed is reported as SKIP, not FAIL.

set -uo pipefail # deliberately no -e: we want to run every case, not stop at the first failure

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CREATE_REPO="$REPO_ROOT/.create_repo.sh"

KEEP=0
[ "${1:-}" = "--keep" ] && KEEP=1

PASS=0
FAIL=0
SKIP=0
FAILED_NAMES=()

have() { command -v "$1" >/dev/null 2>&1; }

# build system -> space-separated list of tools it needs on top of a compiler
declare -A REQUIRED_TOOLS=(
  [make]=""
  [cmake]="cmake"
  [posix-build.sh]=""
  [configure]=""
  [autoconf]="autoreconf automake autoconf"
)

# run_case LANG BUILD
# LANG is "c" or "c++". BUILD is one of the five build-system choices.
# The *_num values below are positions in prompts.sh's choose() menus -
# if you reorder a menu there, update the matching number here too.
run_case() {
  local lang="$1" build="$2" name tmp answers out rc missing tool

  name="t_${build//[^a-zA-Z0-9]/_}_${lang//[^a-zA-Z0-9]/_}"

  missing=""
  local cc_check="cc"
  [ "$lang" = "c++" ] && cc_check="c++"
  have "$cc_check" || missing="$missing $cc_check"
  have make || missing="$missing make"
  for tool in ${REQUIRED_TOOLS[$build]}; do
    have "$tool" || missing="$missing $tool"
  done
  if [ -n "$missing" ]; then
    printf 'SKIP  %-24s (missing:%s)\n' "$name" "$missing"
    SKIP=$((SKIP + 1))
    return
  fi

  tmp="$(mktemp -d "${TMPDIR:-/tmp}/create_repo_test.XXXXXX")"

  local lang_num std_num build_num
  if [ "$lang" = "c" ]; then lang_num=1; std_num=2; else lang_num=2; std_num=3; fi
  case "$build" in
    make)            build_num=1 ;;
    cmake)           build_num=2 ;;
    posix-build.sh)  build_num=3 ;;
    configure)       build_num=4 ;;
    autoconf)        build_num=5 ;;
  esac

  # name, author, lang, std, build, license(MIT), test(none), ci(no), lint(no)
  answers="$name
Test Author
$lang_num
$std_num
$build_num
1
1
2
2
"

  if ! (cd "$tmp" && printf '%s' "$answers" | bash "$CREATE_REPO") > "$tmp/.scaffold.log" 2>&1; then
    printf 'FAIL  %-24s (scaffold step failed)\n' "$name"
    tail -20 "$tmp/.scaffold.log" | sed 's/^/        /'
    echo "        kept: $tmp"
    FAIL=$((FAIL + 1))
    FAILED_NAMES+=("$name")
    return
  fi

  out=""
  case "$build" in
    make)
      out="$(cd "$tmp" && make 2>&1 && ./build/"$name" 2>&1)"
      ;;
    cmake)
      out="$(cd "$tmp" && cmake -S . -B build >/dev/null 2>&1 && cmake --build build 2>&1 && ./build/"$name" 2>&1)"
      ;;
    posix-build.sh)
      out="$(cd "$tmp" && sh build.sh run 2>&1)"
      ;;
    configure)
      out="$(cd "$tmp" && sh ./configure >/dev/null 2>&1 && make 2>&1 && ./build/"$name" 2>&1)"
      ;;
    autoconf)
      out="$(cd "$tmp" && ./bootstrap >/dev/null 2>&1 && ./configure >/dev/null 2>&1 && make 2>&1 && ./build/"$name" 2>&1)"
      ;;
  esac
  rc=$?

  if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -q "Hello from $name"; then
    printf 'PASS  %-24s\n' "$name"
    PASS=$((PASS + 1))
    [ "$KEEP" -eq 0 ] && rm -rf "$tmp"
  else
    printf 'FAIL  %-24s\n' "$name"
    printf '%s\n' "$out" | tail -20 | sed 's/^/        /'
    echo "        kept: $tmp"
    FAIL=$((FAIL + 1))
    FAILED_NAMES+=("$name")
  fi
}

echo "==> testing $REPO_ROOT"
echo

for lang in c c++; do
  for build in make cmake posix-build.sh configure autoconf; do
    run_case "$lang" "$build"
  done
done

echo
echo "==> $PASS passed, $FAIL failed, $SKIP skipped"

if [ "$FAIL" -ne 0 ]; then
  echo
  echo "failed: ${FAILED_NAMES[*]}"
  exit 1
fi
