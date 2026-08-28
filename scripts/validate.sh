#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
errors=0

for json in "$root/core/workflow.json" "$root/core/risk-policy.json" "$root/evals/scenarios.json" \
  "$root/.claude-plugin/marketplace.json" \
  "$root/.claude-plugin/plugin.json" "$root/.codex-plugin/plugin.json"; do
  if ! jq -e . "$json" >/dev/null; then
    echo "invalid JSON: ${json#"$root/"}" >&2
    errors=1
  fi
done

for skill in "$root"/skills/*/SKILL.md; do
  first=$(sed -n '1p' "$skill")
  if test "$first" != '---' || ! grep -q '^description:' "$skill"; then
    echo "invalid skill frontmatter: ${skill#"$root/"}" >&2
    errors=1
  fi
  if grep -q '\[TODO:' "$skill"; then
    echo "placeholder: ${skill#"$root/"}" >&2
    errors=1
  fi
done

if grep -R -n -i -E 'python3|scripts/flow42\.py|scripts/check-parity\.py|scripts/validate\.py' \
  "$root/README.md" "$root/CONTRIBUTING.md" "$root/.github" "$root/skills" >/dev/null; then
  echo 'supported path still references the retired Python runtime' >&2
  errors=1
fi

if find "$root" -type f \( -name '*.py' -o -name '*.pyc' \) -not -path "$root/.git/*" | grep -q .; then
  echo 'Python implementation or cache remains in the repository' >&2
  errors=1
fi

if grep -R -n '\.sdlc' "$root" --exclude=validate.sh --exclude-dir=.git \
  --exclude-dir=dist --exclude-dir=build >/dev/null; then
  echo 'legacy workspace path remains' >&2
  errors=1
fi

test "$errors" -eq 0 || exit 1

versions=$(jq -r '.version' "$root/.claude-plugin/marketplace.json" \
  "$root/.claude-plugin/plugin.json" "$root/.codex-plugin/plugin.json" | sort -u)
if test "$(printf '%s\n' "$versions" | wc -l | tr -d ' ')" != 1 ||
  ! printf '%s\n' "$versions" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo 'plugin and marketplace versions must match semantic versioning' >&2
  exit 1
fi

echo 'validation ok'
