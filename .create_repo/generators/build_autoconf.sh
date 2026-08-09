#!/usr/bin/env bash
# .create_repo/generators/build_autoconf.sh
generate_autoconf() {
  echo "==> autoconf + automake"
  render_template "$TEMPLATES/configure.ac.tmpl" "configure.ac"
  render_template "$TEMPLATES/Makefile.am.tmpl" "Makefile.am"
  render_template "$TEMPLATES/bootstrap.tmpl" "bootstrap"
  chmod +x "bootstrap"

  if command -v autoreconf >/dev/null 2>&1; then
    echo "==> running bootstrap"
    ./bootstrap
  else
    echo "  autoreconf not found - skipping bootstrap for now."
    echo "  install autoconf/automake/libtool, then run: ./bootstrap && ./configure && make"
  fi
}
