import type { FooterNavSection } from "@/config/navigation/types"

/**
 * Splits the footer's sections into balanced sitemap columns.
 *
 * CSS multi-column was the obvious answer and is the wrong one here. It fills
 * columns in document order and cannot reorder, and the three tall programme
 * sections (FRM, SCR, RAI — nine rows each) come first: each one claims a whole
 * column, and the six short sections behind them are crammed into the
 * remaining two. Measured, that produced a 528px block where a balanced one is
 * about 350px.
 *
 * So the packing is done here instead: longest-processing-time-first, the
 * standard greedy approximation for multiway number partitioning. Each section
 * weighs one row per link plus one for its heading.
 *
 * Reading order is restored afterwards — bins are emitted, and each bin's
 * contents ordered, by the section's original index — so the result is
 * balanced *and* still reads FRM, SCR, RAI, … left to right. Anything else
 * makes the footer look shuffled every time a link is added.
 *
 * Wrapped link titles cost extra rows this cannot see, so the balance is
 * approximate. It only has to beat "one tall section per column", which it
 * does comfortably.
 */
export function packFooterColumns(
	sections: FooterNavSection[],
	columnCount: number,
): FooterNavSection[][] {
	if (columnCount < 1) return [sections]

	const weighted = sections.map((section, index) => ({
		section,
		index,
		// Heading occupies a row too, so a one-link section is not free.
		weight: section.links.length + 1,
	}))

	const bins = Array.from({ length: columnCount }, () => ({
		total: 0,
		items: [] as typeof weighted,
	}))

	const byWeightDesc = [...weighted].sort(
		// Ties broken by original index so the packing is deterministic.
		(a, b) => b.weight - a.weight || a.index - b.index,
	)

	for (const item of byWeightDesc) {
		const lightest = bins.reduce((min, bin) => (bin.total < min.total ? bin : min))
		lightest.items.push(item)
		lightest.total += item.weight
	}

	return bins
		.filter((bin) => bin.items.length > 0)
		.map((bin) => [...bin.items].sort((a, b) => a.index - b.index))
		.sort((a, b) => a[0].index - b[0].index)
		.map((items) => items.map((item) => item.section))
}
