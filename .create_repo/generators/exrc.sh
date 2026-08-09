#!/usr/bin/env bash
# .create_repo/generators/exrc.sh
generate_exrc() {
  echo "==> exrc config"
  render_template "$TEMPLATES/exrc.tmpl" ".exrc"
}

