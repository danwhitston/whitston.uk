import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';
import { SITE_DESCRIPTION, SITE_TITLE } from '../consts';

// Served at /feed.xml, matching the path jekyll-feed used. Do not rename to
// rss.xml: feed readers do not follow redirects reliably, and moving the path
// drops existing subscribers silently rather than failing loudly.
export async function GET(context) {
	const posts = (await getCollection('blog')).sort(
		(a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf(),
	);
	return rss({
		title: SITE_TITLE,
		description: SITE_DESCRIPTION,
		site: context.site,
		items: posts.map((post) => ({
			title: post.data.title,
			description: post.data.description,
			pubDate: post.data.pubDate,
			link: `/blog/${post.id}/`,
		})),
	});
}
