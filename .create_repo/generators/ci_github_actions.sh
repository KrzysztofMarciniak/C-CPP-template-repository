#!/usr/bin/env bash
# .create_repo/generators/ci_github_actions.sh
generate_ci() {
  echo "==> GitHub Actions CI"
  render_template "$TEMPLATES/workflow.yml.tmpl" ".github/workflows/ci.yml"
}
