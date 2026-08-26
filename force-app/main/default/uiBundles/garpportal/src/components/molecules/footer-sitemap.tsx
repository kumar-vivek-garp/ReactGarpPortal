import { useMemo, useState } from "react"
import { animated, useSpring } from "@react-spring/web"
import { ChevronDown } from "lucide-react"

import {
	FooterNavLinkList,
	FooterNavSectionView,
	FooterSectionDot,
} from "@/components/molecules/footer-nav-section"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { useMediaQuery } from "@/hooks/use-media-query"
import { usePrefersReducedMotion } from "@/hooks/use-prefers-reduced-motion"
import { useSpringPress } from "@/hooks/use-spring-press"
import { packFooterColumns } from "@/lib/footer-sitemap-columns"
import type { FooterNavSection } from "@/config/navigation/types"

/** Matches the `lg:` breakpoint the sitemap columns are written against. */
const DESKTOP_QUERY = "(min-width: 64rem)"

/** Five columns inside `max-w-footer` leaves ~230px each — wide enough that
 *  only the longest link titles wrap, which is where they wrapped before. */
const SITEMAP_COLUMNS = 5

const REVEAL_SPRING = { mass: 0.9, tension: 300, friction: 30 }

/**
 * Generous enough for the tallest column stack; the spring animates towards it
 * and `overflow-hidden` clips, so an over-estimate only affects the easing
 * curve, never the resting layout.
 */
const OPEN_MAX_HEIGHT = 2600
const SECTION_MAX_HEIGHT = 600

function useDisclosure(open: boolean, maxHeight: number, immediate: boolean) {
	const body = useSpring({
		opacity: open ? 1 : 0,
		maxHeight: open ? maxHeight : 0,
		config: REVEAL_SPRING,
		immediate,
	})
	const chevron = useSpring({
		transform: open ? "rotate(180deg)" : "rotate(0deg)",
		config: REVEAL_SPRING,
		immediate,
	})
	return { body, chevron }
}

/**
 * The chevron, in the same filled disc the brand band's "Contact Us" arrow
 * uses. Borrowed deliberately: it is already this footer's word for "this
 * takes you somewhere", so the sitemap does not need to introduce a second.
 */
function DisclosureChevron({
	style,
}: {
	style: ReturnType<typeof useDisclosure>["chevron"]
}) {
	return (
		<animated.span
			style={style}
			className="flex size-7 shrink-0 items-center justify-center rounded-full bg-primary text-primary-foreground"
			aria-hidden
		>
			<ChevronDown className="size-4" />
		</animated.span>
	)
}

/** One collapsible section — the sub-`lg` presentation of a sitemap column. */
function FooterSitemapAccordionItem({
	section,
	immediate,
}: {
	section: FooterNavSection
	immediate: boolean
}) {
	const [open, setOpen] = useState(false)
	const { body, chevron } = useDisclosure(open, SECTION_MAX_HEIGHT, immediate)
	const { bind, style } = useSpringPress()
	const contentId = `footer-section-${section.key}`

	return (
		<div className="overflow-hidden rounded-xl border border-border bg-card/50">
			<animated.button
				type="button"
				{...bind}
				style={style}
				onClick={() => setOpen((wasOpen) => !wasOpen)}
				aria-expanded={open}
				aria-controls={contentId}
				className="flex w-full cursor-pointer items-center justify-between gap-4 py-2.5 pr-2.5 pl-4 text-left font-sans text-section font-bold text-foreground"
			>
				<span className="flex items-center gap-2.5">
					<FooterSectionDot token={section.accentToken} />
					{section.label}
				</span>
				<DisclosureChevron style={chevron} />
			</animated.button>
			<animated.div id={contentId} className="overflow-hidden" style={body}>
				<FooterNavLinkList section={section} className="px-4 pb-4 pl-9" />
			</animated.div>
		</div>
	)
}

/**
 * The 48-link sitemap, disclosed rather than always-on.
 *
 * Both layouts exist because the failure mode differs by width, not by taste:
 *
 * - Below `lg` the columns can only stack, and nine expanded sections made the
 *   footer roughly 2,470px — five or six phone screens of links under every
 *   page. Each section collapses into its own card instead.
 * - At `lg` the columns fit side by side and are short enough to read, but the
 *   grid still cost ~430px on every page in an app whose real navigation is
 *   the top nav and sidebar. Every link here points at www.garp.org, so this
 *   is secondary marketing-site navigation: one disclosure, closed by default.
 *
 * Nothing is removed in either case — the same nine sections and the same
 * links are present in the DOM, one interaction away.
 *
 * There is deliberately no rule above or below the trigger. A full-bleed
 * horizontal line reads as a structural seam and made the footer look like
 * three stacked documents; the centred pill is its own object and needs no
 * frame to sit in. Legal is separated by space and a step down in weight.
 *
 * Columns come from [packFooterColumns] rather than the named
 * `grid-template-areas` this replaced. That template was copied from the legacy
 * footer and had to be hand-rebalanced whenever a section changed length, and
 * CSS multi-column — the obvious replacement — balances this particular set
 * badly. See that function for the measurement.
 */
function FooterSitemap({ sections }: { sections: FooterNavSection[] }) {
	const isDesktop = useMediaQuery(DESKTOP_QUERY)
	const reduceMotion = usePrefersReducedMotion()
	const [open, setOpen] = useState(false)
	const { body, chevron } = useDisclosure(open, OPEN_MAX_HEIGHT, reduceMotion)
	const { bind, style } = useSpringPress()
	const columns = useMemo(
		() => packFooterColumns(sections, SITEMAP_COLUMNS),
		[sections],
	)

	if (!isDesktop) {
		return (
			<nav aria-label="Site map" className="flex flex-col gap-2">
				{sections.map((section) => (
					<FooterSitemapAccordionItem
						key={section.key}
						section={section}
						immediate={reduceMotion}
					/>
				))}
			</nav>
		)
	}

	return (
		<nav aria-label="Site map">
			<div className="flex justify-center">
				<animated.button
					type="button"
					{...bind}
					style={style}
					onClick={() => setOpen((wasOpen) => !wasOpen)}
					aria-expanded={open}
					aria-controls="footer-sitemap-columns"
					className="flex cursor-pointer items-center gap-3 rounded-full border border-border bg-card/60 py-1.5 pr-1.5 pl-5 font-sans text-section font-bold text-foreground hover:bg-card"
				>
					{open ? "Hide site map" : "Site map"}
					<DisclosureChevron style={chevron} />
				</animated.button>
			</div>

			<animated.div
				id="footer-sitemap-columns"
				className="overflow-hidden"
				style={body}
			>
				{/*
				 * Keyed on `open` so the trail replays on every reveal. Left
				 * unkeyed it would run once, on the first render — while the
				 * panel is still closed — and every actual opening after that
				 * would be a plain curtain.
				 */}
				<StaggerReveal
					key={open ? "open" : "closed"}
					className="grid grid-cols-5 items-start gap-x-6 pt-8 pb-2"
				>
					{columns.map((column) => (
						<div key={column[0].key} className="flex flex-col gap-7">
							{column.map((section) => (
								<FooterNavSectionView key={section.key} section={section} />
							))}
						</div>
					))}
				</StaggerReveal>
			</animated.div>
		</nav>
	)
}

export { FooterSitemap }
