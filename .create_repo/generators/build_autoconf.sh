#!/usr/bin/env bash
# .create_repo/generators/build_autoconf.sh
generate_autoconf() {
  echo "==> autoconf + automake"
  render_template "$TEMPLATES/configure.ac.tmpl" "configure.ac"
  render_template "$TEMPLATES/Makefile.am.tmpl" "Makefile.am"
  # Generate configure script and Makefile.in from the templates
  autoreconf -fiv
}
