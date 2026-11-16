#!/usr/bin/env bash
# Fixture for the ShellCheck job: a script that passes.
set -euo pipefail

name="${1:-fixture}"
printf 'Hello, %s\n' "$name"
