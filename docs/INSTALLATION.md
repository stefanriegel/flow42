# Installation

Flow42 requires Git and a supported coding-agent harness. Forge operations also
require authenticated `gh` for GitHub or `glab` for GitLab. Flow42 has no runtime.

## Development checkout

Clone Flow42 and validate the plugin before installation:

```sh
git clone https://github.com/stefanriegel/flow42.git
cd flow42
sh scripts/check-parity.sh
```

This path is executable before release: run Claude directly with `--plugin-dir`
as shown below, or point Codex at the checkout's `skills/` through its native
local skill discovery. It does not depend on a tag, marketplace publication, or
the pending 90-second claim.

## Claude Code

Test a checkout without persistent installation:

```sh
claude --plugin-dir "$PWD"
```

The skills are namespaced as `/flow42:flow`, `/flow42:init`, and so on.

After `v1.0.0` is tagged, install and start Claude Code with:

```sh
claude plugin marketplace add stefanriegel/flow42#v1.0.0
claude plugin install flow42@flow42
claude
```

Invoke `/flow42:init`, then `/flow42:intent <request>`. Update or uninstall with:

```sh
claude plugin update flow42@flow42
claude plugin uninstall flow42@flow42
claude plugin marketplace remove flow42
```

## Codex

Codex installs plugins from marketplace snapshots. After `v1.0.0` is tagged,
install and start Codex with:

```sh
codex plugin marketplace add stefanriegel/flow42 --ref v1.0.0
codex plugin add flow42@flow42
codex
```

Ask Codex to invoke `flow42:init`, then `flow42:intent` for the request. Refresh
the Git marketplace or uninstall with:

```sh
codex plugin marketplace upgrade flow42
codex plugin remove flow42@flow42
codex plugin marketplace remove flow42
```

These versioned commands cannot resolve until the tag exists. Before install,
verify the `v1.0.0` tag and published checksum against the resolved commit. Both
harnesses need a new session after installation or update. Local and remote
same-version install/update/removal paths were exercised; a version-changing
upgrade has not run. Current-head Codex invocation passed, while current-head
Claude invocation was blocked by missing authentication in the isolated test
scope; earlier authenticated Claude invocation evidence remains valid for its
recorded commit. See [installation evidence](../evidence/install/).

## Release checksum

From a clean checkout containing the published tag, create the deterministic
source archive and checksum with:

```sh
sh scripts/release-checksum.sh refs/tags/v1.0.0 dist
```

The script accepts only the exact annotated tag ref `refs/tags/v1.0.0`, verifies
its Git signature, and requires all three manifests in that tag to declare
`1.0.0`. It then uses `git archive` and the platform's native `sha256sum` or
`shasum -a 256`, writing `dist/flow42-v1.0.0.tar` and the adjacent
`.sha256` file. Verify after download with one of:

```sh
sha256sum -c flow42-v1.0.0.tar.sha256
shasum -a 256 -c flow42-v1.0.0.tar.sha256
```
