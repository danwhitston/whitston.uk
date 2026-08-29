#!/usr/bin/env bash
# Verifies every pre-migration URL still resolves in the built output.
# Usage: npm run build && npm run check:urls
set -uo pipefail

fail=0
while read -r u; do
  case "$u" in
    /)  f="dist/index.html" ;;
    */) f="dist${u}index.html" ;;
    *)  f="dist${u}" ;;
  esac
  if [ -f "$f" ]; then
    printf '  ok   %s\n' "$u"
  else
    printf '  MISS %s\n' "$u"
    fail=1
  fi
done < <(grep -E '^/' _migration/urls.txt)

if [ "$fail" -ne 0 ]; then
  echo "FAILED: at least one pre-migration URL is missing from dist/" >&2
  exit 1
fi
echo "All pre-migration URLs resolve."
