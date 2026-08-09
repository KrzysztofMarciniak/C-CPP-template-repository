#!/usr/bin/env bash
# .create_repo.sh
# Scaffolds a C/C++ project in the current directory.
#
# All questions live in .create_repo/lib/prompts.sh
# All shared helpers live in .create_repo/lib/utils.sh
# Each feature is its own file in .create_repo/generators/
# Raw file content lives in .create_repo/templates/
#
# Add a new feature: drop a generators/foo.sh (defining generate_foo) and,
# if it needs one, a templates/foo.tmpl - then call generate_foo from main()
# below. Nothing else needs to change.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CR="$SCRIPT_DIR/.create_repo"
export TEMPLATES="$CR/templates"

source "$CR/lib/utils.sh"
source "$CR/lib/prompts.sh"
for g in "$CR"/generators/*.sh; do
  # shellcheck disable=SC1090
  source "$g"
done

main() {
  collect_config

  echo
  echo "==> Configuration"
  echo "    name:    $PROJECT_NAME"
  echo "    lang:    $LANG ($STD)"
  echo "    build:   $BUILD"
  echo "    license: $LICENSE"
  echo "    tests:   $TEST_FW"
  echo "    ci:      $USE_CI"
  echo "    lint:    $USE_LINT"
  echo

  generate_structure
  generate_format_scripts

  case "$BUILD" in
    make)            generate_make ;;
    cmake)           generate_cmake ;;
    posix-build.sh)  generate_posix_build ;;
    configure)       generate_configure ;;
  esac

  generate_gitignore
  generate_readme

  [ "$LICENSE" != "None" ] && generate_license
  [ "$TEST_FW" != "none" ] && generate_tests
  [ "$USE_CI" = "yes" ]    && generate_ci
  [ "$USE_LINT" = "yes" ]  && generate_lint

  echo
  echo "==> Done. Scaffolded '${PROJECT_NAME}' in $(pwd)"
}

main "$@"
