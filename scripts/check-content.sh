#!/usr/bin/env bash
# Structural checks on the built output: metadata that must be present.
# Usage: npm run build && npm run check:content
set -uo pipefail

fail=0
note() { printf '  %-6s %s\n' "$1" "$2"; }

# --- Required elements ---
check_present() {
  if grep -rqF "$1" "$2" 2>/dev/null; then
    note "ok" "$3"
  else
    note "FAIL" "$3"
    fail=1
  fi
}

check_present '"@type":"Person"'          dist/index.html      'JSON-LD Person on front page'
check_present 'og:image'                  dist/index.html      'og:image on front page'
check_present 'rel="canonical"'           dist/index.html      'canonical on front page'
check_present 'rel="canonical"'           dist/about/index.html 'canonical on /about'
check_present 'rel="canonical"'           dist/blog/driving-sales-with-crm/index.html 'canonical on a sample post'
check_present 'mailto:dan@whitston.uk'    dist/index.html      'contact link resolves to dan@whitston.uk'
check_present 'sitemap-index.xml'         dist/robots.txt      'robots.txt points at the sitemap'

[ -f dist/og.png ] && note "ok" 'og.png present' || { note "FAIL" 'og.png present'; fail=1; }

# --- Whitespace swallowed before an inline link ---
# Astro's compressor collapses a newline before an inline <a> to nothing, not to
# a space, so `reach me at\n<a ...>` renders as "reach me at<a". Invisible in the
# source; only shows in the built output. Keep the text and the opening tag on
# the same line.
jammed=$(grep -rhoE '[a-z]{2,}<a href' dist --include='*.html' 2>/dev/null | sort -u)
if [ -n "$jammed" ]; then
  note "FAIL" "missing space before an inline link: $(echo "$jammed" | tr '\n' ' ')"
  fail=1
else
  note "ok" 'no text jammed against an inline link'
fi

# --- About page length ---
# Count the prose in <main> only. Counting the whole document swept in the
# header and footer chrome (~100 words), so the number never matched the word
# target the brief actually sets for the body copy. Target is ~430 words
# (site-brief-astro-2026-08-29.md §4); 500 leaves headroom without letting the
# page quietly double.
# Output is minified onto two lines and Astro adds a scoped-style attribute, so
# match `<main` with attributes and flatten newlines first.
words=$(tr '\n' ' ' < dist/about/index.html \
  | sed -e 's/.*<main[^>]*>//' -e 's|</main>.*||' -e 's/<[^>]*>/ /g' | wc -w)
if [ "$words" -eq 0 ]; then
  # Extraction failed rather than the page being empty; never pass this silently.
  note "FAIL" "/about: could not extract <main> to count words"
  fail=1
elif [ "$words" -le 500 ]; then
  note "ok" "/about body is ${words} words (target ~430)"
else
  note "FAIL" "/about body is ${words} words, over the ~430 target"
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "FAILED: structural content checks" >&2
  exit 1
fi
echo "Structural content checks pass."
