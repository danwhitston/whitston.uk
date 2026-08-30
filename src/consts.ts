// Global site data, imported anywhere via `import { ... } from '../consts'`.
export const SITE_TITLE = 'Daniel Whitston';

// Has to stand alone in a Google result and a LinkedIn link preview. Matches the
// front-page strapline word for word (2026-08-30 brief §1e). Kept under ~155
// chars so Google doesn't truncate it mid-clause.
export const SITE_DESCRIPTION =
	'Founding CTO at AutogenAI. Shipped a production LLM product before ChatGPT launched; the architecture has survived four model generations since. London.';

// Site-level Open Graph image (public/og.png), used wherever a page supplies none.
export const OG_IMAGE = 'og.png';
