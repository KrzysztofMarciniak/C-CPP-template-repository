#!/usr/bin/env bash
# .create_repo/generators/build_posix.sh
generate_posix_build() {
  echo "==> build.sh"
  render_template "$TEMPLATES/build.sh.tmpl" "build.sh"
  chmod +x "build.sh"
}
