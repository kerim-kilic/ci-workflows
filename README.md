# ci-workflows

Reusable GitHub Actions workflows for my website and the lab repositories that go with my articles. They run static
checks only: no cloud credentials, nothing planned, applied or deployed. Deployments stay in each repository.

| Workflow | What it runs |
| --- | --- |
| [`terraform.yml`](.github/workflows/terraform.yml) | `terraform fmt`, `terraform validate` per root module, TFLint, Trivy |
| [`repo-checks.yml`](.github/workflows/repo-checks.yml) | actionlint and zizmor on the workflows, ShellCheck on the scripts |

Tool versions are pinned in the workflows, so every repository that calls them lints with the same versions.

## Using them

Call them from a job with `uses:`, pinned to a release's full commit SHA, with the tag as a comment:

```yaml
permissions:
  contents: read

jobs:
  terraform:
    uses: kerim-kilic/ci-workflows/.github/workflows/terraform.yml@<commit-sha> # v1.0.0
    with:
      validate-directories: '["envs/dev", "envs/prod"]'

  repo:
    uses: kerim-kilic/ci-workflows/.github/workflows/repo-checks.yml@<commit-sha> # v1.0.0
    with:
      shellcheck-paths: scripts/*.sh
```

Dependabot's `github-actions` ecosystem bumps the SHA and the comment when a new release is tagged. Don't pass
`secrets: inherit`: these workflows need nothing beyond the default `GITHUB_TOKEN`, with read access to the contents.

Full callers are in [`examples/`](examples/).

### `terraform.yml` inputs

| Input | Default | Meaning |
| --- | --- | --- |
| `working-directory` | `terraform` | Directory with the Terraform code |
| `validate-directories` | `["."]` | JSON array of root modules to initialise and validate, relative to `working-directory` |
| `terraform-version` | `^1.11.0` | Version constraint for setup-terraform |
| `tflint-config` | `.tflint.hcl` | TFLint configuration, relative to `working-directory` |
| `tflint-recursive` | `false` | Lint every directory under `working-directory` as its own module |
| `trivy` | `true` | Scan with Trivy. Accept findings inline in the Terraform (`#trivy:ignore:<id>`) with a reason |

### `repo-checks.yml` inputs

| Input | Default | Meaning |
| --- | --- | --- |
| `shellcheck-paths` | empty (skipped) | Space-separated paths or globs, such as `scripts/*.sh`. Fails when nothing matches |
| `zizmor` | `true` | Audit the workflows with zizmor, using the caller's `.github/zizmor.yml` if there is one |

## Check names

A called job reports as `<caller job> / <called job>`, for example `terraform / tflint` or
`terraform / validate (envs/dev)`. When a repository switches to these workflows, update its required status checks
in the branch protection or ruleset at the same time, or pull requests will wait for checks that no longer report.

A job switched off by an input (`trivy: false`, empty `shellcheck-paths`) reports as skipped, which satisfies a required
check.

## Releases

1. Change the workflows on a branch. The [self-test](.github/workflows/self-test.yml) runs both workflows from that
   commit against the fixtures in `tests/`, and lints and audits this repository's own workflows.
2. Merge to `main` once it passes.
3. Tag the merge commit with a semantic version and publish a GitHub release with notes. A new required input, a removed
   input or a stricter check that can fail existing callers is a new major version.
4. Let Dependabot raise the bump in each calling repository, so every one of them runs the new version on its own branch
   before it reaches its `main`.

### Tool versions

Dependabot keeps the actions here current. It can't see the tool versions inside the workflows (the Docker image tags
in `run:` steps, and TFLint's `tflint_version`), so each one is also kept in `tools/<tool>/Dockerfile`. Those files are
never built: they are there for Dependabot's `docker` ecosystem to watch.

When Dependabot bumps one, the self-test's `tool-versions` job ([`tools/check-tool-versions.sh`](tools/check-tool-versions.sh))
fails and names the workflow line that still has the old version. Change that line on the Dependabot branch, let the
self-test pass, merge, and release. To bump a tool by hand, change both places in the same commit.

## Security

See [SECURITY.md](SECURITY.md) to report a problem privately.

## Licence

[MIT](LICENSE)
