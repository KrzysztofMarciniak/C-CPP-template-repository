#!/usr/bin/env bash
# .create_repo/generators/exrc.sh
generate_exrc() {
  echo "==> .vimrc and .dir-locals.el"
  render_template "$TEMPLATES/.vimrc.tmpl" ".vimrc"
  render_template "$TEMPLATES/.dir-locals.el.tmpl" ".dir-locals.el"
}
