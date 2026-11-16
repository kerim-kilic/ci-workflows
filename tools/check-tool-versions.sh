#!/usr/bin/env bash
# Checks that the reusable workflows use the tool versions in tools/<tool>/Dockerfile.
#
# The workflows can't read those files at run time (a caller only checks out its own repository), so each version is
# written in two places. Dependabot bumps the Dockerfile; this check then fails until the workflow says the same.
# Run from the repository root.
set -euo pipefail

workflows=(.github/workflows/terraform.yml .github/workflows/repo-checks.yml)
status=0

for dockerfile in tools/*/Dockerfile; do
  tool=$(basename "$(dirname "$dockerfile")")
  image_ref=$(sed -n 's/^FROM[[:space:]]\{1,\}\([^[:space:]]*\).*/\1/p' "$dockerfile" | head -n 1)
  if [ -z "$image_ref" ]; then
    echo "::error file=$dockerfile::No FROM line found."
    status=1
    continue
  fi
  image=${image_ref%:*}
  tag=${image_ref##*:}

  if [ "$tool" = "tflint" ]; then
    # Installed by setup-tflint, so the workflow names the version, not the image.
    pattern='tflint_version: [^[:space:]]+'
    expected="tflint_version: $tag"
  else
    escaped=$(printf '%s' "$image" | sed 's/[][\.*^$/]/\\&/g')
    pattern="${escaped}:[^[:space:]\"']+"
    expected=$image_ref
  fi

  found=$(grep -ohE "$pattern" "${workflows[@]}" | sort -u || true)
  if [ -z "$found" ]; then
    echo "::error file=$dockerfile::$tool isn't used in ${workflows[*]}. Remove $dockerfile or use the tool."
    status=1
  elif [ "$found" != "$expected" ]; then
    echo "::error file=$dockerfile::$tool: $dockerfile has '$expected', the workflows have '$(echo "$found" | paste -sd ' ')'. Make them match."
    status=1
  else
    echo "$tool: $expected"
  fi
done

exit "$status"
