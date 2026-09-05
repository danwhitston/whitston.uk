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

# Every page carries GitHub and LinkedIn links at every width (the header icons
# hide below 720px; the footer text links are what makes this hold on a phone).
for f in dist/index.html dist/about/index.html dist/blog/index.html dist/404.html \
         dist/blog/driving-sales-with-crm/index.html; do
  check_present 'href="https://www.linkedin.com/in/danielwhitston"' "$f" "LinkedIn link on ${f#dist/}"
done
check_present 'href="https://github.com/danwhitston"' dist/blog/index.html 'GitHub link on /blog/'

# Blog post titles carry the site-name suffix like every other page.
check_present '· Daniel Whitston</title>' dist/blog/tech-test-adventure-arbitrary/index.html 'blog post <title> has " · Daniel Whitston" suffix'

# --- Hostile-reader check (site-review-2026-09-05.md §5) ---
# Phrases withdrawn from the copy must not creep back in any form. "Model generations"
# blends two separate claims (application architecture vs the model layer); the true
# claim is four generations of architecture on one codebase, corrected by Daniel
# 31 Aug and again 5 Sept 2026. Scoped to the
# pages under Daniel's name; the 2010-2017 archive posts are historical writing.
copy_pages="dist/index.html dist/about/index.html dist/blog/index.html dist/404.html"
banned=(
  'first commercial LLM'
  "world's first"
  'twenty-five years'
  'same buyer'
  'one technology generation'
  'the point is'
  'is the point'
  'model generation'
  'generations of model'
  'model capability'
)
banned_hit=0
for phrase in "${banned[@]}"; do
  if grep -qiF -- "$phrase" $copy_pages; then
    note "FAIL" "banned phrase present: \"$phrase\""
    banned_hit=1
  fi
done
[ "$banned_hit" -eq 0 ] && note "ok" 'no withdrawn phrases in the copy pages' || fail=1

# Unfilled placeholders from a staged edit must never ship.
if grep -rqF -- '[END DATE]' dist --include='*.html'; then
  note "FAIL" 'unfilled [END DATE] placeholder in built output'
  fail=1
else
  note "ok" 'no unfilled placeholders'
fi

# House style: no em-dashes in copy under Daniel's name. Check the visible text of
# <main> only, since the blog layout and inline CSS are not copy.
dash_hit=0
for f in $copy_pages; do
  if tr '\n' ' ' < "$f" | sed -e 's/.*<main[^>]*>//' -e 's|</main>.*||' | grep -q $'\xe2\x80\x94'; then
    note "FAIL" "em-dash in ${f#dist/}"
    dash_hit=1
  fi
done
[ "$dash_hit" -eq 0 ] && note "ok" 'no em-dashes in the copy pages' || fail=1

# The profile strings are one source: strapline == meta description == og:description.
strap=$(tr '\n' ' ' < dist/index.html | grep -oE 'class="strapline"[^>]*>[^<]*' | sed -e 's/.*>//' -e 's/^ *//' -e 's/ *$//')
meta=$(grep -oE '<meta name="description" content="[^"]*"' dist/index.html | sed -e 's/.*content="//' -e 's/"$//')
if [ -n "$strap" ] && [ "$strap" = "$meta" ]; then
  note "ok" 'front-page strapline and meta description agree'
else
  note "FAIL" "front-page strapline and meta description differ"
  fail=1
fi

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
