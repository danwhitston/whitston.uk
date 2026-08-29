// Generates public/og.png, the single site-level Open Graph card: plain and
// legible, name and one line. This is what appears when the link is pasted into
// LinkedIn or Slack.
//
// Runs as part of `prebuild`, so the card is always rendered from the current
// src/config/profile.ts and can never say something the page no longer says.
// Text is set in the site font (Atkinson Hyperlegible, from src/assets/fonts) via
// satori, which rasterises glyphs itself, so CI needs no system fonts.
import { readFile, writeFile } from 'node:fs/promises';
import satori from 'satori';
import sharp from 'sharp';
import { profile } from '../src/config/profile.ts';

const [regular, bold] = await Promise.all([
	readFile(new URL('../src/assets/fonts/atkinson-regular.woff', import.meta.url)),
	readFile(new URL('../src/assets/fonts/atkinson-bold.woff', import.meta.url)),
]);

const el = (type, style, children) => ({ type, props: { style, children } });

const svg = await satori(
	el(
		'div',
		{
			width: '100%',
			height: '100%',
			display: 'flex',
			flexDirection: 'column',
			justifyContent: 'center',
			padding: '0 90px',
			background: '#fdfdfd',
			borderTop: '10px solid #2337ff',
			fontFamily: 'Atkinson',
		},
		[
			el('div', { fontSize: 76, fontWeight: 700, color: '#111820', marginBottom: 18 }, profile.name),
			el('div', { fontSize: 36, color: '#3d4663' }, profile.ogLine),
			el('div', { fontSize: 28, color: '#8492a6', marginTop: 150 }, 'whitston.uk'),
		],
	),
	{
		width: 1200,
		height: 630,
		fonts: [
			{ name: 'Atkinson', data: regular, weight: 400, style: 'normal' },
			{ name: 'Atkinson', data: bold, weight: 700, style: 'normal' },
		],
	},
);

await writeFile('public/og.png', await sharp(Buffer.from(svg)).png().toBuffer());
console.log(`gen-og-image: wrote public/og.png (1200x630): "${profile.ogLine}"`);
