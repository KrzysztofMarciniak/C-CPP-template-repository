#!/usr/bin/env bash
# .create_repo/generators/format_scripts.sh
# Runs regardless of the USE_LINT prompt: these scripts have sane defaults
# even without a .clang-format/.clang-tidy file, and every build system's
# `format`/`lint` targets shell out to them.
generate_format_scripts() {
  echo "==> scripts/format.sh, scripts/lint.sh"
  render_template "$TEMPLATES/format.sh.tmpl" "scripts/format.sh"
  render_template "$TEMPLATES/lint.sh.tmpl" "scripts/lint.sh"
  chmod +x "scripts/format.sh" "scripts/lint.sh"
}
