#!/usr/bin/env bash
# .create_repo/lib/prompts.sh
# All interactive questions live here. Edit this file to add/remove/reorder
# prompts without touching any generator.

collect_config() {
  PROJECT_NAME=$(ask "Project name" "$(basename "$PWD")")
  AUTHOR=$(ask "Author name" "$(git config user.name 2>/dev/null || echo "Your Name")")
  YEAR=$(date +%Y)

  LANG=$(choose "Language:" "c" "c++")
  if [ "$LANG" = "c" ]; then
    STD=$(choose "C standard:" "c99" "c11" "c17" "c23")
    SRC_EXT="c"
    CC="cc"
    CMAKE_LANG="C"
    CMAKE_STD_VAR="C"
  else
    STD=$(choose "C++ standard:" "c++11" "c++14" "c++17" "c++20" "c++23")
    SRC_EXT="cpp"
    CC="c++"
    CMAKE_LANG="CXX"
    CMAKE_STD_VAR="CXX"
  fi
  # numeric standard for CMake, e.g. c++17 -> 17, c11 -> 11
  CMAKE_STD_NUM=$(echo "$STD" | grep -o '[0-9]\+$')

  BUILD=$(choose "Build system:" "make" "cmake" "posix-build.sh" "configure")

  LICENSE=$(choose "License:" "MIT" "Apache-2.0" "GPL-3.0" "BSD-3-Clause" "None")

  if [ "$LANG" = "c" ]; then
    TEST_FW=$(choose "Test framework:" "none" "Unity" "cmocka" "criterion")
  else
    TEST_FW=$(choose "Test framework:" "none" "Catch2" "GoogleTest" "doctest")
  fi

  USE_CI=$(choose "Add GitHub Actions CI?" "yes" "no")
  USE_LINT=$(choose "Add clang-format/clang-tidy/.editorconfig?" "yes" "no")

  export PROJECT_NAME AUTHOR YEAR LANG STD SRC_EXT CC CMAKE_LANG CMAKE_STD_VAR \
         CMAKE_STD_NUM BUILD LICENSE TEST_FW USE_CI USE_LINT
}
