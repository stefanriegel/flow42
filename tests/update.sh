#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
stateful_tmp=
fake_bin=

cleanup() {
  if test -n "$stateful_tmp" && test -d "$stateful_tmp"; then
    find "$stateful_tmp" -depth -delete
  fi
  if test -n "$fake_bin" && test -d "$fake_bin"; then
    find "$fake_bin" -depth -delete
  fi
}
trap cleanup EXIT HUP INT TERM

test -f "$root/skills/update/SKILL.md"
test "$(sed -n '1p' "$root/skills/update/SKILL.md")" = '---'
grep -q '^name: update$' "$root/skills/update/SKILL.md"
grep -q '^require_command()' "$root/scripts/install-local"
grep -q 'dry-run && return 0' "$root/scripts/install-local"
for dry_run_doc in "$root/README.md" "$root/docs/INSTALLATION.md"; do
  tr '\n' ' ' <"$dry_run_doc" |
    grep -Fq 'no harness mutation or install commands and no plugin validation'
done

# These are deliberately literal shell snippets required in the instruction file.
# shellcheck disable=SC2016
assert_trusted_release_instructions() {
  skill=$1
  grep -Fq 'trusted_root=' "$skill" || return 1
  grep -Fq 'git -C "$candidate_repo" init' "$skill" || return 1
  grep -Fq 'refs/tags/${tag}:refs/tags/${tag}' "$skill" || return 1
  grep -Fq 'cd "$candidate_repo"' "$skill" || return 1
  grep -Fq 'sh "$trusted_root/scripts/release-checksum.sh" "refs/tags/$tag" "$candidate_repo/dist"' "$skill" || return 1
  grep -Fq 'sha256sum -c "$(basename "$checksum_file")"' "$skill" || return 1
  grep -Fq 'shasum -a 256 -c "$(basename "$checksum_file")"' "$skill" || return 1
  grep -Fq 'verified_repository_url=$repository_url' "$skill" || return 1
  grep -Fq 'verified_candidate_commit=$(git -C "$candidate_repo" rev-parse' "$skill" || return 1
  grep -Fq 'verified_candidate_archive_digest=$(awk' "$skill" || return 1
  if grep -Fq 'FLOW42_VERIFIED_SOURCE_ID' "$skill"; then
    echo 'update skill: candidate repository identity is caller-supplied' >&2
    return 1
  fi
  awk '
    function require_after_verification(token, position) {
      position = index(instructions, token)
      if (!position || position <= verification_complete) {
        failed = 1
      }
    }
    function reject_early_mutations(pattern, remaining, offset, position) {
      remaining = instructions
      offset = 0
      while (match(remaining, pattern)) {
        position = offset + RSTART
        if (position <= verification_complete) {
          failed = 1
        }
        offset += RSTART + RLENGTH - 1
        remaining = substr(remaining, RSTART + RLENGTH)
      }
    }
    { instructions = instructions " " $0 }
    END {
      gsub(/[[:space:]]+/, " ", instructions)
      resolved = index(instructions, "git ls-remote --tags --refs")
      verified = index(instructions, "sh \"$trusted_root/scripts/release-checksum.sh\"")
      sha256_checked = index(instructions, "sha256sum -c")
      shasum_checked = index(instructions, "shasum -a 256 -c")
      verification_complete = sha256_checked > shasum_checked ? sha256_checked : shasum_checked
      if (!resolved || !verified || !sha256_checked || !shasum_checked ||
          !(resolved < verified && verified < sha256_checked && verified < shasum_checked)) {
        exit 1
      }

      require_after_verification("claude plugin marketplace remove")
      require_after_verification("claude plugin marketplace add")
      require_after_verification("claude plugin install")
      require_after_verification("claude plugin update")
      require_after_verification("codex plugin marketplace remove")
      require_after_verification("codex plugin marketplace add")
      require_after_verification("codex plugin add")

      pi_section = index(instructions, "For Pi,")
      pi_install = index(instructions, "install `git:github.com/<owner>/<repo>@<tag>`")
      if (!pi_section || !pi_install || pi_section <= verification_complete || pi_install <= pi_section) {
        failed = 1
      }

      reject_early_mutations("(claude|codex) plugins? marketplace (add|remove|rm|update|upgrade)")
      reject_early_mutations("(claude|codex) plugins? (add|install|i|remove|rm|uninstall|update)")
      reject_early_mutations("pi (install|remove|rm|uninstall|update)")
      exit failed
    }
  ' "$skill" || return 1
  if grep -Eq 'published checksum|prints the (deterministic )?SHA-256|prints the digest' "$skill"; then
    echo 'update skill: claims an unavailable published checksum or digest output' >&2
    return 1
  fi
}

assert_trusted_release_instructions "$root/skills/update/SKILL.md"

# Claude exposes marketplace and plugin scopes through different state. The
# update and rollback instructions must preserve every plugin scope and the
# declaration's original source kind.
# shellcheck disable=SC2016
assert_claude_scope_instructions() {
  skill=$1
  grep -Fq '${marketplace_scope:?run the Claude preflight in this same shell first}' "$skill" || return 1
  grep -Fq '${plugin_scopes:?run the Claude preflight in this same shell first}' "$skill" || return 1
  grep -Fq '${recorded_marketplace_source:?run the Claude preflight in this same shell first}' "$skill" || return 1
  grep -Fq 'target_marketplace_source=${flow42_target_source_repo}@${flow42_target_source_ref}' "$skill" || return 1
  grep -Fq 'target_marketplace_source=${flow42_target_source_url}#${flow42_target_source_ref}' "$skill" || return 1
  grep -Fq 'claude plugin marketplace add "$target_marketplace_source" --scope "$marketplace_scope"' "$skill" || return 1
  grep -Fq 'claude plugin marketplace add "$recorded_marketplace_source" --scope "$marketplace_scope"' "$skill" || return 1
  grep -Fq 'recorded_marketplace_removed=false' "$skill" || return 1
  grep -Fq 'target_marketplace_added=false' "$skill" || return 1
  grep -Fq '${declaring_settings_file:?run the Claude preflight in this same shell first}' "$skill" || return 1
  grep -Fq 'if test "$target_marketplace_added" = true; then' "$skill" || return 1
  grep -Fq 'test "$recorded_marketplace_removed" = true; then' "$skill" || return 1
  test "$(grep -Fc 'claude plugin marketplace remove flow42 --scope "$marketplace_scope"' "$skill")" -ge 2 || return 1
  test "$(grep -Fc 'claude plugin install flow42@flow42 --scope "$plugin_scope" -y' "$skill")" -ge 2 || return 1
  test "$(grep -Fc 'claude plugin update flow42@flow42 --scope "$plugin_scope" -y' "$skill")" -ge 2 || return 1
  grep -Fq 'object to deep-equal the recorded source' "$skill" || return 1
  grep -Fq 'require every selected `version` to equal that target version' "$skill" || return 1
  grep -Fq 'A single marketplace pin cannot soundly restore' "$skill" || return 1
  if grep -Fq '<owner>/<repo>#<tag>' "$skill"; then
    echo 'update skill: Claude GitHub shorthand uses obsolete #ref syntax' >&2
    return 1
  fi
}

assert_claude_scope_instructions "$root/skills/update/SKILL.md"

assert_claude_declaration_safety() {
  skill=$1
  grep -Fq 'Require exactly one declaring scope;' "$skill" || return 1
  grep -Fq 'stop before mutation and report the exact declaring scopes' "$skill" || return 1
  grep -Fq 'from the settings source object, not' "$skill" || return 1
}

assert_claude_declaration_safety "$root/skills/update/SKILL.md"

for install_doc in "$root/README.md" "$root/docs/INSTALLATION.md"; do
  if grep -Fq 'marketplace add stefanriegel/flow42#' "$install_doc"; then
    echo "update docs: non-canonical Claude marketplace shorthand in $install_doc" >&2
    exit 1
  fi
done

assert_early_mutation_rejected() {
  mutation=$1
  description=$2
  mutated_skill=$(mktemp)
  awk -v mutation="$mutation" '
    /^trusted_root=/ && !inserted {
      print mutation
      inserted = 1
    }
    { print }
    END { exit !inserted }
  ' "$root/skills/update/SKILL.md" >"$mutated_skill"
  if assert_trusted_release_instructions "$mutated_skill" >/dev/null 2>&1; then
    rm -f "$mutated_skill"
    echo "update skill: early $description mutation was not rejected" >&2
    exit 1
  fi
  rm -f "$mutated_skill"
}

assert_reflowed_early_mutation_rejected() {
  mutation_first_line=$1
  mutation_second_line=$2
  description=$3
  mutated_skill=$(mktemp)
  awk -v first="$mutation_first_line" -v second="$mutation_second_line" '
    /^trusted_root=/ && !inserted {
      print first
      print second
      inserted = 1
    }
    { print }
    END { exit !inserted }
  ' "$root/skills/update/SKILL.md" >"$mutated_skill"
  if assert_trusted_release_instructions "$mutated_skill" >/dev/null 2>&1; then
    rm -f "$mutated_skill"
    echo "update skill: early $description mutation was not rejected" >&2
    exit 1
  fi
  rm -f "$mutated_skill"
}

# shellcheck disable=SC2016
assert_early_mutation_rejected \
  'Run `codex plugin marketplace add owner/repo --ref v9.9.9` before verification.' \
  'Codex marketplace pin'
# shellcheck disable=SC2016
assert_early_mutation_rejected \
  'Run `claude plugin marketplace rm flow42 --scope local` before verification.' \
  'Claude marketplace rm alias'
# shellcheck disable=SC2016
assert_reflowed_early_mutation_rejected \
  'Run `codex plugin' \
  '  marketplace add owner/repo --ref v9.9.9` before verification.' \
  'line-reflowed Codex marketplace pin'
# shellcheck disable=SC2016
assert_early_mutation_rejected \
  'Run `pi install git:github.com/owner/repo@v9.9.9` before verification.' \
  'Pi install'
# shellcheck disable=SC2016
assert_early_mutation_rejected \
  'Run `claude plugin update flow42@flow42 --scope local --yes` before verification.' \
  'Claude plugin update'

# Cover the remaining mutation commands and live aliases advertised by the
# current Claude, Codex, and Pi CLIs. The two reviewer regressions above stay as
# named fixtures because they exercise alias and whitespace handling directly.
while IFS='|' read -r mutation description; do
  assert_early_mutation_rejected "$mutation" "$description"
done <<'EOF'
Run `claude plugin marketplace add owner/repo@v9.9.9 --scope local` before verification.|Claude marketplace add
Run `claude plugin marketplace remove flow42 --scope local` before verification.|Claude marketplace remove
Run `claude plugin marketplace update flow42` before verification.|Claude marketplace update
Run `claude plugin install flow42@flow42 --scope local -y` before verification.|Claude plugin install
Run `claude plugin i flow42@flow42 --scope local -y` before verification.|Claude plugin install alias
Run `claude plugin uninstall flow42@flow42 --scope local -y` before verification.|Claude plugin uninstall
Run `claude plugin remove flow42@flow42 --scope local -y` before verification.|Claude plugin remove alias
Run `claude plugin rm flow42@flow42 --scope local -y` before verification.|Claude plugin rm alias
Run `codex plugin marketplace remove flow42` before verification.|Codex marketplace remove
Run `codex plugin marketplace upgrade flow42` before verification.|Codex marketplace upgrade
Run `codex plugin add flow42@flow42 --json` before verification.|Codex plugin add
Run `codex plugin remove flow42@flow42 --json` before verification.|Codex plugin remove
Run `pi remove git:github.com/owner/repo@v9.9.9` before verification.|Pi remove
Run `pi uninstall git:github.com/owner/repo@v9.9.9` before verification.|Pi uninstall alias
Run `pi update git:github.com/owner/repo@v9.9.9` before verification.|Pi update
EOF

if command -v zsh >/dev/null 2>&1; then
  zsh_fixture=$(mktemp -d)
  zsh_source=$zsh_fixture/source
  zsh_candidate=$zsh_fixture/candidate
  git init -q "$zsh_source"
  git -C "$zsh_source" config user.name 'Flow42 zsh fixture'
  git -C "$zsh_source" config user.email 'zsh-fixture@example.invalid'
  printf '%s\n' 'zsh refspec fixture' >"$zsh_source/fixture.txt"
  git -C "$zsh_source" add fixture.txt
  git -C "$zsh_source" commit -qm 'zsh refspec fixture'
  git -C "$zsh_source" tag v1.0.0
  mkdir "$zsh_candidate"
  zsh -c '
    set -eu
    repository_url=$1
    candidate_repo=$2
    tag=v1.0.0
    git -C "$candidate_repo" init -q
    git -C "$candidate_repo" fetch --no-tags "$repository_url" \
      "refs/tags/${tag}:refs/tags/${tag}"
    git -C "$candidate_repo" rev-parse --verify "refs/tags/${tag}"
  ' flow42-update-zsh "$zsh_source" "$zsh_candidate" >/dev/null
  rm -rf "$zsh_fixture"
else
  echo 'SKIP: zsh unavailable; documented fetch refspec regression not run' >&2
fi

mutated_skill=$(mktemp)
# shellcheck disable=SC2016
sed 's|\$trusted_root/scripts/release-checksum.sh|$candidate_repo/scripts/release-checksum.sh|' \
  "$root/skills/update/SKILL.md" >"$mutated_skill"
if assert_trusted_release_instructions "$mutated_skill" >/dev/null 2>&1; then
  echo 'update skill: clone-supplied verifier mutation was not rejected' >&2
  exit 1
fi
rm -f "$mutated_skill"

mutated_skill=$(mktemp)
cp "$root/skills/update/SKILL.md" "$mutated_skill"
printf '\nprints the digest for comparison with the published checksum\n' >>"$mutated_skill"
if assert_trusted_release_instructions "$mutated_skill" >/dev/null 2>&1; then
  echo 'update skill: invented published-checksum mutation was not rejected' >&2
  exit 1
fi
rm -f "$mutated_skill"

extract_claude_update_block() {
  skill=$1
  output=$2
  awk '
    /^# flow42-claude-update$/ { in_block = 1; next }
    in_block && /^```$/ { exit }
    in_block { print }
  ' "$skill" >"$output"
  test -s "$output"
}

extract_claude_preflight_block() {
  skill=$1
  output=$2
  awk '
    /^# flow42-claude-preflight$/ { in_block = 1; next }
    in_block && /^```$/ { exit }
    in_block { print }
  ' "$skill" >"$output"
  test -s "$output"
}

extract_claude_composed_flow() {
  skill=$1
  composed_output=$2
  verified_repository_mode=${3:-match}
  preflight=$composed_output.preflight
  transaction=$composed_output.transaction
  extract_claude_preflight_block "$skill" "$preflight"
  extract_claude_update_block "$skill" "$transaction"
  awk '{ print }' "$preflight" >"$composed_output"
  # shellcheck disable=SC2016
  printf '%s\n' \
    'if test -n "${FLOW42_CANDIDATE_DISCOVERY_MARKER:-}"; then touch "$FLOW42_CANDIDATE_DISCOVERY_MARKER"; fi' \
    >>"$composed_output"
  if test "$verified_repository_mode" = mismatch; then
    printf '%s\n' 'verified_repository_url=https://mismatch.invalid/flow42.git' \
      >>"$composed_output"
  else
    # shellcheck disable=SC2016
    printf '%s\n' 'verified_repository_url=$repository_url' >>"$composed_output"
  fi
  printf '%s\n' \
    'verified_tag=v1.0.2' \
    'verified_candidate_plugin_version=1.0.2' \
    'verified_candidate_commit=2222222222222222222222222222222222222222' \
    'verified_candidate_archive_digest=bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' \
    >>"$composed_output"
  if test "$verified_repository_mode" = postcondition-failure; then
    printf '%s\n' \
      "FAKE_FAIL_COMMAND='plugin list --json'" \
      'export FAKE_FAIL_COMMAND' \
      >>"$composed_output"
  fi
  awk '{ print }' "$transaction" >>"$composed_output"
}

run_stateful_update_scenario() {
  scenario=$1
  skill=$2
  declarations=$3
  installs=$4
  plugin_scopes=$5
  preserve_installs=${6:-false}
  expected_target_source_json=${7:-}
  scenario_root=$stateful_tmp/composed-updates/$scenario
  config_root=$scenario_root/config
  project_root=$scenario_root/project
  state=$scenario_root/state.json
  settings_file=$config_root/settings.json
  instructions=$scenario_root/composed.sh
  mkdir -p "$config_root" "$project_root/.claude"

  jq -n --argjson declarations "$declarations" --argjson installs "$installs" '
    {
      declarations: $declarations,
      installs: $installs,
      available: "1.0.1"
    }
  ' >"$state"
  extract_claude_composed_flow "$skill" "$instructions"
  recorded_source_json=$(printf '%s\n' "$declarations" | jq -c '.user')
  jq -n --argjson source "$recorded_source_json" '{
    extraKnownMarketplaces: {flow42: {source:$source}}
  }' >"$settings_file"
  update_output=$(FAKE_PRESERVE_INSTALLS_ON_REMOVE=$preserve_installs \
    CLAUDE_CONFIG_DIR=$config_root FLOW42_PROJECT_ROOT=$project_root \
    FAKE_SETTINGS_FILE=$settings_file \
    FAKE_STATE=$state \
    PATH="$stateful_bin:$PATH" \
    sh -e "$instructions")
  printf '%s\n' "$update_output" | grep -Fq \
    'candidate commit 2222222222222222222222222222222222222222; candidate archive digest bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  printf '%s\n' "$update_output" | grep -Fq \
    'do not claim those installed-artifact bindings'
  plugin_listing=$(FAKE_STATE=$state PATH="$stateful_bin:$PATH" \
    claude plugin list --json)
  # shellcheck disable=SC2086
  for expected_scope in $plugin_scopes; do
    actual_version=$(printf '%s\n' "$plugin_listing" | jq -r \
      --arg scope "$expected_scope" '
        [.[] | select(.id == "flow42@flow42" and .scope == $scope)] |
        if length == 1 then .[0].version else "absent-or-ambiguous" end
      ')
    if test "$actual_version" != 1.0.2; then
      echo "stateful update: $scenario scope $expected_scope ended at $actual_version; install returned rc=0 without convergence" >&2
      return 1
    fi
  done
  if test -z "$expected_target_source_json"; then
    expected_target_source_json=$(printf '%s\n' "$recorded_source_json" | jq -c '
      if .source == "github" then .ref = "v1.0.2"
      elif .source == "git" then .ref = "v1.0.2"
      else . end
    ')
  fi
  actual_target_source_json=$(jq -c \
    '.extraKnownMarketplaces.flow42.source // empty' "$settings_file")
  if ! jq -en --argjson actual "$actual_target_source_json" \
    --argjson expected "$expected_target_source_json" \
    '$actual == $expected' >/dev/null; then
    echo "stateful update: $scenario changed marketplace source kind or repository" >&2
    return 1
  fi
}

run_composed_candidate_mismatch_scenario() {
  scenario_root=$stateful_tmp/composed-mismatch
  config_root=$scenario_root/config
  project_root=$scenario_root/project
  state=$scenario_root/state.json
  settings_file=$config_root/settings.json
  instructions=$scenario_root/composed.sh
  command_log=$scenario_root/commands.log
  error_log=$scenario_root/stderr.log
  mkdir -p "$config_root" "$project_root/.claude"
  jq -n '{
    declarations: {user:{source:"github", repo:"owner/flow42", ref:"v1.0.1"}},
    installs: {local:"1.0.1"},
    available: "1.0.1"
  }' >"$state"
  jq -n '{
    extraKnownMarketplaces: {
      flow42: {source:{source:"github", repo:"owner/flow42", ref:"v1.0.1"}}
    }
  }' >"$settings_file"
  expected_projection=$(jq -S '{declarations, installs, available}' "$state")
  expected_settings=$(jq -S . "$settings_file")
  extract_claude_composed_flow "$root/skills/update/SKILL.md" \
    "$instructions" mismatch

  if CLAUDE_CONFIG_DIR=$config_root FLOW42_PROJECT_ROOT=$project_root \
    FAKE_SETTINGS_FILE=$settings_file FAKE_COMMAND_LOG=$command_log \
    FAKE_STATE=$state PATH="$stateful_bin:$PATH" \
    sh -e "$instructions" >/dev/null 2>"$error_log"; then
    echo 'composed update: mismatched verified candidate repository was accepted' >&2
    return 1
  fi
  grep -Fq 'verified candidate repository URL differs from the recorded source URL' \
    "$error_log" || return 1
  if grep -Eq '^plugin marketplace (remove|add)|^plugin (install|update) flow42@flow42 ' \
    "$command_log"; then
    echo 'composed update: repository mismatch reached a mutation command' >&2
    return 1
  fi
  test "$(jq -S '{declarations, installs, available}' "$state")" = \
    "$expected_projection" || return 1
  test "$(jq -S . "$settings_file")" = "$expected_settings" || return 1
}

run_composed_directory_stop_scenario() {
  scenario_root=$stateful_tmp/composed-directory-stop
  config_root=$scenario_root/config
  project_root=$scenario_root/project
  state=$scenario_root/state.json
  settings_file=$project_root/.claude/settings.local.json
  instructions=$scenario_root/composed.sh
  command_log=$scenario_root/commands.log
  discovery_marker=$scenario_root/candidate-discovery-started
  error_log=$scenario_root/stderr.log
  mkdir -p "$config_root" "$project_root/.claude"
  jq -n '{
    declarations: {local:{source:"directory", path:"/opt/flow42-source"}},
    installs: {local:"1.0.1"},
    available: "1.0.1"
  }' >"$state"
  jq -n '{
    extraKnownMarketplaces: {
      flow42: {source:{source:"directory", path:"/opt/flow42-source"}}
    }
  }' >"$settings_file"
  expected_projection=$(jq -S '{declarations, installs, available}' "$state")
  expected_settings=$(jq -S . "$settings_file")
  extract_claude_composed_flow "$root/skills/update/SKILL.md" "$instructions"

  if CLAUDE_CONFIG_DIR=$config_root FLOW42_PROJECT_ROOT=$project_root \
    FLOW42_CANDIDATE_DISCOVERY_MARKER=$discovery_marker \
    FAKE_SETTINGS_FILE=$settings_file FAKE_COMMAND_LOG=$command_log \
    FAKE_STATE=$state PATH="$stateful_bin:$PATH" \
    sh -e "$instructions" >/dev/null 2>"$error_log"; then
    echo 'composed update: directory source did not stop before candidate discovery' >&2
    return 1
  fi
  grep -Fq '/opt/flow42-source/scripts/install-local' "$error_log" || return 1
  if test -e "$discovery_marker"; then
    echo 'composed update: directory source reached candidate discovery' >&2
    return 1
  fi
  if grep -Eq '^plugin marketplace (remove|add)|^plugin (install|update) flow42@flow42 ' \
    "$command_log"; then
    echo 'composed update: directory source reached a marketplace mutation' >&2
    return 1
  fi
  test "$(jq -S '{declarations, installs, available}' "$state")" = \
    "$expected_projection" || return 1
  test "$(jq -S . "$settings_file")" = "$expected_settings" || return 1
}

run_composed_postcondition_failure_scenario() {
  scenario_root=$stateful_tmp/composed-postcondition-failure
  config_root=$scenario_root/config
  project_root=$scenario_root/project
  state=$scenario_root/state.json
  settings_file=$config_root/settings.json
  instructions=$scenario_root/composed.sh
  fail_marker=$scenario_root/failed
  mkdir -p "$config_root" "$project_root/.claude"
  source_json='{"source":"github","repo":"owner/flow42","ref":"v1.0.1"}'
  jq -n --argjson source "$source_json" '{
    declarations: {user:$source},
    installs: {user:"1.0.1", local:"1.0.1"},
    available: "1.0.1"
  }' >"$state"
  jq -n --argjson source "$source_json" '{
    extraKnownMarketplaces: {flow42: {source:$source}}
  }' >"$settings_file"
  expected_projection=$(jq -S '{declarations, installs, available}' "$state")
  extract_claude_composed_flow "$root/skills/update/SKILL.md" \
    "$instructions" postcondition-failure

  if CLAUDE_CONFIG_DIR=$config_root FLOW42_PROJECT_ROOT=$project_root \
    FAKE_FAIL_MARKER=$fail_marker FAKE_SETTINGS_FILE=$settings_file \
    FAKE_STATE=$state PATH="$stateful_bin:$PATH" \
    sh -e "$instructions" >/dev/null 2>&1; then
    echo 'composed update: post-condition readback failure was accepted' >&2
    return 1
  fi
  test -f "$fail_marker" || return 1
  assert_stateful_restoration composed-postcondition-failure "$state" \
    "$expected_projection" "$source_json" 'user local' "$settings_file"
}

assert_stateful_restoration() {
  scenario=$1
  state=$2
  expected_projection=$3
  expected_source_json=$4
  plugin_scopes=$5
  settings_file=$6

  actual_projection=$(jq -S '{declarations, installs, available}' "$state")
  if test "$actual_projection" != "$expected_projection"; then
    echo "stateful rollback: $scenario did not restore declarations, installs, and available version exactly" >&2
    return 1
  fi
  marketplace_listing=$(FAKE_STATE=$state PATH="$stateful_bin:$PATH" \
    claude plugin marketplace list --json)
  actual_source_json=$(printf '%s\n' "$marketplace_listing" | jq -c '
    [.[] | select(.name == "flow42")] |
    if length == 1 then .[0] | del(.name) else error("ambiguous readback") end
  ')
  if ! jq -en --argjson actual "$actual_source_json" \
    --argjson expected "$expected_source_json" '$actual == $expected' >/dev/null; then
    echo "stateful rollback: $scenario source-kind readback differed from the recorded object" >&2
    return 1
  fi
  settings_source_json=$(jq -c \
    '.extraKnownMarketplaces.flow42.source // empty' "$settings_file")
  if ! jq -en --argjson actual "$settings_source_json" \
    --argjson expected "$expected_source_json" '$actual == $expected' >/dev/null; then
    echo "stateful rollback: $scenario settings declaration differed from the recorded source object" >&2
    return 1
  fi
  plugin_listing=$(FAKE_STATE=$state PATH="$stateful_bin:$PATH" \
    claude plugin list --json)
  # shellcheck disable=SC2086
  for expected_scope in $plugin_scopes; do
    actual_version=$(printf '%s\n' "$plugin_listing" | jq -r \
      --arg scope "$expected_scope" '
        [.[] | select(.id == "flow42@flow42" and .scope == $scope)] |
        if length == 1 then .[0].version else "absent-or-ambiguous" end
      ')
    if test "$actual_version" != 1.0.1; then
      echo "stateful rollback: $scenario scope $expected_scope restored $actual_version instead of 1.0.1" >&2
      return 1
    fi
  done
}

run_stateful_mutation_failures() {
  source_kind=$1
  source_json=$2
  directory_version=$3
  failure_phase=${4:-before}
  skill=${5:-$root/skills/update/SKILL.md}
  plugin_scopes='user local'
  update_instructions=$stateful_tmp/$source_kind-$failure_phase.composed.sh

  extract_claude_composed_flow "$skill" "$update_instructions"

  recorded_source_kind=$(printf '%s\n' "$source_json" | jq -r '.source')
  case "$recorded_source_kind" in
    github)
      target_source_id=$(printf '%s\n' "$source_json" | jq -r '.repo')
      target_add_source=${target_source_id}@v1.0.2
      ;;
    git)
      target_source_id=$(printf '%s\n' "$source_json" | jq -r '.url')
      target_add_source=${target_source_id}#v1.0.2
      ;;
  esac
  for failed_command in \
    'plugin marketplace remove flow42 --scope user' \
    "plugin marketplace add $target_add_source --scope user" \
    'plugin install flow42@flow42 --scope user -y' \
    'plugin update flow42@flow42 --scope user -y' \
    'plugin install flow42@flow42 --scope local -y' \
    'plugin update flow42@flow42 --scope local -y'; do
    scenario=$source_kind-$failure_phase-$(printf '%s\n' "$failed_command" | tr ' /@' '---')
    scenario_root=$stateful_tmp/composed-failures/$scenario
    config_root=$scenario_root/config
    project_root=$scenario_root/project
    state=$scenario_root/state.json
    settings_file=$config_root/settings.json
    fail_marker=$scenario_root/failed
    command_log=$scenario_root/commands.log
    mkdir -p "$config_root" "$project_root/.claude"
    jq -n --argjson source "$source_json" '{
      declarations: {user:$source},
      installs: {user:"1.0.1", local:"1.0.1"},
      available: "1.0.1"
    }' >"$state"
    jq -n --argjson source "$source_json" '{
      extraKnownMarketplaces: {flow42: {source:$source}}
    }' >"$settings_file"
    expected_projection=$(jq -S '{declarations, installs, available}' "$state")

    if FAKE_FAIL_COMMAND=$failed_command FAKE_FAIL_MARKER=$fail_marker \
      FAKE_FAIL_PHASE=$failure_phase \
      FAKE_DIRECTORY_VERSION=$directory_version \
      CLAUDE_CONFIG_DIR=$config_root FLOW42_PROJECT_ROOT=$project_root \
      FAKE_SETTINGS_FILE=$settings_file \
      FAKE_COMMAND_LOG=$command_log FAKE_STATE=$state \
      PATH="$stateful_bin:$PATH" sh -e "$update_instructions" \
      >/dev/null 2>&1; then
      echo "stateful rollback: $scenario did not observe its forced mutation failure" >&2
      return 1
    fi
    if test ! -f "$fail_marker"; then
      echo "stateful rollback: $scenario never reached its forced mutation step" >&2
      return 1
    fi
    if test "$failed_command" = 'plugin marketplace remove flow42 --scope user' && \
       test "$failure_phase" = before && \
       grep -Eq '^plugin (install|update) flow42@flow42 ' "$command_log"; then
      echo "stateful rollback: $scenario mutated plugins after a pre-effect first-remove failure" >&2
      return 1
    fi

    assert_stateful_restoration "$scenario" "$state" "$expected_projection" \
      "$source_json" "$plugin_scopes" "$settings_file"
  done
}

render_claude_preflight() {
  source_block=$1
  rendered_block=$2
  sed -n 'p' "$source_block" >"$rendered_block"
  # shellcheck disable=SC2016
  printf '%s\n' \
    'printf '\''%s\t%s\t%s\t%s\n'\'' "$marketplace_scope" "$recorded_source_kind" "$recorded_marketplace_source" "$recorded_plugin_version" >"$FLOW42_PREFLIGHT_RESULT"' \
    >>"$rendered_block"
}

run_stateful_preflight_scenario() {
  scenario=$1
  expected_result=$2
  declarations=$3
  installs=$4
  expected_record=$(printf '%b' "${5:-}")
  fail_update_help=${6:-false}
  skill=${7:-$root/skills/update/SKILL.md}
  expected_error=${8:-}
  scenario_root=$stateful_tmp/preflight\ scenarios/$scenario
  config_root=$scenario_root/config
  project_root=$scenario_root/project
  state=$scenario_root/state.json
  extracted=$scenario_root/preflight.extracted.sh
  instructions=$scenario_root/preflight.sh
  result=$scenario_root/result.tsv
  error_log=$scenario_root/stderr.log
  mkdir -p "$config_root" "$project_root/.claude"

  jq -n --argjson declarations "$declarations" --argjson installs "$installs" '{
    declarations: $declarations,
    installs: $installs,
    available: "1.0.1"
  }' >"$state"
  for declaration_scope in user project local; do
    if ! printf '%s\n' "$declarations" | jq -e \
      --arg scope "$declaration_scope" '.[$scope] != null' >/dev/null; then
      continue
    fi
    case "$declaration_scope" in
      user) settings_file=$config_root/settings.json ;;
      project) settings_file=$project_root/.claude/settings.json ;;
      local) settings_file=$project_root/.claude/settings.local.json ;;
    esac
    printf '%s\n' "$declarations" | jq --arg scope "$declaration_scope" '{
      extraKnownMarketplaces: {flow42: {source: .[$scope]}}
    }' >"$settings_file"
  done
  expected_projection=$(jq -S '{declarations, installs, available}' "$state")
  extract_claude_preflight_block "$skill" "$extracted"
  render_claude_preflight "$extracted" "$instructions"

  if CLAUDE_CONFIG_DIR=$config_root FLOW42_PROJECT_ROOT=$project_root \
    FLOW42_PREFLIGHT_RESULT=$result \
    FAKE_FAIL_UPDATE_HELP=$fail_update_help FAKE_STATE=$state \
    PATH="$stateful_bin:$PATH" sh -e "$instructions" \
    >/dev/null 2>"$error_log"; then
    actual_result=pass
  else
    actual_result=fail
  fi
  if test "$actual_result" != "$expected_result"; then
    echo "stateful preflight: $scenario returned $actual_result instead of $expected_result" >&2
    return 1
  fi
  actual_projection=$(jq -S '{declarations, installs, available}' "$state")
  if test "$actual_projection" != "$expected_projection"; then
    echo "stateful preflight: $scenario mutated harness state" >&2
    return 1
  fi
  if test "$expected_result" = pass; then
    if test ! -f "$result" || test "$(cat "$result")" != "$expected_record"; then
      echo "stateful preflight: $scenario did not preserve its scope, source kind, add argument, and version" >&2
      return 1
    fi
  elif test -e "$result"; then
    echo "stateful preflight: $scenario continued after a fail-closed check" >&2
    return 1
  fi
  if test -n "$expected_error" && ! grep -Fq "$expected_error" "$error_log"; then
    echo "stateful preflight: $scenario did not report '$expected_error'" >&2
    return 1
  fi
}

stateful_tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-update-stateful.XXXXXX")
stateful_bin=$stateful_tmp/bin
mkdir "$stateful_bin"
cp "$root/tests/fixtures/update/fake-claude" "$stateful_bin/claude"
chmod +x "$stateful_bin/claude"

run_stateful_preflight_scenario unique-github pass \
  '{"user":{"source":"github","repo":"owner/flow42","ref":"v1.0.1"}}' \
  '{"user":"1.0.1","local":"1.0.1"}' \
  'user	github	owner/flow42@v1.0.1	1.0.1'
run_stateful_preflight_scenario unique-git pass \
  '{"project":{"source":"git","url":"https://example.invalid/flow42.git","ref":"v1.0.1"}}' \
  '{"local":"1.0.1"}' \
  'project	git	https://example.invalid/flow42.git#v1.0.1	1.0.1'
run_stateful_preflight_scenario directory-routes-local-installer fail \
  '{"local":{"source":"directory","path":"/opt/flow42-source"}}' \
  '{"local":"1.0.1"}' '' false '' 'scripts/install-local'
run_stateful_preflight_scenario zero-declarations fail '{}' \
  '{"local":"1.0.1"}' '' false '' 'found: <none>'
run_stateful_preflight_scenario multiple-declarations fail \
  '{"user":{"source":"github","repo":"owner/flow42","ref":"v1.0.1"},"project":{"source":"github","repo":"owner/flow42","ref":"v1.0.1"}}' \
  '{"local":"1.0.1"}' '' false '' 'found: user project'
run_stateful_preflight_scenario heterogeneous-versions fail \
  '{"user":{"source":"github","repo":"owner/flow42","ref":"v1.0.1"}}' \
  '{"user":"1.0.1","local":"0.9.9"}' '' false '' \
  'user=1.0.1, local=0.9.9'
run_stateful_preflight_scenario capability-unavailable fail \
  '{"user":{"source":"github","repo":"owner/flow42","ref":"v1.0.1"}}' \
  '{"local":"1.0.1"}' '' true '' 'does not expose plugin update'

mutated_skill=$stateful_tmp/drop-update-capability-gate.md
sed -f "$root/tests/fixtures/update/drop-update-capability-gate.sed" \
  "$root/skills/update/SKILL.md" >"$mutated_skill"
if cmp -s "$root/skills/update/SKILL.md" "$mutated_skill"; then
  echo 'update mutation: drop-update-capability-gate fixture made no change' >&2
  exit 1
fi
if run_stateful_preflight_scenario mutation-capability-unavailable fail \
  '{"user":{"source":"github","repo":"owner/flow42","ref":"v1.0.1"}}' \
  '{"local":"1.0.1"}' '' true "$mutated_skill" >/dev/null 2>&1; then
  echo 'update mutation: removing the plugin update capability gate was not detected' >&2
  exit 1
fi

mutated_skill=$stateful_tmp/allow-multiple-declarations.md
sed -f "$root/tests/fixtures/update/allow-multiple-declarations.sed" \
  "$root/skills/update/SKILL.md" >"$mutated_skill"
if cmp -s "$root/skills/update/SKILL.md" "$mutated_skill"; then
  echo 'update mutation: allow-multiple-declarations fixture made no change' >&2
  exit 1
fi
if run_stateful_preflight_scenario mutation-multiple-declarations fail \
  '{"user":{"source":"github","repo":"owner/flow42","ref":"v1.0.1"},"project":{"source":"github","repo":"owner/flow42","ref":"v1.0.1"}}' \
  '{"local":"1.0.1"}' '' false "$mutated_skill" >/dev/null 2>&1; then
  echo 'update mutation: allowing multiple declarations was not detected' >&2
  exit 1
fi

mutated_skill=$stateful_tmp/infer-missing-declaration.md
sed -f "$root/tests/fixtures/update/infer-missing-declaration.sed" \
  "$root/skills/update/SKILL.md" >"$mutated_skill"
if cmp -s "$root/skills/update/SKILL.md" "$mutated_skill"; then
  echo 'update mutation: infer-missing-declaration fixture made no change' >&2
  exit 1
fi
if run_stateful_preflight_scenario mutation-zero-declarations fail '{}' \
  '{"local":"1.0.1"}' '' false "$mutated_skill" >/dev/null 2>&1; then
  echo 'update mutation: inferring a missing declaration was not detected' >&2
  exit 1
fi

run_stateful_update_scenario plugin-removed "$root/skills/update/SKILL.md" \
  '{"user":{"source":"github","repo":"owner/flow42","ref":"v1.0.1"}}' \
  '{"local":"1.0.1"}' 'local'
run_stateful_update_scenario plugin-preserved "$root/skills/update/SKILL.md" \
  '{"user":{"source":"github","repo":"owner/flow42","ref":"v1.0.1"}}' \
  '{"local":"1.0.1"}' 'local' true
run_stateful_update_scenario multi-install-scope "$root/skills/update/SKILL.md" \
  '{"user":{"source":"github","repo":"owner/flow42","ref":"v1.0.1"}}' \
  '{"user":"1.0.1","local":"1.0.1"}' 'user local'
run_stateful_update_scenario git-source-convergence "$root/skills/update/SKILL.md" \
  '{"user":{"source":"git","url":"https://example.invalid/flow42.git","ref":"v1.0.1"}}' \
  '{"local":"1.0.1"}' 'local' false \
  '{"source":"git","url":"https://example.invalid/flow42.git","ref":"v1.0.2"}'
run_stateful_update_scenario git-ssh-source-convergence "$root/skills/update/SKILL.md" \
  '{"user":{"source":"git","url":"git@example.invalid:flow42.git","ref":"v1.0.1"}}' \
  '{"local":"1.0.1"}' 'local' false \
  '{"source":"git","url":"git@example.invalid:flow42.git","ref":"v1.0.2"}'
run_composed_candidate_mismatch_scenario
run_composed_directory_stop_scenario
run_composed_postcondition_failure_scenario
run_stateful_mutation_failures github \
  '{"source":"github","repo":"owner/flow42","ref":"v1.0.1"}' \
  ''
run_stateful_mutation_failures git \
  '{"source":"git","url":"https://example.invalid/flow42.git","ref":"v1.0.1"}' \
  ''
run_stateful_mutation_failures github-mirror \
  '{"source":"github","repo":"mirror/flow42","ref":"v1.0.1"}' \
  ''
run_stateful_mutation_failures github \
  '{"source":"github","repo":"owner/flow42","ref":"v1.0.1"}' \
  '' after
run_stateful_mutation_failures git \
  '{"source":"git","url":"https://example.invalid/flow42.git","ref":"v1.0.1"}' \
  '' after
run_stateful_mutation_failures github-mirror \
  '{"source":"github","repo":"mirror/flow42","ref":"v1.0.1"}' \
  '' after

mutated_skill=$stateful_tmp/drop-update-step.md
sed -f "$root/tests/fixtures/update/drop-update-step.sed" \
  "$root/skills/update/SKILL.md" >"$mutated_skill"
if cmp -s "$root/skills/update/SKILL.md" "$mutated_skill"; then
  echo 'update mutation: drop-update-step fixture made no change' >&2
  exit 1
fi
if run_stateful_update_scenario mutation-drop-update "$mutated_skill" \
  '{"user":{"source":"github","repo":"owner/flow42","ref":"v1.0.1"}}' \
  '{"local":"1.0.1"}' 'local' true >/dev/null 2>&1; then
  echo 'update mutation: drop-update-step did not break plugin-preserved convergence' >&2
  exit 1
fi

mutated_skill=$stateful_tmp/single-scope-discovery.md
sed -f "$root/tests/fixtures/update/single-scope-discovery.sed" \
  "$root/skills/update/SKILL.md" >"$mutated_skill"
if cmp -s "$root/skills/update/SKILL.md" "$mutated_skill"; then
  echo 'update mutation: single-scope-discovery fixture made no change' >&2
  exit 1
fi
if assert_claude_declaration_safety "$mutated_skill" >/dev/null 2>&1; then
  echo 'update mutation: single-scope-discovery did not break the ambiguity stop rule' >&2
  exit 1
fi

mutated_skill=$stateful_tmp/listing-derived-rollback.md
sed -f "$root/tests/fixtures/update/listing-derived-rollback.sed" \
  "$root/skills/update/SKILL.md" >"$mutated_skill"
if cmp -s "$root/skills/update/SKILL.md" "$mutated_skill"; then
  echo 'update mutation: listing-derived-rollback fixture made no change' >&2
  exit 1
fi
if run_stateful_mutation_failures mutation-listing-rollback \
  '{"source":"github","repo":"owner/flow42","ref":"v1.0.1"}' \
  '' before "$mutated_skill" >/dev/null 2>&1; then
  echo 'update mutation: listing-derived-rollback did not break exact rollback' >&2
  exit 1
fi
find "$stateful_tmp" -depth -delete
stateful_tmp=

fake_bin=$(mktemp -d)
fake_log=$fake_bin/claude.log
cat > "$fake_bin/claude" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "$FAKE_CLAUDE_LOG"
case "$*" in
  'plugin marketplace list --json') printf '%s\n' "$FAKE_MARKETPLACE_JSON" ;;
esac
EOF
chmod +x "$fake_bin/claude"

# Exercise the literal mixed-scope update and rollback sequences against the
# fake harness. A user marketplace and local plugin must remain independently
# scoped in every mutating command.
: > "$fake_log"
marketplace_scope=user
plugin_scope=local
recorded_marketplace_source=owner/flow42@v1.2.3
target_marketplace_source=owner/flow42@v1.2.4
FAKE_CLAUDE_LOG=$fake_log PATH="$fake_bin:$PATH" \
  claude plugin marketplace remove flow42 --scope "$marketplace_scope"
FAKE_CLAUDE_LOG=$fake_log PATH="$fake_bin:$PATH" \
  claude plugin marketplace add "$target_marketplace_source" --scope "$marketplace_scope"
FAKE_CLAUDE_LOG=$fake_log PATH="$fake_bin:$PATH" \
  claude plugin install flow42@flow42 --scope "$plugin_scope" -y
FAKE_CLAUDE_LOG=$fake_log PATH="$fake_bin:$PATH" \
  claude plugin update flow42@flow42 --scope "$plugin_scope" -y
FAKE_CLAUDE_LOG=$fake_log PATH="$fake_bin:$PATH" \
  claude plugin marketplace remove flow42 --scope "$marketplace_scope"
FAKE_CLAUDE_LOG=$fake_log PATH="$fake_bin:$PATH" \
  claude plugin marketplace add "$recorded_marketplace_source" --scope "$marketplace_scope"
FAKE_CLAUDE_LOG=$fake_log PATH="$fake_bin:$PATH" \
  claude plugin install flow42@flow42 --scope "$plugin_scope" -y
FAKE_CLAUDE_LOG=$fake_log PATH="$fake_bin:$PATH" \
  claude plugin update flow42@flow42 --scope "$plugin_scope" -y
mixed_scope_calls=$(cat "$fake_log")
expected_mixed_scope_calls='plugin marketplace remove flow42 --scope user
plugin marketplace add owner/flow42@v1.2.4 --scope user
plugin install flow42@flow42 --scope local -y
plugin update flow42@flow42 --scope local -y
plugin marketplace remove flow42 --scope user
plugin marketplace add owner/flow42@v1.2.3 --scope user
plugin install flow42@flow42 --scope local -y
plugin update flow42@flow42 --scope local -y'
if test "$mixed_scope_calls" != "$expected_mixed_scope_calls"; then
  echo 'update skill: mixed Claude marketplace and plugin scopes collapsed during update or rollback' >&2
  exit 1
fi

: > "$fake_log"
registered_dry_run=$(FAKE_CLAUDE_LOG=$fake_log \
  FAKE_MARKETPLACE_JSON="[{\"name\":\"flow42\",\"source\":\"directory\",\"path\":\"$root\"}]" \
  PATH="$fake_bin:$PATH" FLOW42_SKIP_PREFLIGHT=1 \
  sh "$root/scripts/install-local" claude --dry-run)
printf '%s\n' "$registered_dry_run" |
  grep -F -q 'DRY-RUN [claude] [plugin] [marketplace] [update] [flow42]'
printf '%s\n' "$registered_dry_run" |
  grep -F -q 'DRY-RUN [claude] [plugin] [update] [flow42@flow42] [--scope] [local] [--yes]'
if test "$(cat "$fake_log")" != 'plugin marketplace list --json'; then
  echo 'install-local: registered dry-run did not discover marketplace state exactly once' >&2
  exit 1
fi

: > "$fake_log"
FAKE_CLAUDE_LOG=$fake_log \
FAKE_MARKETPLACE_JSON='[{"name":"flow42","source":"github","repo":"someone/flow42"}]' \
PATH="$fake_bin:$PATH" FLOW42_SKIP_PREFLIGHT=1 \
  sh "$root/scripts/install-local" claude >/dev/null
wrong_source_calls=$(cat "$fake_log")
expected_wrong_source_calls="plugin validate --strict $root
plugin marketplace list --json
plugin marketplace add $root --scope local
plugin install flow42@flow42 --scope local --yes"
if test "$wrong_source_calls" != "$expected_wrong_source_calls"; then
  echo 'install-local: a same-name marketplace from another source was treated as local' >&2
  exit 1
fi

: > "$fake_log"
FAKE_CLAUDE_LOG=$fake_log \
FAKE_MARKETPLACE_JSON="[{\"name\":\"flow42\",\"source\":\"directory\",\"path\":\"$root\",\"installLocation\":\"$root\"}]" \
PATH="$fake_bin:$PATH" FLOW42_SKIP_PREFLIGHT=1 \
  sh "$root/scripts/install-local" claude >/dev/null
matching_source_calls=$(cat "$fake_log")
expected_matching_source_calls="plugin validate --strict $root
plugin marketplace list --json
plugin marketplace update flow42
plugin update flow42@flow42 --scope local --yes"
if test "$matching_source_calls" != "$expected_matching_source_calls"; then
  echo 'install-local: the matching local marketplace did not use the update path' >&2
  exit 1
fi

repo_link=$fake_bin/flow42-link
ln -s "$root" "$repo_link"
: > "$fake_log"
FAKE_CLAUDE_LOG=$fake_log \
FAKE_MARKETPLACE_JSON="[{\"name\":\"flow42\",\"source\":\"directory\",\"path\":\"$root\"}]" \
PATH="$fake_bin:$PATH" FLOW42_SKIP_PREFLIGHT=1 \
  sh "$repo_link/scripts/install-local" claude >/dev/null
symlink_source_calls=$(cat "$fake_log")
expected_symlink_source_calls="plugin validate --strict $root
plugin marketplace list --json
plugin marketplace update flow42
plugin update flow42@flow42 --scope local --yes"
if test "$symlink_source_calls" != "$expected_symlink_source_calls"; then
  echo 'install-local: a symlink-equivalent local marketplace did not use the update path' >&2
  exit 1
fi

other_source=$fake_bin/other-flow42
mkdir "$other_source"
: > "$fake_log"
FAKE_CLAUDE_LOG=$fake_log \
FAKE_MARKETPLACE_JSON="[{\"name\":\"flow42\",\"source\":\"directory\",\"path\":\"$other_source\"}]" \
PATH="$fake_bin:$PATH" FLOW42_SKIP_PREFLIGHT=1 \
  sh "$root/scripts/install-local" claude >/dev/null
different_source_calls=$(cat "$fake_log")
expected_different_source_calls="plugin validate --strict $root
plugin marketplace list --json
plugin marketplace add $root --scope local
plugin install flow42@flow42 --scope local --yes"
if test "$different_source_calls" != "$expected_different_source_calls"; then
  echo 'install-local: a different local marketplace did not use the add/install path' >&2
  exit 1
fi

: > "$fake_log"
FAKE_CLAUDE_LOG=$fake_log FAKE_MARKETPLACE_JSON='[]' \
PATH="$fake_bin:$PATH" FLOW42_SKIP_PREFLIGHT=1 \
  sh "$root/scripts/install-local" claude >/dev/null
absent_source_calls=$(cat "$fake_log")
if test "$absent_source_calls" != "$expected_different_source_calls"; then
  echo 'install-local: an absent flow42 marketplace did not use the add/install path' >&2
  exit 1
fi

: > "$fake_log"
if FAKE_CLAUDE_LOG=$fake_log FAKE_MARKETPLACE_JSON='not-json' \
  PATH="$fake_bin:$PATH" FLOW42_SKIP_PREFLIGHT=1 \
  sh "$root/scripts/install-local" claude >/dev/null 2>&1; then
  echo 'install-local: malformed marketplace JSON did not fail closed' >&2
  exit 1
fi
malformed_calls=$(cat "$fake_log")
expected_malformed_calls="plugin validate --strict $root
plugin marketplace list --json"
if test "$malformed_calls" != "$expected_malformed_calls"; then
  echo 'install-local: malformed marketplace JSON triggered a mutation command' >&2
  exit 1
fi

# The Claude update path must account for `marketplace remove` uninstalling the
# plugin: move the pin, install again, and use that same reinstall for rollback.
claude_step=$(tr '\n' ' ' < "$root/skills/update/SKILL.md" |
  sed -n 's/.*For Claude Code,\(.*\)For Codex.*/\1/p')
if test -z "$claude_step"; then
  echo 'update skill: no Claude Code step found' >&2
  exit 1
fi
case "$claude_step" in
  *'marketplace remove'*'marketplace add'*'plugin install'*'plugin update'*) ;;
  *)
    echo 'update skill: Claude path must move the pin, install, then update the plugin' >&2
    exit 1
    ;;
esac

rollback_step=$(tr '\n' ' ' < "$root/skills/update/SKILL.md" |
  sed -n 's/.*Treat the add\(.*\)Do not edit harness cache directories.*/\1/p')
case "$rollback_step" in
  *'transaction removes the target only when'*'restores the kind-preserving recorded source'*'complete transaction'*) ;;
  *)
    echo 'update skill: Claude rollback must remain a self-contained transaction' >&2
    exit 1
    ;;
esac

for target in claude codex pi; do
  if test "$target" = claude; then
    : > "$fake_log"
    output=$(FAKE_CLAUDE_LOG=$fake_log FAKE_MARKETPLACE_JSON='[]' \
      PATH="$fake_bin:$PATH" FLOW42_SKIP_PREFLIGHT=1 \
      sh "$root/scripts/install-local" "$target" --dry-run)
    if test "$(cat "$fake_log")" != 'plugin marketplace list --json'; then
      echo 'install-local: absent dry-run did not discover marketplace state exactly once' >&2
      exit 1
    fi
  else
    output=$(FLOW42_SKIP_PREFLIGHT=1 sh "$root/scripts/install-local" "$target" --dry-run)
  fi
  case "$target" in
    claude)
      printf '%s\n' "$output" | grep -F -q "DRY-RUN [claude] [plugin] [validate] [--strict] [$root]"
      printf '%s\n' "$output" | grep -F -q "DRY-RUN [claude] [plugin] [marketplace] [add] [$root] [--scope] [local]"
      printf '%s\n' "$output" | grep -F -q 'DRY-RUN [claude] [plugin] [install] [flow42@flow42] [--scope] [local] [--yes]'
      ;;
    codex)
      printf '%s\n' "$output" | grep -F -q "DRY-RUN [codex] [plugin] [marketplace] [add] [$root] [--json]"
      printf '%s\n' "$output" | grep -F -q 'DRY-RUN [codex] [plugin] [add] [flow42@flow42] [--json]'
      ;;
    pi)
      printf '%s\n' "$output" | grep -F -q "DRY-RUN [pi] [install] [$root] [--local] [--approve]"
      ;;
  esac
  printf '%s\n' "$output" |
    grep -q "local $target installation plan generated; no harness mutation or install commands and no plugin validation were executed"
done

if FLOW42_SKIP_PREFLIGHT=1 sh "$root/scripts/install-local" invalid --dry-run >/dev/null 2>&1; then
  echo 'invalid harness accepted' >&2
  exit 1
fi

echo 'update ok: release skill and local harness plans'
