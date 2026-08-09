#!/usr/bin/env bash
# .create_repo/generators/build_make.sh
generate_make() {
  echo "==> Makefile"
  render_template "$TEMPLATES/Makefile.tmpl" "Makefile"
}
