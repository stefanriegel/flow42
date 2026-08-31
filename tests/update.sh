#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)

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
# update and rollback instructions must therefore keep both values literal and
# must use the current GitHub shorthand ref form.
# shellcheck disable=SC2016
assert_claude_scope_instructions() {
  skill=$1
  grep -Fq 'marketplace_scope=<recorded-marketplace-declaration-scope>' "$skill" || return 1
  grep -Fq 'plugin_scope=<recorded-plugin-installation-scope>' "$skill" || return 1
  grep -Fq 'target_marketplace_source=<owner>/<repo>@<tag>' "$skill" || return 1
  grep -Fq 'claude plugin marketplace add "$target_marketplace_source" --scope "$marketplace_scope"' "$skill" || return 1
  grep -Fq 'claude plugin marketplace add "$recorded_marketplace_source" --scope "$marketplace_scope"' "$skill" || return 1
  test "$(grep -Fc 'claude plugin marketplace remove flow42 --scope "$marketplace_scope"' "$skill")" -ge 2 || return 1
  test "$(grep -Fc 'claude plugin install flow42@flow42 --scope "$plugin_scope" -y' "$skill")" -ge 2 || return 1
  if grep -Fq '<owner>/<repo>#<tag>' "$skill"; then
    echo 'update skill: Claude GitHub shorthand uses obsolete #ref syntax' >&2
    return 1
  fi
}

assert_claude_scope_instructions "$root/skills/update/SKILL.md"

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

fake_bin=$(mktemp -d)
fake_log=$fake_bin/claude.log
trap 'rm -rf "$fake_bin"' EXIT HUP INT TERM
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
  claude plugin marketplace remove flow42 --scope "$marketplace_scope"
FAKE_CLAUDE_LOG=$fake_log PATH="$fake_bin:$PATH" \
  claude plugin marketplace add "$recorded_marketplace_source" --scope "$marketplace_scope"
FAKE_CLAUDE_LOG=$fake_log PATH="$fake_bin:$PATH" \
  claude plugin install flow42@flow42 --scope "$plugin_scope" -y
mixed_scope_calls=$(cat "$fake_log")
expected_mixed_scope_calls='plugin marketplace remove flow42 --scope user
plugin marketplace add owner/flow42@v1.2.4 --scope user
plugin install flow42@flow42 --scope local -y
plugin marketplace remove flow42 --scope user
plugin marketplace add owner/flow42@v1.2.3 --scope user
plugin install flow42@flow42 --scope local -y'
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
  *'marketplace remove'*'marketplace add'*'plugin install'*) ;;
  *)
    echo 'update skill: Claude path must remove the old pin, add the new pin, then reinstall the plugin' >&2
    exit 1
    ;;
esac
case "$claude_step" in
  *'plugin update'*)
    echo 'update skill: Claude path cannot update a plugin uninstalled by marketplace removal' >&2
    exit 1
    ;;
esac

rollback_step=$(tr '\n' ' ' < "$root/skills/update/SKILL.md" |
  sed -n 's/.*Treat the add\(.*\)Do not edit harness cache directories.*/\1/p')
case "$rollback_step" in
  *'For Claude'*'restore the recorded'*'reinstall the plugin'*) ;;
  *)
    echo 'update skill: Claude rollback must restore the marketplace and reinstall the plugin' >&2
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
