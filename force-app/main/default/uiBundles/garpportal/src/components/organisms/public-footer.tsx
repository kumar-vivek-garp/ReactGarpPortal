import { GarpLogoMark } from "@/components/atoms/garp-logo-mark"
import { FooterLegalBar } from "@/components/molecules/footer-legal-bar"
import {
	FOOTER_COPYRIGHT,
	FOOTER_LEGAL_LINKS,
	FOOTER_TAGLINE,
} from "@/config/navigation/footer-misc-links"

/**
 * The guest footer — two bands, per the 2027 Reg Redesign: brand and tagline on
 * the dark chrome band, legal line on a light strip below it.
 *
 * A separate component rather than a prop on [Footer], because it is not that
 * footer restyled — it is a deliberately smaller one. The portal footer's
 * sitemap disclosure, contact link, social row and back-to-top are all absent
 * here, which is the point: this sits under a checkout, and every one of them
 * is a way to leave it half-finished. [Footer] is untouched, so the signed-in
 * portal keeps all of it.
 *
 * Nothing here is new artwork. The design's footer logo is 182.33 × 44, which
 * is [GarpLogoMark]'s viewBox exactly, so it is that component knocked out —
 * its cyan eye survives via `fill-garp-cyan` while the wordmark takes
 * `currentColor` from the band. The legal line is the existing
 * [FooterLegalBar], whose links-left / copyright-right layout is already what
 * the design shows.
 *
 * Worn by every page under `_publicFormLayout`, the guest 404 included — a
 * guest sees one footer whichever public page they land on.
 */
function PublicFooter() {
	return (
		/* Same surface the portal footer uses, so a guest page and a signed-in
		   page put the same chrome under the fold and both follow the theme.
		   The two bands are separated by spacing rather than by colour — the
		   portal footer does the same. */
		<footer className="border-t border-border bg-card font-sans text-foreground">
			<div className="page-container flex flex-col gap-4 py-8 lg:flex-row lg:items-center lg:justify-between lg:gap-10">
				{/* Inline SVG, so the wordmark takes its colour from the surface and
				    needs no light/dark variant. */}
				<GarpLogoMark className="h-11 w-auto shrink-0" />
				<p className="text-body text-muted-foreground lg:max-w-lg lg:text-right">
					{FOOTER_TAGLINE}
				</p>
			</div>

			<div className="page-container mt-2 border-t border-border pt-4 pb-6">
				<FooterLegalBar
					links={FOOTER_LEGAL_LINKS}
					copyright={FOOTER_COPYRIGHT}
				/>
			</div>
		</footer>
	)
}

export { PublicFooter }
