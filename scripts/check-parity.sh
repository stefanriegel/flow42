#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
commands='flow init update intent spec plan build verify pr maintain status resume'

for command in $commands; do
  test -f "$root/skills/$command/SKILL.md" || {
    echo "missing skill: $command" >&2
    exit 1
  }
done

for manifest in "$root/.claude-plugin/plugin.json" "$root/.codex-plugin/plugin.json"; do
  jq -e '.name == "flow42"' "$manifest" >/dev/null || {
    echo "invalid plugin name: $manifest" >&2
    exit 1
  }
done

grep -q '^## Pi examples$' "$root/core/MODEL-ROUTING.md"
grep -q 'pi install git:github.com/stefanriegel/flow42@' "$root/docs/INSTALLATION.md"
grep -q 'orca status' "$root/skills/flow/SKILL.md"

jq -e '.name == "flow42" and (.plugins | length == 1) and .plugins[0].name == "flow42"' \
  "$root/.claude-plugin/marketplace.json" >/dev/null

workflow_commands=$(jq -r '.commands[]' "$root/core/workflow.json" | tr '\n' ' ' | sed 's/ $//')
test "$workflow_commands" = "$commands" || {
  echo "workflow command list differs from canonical skills" >&2
  exit 1
}

echo "parity ok: 12 commands, 3 harness paths, Orca ADE adapter"
