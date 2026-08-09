#!/usr/bin/env bash
# .create_repo/generators/build_cmake.sh
generate_cmake() {
  echo "==> CMakeLists.txt"
  render_template "$TEMPLATES/CMakeLists.txt.tmpl" "CMakeLists.txt"
}
