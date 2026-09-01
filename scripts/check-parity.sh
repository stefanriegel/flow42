#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
workflow="$root/core/workflow.json"
commands=$(jq -r '.lifecycle_commands[], .maintenance_commands[]' "$workflow")

jq -e '
  (.schema_version == 2) and
  (.lifecycle_commands | type == "array") and
  (.maintenance_commands | type == "array") and
  ([.lifecycle_commands[], .maintenance_commands[]] | all(type == "string")) and
  ((.lifecycle_commands + .maintenance_commands | unique | length) ==
   (.lifecycle_commands + .maintenance_commands | length))
' "$workflow" >/dev/null || {
  echo "unsupported workflow schema or invalid canonical command lists: $workflow" >&2
  exit 1
}

# This deliberate independent anchor prevents a workflow entry and its skill
# directory from being removed together without detection.
expected_commands='build
flow
init
intent
maintain
plan
pr
resume
spec
status
update
verify'
actual_commands=$(printf '%s\n' "$commands" | sort)
test "$actual_commands" = "$expected_commands" || {
  echo 'canonical command set differs from the independent parity anchor' >&2
  exit 1
}

for command in $commands; do
  test -f "$root/skills/$command/SKILL.md" || {
    echo "missing skill: $command" >&2
    exit 1
  }
done

for skill_dir in "$root"/skills/*; do
  test -d "$skill_dir" || continue
  skill=$(basename "$skill_dir")
  printf '%s\n' "$commands" | grep -F -x -q "$skill" || {
    echo "skill directory is not canonical: $skill" >&2
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

version=$(jq -r '.version' "$root/.claude-plugin/plugin.json")
expected_tag="v$version"
for document in "$root/README.md" "$root/docs/INSTALLATION.md"; do
  expected_claude="claude plugin marketplace add stefanriegel/flow42@$expected_tag"
  expected_codex="codex plugin marketplace add stefanriegel/flow42 --ref $expected_tag"
  expected_pi="pi install git:github.com/stefanriegel/flow42@$expected_tag"

  for expected_pin in "$expected_claude" "$expected_codex" "$expected_pi"; do
    grep -F -x -q "$expected_pin" "$document" || {
      echo "missing immutable Flow42 install pin: $document requires '$expected_pin'" >&2
      exit 1
    }
  done

  grep -E '^(claude plugin marketplace add stefanriegel/flow42@|codex plugin marketplace add stefanriegel/flow42 --ref |pi install git:github.com/stefanriegel/flow42@)' \
    "$document" |
  while IFS= read -r install_line; do
    case "$install_line" in
      "$expected_claude"|"$expected_codex"|"$expected_pi") ;;
      *)
        echo "documented Flow42 install command is not pinned to $expected_tag: $document has '$install_line'" >&2
        exit 1
        ;;
    esac
  done
done

command_count=$(jq '.lifecycle_commands + .maintenance_commands | length' "$workflow")
echo "parity ok: $command_count commands, 3 harness paths, Orca ADE adapter"
