# Security policy

These are reusable GitHub Actions workflows that my own repositories call to lint and scan their code. They run with
read-only access to the calling repository and no cloud credentials. There is no bug bounty, and I reply on a
best-effort basis.

## Reporting a problem

If you find something that looks like a security problem, please tell me privately instead of opening a public issue.
Examples: a way for input from a calling repository to run commands in a workflow, a workflow asking for more
permissions than it needs, or a tool or action that isn't pinned the way the README says.

- Use GitHub's private vulnerability reporting: the **Security** tab of this repository, then **Report a vulnerability**.
- Or email [hello@kerim-kilic.com](mailto:hello@kerim-kilic.com).

Please say what you found, where, and how to reproduce it.

## What to expect

I'll acknowledge your report as soon as I can, fix real problems promptly in a new release, and credit you if you'd
like.

## Scope

- **In scope:** the workflows, scripts and configuration in this repository.
- **Out of scope:** the tools and actions these workflows run (actionlint, zizmor, ShellCheck, Terraform, TFLint, Trivy,
  the GitHub and HashiCorp actions) and GitHub itself: please report problems in those to their maintainers.
