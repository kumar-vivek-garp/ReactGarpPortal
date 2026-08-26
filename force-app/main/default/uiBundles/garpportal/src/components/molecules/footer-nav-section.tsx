import { cn } from "@/lib/utils"
import type { FooterNavSection, NavAccentToken } from "@/config/navigation/types"

/**
 * Literal classes — Tailwind cannot see an interpolated `bg-${token}`. Only the
 * swatch is needed here: the accent is a dot with nothing written on it, so no
 * `-foreground` partner is in play.
 */
const ACCENT_DOT_CLASS: Record<NavAccentToken, string> = {
	"garp-cyan": "bg-garp-cyan",
	"garp-saffron": "bg-garp-saffron",
	"rai-orange": "bg-rai-orange",
	"deep-purple": "bg-deep-purple",
	"bright-purple": "bg-bright-purple",
	"dark-blue-gray": "bg-dark-blue-gray",
}

/**
 * The section's brand marker.
 *
 * Nine bold headings in a row all read at the same weight, which is what made
 * the old sitemap a wall. A 6px swatch gives each column a fixed point to find,
 * and because the hue is the mega-menu's own, the footer's FRM heading and the
 * nav's FRM tab are visibly the same thing.
 */
function FooterSectionDot({ token }: { token: NavAccentToken }) {
	return (
		<span
			className={cn("size-1.5 shrink-0 rounded-full", ACCENT_DOT_CLASS[token])}
			aria-hidden
		/>
	)
}

/**
 * The link list of one footer section, without its heading.
 *
 * Split out because the two footer layouts label the same list differently:
 * the desktop sitemap gives it an `h3`, the mobile accordion gives it a
 * disclosure button. Only the labelling differs — the list itself must not
 * fork, or the two audiences drift apart.
 */
function FooterNavLinkList({
	section,
	className,
}: {
	section: FooterNavSection
	className?: string
}) {
	return (
		<ul className={cn("flex flex-col gap-1.5", className)}>
			{section.links.map((link) => (
				<li key={link.title}>
					<a
						href={link.url}
						target={link.openInNewTab ? "_blank" : undefined}
						rel={link.openInNewTab ? "noopener noreferrer" : undefined}
						className="text-body text-muted-foreground hover:text-foreground hover:underline"
					>
						{link.title}
					</a>
				</li>
			))}
		</ul>
	)
}

/** Heading + links — the shape used inside the desktop sitemap columns. */
function FooterNavSectionView({
	section,
	className,
}: {
	section: FooterNavSection
	className?: string
}) {
	return (
		<div className={cn(className)}>
			<h3 className="mb-2.5 flex items-center gap-2 font-sans text-section font-bold text-foreground">
				<FooterSectionDot token={section.accentToken} />
				{section.label}
			</h3>
			<FooterNavLinkList section={section} className="pl-3.5" />
		</div>
	)
}

export { FooterNavLinkList, FooterNavSectionView, FooterSectionDot }
