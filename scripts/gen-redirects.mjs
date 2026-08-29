// Emits a meta-refresh stub for every pre-migration Jekyll URL, so old inbound
// links and search results keep resolving. Files go into public/, which Astro
// copies verbatim — this lands them at the EXACT path, including the `.html`.
//
// Do NOT switch this to Astro's `redirects:` config. With the default
// build.format 'directory', a key like `/2017/05/14/slug.html` emits
// `dist/2017/05/14/slug.html/index.html` — a directory named "slug.html" — which
// does not reliably serve at the requested path.
//
// These are HTTP 200s with an instant refresh, not 301s. Cloudflare Bulk
// Redirects sit in front and serve real 301s; these are the fallback. See CLAUDE.md.
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';

const SITE = 'https://whitston.uk';
const MAP = '_migration/redirects.json';

const map = JSON.parse(await readFile(MAP, 'utf8'));
let n = 0;

for (const [from, to] of Object.entries(map)) {
	const target = SITE + to;
	const out = join('public', from.replace(/^\//, ''));
	await mkdir(dirname(out), { recursive: true });
	await writeFile(
		out,
		`<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>Redirecting…</title>
		<link rel="canonical" href="${target}" />
		<meta http-equiv="refresh" content="0; url=${target}" />
		<meta name="robots" content="noindex" />
	</head>
	<body>
		<p>This page has moved to <a href="${target}">${target}</a>.</p>
	</body>
</html>
`,
	);
	n++;
}

console.log(`gen-redirects: wrote ${n} redirect stubs into public/`);
