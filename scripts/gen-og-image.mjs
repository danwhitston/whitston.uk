// Generates public/og.png — the single site-level Open Graph card: plain and
// legible, name and one line. This is what appears when the link is pasted
// into LinkedIn or Slack.
//
// Run manually after changing the text: `node scripts/gen-og-image.mjs`.
// Deliberately NOT part of the build: the output is committed, so CI needs no
// font stack and the build stays fast.
import { writeFile } from 'node:fs/promises';
import sharp from 'sharp';

const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630">
	<rect width="1200" height="630" fill="#fdfdfd"/>
	<rect x="0" y="0" width="1200" height="10" fill="#2337ff"/>
	<text x="90" y="290" font-family="DejaVu Sans, Helvetica, Arial, sans-serif"
		font-size="76" font-weight="bold" fill="#111820">Daniel Whitston</text>
	<text x="90" y="365" font-family="DejaVu Sans, Helvetica, Arial, sans-serif"
		font-size="36" fill="#3d4663">Employee #1 and founding CTO at AutogenAI</text>
	<text x="90" y="545" font-family="DejaVu Sans, Helvetica, Arial, sans-serif"
		font-size="28" fill="#8492a6">whitston.uk</text>
</svg>`;

await writeFile('public/og.png', await sharp(Buffer.from(svg)).png().toBuffer());
console.log('gen-og-image: wrote public/og.png (1200x630)');
