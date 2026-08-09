#!/usr/bin/env bash
# .create_repo/generators/structure.sh
generate_structure() {
  echo "==> base directory structure"
  mkdirp "src"
  mkdirp "include/${PROJECT_NAME}"
  mkdirp "examples"
  mkdirp "docs"
  mkdirp "build"
  render_template "$TEMPLATES/main.${SRC_EXT}.tmpl" "src/main.${SRC_EXT}"
}
