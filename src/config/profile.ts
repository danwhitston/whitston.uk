// The one place the profile facts live. Every string that describes Daniel to a
// search engine, a link preview or a structured-data consumer derives from here:
// the front-page strapline, both meta descriptions, the JSON-LD Person, the header
// and footer links, and the OG image (scripts/gen-og-image.mjs reads this file at
// build time). A role change is an edit to this file plus the prose in
// src/components/Currently.astro and src/pages/about.astro.
//
// Keep the syntax erasable (no enums, no parameter properties): Node imports this
// file directly with type stripping, not through Vite.

export const profile = {
	name: 'Daniel Whitston',

	// Front-page strapline. Doubles as the site meta and OG description, so it has
	// to stand alone in a Google result and a LinkedIn link preview. Kept under
	// ~155 chars so Google doesn't truncate it mid-clause.
	strapline:
		'Founding CTO at AutogenAI. Shipped a production LLM product before ChatGPT launched; the architecture has survived four model generations since. London.',

	// /about meta description. This is where the phrase "Founding CTO" sits for
	// recruiter search, since it does not sit naturally in the prose.
	aboutDescription:
		'Founding CTO at AutogenAI, employee #1 since the first commit in July 2022. Previously CTO at Policy in Practice.',

	// One line under the name on the OG card.
	ogLine: 'Employee #1 and founding CTO at AutogenAI',

	// JSON-LD Person. Both may be null, in which case the key is omitted.
	jobTitle: 'CTO' as string | null,
	worksFor: { name: 'AutogenAI', url: 'https://autogenai.com/' } as { name: string; url: string } | null,

	// Matches LinkedIn. Do not change for a house move.
	location: { locality: 'London', country: 'GB' },

	email: 'dan@whitston.uk',
	links: {
		github: 'https://github.com/danwhitston',
		linkedin: 'https://www.linkedin.com/in/danielwhitston',
	},

	// Site-level Open Graph image, generated into public/ at build time.
	ogImage: 'og.png',
};

export const SITE_URL = 'https://whitston.uk';
