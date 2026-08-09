#!/usr/bin/env bash
# .create_repo/generators/editors.sh
# Editor/IDE support is generated unconditionally - these are all small,
# inert config files that only matter if you actually open the project in
# that editor, so there's no real cost to always including them.
generate_editors_files() {
  echo "==> editor / LSP config files"

  render_template "$TEMPLATES/exrc.tmpl" ".exrc"                     # vi
  render_template "$TEMPLATES/.vimrc.tmpl" ".vimrc"                  # Vim / Neovim

  render_template "$TEMPLATES/.dir-locals.el.tmpl" ".dir-locals.el"  # Emacs

  mkdirp ".vscode"
  render_template "$TEMPLATES/vscode_settings.tmpl" ".vscode/settings.json"
  render_template "$TEMPLATES/vscode_c_cpp_properties.tmpl" ".vscode/c_cpp_properties.json"
  render_template "$TEMPLATES/vscode_tasks.tmpl" ".vscode/tasks.json"

  render_template "$TEMPLATES/sublime-project.tmpl" "${PROJECT_NAME}.sublime-project"

  # compile_flags.txt is a universal fallback for clangd, so anything that
  # speaks the language server protocol gets correct flags/-Iinclude even
  # for build systems that don't produce a compile_commands.json (make,
  # configure, build.sh, autoconf). Covers Neovim, Emacs (eglot/lsp-mode),
  # Sublime LSP, Zed, Helix, Kate, and CLion/VS Code as a fallback too.
  render_template "$TEMPLATES/compile_flags.txt.tmpl" "compile_flags.txt"
}
