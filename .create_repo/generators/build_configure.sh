#!/usr/bin/env bash
# .create_repo/generators/build_configure.sh
generate_configure() {
  echo "==> configure + Makefile"
  render_template "$TEMPLATES/configure.tmpl" "configure"
  chmod +x "configure"
  render_template "$TEMPLATES/Makefile.configure.tmpl" "Makefile"
}
