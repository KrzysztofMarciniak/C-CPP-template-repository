#!/usr/bin/env bash
# .create_repo_CLEAN.sh
# Removes everything .create_repo.sh's generators can produce. Destructive.
# Requires typed confirmation unless --force is passed.
#
# If you add a new generator that writes a new top-level path, add that
# path to TARGETS below so this stays in sync.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

FORCE=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --force)   FORCE=1 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      echo "Usage: $0 [--force] [--dry-run]"
      echo "  --force    skip the confirmation prompt"
      echo "  --dry-run  show what would be deleted, delete nothing"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

TARGETS=(
  "src"
  "include"
  "examples"
  "docs"
  "build"
  "tests"
  "Makefile"
  "CMakeLists.txt"
  "build.sh"
  "configure"
  "config.mk"
  "scripts"
  ".gitignore"
  "README.md"
  "LICENSE"
  ".github/workflows/ci.yml"
  ".clang-format"
  ".clang-tidy"
  ".editorconfig"
  ".exrc"
)

existing=()
for t in "${TARGETS[@]}"; do
  [ -e "$t" ] && existing+=("$t")
done

if [ "${#existing[@]}" -eq 0 ]; then
  echo "Nothing to clean in $SCRIPT_DIR"
  exit 0
fi

echo "WARNING: this will permanently delete the following from:"
echo "  $SCRIPT_DIR"
echo
for t in "${existing[@]}"; do
  echo "  - $t"
done
echo
echo "This will NOT touch .create_repo/, .create_repo.sh, .git, or anything else."

if [ "$DRY_RUN" -eq 1 ]; then
  echo
  echo "(dry run - nothing deleted)"
  exit 0
fi

if [ "$FORCE" -ne 1 ]; then
  echo
  read -r -p "Type DELETE to confirm: " confirm
  if [ "$confirm" != "DELETE" ]; then
    echo "Aborted. Nothing was deleted."
    exit 1
  fi
fi

echo
for t in "${existing[@]}"; do
  rm -rf -- "$t"
  echo "  removed $t"
done

# tidy up an empty .github tree if ci.yml was the only thing in it
[ -d ".github/workflows" ] && rmdir --ignore-fail-on-non-empty .github/workflows .github 2>/dev/null || true

echo
echo "==> Clean."
