# whitston.uk

Personal site for Daniel Whitston. Static, built with Astro, deployed to GitHub
Pages, fronted by Cloudflare.

Migrated from Jekyll in August 2026. `_migration/` holds the URL contract and is
**load-bearing at build time** — don't delete it.

## Build and run

```bash
nvm use            # Node 24, pinned in .nvmrc
npm install
npm run dev        # local dev server
npm run build      # prebuild generates redirect stubs, then astro build
npm run check:urls # verifies every pre-migration URL resolves in dist/
npm run check:content # structural and copy checks on dist/ (banned phrases, em-dashes, links)
```

CI uses `withastro/action@v6` with `node-version: 24`. **Keep that equal to
`.nvmrc`** — divergence is the classic works-on-my-machine failure.

## Profile strings live in one file

`src/config/profile.ts` holds every fact that describes Daniel to a machine: name,
strapline (also the site meta and OG description), About meta description, OG
card line, JSON-LD `jobTitle`/`worksFor`/location, email and social URLs. The
front page, About, `BaseHead`, `Header`, `Footer` and the OG image generator all
read from it. Change a fact there, not in a page. The prose that repeats those
facts in sentences lives in `src/components/Currently.astro` and
`src/pages/about.astro`.

`public/og.png` is **generated, not committed**: `scripts/gen-og-image.mjs` runs
in `prebuild` and renders `profile.name` and `profile.ogLine` in the site font
via satori, so the card cannot say something the page no longer says. The script
imports the `.ts` profile directly, which relies on Node's built-in type
stripping: keep `profile.ts` to erasable syntax (no enums).

## Copy rules

House style for anything under Daniel's name: no em-dashes (commas, brackets or
a semicolon instead), no numbers, dates or superlatives that are not on the CV or
LinkedIn, no unqualified "public sector", no customer names. `npm run
check:content` enforces the mechanical parts against `dist/`. The archive posts
are historical writing and are exempt.

## The URL preservation rule — read before changing routes

The site served dated, file-style URLs under Jekyll:

```
/2017/05/14/browser-testing-for-ruby-from.html
```

Posts now live at `/blog/<slug>/`. **Every old URL must keep resolving.** The full
list is `_migration/urls.txt`; the old→new map is `_migration/redirects.json`.

`scripts/gen-redirects.mjs` runs as `prebuild` and writes a meta-refresh stub into
`public/` for each old path. `public/` is copied verbatim, so a stub lands at the
exact path including the `.html`.

Do **not** replace this with Astro's `redirects:` config. With the default
`build.format: 'directory'`, a key like `/2017/05/14/slug.html` emits
`dist/2017/05/14/slug.html/index.html` — a *directory* named `slug.html` — which
does not reliably serve at the requested path. This was tested, not assumed.

The generated stubs are gitignored (`/public/20*/`); they are rebuilt every build.

If you add or rename a post, update `_migration/redirects.json` only if it maps an
old URL. Never remove entries — those are the contract.

## Redirects live in two places

1. **In this repo:** the `public/` stubs above. These are HTTP 200 with an instant
   meta refresh — search engines follow them, but they are not 301s.
2. **In Cloudflare:** Bulk Redirects / Redirect Rules serve real 301s at the edge
   for the same paths, before requests reach GitHub Pages. **This is configured in
   the Cloudflare dashboard, not in this repo**, so it is invisible here. If old
   URLs start 200-ing with a refresh instead of 301-ing, check whether those rules
   still exist.

The apex `whitston.uk` is Cloudflare-proxied; `whitston.org.uk` 301s to it at the
edge (that domain move happened in 2022). That redirect is a Page Rule on the
`whitston.org.uk` zone forwarding `*whitston.org.uk/*` to `https://whitston.uk/$2`,
so paths and query strings carry over; it was fixed to do so on 2026-09-05, having
dropped the path for several years before that.

## There is no feed

Jekyll served an Atom feed at `/feed.xml` and the migration initially kept it as
RSS. It was removed on 2026-08-30: the last post is from 2017, the site had been
static for years, and there were no subscribers worth preserving. `/feed.xml` now
404s and is listed as deliberately dropped in `_migration/urls.txt`. Don't add it
back, and don't add `@astrojs/rss` back either.

## The archive is deliberately unlinked from the home page

Nine posts from 2010–2017 on welfare policy, community organising and Ruby
tooling. They stay online and crawlable — the redirects have to land somewhere
real — but they are not current work. The home page does not list them and the
main nav does not link them; `/blog/` is reachable from the footer only. This is
intentional, not an oversight.

## Deploying

Pushing to `main` triggers `.github/workflows/deploy.yml`. Repo Settings → Pages →
Source must be **GitHub Actions** (not "Deploy from a branch").

After a deploy that changes old URLs, **purge the Cloudflare cache** — stale edge
copies will otherwise mask both successes and failures.

## Astro documentation

- [Routing](https://docs.astro.build/en/guides/routing/)
- [Content collections](https://docs.astro.build/en/guides/content-collections/)
- [Astro components](https://docs.astro.build/en/basics/astro-components/)
