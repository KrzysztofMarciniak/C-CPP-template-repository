#!/usr/bin/env bash
# .create_repo/generators/gitignore.sh
generate_gitignore() {
  echo "==> .gitignore"
  render_template "$TEMPLATES/gitignore.tmpl" ".gitignore"
}
