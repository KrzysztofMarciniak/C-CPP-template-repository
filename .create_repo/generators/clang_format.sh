#!/usr/bin/env bash
# .create_repo/generators/clang_format.sh
generate_lint() {
  echo "==> lint configs"
  render_template "$TEMPLATES/clang-format.tmpl" ".clang-format"
  render_template "$TEMPLATES/clang-tidy.tmpl" ".clang-tidy"
  render_template "$TEMPLATES/editorconfig.tmpl" ".editorconfig"
}
