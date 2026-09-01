#!/bin/sh
set -eu

# Behavioural: exercise Git's NUL-delimited status and literal path handling in
# a disposable repository. Text assertions below only bind the shipped
# instructions to the behaviour demonstrated here.

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-ownership.XXXXXX")
trap 'find "$tmp" -depth -delete' EXIT HUP INT TERM
repo="$tmp/repo"

fail() {
  printf 'ownership failed: %s\n' "$1" >&2
  exit 1
}

delete_paths() {
  for delete_path in "$@"; do
    if test -e "$delete_path" || test -L "$delete_path"; then
      find "$delete_path" -depth -delete
    fi
  done
}

require_path() {
  json_file=$1
  exact_path=$2
  diagnostic=$3
  jq -e --arg path "$exact_path" 'index($path) != null' "$json_file" >/dev/null ||
    fail "$diagnostic"
}

parse_status_paths() {
  jq -Rs '
    split("\u0000") | .[:-1] as $records |
    reduce range(0; $records | length) as $index
      ({paths: [], skip: false};
       if .skip then
         .skip = false
       else
         $records[$index] as $record |
         if $record | startswith("2 ") then
           if ($index + 1) >= ($records | length) then
             error("missing porcelain-v2 rename/copy endpoint")
           else
             .paths += [
               ($record | capture("(?s)^2(?: [^ ]+){8} (?<path>.*)$").path),
               $records[$index + 1]
             ] | .skip = true
           end
         elif $record | startswith("1 ") then
           .paths += [
             ($record | capture("(?s)^1(?: [^ ]+){7} (?<path>.*)$").path)
           ]
         elif $record | startswith("u ") then
           .paths += [
             ($record | capture("(?s)^u(?: [^ ]+){9} (?<path>.*)$").path)
           ]
         elif $record | startswith("? ") then
           .paths += [($record[2:])]
         else
           error("unexpected porcelain-v2 record: \($record)")
         end
       end) |
    .paths
  ' "$1"
}

parse_diff_name_status_paths() {
  jq -Rs '
    split("\u0000") | .[:-1] as $records |
    reduce range(0; $records | length) as $index
      ({paths: [], skip: 0};
       if .skip > 0 then
         .skip -= 1
       else
         $records[$index] as $status |
         if $status | test("^[RC][0-9]+$") then
           if ($index + 2) >= ($records | length) then
             error("missing name-status rename/copy endpoint")
           else
             .paths += [$records[$index + 1], $records[$index + 2]] |
             .skip = 2
           end
         elif $status | test("^[ADMRTUXB]$") then
           if ($index + 1) >= ($records | length) then
             error("missing name-status path")
           else
             .paths += [$records[$index + 1]] |
             .skip = 1
           end
         else
           error("unexpected name-status record: \($status)")
         end
       end) |
    .paths
  ' "$1"
}

is_owned() {
  candidate=$1
  case "$candidate" in
    '' | /* | ../* | */../* | */..)
      return 1
      ;;
    owned | owned/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

dirty_overlap_allowed() {
  before_identity=$1
  after_identity=$2
  explicitly_handed_off=$3
  test "$before_identity" = "$after_identity" ||
    test "$explicitly_handed_off" = true
}

hash_file_or_missing() {
  hash_path=$1
  test ! -L "$hash_path" || return 1
  if test -f "$hash_path"; then
    hash_output=$(shasum -a 256 "$hash_path") || return 1
    hash_value=${hash_output%% *}
    case "$hash_value" in *[!0-9a-f]*|'') return 1 ;; esac
    test "${#hash_value}" -eq 64 || return 1
    printf '%s\n' "$hash_value"
  elif test -e "$hash_path"; then
    return 1
  else
    printf '%s\n' missing
  fi
}

hash_tree_or_missing() {
  tree_path=$1
  tree_archive="$tmp/admin-tree.tar"
  tree_links="$tmp/admin-tree.links"
  delete_paths "$tree_archive" "$tree_links"
  test ! -L "$tree_path" || return 1
  if test -d "$tree_path"; then
    find "$tree_path" \( -type l -o \( -type f -links +1 \) -o \
      \( ! -type f ! -type d \) \) -print \
      >"$tree_links" || return 1
    test ! -s "$tree_links" || return 1
    if ! tar -cf "$tree_archive" -C "$tree_path" .; then
      delete_paths "$tree_archive"
      return 1
    fi
    tree_identity=$(hash_file_or_missing "$tree_archive") || {
      delete_paths "$tree_archive"
      return 1
    }
    delete_paths "$tree_archive"
    printf '%s\n' "$tree_identity"
  elif test -e "$tree_path"; then
    return 1
  else
    printf '%s\n' missing
  fi
}

hash_string() {
  hash_capture="$tmp/hash-string"
  printf '%s' "$1" >"$hash_capture" || return 1
  hash_file_or_missing "$hash_capture"
}

path_metadata() {
  metadata_path=$1
  if metadata=$(stat -f '%HT:%Lp:%d:%i:%l' "$metadata_path" 2>/dev/null); then
    printf '%s\n' "$metadata"
  elif metadata=$(stat -c '%F:%a:%d:%i:%h' -- "$metadata_path" 2>/dev/null); then
    printf '%s\n' "$metadata"
  else
    return 1
  fi
}

hash_behavior_path() {
  behavior_path=$1
  test ! -L "$behavior_path" || return 1
  if test -f "$behavior_path"; then
    behavior_metadata=$(path_metadata "$behavior_path") || return 1
    behavior_links=${behavior_metadata##*:}
    test "$behavior_links" -eq 1 || return 1
    behavior_content=$(hash_file_or_missing "$behavior_path") || return 1
    behavior_kind=regular
  elif test -d "$behavior_path"; then
    behavior_metadata=$(path_metadata "$behavior_path") || return 1
    behavior_kind=directory
    behavior_content=$(hash_tree_or_missing "$behavior_path") || return 1
  elif test -e "$behavior_path"; then
    return 1
  else
    behavior_metadata=missing
    behavior_kind=missing
    behavior_content=missing
  fi

  hash_string "$behavior_kind:$behavior_metadata:$behavior_content"
}

snapshot_behavior_path() {
  behavior_label=$1
  behavior_path=$2
  behavior_path_identity=$(hash_string "$behavior_path") || return 1
  behavior_content_identity=$(hash_behavior_path "$behavior_path") || return 1
  printf '%s-path=%s\n' "$behavior_label" "$behavior_path_identity"
  printf '%s-content=%s\n' "$behavior_label" "$behavior_content_identity"
}

snapshot_external_behavior_path() {
  behavior_repo=$1
  behavior_key=$2
  behavior_default_leaf=$3
  behavior_label=$4
  behavior_capture_prefix=$5
  behavior_config_rc=0
  behavior_config_capture="$behavior_capture_prefix.$behavior_label.config"

  if capture_git_config_path "$behavior_repo" "$behavior_key" \
    "$behavior_config_capture"; then
    behavior_configured=$(LC_ALL=C dd \
      if="$behavior_config_capture.value" 2>/dev/null) || return 1
    delete_paths "$behavior_config_capture.value"
    if test -z "$behavior_configured"; then
      printf '%s-path=configured-empty\n' "$behavior_label"
      printf '%s-content=missing\n' "$behavior_label"
      return 0
    fi
    case "$behavior_configured" in
      /*) behavior_external_path=$behavior_configured ;;
      *) behavior_external_path="$behavior_repo/$behavior_configured" ;;
    esac
  else
    behavior_config_rc=$?
    test "$behavior_config_rc" -eq 1 || return 1
  fi

  if test "${behavior_config_rc:-0}" -eq 1 &&
    test -n "${XDG_CONFIG_HOME:-}"; then
    case "$XDG_CONFIG_HOME" in /*) ;; *) return 1 ;; esac
    behavior_external_path="$XDG_CONFIG_HOME/git/$behavior_default_leaf"
  elif test "${behavior_config_rc:-0}" -eq 1 && test -n "${HOME:-}"; then
    case "$HOME" in /*) ;; *) return 1 ;; esac
    behavior_external_path="$HOME/.config/git/$behavior_default_leaf"
  elif test "${behavior_config_rc:-0}" -eq 1; then
    printf '%s-path=no-default-home\n' "$behavior_label"
    printf '%s-content=missing\n' "$behavior_label"
    return 0
  fi

  snapshot_behavior_path "$behavior_label" "$behavior_external_path"
}

capture_git_config_path() {
  config_repo=$1
  config_key=$2
  config_prefix=$3
  config_raw="$config_prefix.raw"
  config_value="$config_prefix.value"
  config_last="$config_prefix.last"
  config_without_nul="$config_prefix.without-nul"
  config_roundtrip="$config_prefix.roundtrip"
  delete_paths "$config_raw" "$config_value" "$config_last" \
    "$config_without_nul" "$config_roundtrip"

  if git -C "$config_repo" config --path --null --get "$config_key" \
    >"$config_raw"; then
    :
  else
    config_rc=$?
    delete_paths "$config_raw"
    test "$config_rc" -eq 1 && return 1
    return 2
  fi
  config_size_raw=$(LC_ALL=C wc -c <"$config_raw") || return 2
  config_size=$(printf '%s' "$config_size_raw" | tr -d '[:space:]') ||
    return 2
  case "$config_size" in ''|*[!0-9]*) return 2 ;; esac
  test "$config_size" -ge 1 || return 2
  dd if="$config_raw" of="$config_last" bs=1 \
    skip=$((config_size - 1)) count=1 2>/dev/null || return 2
  config_last_byte_raw=$(od -An -tu1 "$config_last") || return 2
  config_last_byte=$(printf '%s' "$config_last_byte_raw" |
    tr -d '[:space:]') || return 2
  test "$config_last_byte" = 0 || return 2
  dd if="$config_raw" of="$config_value" bs=1 \
    count=$((config_size - 1)) 2>/dev/null || return 2
  LC_ALL=C tr -d '\000' <"$config_raw" >"$config_without_nul" || return 2
  cmp -s "$config_value" "$config_without_nul" || return 2
  jq -jRs '.' "$config_value" >"$config_roundtrip" || return 2
  cmp -s "$config_value" "$config_roundtrip" || return 2
  config_line_count_raw=$(LC_ALL=C wc -l <"$config_value") || return 2
  config_line_count=$(printf '%s' "$config_line_count_raw" |
    tr -d '[:space:]') || return 2
  test "$config_line_count" -eq 0 || return 2
  delete_paths "$config_raw" "$config_last" "$config_without_nul" \
    "$config_roundtrip"
}

behavior_surfaces_snapshot() {
  behavior_repo=$1
  behavior_output=$2
  behavior_capture_prefix="$behavior_output.capture"
  {
    snapshot_external_behavior_path "$behavior_repo" core.excludesFile ignore \
      external-excludes "$behavior_capture_prefix" || return 1
    snapshot_external_behavior_path "$behavior_repo" core.attributesFile \
      attributes external-attributes "$behavior_capture_prefix" || return 1
  } >"$behavior_output"
}

absolute_git_dir() {
  snapshot_repo=$1
  selector=$2
  raw=$(git -C "$snapshot_repo" rev-parse "$selector") || return 1
  case "$raw" in
    /*) printf '%s\n' "$raw" ;;
    *) (CDPATH=''; export CDPATH; cd -- "$snapshot_repo/$raw" && pwd -P) ;;
  esac
}

admin_snapshot() {
  snapshot_repo=$1
  output=$2
  common_dir=$(absolute_git_dir "$snapshot_repo" --git-common-dir) || return 1
  git_dir=$(absolute_git_dir "$snapshot_repo" --git-dir) || return 1

  common_tree_identity=$(hash_tree_or_missing "$common_dir") || return 1
  if test "$git_dir" = "$common_dir"; then
    git_tree_identity=same-as-common
  else
    git_tree_identity=$(hash_tree_or_missing "$git_dir") || return 1
  fi

  hooks_dir="$common_dir/hooks"
  hooks_capture="$output.hooks-path"
  if capture_git_config_path "$snapshot_repo" core.hooksPath "$hooks_capture"; then
    configured_hooks=$(LC_ALL=C dd if="$hooks_capture.value" 2>/dev/null) ||
      return 1
    find "$hooks_capture.value" -delete
    test -n "$configured_hooks" || return 1
    case "$configured_hooks" in
      /*) hooks_dir=$configured_hooks ;;
      *) hooks_dir="$snapshot_repo/$configured_hooks" ;;
    esac
  else
    hooks_config_rc=$?
    test "$hooks_config_rc" -eq 1 || return 1
  fi
  hooks_identity=$(hash_behavior_path "$hooks_dir") || return 1

  effective_config_capture="$output.effective-config"
  git -C "$snapshot_repo" config --null --show-origin --show-scope --list \
    >"$effective_config_capture" || return 1
  effective_config_identity=$(hash_file_or_missing "$effective_config_capture") ||
    return 1
  delete_paths "$effective_config_capture"

  refs_capture="$output.refs"
  git -C "$snapshot_repo" for-each-ref \
    --format='%(refname)%00%(objectname)%00%(symref)' >"$refs_capture" ||
    return 1
  refs_identity=$(hash_file_or_missing "$refs_capture") || return 1
  delete_paths "$refs_capture"

  behavior_surfaces_file="$output.behavior-surfaces"
  behavior_surfaces_snapshot "$snapshot_repo" "$behavior_surfaces_file" ||
    return 1
  behavior_surfaces_identity=$(hash_file_or_missing "$behavior_surfaces_file") ||
    return 1

  common_dir_identity=$(hash_string "$common_dir") || return 1
  git_dir_identity=$(hash_string "$git_dir") || return 1
  hooks_dir_identity=$(hash_string "$hooks_dir") || return 1
  common_config_identity=$(hash_file_or_missing "$common_dir/config") || return 1
  worktree_config_identity=$(hash_file_or_missing "$git_dir/config.worktree") ||
    return 1
  packed_refs_identity=$(hash_file_or_missing "$common_dir/packed-refs") ||
    return 1
  reftable_identity=$(hash_tree_or_missing "$common_dir/reftable") || return 1
  index_identity=$(hash_file_or_missing "$git_dir/index") || return 1

  {
    printf 'common-dir=%s\n' "$common_dir_identity"
    printf 'git-dir=%s\n' "$git_dir_identity"
    printf 'common-admin-tree=%s\n' "$common_tree_identity"
    printf 'git-admin-tree=%s\n' "$git_tree_identity"
    printf 'common-config=%s\n' "$common_config_identity"
    printf 'worktree-config=%s\n' "$worktree_config_identity"
    printf 'effective-config=%s\n' "$effective_config_identity"
    printf 'hooks-dir=%s\n' "$hooks_dir_identity"
    printf 'hooks=%s\n' "$hooks_identity"
    printf 'behavior-surfaces=%s\n' "$behavior_surfaces_identity"
    while IFS= read -r behavior_surface_record; do
      printf 'behavior-%s\n' "$behavior_surface_record"
    done <"$behavior_surfaces_file"
    printf 'refs=%s\n' "$refs_identity"
    printf 'packed-refs=%s\n' "$packed_refs_identity"
    printf 'reftable=%s\n' "$reftable_identity"
    printf 'index=%s\n' "$index_identity"
  } >"$output"
  delete_paths "$behavior_surfaces_file"
}

validate_contract() {
  contract=$1
  grep -Fq 'git status --porcelain=v2 -z --untracked-files=all' "$contract" || {
    printf '%s\n' 'OWNERSHIP-NUL-STATUS' >&2
    return 1
  }
  grep -Fq "git diff --name-status -z --find-renames \"\$base\" --" "$contract" || {
    printf '%s\n' 'OWNERSHIP-NUL-RENAME-DIFF' >&2
    return 1
  }
  grep -Fq "git --literal-pathspecs add -- \"\$path\"" "$contract" || {
    printf '%s\n' 'OWNERSHIP-LITERAL-PATHSPEC' >&2
    return 1
  }
  grep -Eiq 'both endpoints of every rename|both the source and destination of every rename' "$contract" || {
    printf '%s\n' 'OWNERSHIP-RENAME-ENDPOINTS' >&2
    return 1
  }
  tr '\n' ' ' <"$contract" |
    grep -Eiq 'ordinary tracked.*rename.*unmerged.*untracked' || {
    printf '%s\n' 'OWNERSHIP-PORCELAIN-RECORD-TYPES' >&2
    return 1
  }
  tr '\n' ' ' <"$contract" |
    grep -Eiq 'unknown record type.*fail closed|fail closed.*unknown record type' || {
    printf '%s\n' 'OWNERSHIP-UNKNOWN-RECORD' >&2
    return 1
  }
  grep -Eiq 'content (hash|identity)' "$contract" || {
    printf '%s\n' 'OWNERSHIP-DIRTY-IDENTITY' >&2
    return 1
  }
  tr '\n' ' ' <"$contract" |
    grep -Eiq 'block integration.*pre-existing dirty path|pre-existing dirty path.*block integration' || {
    printf '%s\n' 'OWNERSHIP-DIRTY-OVERLAP' >&2
    return 1
  }
  if grep -Eiq 'path snapshots? may be split on (a )?newline|ordinary pathspec interpretation' "$contract"; then
    printf '%s\n' 'OWNERSHIP-CONTRADICTORY-EXCEPTION' >&2
    return 1
  fi
  if ! grep -Fq 'git rev-parse --git-common-dir' "$contract" ||
    ! grep -Fq 'git rev-parse --git-dir' "$contract"; then
    printf '%s\n' 'OWNERSHIP-GIT-ADMIN-ROOTS' >&2
    return 1
  fi
  tr '\n' ' ' <"$contract" |
    grep -Eiq 'common.*config.*remote.*hook.*ref.*index' || {
    printf '%s\n' 'OWNERSHIP-GIT-ADMIN-IDENTITY' >&2
    return 1
  }
  if ! grep -Fq 'complete content-and-metadata identity for every entry' "$contract" ||
    ! grep -Fq 'without exclusions' "$contract" ||
    ! grep -Fq 'refs, reflogs' "$contract" ||
    ! grep -Fq 'object database, and the index' "$contract"; then
    printf '%s\n' 'OWNERSHIP-COMPLETE-GIT-ADMIN' >&2
    return 1
  fi
  if ! tr '\n' ' ' <"$contract" |
    grep -Fq 'by value and origin path only'; then
    printf '%s\n' 'OWNERSHIP-EXTERNAL-GIT-RESIDUALS' >&2
    return 1
  fi
  if ! tr '\n' ' ' <"$contract" |
    grep -Fq 'does not resolve or snapshot an external object store'; then
    printf '%s\n' 'OWNERSHIP-EXTERNAL-GIT-RESIDUALS' >&2
    return 1
  fi
  grep -Fq 'does not govern resource lifecycle' "$contract" || {
    printf '%s\n' 'OWNERSHIP-RESOURCE-LIFECYCLE-SCOPE' >&2
    return 1
  }
  if ! grep -Fq 'exactly one NUL-terminated byte record' "$contract" ||
    ! grep -Fq 'invalid UTF-8' "$contract" ||
    ! grep -Fq 'trailing-newline path must fail closed' "$contract"; then
    printf '%s\n' 'OWNERSHIP-EXACT-CONFIG-PATH' >&2
    return 1
  fi
  if ! tr '\n' ' ' <"$contract" |
    grep -Fq 'symlink, or multiply linked regular file'; then
    printf '%s\n' 'OWNERSHIP-ADMIN-PRODUCER-LINKS' >&2
    return 1
  fi
  if ! tr '\n' ' ' <"$contract" |
    grep -Fq 'partial archive or hash pipeline'; then
    printf '%s\n' 'OWNERSHIP-ADMIN-PRODUCER-LINKS' >&2
    return 1
  fi
  grep -Fq 'Workers are forbidden from creating commits' "$contract" || {
    printf '%s\n' 'OWNERSHIP-WORKER-COMMIT-FORBIDDEN' >&2
    return 1
  }
  tr '\n' ' ' <"$contract" |
    grep -Eiq 'Workers are forbidden.*HEAD.*ref' || {
    printf '%s\n' 'OWNERSHIP-WORKER-HEAD-REF-FORBIDDEN' >&2
    return 1
  }
  if tr '\n' ' ' <"$contract" |
    grep -Eiq 'workers? (may|can|are allowed to|are permitted to).*(commit|HEAD|refs?)'; then
    printf '%s\n' 'OWNERSHIP-WORKER-GIT-MUTATION-EXCEPTION' >&2
    return 1
  fi
  if tr '\n' ' ' <"$contract" |
    grep -Eiq 'workers? (may|can|are allowed to|are permitted to).*Git administrative'; then
    printf '%s\n' 'OWNERSHIP-GIT-ADMIN-EXCEPTION' >&2
    return 1
  fi
  grep -Fq 'worker stage' "$contract" || {
    printf '%s\n' 'OWNERSHIP-WORKER-STAGING-FORBIDDEN' >&2
    return 1
  }
  tr '\n' ' ' <"$contract" |
    grep -Eiq 'worker.*(must not|forbidden|block).*Git administrative|Git administrative.*worker.*(must not|forbidden|block)' || {
    printf '%s\n' 'OWNERSHIP-GIT-ADMIN-BLOCK' >&2
    return 1
  }
}

validate_external_alternate_claims() {
  ownership_contract=$1
  architecture_contract=$2
  threat_model_contract=$3

  for alternate_contract in "$ownership_contract" "$architecture_contract" \
    "$threat_model_contract"; do
    tr '\n' ' ' <"$alternate_contract" |
      grep -Eiq 'pre-existing latent ref.*resolvable or unresolvable.*without changing (the )?bound ref stream' || {
      printf '%s\n' 'OWNERSHIP-EXTERNAL-ALTERNATE-LATENT-REF' >&2
      return 1
    }
    tr '\n' ' ' <"$alternate_contract" |
      grep -Eiq 'snapshot equality is not object-availability proof' || {
      printf '%s\n' 'OWNERSHIP-EXTERNAL-ALTERNATE-AVAILABILITY' >&2
      return 1
    }
    if grep -Eiq 'external (alternate )?object.*inert|cannot affect integration on its own' \
      "$alternate_contract"; then
      printf '%s\n' 'OWNERSHIP-EXTERNAL-ALTERNATE-FALSE-INERTNESS' >&2
      return 1
    fi
  done

  tr '\n' ' ' <"$ownership_contract" |
    grep -Eiq 'Integration may rely only on objects and identities explicitly resolved for (its|the) actual baseline, HEAD, index, and owned worktree decision' || {
    printf '%s\n' 'OWNERSHIP-EXTERNAL-ALTERNATE-INTEGRATION-INPUTS' >&2
    return 1
  }
}

validate_orca_context_and_delegation_claims() {
  ownership_contract=$1
  architecture_contract=$2
  implementer_contract=$3
  threat_model_contract=$4

  for context_contract in "$ownership_contract" "$architecture_contract" \
    "$implementer_contract" "$threat_model_contract"; do
    if grep -Eiq 'isolated worktrees?' "$context_contract"; then
      printf '%s\n' 'OWNERSHIP-ORCA-ISOLATED-WORKTREE-CLAIM' >&2
      return 1
    fi
  done

  for context_contract in "$ownership_contract" "$architecture_contract"; do
    tr '\n' ' ' <"$context_contract" |
      grep -Eiq 'Orca-provided execution context' || {
      printf '%s\n' 'OWNERSHIP-ORCA-PROVIDED-CONTEXT' >&2
      return 1
    }
    tr '\n' ' ' <"$context_contract" |
      grep -Eiq 'record(s|ed)? (the )?exact worktree' || {
      printf '%s\n' 'OWNERSHIP-ORCA-EXACT-WORKTREE' >&2
      return 1
    }
    tr '\n' ' ' <"$context_contract" |
      grep -Eiq 'current worktree.*disjoint ownership.*barriers?' || {
      printf '%s\n' 'OWNERSHIP-ORCA-CURRENT-WORKTREE-BARRIERS' >&2
      return 1
    }
  done

  tr '\n' ' ' <"$implementer_contract" |
    grep -Eiq 'assigned execution context.*exact worktree' || {
    printf '%s\n' 'OWNERSHIP-IMPLEMENTER-ASSIGNED-CONTEXT' >&2
    return 1
  }

  for delegation_contract in "$ownership_contract" "$architecture_contract" \
    "$threat_model_contract"; do
    tr '\n' ' ' <"$delegation_contract" |
      grep -Eiq 'observed through Orca records or (through )?worker reporting (in|on|under) native execution' || {
      printf '%s\n' 'OWNERSHIP-DELEGATION-OBSERVATION-BOUNDARY' >&2
      return 1
    }
    if grep -Eiq 'Block integration when .*worker launched a delegate' \
      "$delegation_contract"; then
      printf '%s\n' 'OWNERSHIP-DELEGATION-UNQUALIFIED-BLOCK' >&2
      return 1
    fi
  done

  tr '\n' ' ' <"$threat_model_contract" |
    grep -Eiq 'non-cooperative native worker.*residual|residual.*non-cooperative native worker' || {
    printf '%s\n' 'OWNERSHIP-DELEGATION-NATIVE-RESIDUAL' >&2
    return 1
  }
  if tr '\n' ' ' <"$threat_model_contract" |
    grep -Eiq 'native execution (always )?proves.*(did not delegate|absence of delegation)'; then
    printf '%s\n' 'OWNERSHIP-DELEGATION-FALSE-NATIVE-PROOF' >&2
    return 1
  fi
}

git init -q "$repo"
git -C "$repo" config user.name 'Flow42 ownership fixture'
git -C "$repo" config user.email 'ownership@example.invalid'

space_path='owned/space name.txt'
tab_path=$(printf 'owned/tab\tname.txt')
utf8_path='owned/Grüße.txt'
newline_path=$(printf 'outside/line\nquote"name.txt')
leading_path='-leading.txt'
rename_source=$(printf 'outside/rename\tsource.txt')
rename_target=$(printf 'owned/rename\ntarget.txt')
deleted_path='owned/delete me.txt'
dirty_path='owned/already dirty.txt'
literal_path='owned/[literal].txt'
lookalike_path='owned/l.txt'

mkdir -p "$repo/owned" "$repo/outside"
for path in "$space_path" "$tab_path" "$utf8_path" "$leading_path" \
  "$rename_source" "$deleted_path" "$dirty_path" "$literal_path" \
  "$lookalike_path"; do
  printf 'baseline %s\n' "$path" >"$repo/$path"
done
git -C "$repo" add --all
git -C "$repo" commit -qm baseline
base=$(git -C "$repo" rev-parse HEAD)

printf '%s\n' coordinator >>"$repo/$dirty_path"
git -C "$repo" status --porcelain=v2 -z --untracked-files=all >"$tmp/pre-status"
parse_status_paths "$tmp/pre-status" >"$tmp/pre-paths.json"
require_path "$tmp/pre-paths.json" "$dirty_path" OWNERSHIP-PRE-DIRTY-MISSING
pre_dirty_hash=$(git -C "$repo" hash-object -- "$dirty_path")

printf '%s\n' worker >>"$repo/$dirty_path"
printf '%s\n' worker >>"$repo/$space_path"
printf '%s\n' worker >>"$repo/$tab_path"
printf '%s\n' worker >>"$repo/$utf8_path"
printf '%s\n' worker >>"$repo/$leading_path"
printf '%s\n' worker >>"$repo/$literal_path"
printf '%s\n' worker >>"$repo/$lookalike_path"
git -C "$repo" mv -- "$rename_source" "$rename_target"
git -C "$repo" rm -q -- "$deleted_path"
printf '%s\n' worker >"$repo/$newline_path"

git -C "$repo" status --porcelain=v2 -z --untracked-files=all >"$tmp/post-status"
parse_status_paths "$tmp/post-status" >"$tmp/post-paths.json"
for path in "$space_path" "$tab_path" "$utf8_path" "$newline_path" \
  "$leading_path" "$rename_source" "$rename_target" "$deleted_path" \
  "$dirty_path" "$literal_path" "$lookalike_path"; do
  require_path "$tmp/post-paths.json" "$path" OWNERSHIP-NUL-EXACT-PATH
done

git -C "$repo" status --short >"$tmp/line-status"
jq -Rsc 'split("\n")[:-1]' "$tmp/line-status" >"$tmp/line-paths.json"
if jq -e --arg path "$newline_path" 'index($path) != null' "$tmp/line-paths.json" >/dev/null; then
  fail OWNERSHIP-LINE-COLLECTOR-CHARACTERIZATION
fi

is_owned 'owned/x' || fail OWNERSHIP-EXACT-PREFIX
if is_owned 'owned-other/x' || is_owned "$newline_path" || is_owned "$rename_source" ||
  is_owned "$leading_path" || is_owned '../owned/x' || is_owned '/owned/x'; then
  fail OWNERSHIP-FAIL-CLOSED-PREFIX
fi
is_owned "$rename_target" || fail OWNERSHIP-RENAME-TARGET

post_dirty_hash=$(git -C "$repo" hash-object -- "$dirty_path")
test "$pre_dirty_hash" != "$post_dirty_hash" || fail OWNERSHIP-DIRTY-IDENTITY
require_path "$tmp/post-paths.json" "$dirty_path" OWNERSHIP-DIRTY-COLLISION
if dirty_overlap_allowed "$pre_dirty_hash" "$post_dirty_hash" false; then
  fail OWNERSHIP-DIRTY-OVERLAP-NOT-BLOCKED
fi
dirty_overlap_allowed "$pre_dirty_hash" "$post_dirty_hash" true ||
  fail OWNERSHIP-EXPLICIT-DIRTY-HANDOFF

git -C "$repo" reset -q
git -C "$repo" --literal-pathspecs add -- "$literal_path"
git -C "$repo" diff --cached --name-only -z >"$tmp/staged"
jq -Rs 'split("\u0000")[:-1]' "$tmp/staged" >"$tmp/staged.json"
test "$(jq 'length' "$tmp/staged.json")" -eq 1 || fail OWNERSHIP-PATHSPEC-COLLISION
require_path "$tmp/staged.json" "$literal_path" OWNERSHIP-LITERAL-PATHSPEC

git -C "$repo" reset -q
git -C "$repo" --literal-pathspecs add -- "$leading_path"
git -C "$repo" diff --cached --name-only -z >"$tmp/leading-staged"
jq -Rs 'split("\u0000")[:-1]' "$tmp/leading-staged" >"$tmp/leading-staged.json"
test "$(jq 'length' "$tmp/leading-staged.json")" -eq 1 || fail OWNERSHIP-LEADING-DASH
require_path "$tmp/leading-staged.json" "$leading_path" OWNERSHIP-LEADING-DASH

git -C "$repo" diff --name-status -z --find-renames "$base" -- >"$tmp/tracked-name-status"
parse_diff_name_status_paths "$tmp/tracked-name-status" >"$tmp/tracked-paths.json"
require_path "$tmp/tracked-paths.json" "$deleted_path" OWNERSHIP-DELETE

git -C "$repo" add --all
# Disposable evidence only: dispatched workers may not commit or move HEAD.
git -C "$repo" commit -qm 'worker committed changes'
git -C "$repo" status --porcelain=v2 -z --untracked-files=all >"$tmp/committed-status"
test ! -s "$tmp/committed-status" || fail OWNERSHIP-COMMITTED-STATUS-NOT-CLEAN

git -C "$repo" diff --name-only -z --find-renames "$base" -- >"$tmp/committed-name-only"
jq -Rs 'split("\u0000")[:-1]' "$tmp/committed-name-only" >"$tmp/committed-name-only.json"
require_path "$tmp/committed-name-only.json" "$rename_target" OWNERSHIP-NAME-ONLY-TARGET
if jq -e --arg path "$rename_source" 'index($path) != null' "$tmp/committed-name-only.json" >/dev/null; then
  fail OWNERSHIP-NAME-ONLY-CHARACTERIZATION
fi

git -C "$repo" diff --name-status -z --find-renames "$base" -- >"$tmp/committed-name-status"
parse_diff_name_status_paths "$tmp/committed-name-status" >"$tmp/committed-paths.json"
require_path "$tmp/committed-paths.json" "$rename_source" OWNERSHIP-COMMITTED-RENAME-SOURCE
require_path "$tmp/committed-paths.json" "$rename_target" OWNERSHIP-COMMITTED-RENAME-TARGET
if is_owned "$rename_source" && is_owned "$rename_target"; then
  fail OWNERSHIP-COMMITTED-CROSS-BOUNDARY-RENAME-NOT-BLOCKED
fi

conflict_repo="$tmp/conflict-repo"
conflict_path=$(printf 'owned/conflict\nGrüße.txt')
git init -q "$conflict_repo"
git -C "$conflict_repo" config user.name 'Flow42 conflict fixture'
git -C "$conflict_repo" config user.email 'ownership-conflict@example.invalid'
mkdir -p "$conflict_repo/owned"
printf '%s\n' baseline >"$conflict_repo/$conflict_path"
git -C "$conflict_repo" add --all
git -C "$conflict_repo" commit -qm baseline
conflict_base_branch=$(git -C "$conflict_repo" symbolic-ref --short HEAD)
git -C "$conflict_repo" checkout -q -b worker-side
printf '%s\n' worker >"$conflict_repo/$conflict_path"
git -C "$conflict_repo" commit -qam worker
git -C "$conflict_repo" checkout -q "$conflict_base_branch"
printf '%s\n' coordinator >"$conflict_repo/$conflict_path"
git -C "$conflict_repo" commit -qam coordinator
if git -C "$conflict_repo" merge worker-side >"$tmp/conflict-merge.log" 2>&1; then
  fail OWNERSHIP-CONFLICT-FIXTURE-DID-NOT-CONFLICT
fi
git -C "$conflict_repo" status --porcelain=v2 -z --untracked-files=all >"$tmp/conflict-status"
parse_status_paths "$tmp/conflict-status" >"$tmp/conflict-paths.json"
require_path "$tmp/conflict-paths.json" "$conflict_path" OWNERSHIP-UNMERGED-PATH

printf 'x unsupported\0' >"$tmp/unknown-status"
if parse_status_paths "$tmp/unknown-status" >"$tmp/unknown-paths.json" 2>/dev/null; then
  fail OWNERSHIP-UNKNOWN-STATUS-ACCEPTED
fi

printf 'Z\0owned/unsupported\0' >"$tmp/unknown-name-status"
if parse_diff_name_status_paths "$tmp/unknown-name-status" >"$tmp/unknown-diff-paths.json" 2>/dev/null; then
  fail OWNERSHIP-UNKNOWN-NAME-STATUS-ACCEPTED
fi

printf 'R100\0outside/truncated\0' >"$tmp/truncated-name-status"
if parse_diff_name_status_paths "$tmp/truncated-name-status" >"$tmp/truncated-diff-paths.json" 2>/dev/null; then
  fail OWNERSHIP-TRUNCATED-NAME-STATUS-ACCEPTED
fi

admin_repo="$tmp/admin-repo"
admin_remote="$tmp/admin-remote.git"
git init -q "$admin_repo"
git init -q --bare "$admin_remote"
git -C "$admin_repo" config user.name 'Flow42 admin fixture'
git -C "$admin_repo" config user.email 'ownership-admin@example.invalid'
printf '%s\n' tracked >"$admin_repo/tracked.txt"
git -C "$admin_repo" add tracked.txt
git -C "$admin_repo" commit -qm baseline
admin_baseline_excludes="$tmp/admin-baseline-ignore"
admin_baseline_attributes="$tmp/admin-baseline-attributes"
: >"$admin_baseline_excludes"
: >"$admin_baseline_attributes"
git -C "$admin_repo" config core.excludesFile "$admin_baseline_excludes"
git -C "$admin_repo" config core.attributesFile "$admin_baseline_attributes"

admin_common=$(absolute_git_dir "$admin_repo" --git-common-dir)
cp "$admin_common/info/exclude" "$tmp/admin-info-exclude.backup"
admin_snapshot "$admin_repo" "$tmp/admin-before-info-exclude"
git -C "$admin_repo" status --porcelain=v2 -z --untracked-files=all \
  >"$tmp/admin-status-before-info-exclude"
if is_owned outside-hidden.txt; then
  fail OWNERSHIP-ADMIN-INFO-EXCLUDE-FIXTURE-IN-SCOPE
fi
printf '%s\n' 'outside-hidden.txt' >>"$admin_common/info/exclude"
printf '%s\n' hidden >"$admin_repo/outside-hidden.txt"
git -C "$admin_repo" check-ignore -q -- outside-hidden.txt ||
  fail OWNERSHIP-ADMIN-INFO-EXCLUDE-FIXTURE-NOT-HIDDEN
git -C "$admin_repo" status --porcelain=v2 -z --untracked-files=all \
  >"$tmp/admin-status-after-info-exclude"
cmp -s "$tmp/admin-status-before-info-exclude" \
  "$tmp/admin-status-after-info-exclude" ||
  fail OWNERSHIP-ADMIN-INFO-EXCLUDE-PORCELAIN-CHANGED
admin_snapshot "$admin_repo" "$tmp/admin-after-info-exclude"
cmp -s "$tmp/admin-before-info-exclude" "$tmp/admin-after-info-exclude" &&
  fail OWNERSHIP-ADMIN-INFO-EXCLUDE-UNDETECTED
cp "$tmp/admin-info-exclude.backup" "$admin_common/info/exclude"
find "$admin_repo/outside-hidden.txt" -delete

admin_attributes="$admin_common/info/attributes"
admin_snapshot "$admin_repo" "$tmp/admin-before-info-attributes"
printf '%s\n' 'tracked.txt fixture-attribute' >"$admin_attributes"
test "$(git -C "$admin_repo" check-attr fixture-attribute -- tracked.txt)" = \
  'tracked.txt: fixture-attribute: set' ||
  fail OWNERSHIP-ADMIN-INFO-ATTRIBUTES-FIXTURE-NOT-EFFECTIVE
admin_snapshot "$admin_repo" "$tmp/admin-after-info-attributes"
cmp -s "$tmp/admin-before-info-attributes" \
  "$tmp/admin-after-info-attributes" &&
  fail OWNERSHIP-ADMIN-INFO-ATTRIBUTES-UNDETECTED
find "$admin_attributes" -delete

admin_alternates="$admin_common/objects/info/alternates"
admin_snapshot "$admin_repo" "$tmp/admin-before-alternates"
printf '%s\n' "$admin_remote/objects" >"$admin_alternates"
git -C "$admin_repo" cat-file -e 'HEAD^{commit}' ||
  fail OWNERSHIP-ADMIN-ALTERNATES-FIXTURE-BROKE-REPOSITORY
admin_snapshot "$admin_repo" "$tmp/admin-after-alternates"
cmp -s "$tmp/admin-before-alternates" "$tmp/admin-after-alternates" &&
  fail OWNERSHIP-ADMIN-ALTERNATES-UNDETECTED

# External alternate contents are intentionally outside the snapshot. Pin the
# residual: adding external content changes whether a pre-existing latent ref
# resolves even though the complete snapshot and bound ref stream stay equal.
latent_payload='alternate-latent-ref-object'
latent_object=$(printf '%s\n' "$latent_payload" | git hash-object --stdin)
latent_ref_name=refs/flow42/latent-alternate
latent_ref_path="$admin_common/$latent_ref_name"
mkdir -p "${latent_ref_path%/*}"
printf '%s\n' "$latent_object" >"$latent_ref_path"
if git -C "$admin_repo" cat-file -e "$latent_ref_name^{blob}" \
  >/dev/null 2>&1; then
  fail OWNERSHIP-EXTERNAL-ALTERNATE-LATENT-REF-ALREADY-RESOLVABLE
fi
admin_snapshot "$admin_repo" "$tmp/admin-before-external-alternate-object"
external_object=$(printf '%s\n' "$latent_payload" |
  git --git-dir="$admin_remote" hash-object -w --stdin)
test "$external_object" = "$latent_object" ||
  fail OWNERSHIP-EXTERNAL-ALTERNATE-LATENT-REF-OID-MISMATCH
git -C "$admin_repo" cat-file -e "$latent_ref_name^{blob}" ||
  fail OWNERSHIP-EXTERNAL-ALTERNATE-LATENT-REF-NOT-RESOLVABLE
admin_snapshot "$admin_repo" "$tmp/admin-after-external-alternate-object"
cmp -s "$tmp/admin-before-external-alternate-object" \
  "$tmp/admin-after-external-alternate-object" ||
  fail OWNERSHIP-EXTERNAL-ALTERNATE-LATENT-REF-SNAPSHOT-CHANGED
git -C "$admin_repo" update-ref refs/flow42/external-alternate "$external_object"
admin_snapshot "$admin_repo" "$tmp/admin-after-external-alternate-ref"
cmp -s "$tmp/admin-after-external-alternate-object" \
  "$tmp/admin-after-external-alternate-ref" &&
  fail OWNERSHIP-EXTERNAL-ALTERNATE-REF-UNDETECTED
git -C "$admin_repo" update-ref -d refs/flow42/external-alternate
delete_paths "$latent_ref_path"
find "$admin_alternates" -delete

external_include="$tmp/external-include.config"
printf '%s\n' '[flow42]' '  claim = baseline' >"$external_include"
git -C "$admin_repo" config --add include.path "$external_include"
test "$(git -C "$admin_repo" config --get flow42.claim)" = baseline ||
  fail OWNERSHIP-EXTERNAL-INCLUDE-FIXTURE-NOT-EFFECTIVE
admin_snapshot "$admin_repo" "$tmp/admin-before-external-include-value"
printf '%s\n' '[flow42]' '  claim = changed' >"$external_include"
test "$(git -C "$admin_repo" config --get flow42.claim)" = changed ||
  fail OWNERSHIP-EXTERNAL-INCLUDE-VALUE-NOT-EFFECTIVE
admin_snapshot "$admin_repo" "$tmp/admin-after-external-include-value"
cmp -s "$tmp/admin-before-external-include-value" \
  "$tmp/admin-after-external-include-value" &&
  fail OWNERSHIP-EXTERNAL-INCLUDE-VALUE-UNDETECTED

printf '%s\n' '[flow42]' '  claim = baseline' >"$external_include"
admin_snapshot "$admin_repo" "$tmp/admin-before-external-include-link"
printf '%s\n' '[flow42]' '  claim = baseline' >"$tmp/external-include-target"
delete_paths "$external_include"
ln -s "$tmp/external-include-target" "$external_include"
test -L "$external_include" ||
  fail OWNERSHIP-EXTERNAL-INCLUDE-LINK-FIXTURE-NOT-A-LINK
admin_snapshot "$admin_repo" "$tmp/admin-after-external-include-link"
cmp -s "$tmp/admin-before-external-include-link" \
  "$tmp/admin-after-external-include-link" ||
  fail OWNERSHIP-EXTERNAL-INCLUDE-EQUAL-VALUE-LINK-UNEXPECTEDLY-BOUND
git -C "$admin_repo" config --unset-all include.path
delete_paths "$external_include" "$tmp/external-include-target"

external_excludes="$tmp/external-ignore"
: >"$external_excludes"
git -C "$admin_repo" config core.excludesFile "$external_excludes"
admin_snapshot "$admin_repo" "$tmp/admin-before-external-excludes"
git -C "$admin_repo" status --porcelain=v2 -z --untracked-files=all \
  >"$tmp/admin-status-before-external-excludes"
printf '%s\n' 'external-hidden.txt' >>"$external_excludes"
printf '%s\n' hidden >"$admin_repo/external-hidden.txt"
git -C "$admin_repo" check-ignore -q -- external-hidden.txt ||
  fail OWNERSHIP-ADMIN-EXTERNAL-EXCLUDES-FIXTURE-NOT-HIDDEN
git -C "$admin_repo" status --porcelain=v2 -z --untracked-files=all \
  >"$tmp/admin-status-after-external-excludes"
cmp -s "$tmp/admin-status-before-external-excludes" \
  "$tmp/admin-status-after-external-excludes" ||
  fail OWNERSHIP-ADMIN-EXTERNAL-EXCLUDES-PORCELAIN-CHANGED
admin_snapshot "$admin_repo" "$tmp/admin-after-external-excludes"
cmp -s "$tmp/admin-before-external-excludes" \
  "$tmp/admin-after-external-excludes" &&
  fail OWNERSHIP-ADMIN-EXTERNAL-EXCLUDES-UNDETECTED
find "$admin_repo/external-hidden.txt" -delete
git -C "$admin_repo" config core.excludesFile "$admin_baseline_excludes"

newline_external_excludes=$(printf 'external\nignore')
git -C "$admin_repo" config core.excludesFile "$newline_external_excludes"
if admin_snapshot "$admin_repo" "$tmp/admin-newline-external-excludes" \
  >/dev/null 2>&1; then
  fail OWNERSHIP-ADMIN-EXTERNAL-PATH-NEWLINE-ACCEPTED
fi
git -C "$admin_repo" config core.excludesFile "$admin_baseline_excludes"

external_attributes="$tmp/external-attributes"
: >"$external_attributes"
git -C "$admin_repo" config core.attributesFile "$external_attributes"
admin_snapshot "$admin_repo" "$tmp/admin-before-external-attributes"
printf '%s\n' 'tracked.txt external-attribute' >>"$external_attributes"
test "$(git -C "$admin_repo" check-attr external-attribute -- tracked.txt)" = \
  'tracked.txt: external-attribute: set' ||
  fail OWNERSHIP-ADMIN-EXTERNAL-ATTRIBUTES-FIXTURE-NOT-EFFECTIVE
admin_snapshot "$admin_repo" "$tmp/admin-after-external-attributes"
cmp -s "$tmp/admin-before-external-attributes" \
  "$tmp/admin-after-external-attributes" &&
  fail OWNERSHIP-ADMIN-EXTERNAL-ATTRIBUTES-UNDETECTED
git -C "$admin_repo" config core.attributesFile "$admin_baseline_attributes"

admin_snapshot "$admin_repo" "$tmp/admin-before-remote"
git -C "$admin_repo" remote add injected "$admin_remote"
test -z "$(git -C "$admin_repo" status --porcelain)" || fail OWNERSHIP-ADMIN-REMOTE-DIRTY-WORKTREE
admin_snapshot "$admin_repo" "$tmp/admin-after-remote"
cmp -s "$tmp/admin-before-remote" "$tmp/admin-after-remote" && fail OWNERSHIP-ADMIN-REMOTE-UNDETECTED
git -C "$admin_repo" remote remove injected

admin_snapshot "$admin_repo" "$tmp/admin-before-hooks-path"
git -C "$admin_repo" config core.hooksPath ../outside-hooks
test -z "$(git -C "$admin_repo" status --porcelain)" || fail OWNERSHIP-ADMIN-HOOKS-PATH-DIRTY-WORKTREE
admin_snapshot "$admin_repo" "$tmp/admin-after-hooks-path"
cmp -s "$tmp/admin-before-hooks-path" "$tmp/admin-after-hooks-path" && fail OWNERSHIP-ADMIN-HOOKS-PATH-UNDETECTED
git -C "$admin_repo" config --unset core.hooksPath

admin_snapshot "$admin_repo" "$tmp/admin-before-hook"
printf '%s\n' '#!/bin/sh' 'exit 0' >"$admin_common/hooks/pre-commit"
chmod +x "$admin_common/hooks/pre-commit"
test -z "$(git -C "$admin_repo" status --porcelain)" || fail OWNERSHIP-ADMIN-HOOK-DIRTY-WORKTREE
admin_snapshot "$admin_repo" "$tmp/admin-after-hook"
cmp -s "$tmp/admin-before-hook" "$tmp/admin-after-hook" && fail OWNERSHIP-ADMIN-HOOK-UNDETECTED
find "$admin_common/hooks/pre-commit" -delete

admin_snapshot "$admin_repo" "$tmp/admin-before-ref"
git -C "$admin_repo" update-ref refs/heads/injected HEAD
test -z "$(git -C "$admin_repo" status --porcelain)" || fail OWNERSHIP-ADMIN-REF-DIRTY-WORKTREE
admin_snapshot "$admin_repo" "$tmp/admin-after-ref"
cmp -s "$tmp/admin-before-ref" "$tmp/admin-after-ref" && fail OWNERSHIP-ADMIN-REF-UNDETECTED
git -C "$admin_repo" update-ref -d refs/heads/injected

admin_snapshot "$admin_repo" "$tmp/admin-before-index"
git -C "$admin_repo" update-index --assume-unchanged tracked.txt
test -z "$(git -C "$admin_repo" status --porcelain)" || fail OWNERSHIP-ADMIN-INDEX-DIRTY-WORKTREE
admin_snapshot "$admin_repo" "$tmp/admin-after-index"
cmp -s "$tmp/admin-before-index" "$tmp/admin-after-index" && fail OWNERSHIP-ADMIN-INDEX-UNDETECTED
git -C "$admin_repo" update-index --no-assume-unchanged tracked.txt

# The complete Git-admin tree catches future or uncommon state without relying
# on a maintained filename manifest.
admin_snapshot "$admin_repo" "$tmp/admin-before-future-state"
printf '%s\n' future >"$admin_common/FUTURE_STATE"
admin_snapshot "$admin_repo" "$tmp/admin-after-future-state"
cmp -s "$tmp/admin-before-future-state" "$tmp/admin-after-future-state" &&
  fail OWNERSHIP-ADMIN-FUTURE-STATE-UNDETECTED
delete_paths "$admin_common/FUTURE_STATE"

admin_head=$(git -C "$admin_repo" rev-parse HEAD)
admin_snapshot "$admin_repo" "$tmp/admin-before-rebase-head"
printf '%s\n' "$admin_head" >"$admin_common/REBASE_HEAD"
test "$(git -C "$admin_repo" rev-parse REBASE_HEAD)" = "$admin_head" ||
  fail OWNERSHIP-ADMIN-REBASE-HEAD-FIXTURE-NOT-RESOLVED
admin_snapshot "$admin_repo" "$tmp/admin-after-rebase-head"
cmp -s "$tmp/admin-before-rebase-head" "$tmp/admin-after-rebase-head" &&
  fail OWNERSHIP-ADMIN-REBASE-HEAD-UNDETECTED
delete_paths "$admin_common/REBASE_HEAD"

admin_reflog="$admin_common/logs/HEAD"
cp "$admin_reflog" "$tmp/admin-reflog.backup"
admin_snapshot "$admin_repo" "$tmp/admin-before-reflog"
printf '%s %s Flow42 fixture <fixture@example.invalid> 1700000000 +0000\tworker-marker\n' \
  "$admin_head" "$admin_head" >>"$admin_reflog"
test "$(git -C "$admin_repo" reflog show -1 --format=%gs HEAD)" = worker-marker ||
  fail OWNERSHIP-ADMIN-REFLOG-FIXTURE-NOT-VISIBLE
admin_snapshot "$admin_repo" "$tmp/admin-after-reflog"
cmp -s "$tmp/admin-before-reflog" "$tmp/admin-after-reflog" &&
  fail OWNERSHIP-ADMIN-REFLOG-UNDETECTED
cp "$tmp/admin-reflog.backup" "$admin_reflog"

# A trailing newline is part of core.hooksPath. Shell-trimming it would inspect
# a different directory from the one Git executes, so the snapshot rejects it.
newline_hooks='../outside-hooks
'
mkdir -p "$admin_repo/$newline_hooks"
printf '%s\n' '#!/bin/sh' 'exit 23' >"$admin_repo/$newline_hooks/pre-commit"
chmod +x "$admin_repo/$newline_hooks/pre-commit"
git -C "$admin_repo" config core.hooksPath "$newline_hooks"
if admin_snapshot "$admin_repo" "$tmp/admin-newline-hooks" >/dev/null 2>&1; then
  fail OWNERSHIP-ADMIN-HOOKS-PATH-TRAILING-NEWLINE-ACCEPTED
fi
hook_rc=0
git -C "$admin_repo" hook run pre-commit >/dev/null 2>&1 || hook_rc=$?
test "$hook_rc" -eq 23 || fail OWNERSHIP-ADMIN-HOOKS-PATH-FIXTURE-NOT-EXECUTED
git -C "$admin_repo" config --unset core.hooksPath
delete_paths "$admin_repo/$newline_hooks"

# Configured external behavior paths are byte-validated and cannot redirect
# through equal-content links.
printf '%s\n' baseline >"$external_excludes"
git -C "$admin_repo" config core.excludesFile "$external_excludes"
printf '%s\n' baseline >"$tmp/external-ignore-target"
delete_paths "$external_excludes"
ln -s "$tmp/external-ignore-target" "$external_excludes"
if admin_snapshot "$admin_repo" "$tmp/admin-external-symlink" >/dev/null 2>&1; then
  fail OWNERSHIP-ADMIN-EXTERNAL-SYMLINK-ACCEPTED
fi
delete_paths "$external_excludes"
printf '%s\n' baseline >"$external_excludes"
ln "$external_excludes" "$tmp/external-ignore-hardlink"
if admin_snapshot "$admin_repo" "$tmp/admin-external-hardlink" >/dev/null 2>&1; then
  fail OWNERSHIP-ADMIN-EXTERNAL-HARDLINK-ACCEPTED
fi
delete_paths "$tmp/external-ignore-hardlink"

non_utf8_suffix=$(printf '\377x')
non_utf8_path="$tmp/non-utf8-$non_utf8_suffix"
git -C "$admin_repo" config core.excludesFile "$non_utf8_path"
if admin_snapshot "$admin_repo" "$tmp/admin-non-utf8-config" >/dev/null 2>&1; then
  fail OWNERSHIP-ADMIN-NON-UTF8-CONFIG-ACCEPTED
fi
git -C "$admin_repo" config core.excludesFile "$external_excludes"

git -C "$admin_repo" config --unset core.excludesFile
if XDG_CONFIG_HOME=relative HOME="$HOME" \
  admin_snapshot "$admin_repo" "$tmp/admin-relative-xdg" >/dev/null 2>&1; then
  fail OWNERSHIP-ADMIN-RELATIVE-XDG-ACCEPTED
fi
git -C "$admin_repo" config core.excludesFile "$external_excludes"

# Producer failures are observed directly; no POSIX pipeline can turn a partial
# archive or digest into a successful identity.
producer_bin="$tmp/producer-bin"
mkdir "$producer_bin"
cp "$root/tests/fixtures/ownership/failing-tar" "$producer_bin/tar"
chmod +x "$producer_bin/tar"
if PATH="$producer_bin:$PATH" \
  admin_snapshot "$admin_repo" "$tmp/admin-failing-tar" >/dev/null 2>&1; then
  fail OWNERSHIP-ADMIN-TAR-FAILURE-ACCEPTED
fi
delete_paths "$producer_bin/tar"
cp "$root/tests/fixtures/ownership/failing-shasum" "$producer_bin/shasum"
chmod +x "$producer_bin/shasum"
if PATH="$producer_bin:$PATH" \
  admin_snapshot "$admin_repo" "$tmp/admin-failing-shasum" >/dev/null 2>&1; then
  fail OWNERSHIP-ADMIN-HASH-FAILURE-ACCEPTED
fi
delete_paths "$producer_bin"

validate_contract "$root/core/OWNERSHIP.md"
validate_external_alternate_claims "$root/core/OWNERSHIP.md" \
  "$root/docs/ARCHITECTURE.md" "$root/evidence/security/threat-model.md"
validate_orca_context_and_delegation_claims "$root/core/OWNERSHIP.md" \
  "$root/docs/ARCHITECTURE.md" "$root/agents/implementer.md" \
  "$root/evidence/security/threat-model.md"

cp "$root/evidence/security/threat-model.md" \
  "$tmp/mutated-external-alternate-inert.md"
printf '%s\n' 'An external alternate object is inert for integration.' \
  >>"$tmp/mutated-external-alternate-inert.md"
if validate_external_alternate_claims "$root/core/OWNERSHIP.md" \
  "$root/docs/ARCHITECTURE.md" \
  "$tmp/mutated-external-alternate-inert.md" >/dev/null 2>&1; then
  fail OWNERSHIP-MUTATION-EXTERNAL-ALTERNATE-INERT-ACCEPTED
fi

cp "$root/docs/ARCHITECTURE.md" "$tmp/mutated-isolated-worktree.md"
printf '%s\n' 'Workers receive bounded slices in isolated worktrees.' \
  >>"$tmp/mutated-isolated-worktree.md"
if validate_orca_context_and_delegation_claims "$root/core/OWNERSHIP.md" \
  "$tmp/mutated-isolated-worktree.md" "$root/agents/implementer.md" \
  "$root/evidence/security/threat-model.md" >/dev/null 2>&1; then
  fail OWNERSHIP-MUTATION-ORCA-ISOLATED-WORKTREE-ACCEPTED
fi

cp "$root/evidence/security/threat-model.md" \
  "$tmp/mutated-native-delegation-proof.md"
printf '%s\n' 'Native execution always proves the worker did not delegate.' \
  >>"$tmp/mutated-native-delegation-proof.md"
if validate_orca_context_and_delegation_claims "$root/core/OWNERSHIP.md" \
  "$root/docs/ARCHITECTURE.md" "$root/agents/implementer.md" \
  "$tmp/mutated-native-delegation-proof.md" >/dev/null 2>&1; then
  fail OWNERSHIP-MUTATION-NATIVE-DELEGATION-PROOF-ACCEPTED
fi

cp "$root/core/OWNERSHIP.md" "$tmp/mutated-unqualified-delegation.md"
printf '%s\n' 'Block integration when the worker launched a delegate.' \
  >>"$tmp/mutated-unqualified-delegation.md"
if validate_orca_context_and_delegation_claims \
  "$tmp/mutated-unqualified-delegation.md" "$root/docs/ARCHITECTURE.md" \
  "$root/agents/implementer.md" "$root/evidence/security/threat-model.md" \
  >/dev/null 2>&1; then
  fail OWNERSHIP-MUTATION-UNQUALIFIED-DELEGATION-ACCEPTED
fi

cp "$root/core/OWNERSHIP.md" "$tmp/mutated-newline.md"
printf '%s\n' 'As an exception, path snapshots may be split on newline.' >>"$tmp/mutated-newline.md"
if validate_contract "$tmp/mutated-newline.md" >/dev/null 2>&1; then
  fail OWNERSHIP-MUTATION-NEWLINE-ACCEPTED
fi

cp "$root/core/OWNERSHIP.md" "$tmp/mutated-pathspec.md"
printf '%s\n' 'As an exception, recovery may stage names with ordinary pathspec interpretation.' >>"$tmp/mutated-pathspec.md"
if validate_contract "$tmp/mutated-pathspec.md" >/dev/null 2>&1; then
  fail OWNERSHIP-MUTATION-PATHSPEC-ACCEPTED
fi

cp "$root/core/OWNERSHIP.md" "$tmp/mutated-worker-commit.md"
printf '%s\n' 'Workers may commit and change HEAD or refs during a dispatch.' \
  >>"$tmp/mutated-worker-commit.md"
if validate_contract "$tmp/mutated-worker-commit.md" >/dev/null 2>&1; then
  fail OWNERSHIP-MUTATION-WORKER-COMMIT-ACCEPTED
fi

cp "$root/core/OWNERSHIP.md" "$tmp/mutated-admin-exception.md"
printf '%s\n' 'Workers may mutate any Git administrative file absent from the examples.' \
  >>"$tmp/mutated-admin-exception.md"
if validate_contract "$tmp/mutated-admin-exception.md" >/dev/null 2>&1; then
  fail OWNERSHIP-MUTATION-GIT-ADMIN-EXCEPTION-ACCEPTED
fi

echo 'ownership ok: exact paths plus complete fail-closed Git-admin identity'
