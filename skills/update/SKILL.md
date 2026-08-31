---
name: update
description: Update an installed Flow42 plugin from its configured repository or immutable release using the active harness. Use when the user asks to update, upgrade, or refresh Flow42 itself.
---

# Update Flow42

Treat this as plugin maintenance, not a work-item lifecycle stage. Do not create
issues, comments, branches, commits, or Flow42 approval artifacts.

Detect the active harness and inspect its installed plugin listing. Read the
installed Flow42 version without printing credentials. Derive the Flow42
repository from the recorded marketplace or package source of that installation,
so a fork or mirror keeps updating from its own origin; `stefanriegel/flow42` is
only the fallback default when the recorded source names no repository.

Resolve and verify the target release before mutating anything. List candidate
tags with `git ls-remote --tags --refs <repository-url> 'v[0-9]*.[0-9]*.[0-9]*'`
and take the highest semantic version; never update from an untagged branch
unless the user explicitly requests a development checkout. Resolve
`trusted_root` as the absolute root of the already-installed Flow42 bundle from
the active harness listing, before fetching candidate content. Confirm that
`$trusted_root/scripts/release-checksum.sh` and
`$trusted_root/.github/allowed_signers` exist, then use a fresh temporary Git
repository and the resolved `repository_url` and `tag` values literally as
follows:

```sh
trusted_root=/absolute/path/from-the-active-harness-listing/to/installed/flow42
candidate_repo=$(mktemp -d "${TMPDIR:-/tmp}/flow42-update.XXXXXX")
trap 'test ! -d "$candidate_repo" || find "$candidate_repo" -depth -delete' EXIT HUP INT TERM
git -C "$candidate_repo" init
git -C "$candidate_repo" fetch --no-tags "$repository_url" \
  "refs/tags/${tag}:refs/tags/${tag}"
checksum_file=$(
  cd "$candidate_repo"
  sh "$trusted_root/scripts/release-checksum.sh" "refs/tags/$tag" "$candidate_repo/dist"
)
if command -v sha256sum >/dev/null 2>&1; then
  (cd "$(dirname "$checksum_file")" && sha256sum -c "$(basename "$checksum_file")")
else
  (cd "$(dirname "$checksum_file")" && shasum -a 256 -c "$(basename "$checksum_file")")
fi
find "$candidate_repo" -depth -delete
```

The working directory is deliberately `candidate_repo`, because it owns the
fetched `refs/tags/$tag`; the verifier path is deliberately under
`trusted_root`, because the installed bundle supplies the pinned signer policy.
The candidate tag still supplies its release allowlist, but the trusted verifier
requires that allowlist to match its embedded principal and fingerprint before
checking the annotated tag signature and manifest versions. The script prints
the generated `.sha256` file path, and the final command checks that local
manifest against the locally generated archive. This proves the fetched signed
tag and deterministic local archive are internally consistent; it does not
compare a separately published release artifact because no such source is
defined. Any fetch, signature, manifest, or checksum failure ends the update
with the pin untouched; the trap also deletes `candidate_repo` on failure.

Report `installed -> available`. If already current, validate the installed
bundle and stop. Otherwise use only the harness-native update path. Released
marketplaces are pinned to immutable tags, so refreshing the existing
marketplace cannot advance versions; the pin must move to the verified tag first.

For Claude Code, query both `claude plugin marketplace list --json` and
`claude plugin list --json` before changing state. The marketplace listing
identifies the recorded source but does not report its declaration scope, so
match that exact source under `extraKnownMarketplaces.flow42` in the effective
user, project, and local settings. Record that independently as
`marketplace_scope`; record the installed plugin entry's `scope` independently
as `plugin_scope`. If either scope or the source is absent, managed, or
ambiguous, stop before mutation rather than guessing.

`marketplace remove` without `--scope` removes the declaration from every scope,
while `marketplace add` and `install` default to user scope. Removing a
marketplace also uninstalls plugins installed from it, so a mixed installation
such as a user-scope marketplace with a local-scope plugin must deliberately use
two different scope values. For a GitHub shorthand, the current ref form is
`owner/repo@tag`; `#ref` is only for a full Git URL. With the angle-bracket
assignments below replaced by the recorded values, use this literal sequence:

```sh
marketplace_scope=<recorded-marketplace-declaration-scope>
plugin_scope=<recorded-plugin-installation-scope>
recorded_marketplace_source=<exact-current-add-source>
target_marketplace_source=<owner>/<repo>@<tag>
claude plugin marketplace remove flow42 --scope "$marketplace_scope"
claude plugin marketplace add "$target_marketplace_source" --scope "$marketplace_scope"
claude plugin install flow42@flow42 --scope "$plugin_scope" -y
```

The explicit `-y` is required whenever stdin or stdout is not a TTY, the normal
case in an agent shell.

For Codex, record the current marketplace source, then run `codex plugin
marketplace remove flow42`, `codex plugin marketplace add <owner>/<repo> --ref
<tag>`, and `codex plugin add flow42@flow42 --json`. For Pi, read the installed
source from `pi list` and install `git:github.com/<owner>/<repo>@<tag>`
explicitly. Neither documents an installation-scope selector, so the recorded
source is their whole rollback state; do not invent a scope flag to fake symmetry.

Treat the add and the install or refresh alike as rollback triggers. For Claude,
if the target marketplace was added, remove it only from `marketplace_scope`,
then restore the recorded source at `marketplace_scope` and reinstall the plugin
at `plugin_scope`:

```sh
claude plugin marketplace remove flow42 --scope "$marketplace_scope"
claude plugin marketplace add "$recorded_marketplace_source" --scope "$marketplace_scope"
claude plugin install flow42@flow42 --scope "$plugin_scope" -y
```

For Codex or Pi, restore the recorded source and re-run its harness refresh.
Report the failed command; a moved pin with an unmoved plugin, a marketplace
missing from every scope, or a changed declaration or installation scope is
itself a failed update.

Do not edit harness cache directories or copy files into them. Do not uninstall
the plugin merely to force an update; replacing the pinned marketplace source is
the narrow required mutation. If the configured source is a local checkout,
direct the maintainer to that checkout's `scripts/install-local` instead of
replacing it with a release source.

After the update, verify the reported version, manifest, contract, templates,
and one skill directory for every command declared in `core/workflow.json`. A
version mismatch or missing component is a failed update. Report the exact
failed check and recovery command without claiming success, and on success tell
the user to restart the harness before using the new instructions.
