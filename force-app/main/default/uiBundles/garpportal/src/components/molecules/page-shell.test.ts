import { describe, expect, it } from "vitest"

import {
	PAGE_SHELL,
	PAGE_STICKY_HEADER,
	PAGE_STICKY_SUBHEADER,
} from "@/components/molecules/page-shell"

describe("the page shell", () => {
	it("carries no height and no overflow of its own", () => {
		/*
		 * The regression this file exists for. Every panel used to pin itself to
		 * `h-[calc(100vh-4rem)]` and open a scroller inside it, which stacked a
		 * second scroll container inside the document's and left the footer
		 * outside all twenty-four of them. The shell owns the only scroller now;
		 * a page that re-derives the viewport height has undone that.
		 */
		expect(PAGE_SHELL).not.toMatch(/100vh|overflow-|min-h-0|flex-1/)
	})
})

describe("a pinned page header", () => {
	/*
	 * `sticky` alone is not enough: the header is opaque only if it also pulls
	 * back over `PageContainer`'s padding. Without the bleed the page shows
	 * through a band above the header and a strip down each side while it is
	 * pinned, which reads as a rendering fault rather than as depth.
	 */
	it.each([
		["header", PAGE_STICKY_HEADER],
		["subheader", PAGE_STICKY_SUBHEADER],
	])("pins %s opaquely, bleeding over the container's padding", (_, classes) => {
		expect(classes).toContain("sticky")
		expect(classes).toContain("top-0")
		expect(classes).toContain("bg-background")
		expect(classes).toContain("-mt-6")
		expect(classes).toContain("pt-6")
		expect(classes).toContain("-mx-shell-gutter")
		expect(classes).toContain("px-shell-gutter")
	})

	it("holds the gap below itself, where a pinned header must", () => {
		/*
		 * This gap used to be the content's own `mt-6` / `mt-4`. A margin on the
		 * content scrolls away with the content, so the first card would touch
		 * the pinned title; the padding has to be on the header instead.
		 */
		expect(PAGE_STICKY_HEADER).toContain("pb-6")
		expect(PAGE_STICKY_SUBHEADER).toContain("pb-4")
	})
})
