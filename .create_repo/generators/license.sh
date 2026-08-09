#!/usr/bin/env bash
# .create_repo/generators/license.sh
generate_license() {
  echo "==> LICENSE ($LICENSE)"
  render_template "$TEMPLATES/licenses/${LICENSE}.tmpl" "LICENSE"
}
