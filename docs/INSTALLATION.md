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

## Claude Code

Test a checkout without persistent installation:

```sh
claude --plugin-dir "$PWD"
```

The skills are namespaced as `/flow42:flow`, `/flow42:init`, and so on.

```sh
claude plugin marketplace add stefanriegel/flow42#v1.0.0
claude plugin install flow42@flow42
claude plugin update flow42@flow42
claude plugin uninstall flow42@flow42
claude plugin marketplace remove flow42
```

## Codex

Codex installs plugins from marketplace snapshots.

```sh
codex plugin marketplace add stefanriegel/flow42 --ref v1.0.0
codex plugin add flow42@flow42
codex plugin marketplace upgrade flow42
codex plugin remove flow42@flow42
codex plugin marketplace remove flow42
```

These V1 commands are not supported until the tag and checksum are published.
Before install, verify the signed `v1.0.0` tag and published checksum against the
resolved commit. After install, start a new harness session and invoke `flow42:init`. Installation
and removal were exercised locally; remote installation remains unsupported
until the marketplace manifest is merged to the public default branch.
