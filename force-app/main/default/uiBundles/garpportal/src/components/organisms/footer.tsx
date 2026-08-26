import { ArrowRight } from "lucide-react"

import { GarpLogoFull } from "@/components/atoms/garp-logo-full"
import { FooterBackToTop } from "@/components/molecules/footer-back-to-top"
import { FooterLegalBar } from "@/components/molecules/footer-legal-bar"
import { FooterSitemap } from "@/components/molecules/footer-sitemap"
import { FooterSocialLinks } from "@/components/molecules/footer-social-links"
import {
	FOOTER_CONTACT_LINK,
	FOOTER_COPYRIGHT,
	FOOTER_LEGAL_LINKS,
	FOOTER_SOCIAL_LINKS,
	FOOTER_TAGLINE,
} from "@/config/navigation/footer-misc-links"
import { FOOTER_NAV_SECTIONS } from "@/config/navigation/footer-nav-sections"

/**
 * The portal footer.
 *
 * Three bands, in descending order of how often they are actually wanted: the
 * brand and how to reach GARP, then the sitemap (disclosed — see
 * [FooterSitemap] for why), then the legal line. Everything that was here
 * before is still here; the 48 marketing-site links simply no longer occupy
 * ~640px of desktop and ~2,400px of mobile beneath every page.
 *
 * The lockup is the inline [GarpLogoFull] rather than a PNG: it takes its
 * colour from `text-foreground`, so it survives this footer's dark-mode
 * surface, which the dark-ink asset did not.
 *
 * Painted as chrome, not canvas: the same card-white surface as the toolbar
 * and sidebar, separated from the dulled main panel by a hairline — one frame
 * around the content, matching www.garp.org's white-chrome look.
 */
function Footer() {
	return (
		<footer className="border-t border-border bg-card px-8 py-8 font-sans text-foreground">
			<div className="footer-container flex flex-col gap-6 pb-8 lg:flex-row lg:items-start lg:justify-between lg:gap-10">
				<div className="flex flex-col items-start gap-3 lg:max-w-lg">
					<GarpLogoFull className="h-9 w-auto" />
					<p className="text-body text-muted-foreground">{FOOTER_TAGLINE}</p>
				</div>

				<div className="flex flex-col items-start gap-4 lg:items-end">
					<a
						href={FOOTER_CONTACT_LINK.url}
						className="flex items-center gap-2 text-body font-black hover:underline"
					>
						{FOOTER_CONTACT_LINK.title}
						<span className="flex size-6 items-center justify-center rounded-full bg-primary text-primary-foreground">
							<ArrowRight className="size-3.5" />
						</span>
					</a>
					<FooterSocialLinks links={FOOTER_SOCIAL_LINKS} />
				</div>
			</div>

			<div className="footer-container">
				<FooterSitemap sections={FOOTER_NAV_SECTIONS} />
			</div>

			{/* Space, not a rule — see [FooterSitemap] on why the seams went. */}
			<div className="footer-container mt-10">
				<FooterLegalBar links={FOOTER_LEGAL_LINKS} copyright={FOOTER_COPYRIGHT} />
			</div>
			<FooterBackToTop />
		</footer>
	)
}

export { Footer }
