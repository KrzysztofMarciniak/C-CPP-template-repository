#!/usr/bin/env bash
# .create_repo/generators/editors.sh
generate_editors_files() {
  echo "==> .exrc, .vimrc and .dir-locals.el"
  render_template "$TEMPLATES/exrc.tmpl" ".exrc"
  render_template "$TEMPLATES/.vimrc.tmpl" ".vimrc"
  render_template "$TEMPLATES/.dir-locals.el.tmpl" ".dir-locals.el"
}
