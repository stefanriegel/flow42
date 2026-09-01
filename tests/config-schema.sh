#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
schema="$root/core/config-schema.json"
fixtures="$root/tests/fixtures/config"
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-config.XXXXXX")
trap 'rm -rf "$tmp"' 0 HUP INT TERM

test -f "$schema" || { echo CONFIG-SCHEMA-MISSING >&2; exit 1; }
jq -e '.schema_version == 1 and .unknown_fields == "block" and .extra_gates == "allowed" and .command_paths == "must-exist-or-be-auto"' "$schema" >/dev/null
jq -e '.fields.base_branch.validation == "git-check-ref-format---branch" and
  .command_policy.fail_closed == true and
  .command_policy.authority_bearing_executables == ["git", "gh", "glab", "terraform"] and
  .command_policy.read_only_control_cli_allowlist == [] and
  (.command_policy.token_pattern | type == "string" and length > 0) and
  (.command_policy.shell_evaluation_prefixes | type == "array" and length > 0) and
  (.command_policy.disallowed_mutation_prefixes | type == "array" and length > 0) and
  (.command_policy.forbidden_token_pattern | type == "string" and length > 0)' "$schema" >/dev/null || {
  echo CONFIG-COMMAND-POLICY >&2
  exit 1
}

scalar() { awk -v key="$2" '$0 ~ "^" key ":[[:space:]]*" {sub("^[^:]*:[[:space:]]*", ""); print; exit}' "$1"; }
top_keys() { awk '/^[A-Za-z_][A-Za-z0-9_]*:/ {sub(/:.*/, ""); print}' "$1"; }
section_pairs() { awk -v section="$2" '$0 == section ":" {inside=1; next} inside && /^[^ ]/ {exit} inside && /^  [A-Za-z_][A-Za-z0-9_]*:/ {sub(/^  /, ""); key=$0; sub(/:.*/, "", key); sub(/^[^:]*:[[:space:]]*/, ""); print key "\t" $0}' "$1"; }
list_values() { awk -v section="$2" '$0 == section ":" {inside=1; next} inside && /^[^ ]/ {exit} inside && /^  - / {sub(/^  - /, ""); print}' "$1"; }
fail() { echo "$1" >&2; return 1; }

validate_yaml_form() {
  file=$1
  if grep -q '"' "$file" || grep -q "'" "$file" ||
    grep -Eq "$(printf '\t')|(^|[[:space:]])(&[^[:space:]]+|[*][^[:space:]]+|![^[:space:]]+|<<:)" "$file"; then
    fail CONFIG-YAML-FORM
    return
  fi
  awk '
    /^[[:space:]]*$/ {next}
    /^[A-Za-z_][A-Za-z0-9_]*:/ {
      section=$0; sub(/:.*/, "", section)
      if (seen[section]++) exit 1
      if (section == "model_profiles" || section == "commands" || section == "mandatory_gates") {
        if ($0 != section ":") exit 1
      } else if (section == "protected_paths") {
        if ($0 != "protected_paths:" && $0 != "protected_paths: []") exit 1
      } else if ($0 !~ /^[A-Za-z_][A-Za-z0-9_]*: [^[:space:]].*$/) exit 1
      next
    }
    /^  [A-Za-z_][A-Za-z0-9_]*: / {
      if (section != "model_profiles" && section != "commands") exit 1
      child=$0; sub(/^  /, "", child); sub(/:.*/, "", child)
      if (seen[section "." child]++) exit 1
      next
    }
    /^  - [^[:space:]].*$/ {if (section != "mandatory_gates" && section != "protected_paths") exit 1; next}
    {exit 1}
  ' "$file" || { fail CONFIG-YAML-FORM; return; }
}

validate_command() {
  value=$1
  if ! printf '%s\n' "$value" | grep -Eq '^\[[^][[:space:],]+([[:space:]]*,[[:space:]]*[^][[:space:],]+)*\]$'; then
    fail CONFIG-COMMAND-TOKEN
    return
  fi
  tokens=$(printf '%s\n' "$value" | sed 's/^\[//; s/\]$//' | tr ',' '\n' |
    sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
  token_pattern=$(jq -r '.command_policy.token_pattern' "$schema")
  if printf '%s\n' "$tokens" | grep -Ev "$token_pattern" >/dev/null; then
    fail CONFIG-COMMAND-TOKEN
    return
  fi
  first=$(printf '%s\n' "$tokens" | sed -n '1p')
  first=${first##*/}
  canonical=$(printf '%s\n' "$tokens" | awk -v first="$first" 'NR == 1 {$0=first} {if (NR > 1) printf "\t"; printf "%s", $0} END {print ""}')

  if jq -e --arg executable "$first" \
    '.command_policy.authority_bearing_executables | index($executable) != null' \
    "$schema" >/dev/null; then
    fail CONFIG-COMMAND-CONTROL-CLI
    return
  fi

  forbidden_pattern=$(jq -r '.command_policy.forbidden_token_pattern' "$schema")
  if printf '%s\n' "$tokens" | grep -Eq "$forbidden_pattern"; then
    fail CONFIG-COMMAND-SHELL-EVAL
    return
  fi
  while IFS= read -r prefix; do
    case "$canonical" in "$prefix" | "$prefix""$(printf '\t')"*) fail CONFIG-COMMAND-SHELL-EVAL; return ;; esac
  done <<EOF
$(jq -r '.command_policy.shell_evaluation_prefixes[] | @tsv' "$schema")
EOF
  while IFS= read -r prefix; do
    case "$canonical" in "$prefix" | "$prefix""$(printf '\t')"*) fail CONFIG-COMMAND-UNSAFE; return ;; esac
  done <<EOF
$(jq -r '.command_policy.disallowed_mutation_prefixes[] | @tsv' "$schema")
EOF
}

validate_config() {
  file=$1
  validate_yaml_form "$file" || return
  version=$(scalar "$file" schema_version)
  test "$version" = "$(jq -r '.schema_version' "$schema")" || { fail CONFIG-SCHEMA-VERSION; return; }

  for key in $(top_keys "$file"); do
    jq -e --arg key "$key" '.fields | has($key)' "$schema" >/dev/null || { fail CONFIG-UNKNOWN-FIELD; return; }
  done
  for key in $(jq -r '.fields | to_entries[] | select(.value.required) | .key' "$schema"); do
    top_keys "$file" | grep -Fxq "$key" || { fail CONFIG-MISSING-FIELD; return; }
  done

  for key in forge harness execution_environment; do
    value=$(scalar "$file" "$key")
    jq -e --arg key "$key" --arg value "$value" '.fields[$key].enum | index($value)' "$schema" >/dev/null || { fail CONFIG-ENUM; return; }
  done
  concurrency=$(scalar "$file" concurrency)
  case "$concurrency" in *[!0-9]*|'') fail CONFIG-CONCURRENCY; return ;; esac
  min=$(jq -r '.fields.concurrency.minimum' "$schema"); max=$(jq -r '.fields.concurrency.maximum' "$schema")
  test "$concurrency" -ge "$min" && test "$concurrency" -le "$max" || { fail CONFIG-CONCURRENCY; return; }

  base_branch=$(scalar "$file" base_branch)
  if test "$base_branch" != auto; then
    base_pattern=$(jq -r '.fields.base_branch.pattern' "$schema")
    if ! printf '%s\n' "$base_branch" | grep -Eq "$base_pattern" ||
      ! git check-ref-format --branch "$base_branch" >/dev/null 2>&1; then
      fail CONFIG-BASE-BRANCH
      return
    fi
  fi
  worktree_parent=$(scalar "$file" worktree_parent)
  worktree_pattern=$(jq -r '.fields.worktree_parent.pattern' "$schema")
  printf '%s\n' "$worktree_parent" | grep -Eq "$worktree_pattern" || { fail CONFIG-WORKTREE-PARENT; return; }
  case "$worktree_parent" in auto) ;; /* | [~] | [~]/* | .. | ../* | */../* | */..) fail CONFIG-WORKTREE-PARENT; return ;; esac

  for section in model_profiles commands; do
    expected_keys=$(jq -r --arg section "$section" '.fields[$section].properties | keys[]' "$schema")
    actual=$(section_pairs "$file" "$section" | cut -f1)
    for key in $actual; do printf '%s\n' "$expected_keys" | grep -Fxq "$key" || { fail CONFIG-UNKNOWN-FIELD; return; }; done
    for key in $expected_keys; do printf '%s\n' "$actual" | grep -Fxq "$key" || { fail CONFIG-MISSING-FIELD; return; }; done
  done

  pattern=$(jq -r '.fields.model_profiles.properties.frontier.pattern' "$schema")
  model_failed=0
  while IFS="$(printf '\t')" read -r key value; do
    if test "$value" != auto && ! printf '%s\n' "$value" | grep -Eq "$pattern"; then
      model_failed=1
      break
    fi
  done <<EOF
$(section_pairs "$file" model_profiles)
EOF
  test "$model_failed" -eq 0 || { fail CONFIG-MODEL-ID; return; }

  command_array_failed=0
  while IFS="$(printf '\t')" read -r key value; do
    if ! printf '%s\n' "$value" | grep -Eq '^\[[^]]*\]$'; then
      command_array_failed=1
      break
    fi
  done <<EOF
$(section_pairs "$file" commands)
EOF
  test "$command_array_failed" -eq 0 || { fail CONFIG-COMMAND-ARRAY; return; }

  command_failed=0
  while IFS="$(printf '\t')" read -r key value; do
    if test "$value" != '[]' && test "$value" != '[auto]' && ! validate_command "$value"; then
      command_failed=1
      break
    fi
  done <<EOF
$(section_pairs "$file" commands)
EOF
  test "$command_failed" -eq 0 || return 1

  command_path_failed=0
  while IFS= read -r token; do
    token=$(printf '%s' "$token" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    case "$token" in
      ''|auto|-*) continue ;;
      */*)
        if ! test -e "$root/$token"; then
          command_path_failed=1
          break
        fi
        ;;
    esac
  done <<EOF
$(section_pairs "$file" commands | cut -f2- | tr -d '[]' | tr ',' '\n')
EOF
  test "$command_path_failed" -eq 0 || { fail CONFIG-COMMAND-PATH; return; }

  path_pattern=$(jq -r '.fields.protected_paths.item_pattern' "$schema")
  for protected_path in $(list_values "$file" protected_paths); do
    printf '%s\n' "$protected_path" | grep -Eq "$path_pattern" || { fail CONFIG-PROTECTED-PATH; return; }
    case "$protected_path" in /* | [~] | [~]/* | .. | ../* | */../* | */..) fail CONFIG-PROTECTED-PATH; return ;; esac
  done

  retired=$(jq -r '.retired_gates.names[]' "$schema")
  gate_pattern=$(jq -r '.fields.mandatory_gates.item_pattern' "$schema")
  for gate in $(list_values "$file" mandatory_gates); do
    printf '%s\n' "$gate" | grep -Eq "$gate_pattern" || { fail CONFIG-GATE-GRAMMAR; return; }
    if printf '%s\n' "$retired" | grep -Fxq "$gate"; then fail CONFIG-RETIRED-GATE; return; fi
  done
  for gate in $(jq -r '.canonical_mandatory_gates[]' "$schema"); do
    list_values "$file" mandatory_gates | grep -Fxq "$gate" || { fail CONFIG-MISSING-GATE; return; }
  done
}

validate_config "$root/templates/config.yml"
validate_config "$root/.flow42/config.yml"
validate_config "$fixtures/valid.yml"
validate_config "$fixtures/extra-custom-gate.yml"

for fixture in retired-gate missing-canonical-gate unknown-field scalar-command bad-model-id \
  bad-base-branch invalid-git-ref previous-checkout-base-branch unsafe-protected-path missing-command-path \
  shell-eval-command shell-eval-env-command command-substitution-command \
  destructive-command forge-mutation-command unsafe-worktree-absolute \
  unsafe-worktree-home unsafe-worktree-parent bare-parent-protected-path \
  command-path-qualified-rm command-sudo-rm command-env-rm command-wrapper-rm \
  command-git-global-push command-gh-global-merge command-terraform-chdir-apply \
  command-git-alias-push command-git-status command-gh-api-post command-glab-api-post \
  command-terraform-plan command-empty-token command-trailing-empty-token command-whitespace-token \
  unsupported-yaml-form unsupported-quoted-scalar unsupported-duplicate-key \
  unknown-schema-version; do
  case "$fixture" in
    retired-gate) expected=CONFIG-RETIRED-GATE ;;
    missing-canonical-gate) expected=CONFIG-MISSING-GATE ;;
    unknown-field) expected=CONFIG-UNKNOWN-FIELD ;;
    scalar-command) expected=CONFIG-COMMAND-ARRAY ;;
    bad-model-id) expected=CONFIG-MODEL-ID ;;
    bad-base-branch | invalid-git-ref | previous-checkout-base-branch) expected=CONFIG-BASE-BRANCH ;;
    unsafe-protected-path) expected=CONFIG-PROTECTED-PATH ;;
    bare-parent-protected-path) expected=CONFIG-PROTECTED-PATH ;;
    unsafe-worktree-absolute | unsafe-worktree-home | unsafe-worktree-parent) expected=CONFIG-WORKTREE-PARENT ;;
    unsupported-yaml-form | unsupported-quoted-scalar | unsupported-duplicate-key) expected=CONFIG-YAML-FORM ;;
    missing-command-path) expected=CONFIG-COMMAND-PATH ;;
    shell-eval-command | shell-eval-env-command | command-substitution-command) expected=CONFIG-COMMAND-SHELL-EVAL ;;
    command-path-qualified-rm | command-sudo-rm | command-env-rm | \
      command-wrapper-rm) expected=CONFIG-COMMAND-UNSAFE ;;
    destructive-command | forge-mutation-command | command-git-global-push | \
      command-gh-global-merge | command-terraform-chdir-apply | \
      command-git-alias-push | command-git-status | command-gh-api-post | \
      command-glab-api-post | command-terraform-plan) expected=CONFIG-COMMAND-CONTROL-CLI ;;
    command-empty-token | command-trailing-empty-token | command-whitespace-token) expected=CONFIG-COMMAND-TOKEN ;;
    unknown-schema-version) expected=CONFIG-SCHEMA-VERSION ;;
  esac
  log="$tmp/$fixture.log"
  validation_rc=0
  (set +e; validate_config "$fixtures/$fixture.yml") >"$log" 2>&1 || validation_rc=$?
  if test "$validation_rc" -eq 0; then echo "config mutation survived: $fixture" >&2; exit 1; fi
  test "$(grep -c '^CONFIG-' "$log")" -eq 1
  grep -Fxq "$expected" "$log"
done

alias_repo="$tmp/git-alias-repo"
alias_remote="$tmp/git-alias-remote.git"
git init -q "$alias_repo"
git init -q --bare "$alias_remote"
git -C "$alias_repo" config user.name 'Flow42 config fixture'
git -C "$alias_repo" config user.email 'config-fixture@example.invalid'
printf '%s\n' fixture >"$alias_repo/file.txt"
git -C "$alias_repo" add file.txt
git -C "$alias_repo" commit -qm baseline
git -C "$alias_repo" remote add origin "$alias_remote"
git -C "$alias_repo" config alias.publish-safely 'push origin HEAD:refs/heads/injected'
if git --git-dir="$alias_remote" show-ref --verify --quiet refs/heads/injected; then
  echo CONFIG-GIT-ALIAS-PRECONDITION >&2
  exit 1
fi
git -C "$alias_repo" publish-safely >/dev/null 2>&1
git --git-dir="$alias_remote" show-ref --verify --quiet refs/heads/injected || {
  echo CONFIG-GIT-ALIAS-NOT-EXECUTABLE >&2
  exit 1
}

schema_fields=$(jq -r '.fields | to_entries[] | if (.value.type == "object") then .key as $p | .value.properties | keys[] | $p + "." + . else .key end' "$schema" | sort)
doc_fields=$(awk -F'`' '/^\| `/ {print $2}' "$root/docs/CONFIGURATION.md" | sort)
test "$schema_fields" = "$doc_fields" || { echo CONFIG-DOC-DRIFT >&2; exit 1; }
grep -q '^## Configuration: removed approval gates$' "$root/docs/MIGRATION.md"

echo 'config schema ok: Git refs, safe paths/YAML, fail-closed argv policy, strict fixtures, documentation drift'
