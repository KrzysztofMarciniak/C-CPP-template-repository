#!/usr/bin/env bash
# .create_repo/lib/prompts.sh
# All interactive questions live here. Edit this file to add/remove/reorder
# prompts without touching any generator.

collect_config() {
  PROJECT_NAME=$(ask "Project name" "$(basename "$PWD")")
  # automake requires Makefile variable prefixes with no hyphens/dots - the
  # binary name itself (bin_PROGRAMS) can keep them, but *_SOURCES/*_CFLAGS
  # etc. can't. Mirror automake's own canonicalization here.
  PROJECT_NAME_CANON=$(echo "$PROJECT_NAME" | sed 's/[^A-Za-z0-9]/_/g')
  AUTHOR=$(ask "Author name" "$(git config user.name 2>/dev/null || echo "Your Name")")
  YEAR=$(date +%Y)

  LANG=$(choose "Language:" "c" "c++")
  if [ "$LANG" = "c" ]; then
    STD=$(choose "C standard:" "c99" "c11" "c17" "c23")
    SRC_EXT="c"
    CC="cc"
    CMAKE_LANG="C"
    CMAKE_STD_VAR="C"
    FLAGS_VAR="CFLAGS"
  else
    STD=$(choose "C++ standard:" "c++11" "c++14" "c++17" "c++20" "c++23")
    SRC_EXT="cpp"
    CC="c++"
    CMAKE_LANG="CXX"
    CMAKE_STD_VAR="CXX"
    FLAGS_VAR="CXXFLAGS"
  fi
  # numeric standard for CMake, e.g. c++17 -> 17, c11 -> 11
  CMAKE_STD_NUM=$(echo "$STD" | grep -o '[0-9]\+$')

  BUILD=$(choose "Build system:" "make" "cmake" "posix-build.sh" "configure" "autoconf")
  case "$BUILD" in
    make)            BUILD_CMD="make" ;;
    cmake)           BUILD_CMD="cmake --build build" ;;
    posix-build.sh)  BUILD_CMD="./build.sh" ;;
    configure)       BUILD_CMD="make" ;;
    autoconf)        BUILD_CMD="make" ;;
  esac

  LICENSE=$(choose "License:" "MIT" "Apache-2.0" "GPL-3.0" "BSD-3-Clause" "None")

  while true; do
    if [ "$LANG" = "c" ]; then
      TEST_FW=$(choose "Test framework:" "none" "Unity" "cmocka" "criterion")
    else
      TEST_FW=$(choose "Test framework:" "none" "Catch2" "GoogleTest" "doctest")
    fi

    if test_fw_available "$TEST_FW"; then
      break
    fi

    echo
    echo "  note: $TEST_FW doesn't look like it's installed (checked pkg-config"
    echo "        and common include paths). The generated tests/ will still"
    echo "        be created, but won't compile until it's installed."
    next=$(choose "What would you like to do?" \
      "choose a different framework" "use $TEST_FW anyway")
    echo
    [ "$next" = "use $TEST_FW anyway" ] && break
  done

  USE_CI=$(choose "Add GitHub Actions CI?" "yes" "no")
  USE_LINT=$(choose "Add clang-format/clang-tidy/.editorconfig?" "yes" "no")

  # VS Code / Sublime want an explicit std for both C and C++ fields even
  # though the project is only one language; fill the unused one with a
  # sane default rather than leaving it blank.
  if [ "$LANG" = "c" ]; then
    VSCODE_C_STD="$STD"
    VSCODE_CPP_STD="c++17"
    VSCODE_LANG_ID="c"
  else
    VSCODE_C_STD="c17"
    VSCODE_CPP_STD="$STD"
    VSCODE_LANG_ID="cpp"
  fi

  export PROJECT_NAME PROJECT_NAME_CANON AUTHOR YEAR LANG STD SRC_EXT CC CMAKE_LANG CMAKE_STD_VAR \
         CMAKE_STD_NUM FLAGS_VAR BUILD BUILD_CMD LICENSE TEST_FW USE_CI USE_LINT \
         VSCODE_C_STD VSCODE_CPP_STD VSCODE_LANG_ID
}
