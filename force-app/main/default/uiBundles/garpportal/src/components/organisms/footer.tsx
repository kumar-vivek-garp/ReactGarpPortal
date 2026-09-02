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
 * Two bands: brand, sitemap trigger and contact/social share the first (the
 * sitemap disclosed — see [FooterSitemap] for why), the legal line is the
 * second. Everything that was here before is still here; the 48 marketing-site
 * links simply no longer occupy ~640px of desktop and ~2,400px of mobile
 * beneath every page.
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
		/* `page-container`, not the old centred `max-w-footer` block: the footer
		   sits in the main column, so its content lines up with the page
		   content's own gutters instead of floating ~90px further in. */
		<footer className="border-t border-border bg-card py-6 font-sans text-foreground">
			<div className="page-container">
				{/*
				 * The sitemap trigger shares the brand band instead of holding a band
				 * of its own: logo left, pill centred, contact/social right. The
				 * `1fr auto 1fr` template is what centres the pill for real —
				 * `justify-between` only centres it when the side groups happen to be
				 * equal. Mobile keeps the old stacking order (brand, contact, pill)
				 * via the `order` utilities; the reveal panel is rendered by
				 * [FooterSitemap] *below* this whole band, at full width.
				 */}
				<FooterSitemap
					sections={FOOTER_NAV_SECTIONS}
					renderBar={(trigger) => (
						<div className="flex flex-col gap-6 lg:grid lg:grid-cols-[1fr_auto_1fr] lg:items-center lg:gap-10">
							<div className="order-1 flex flex-col items-start gap-3 lg:max-w-lg">
								<GarpLogoFull className="h-9 w-auto" />
								<p className="text-body text-muted-foreground">
									{FOOTER_TAGLINE}
								</p>
							</div>

							<div className="order-3 flex justify-center lg:order-2">
								{trigger}
							</div>

							<div className="order-2 flex flex-col items-start gap-4 lg:order-3 lg:items-end">
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
					)}
				/>
			</div>

			{/* Space, not a rule — see [FooterSitemap] on why the seams went. */}
			<div className="page-container mt-6">
				<FooterLegalBar links={FOOTER_LEGAL_LINKS} copyright={FOOTER_COPYRIGHT} />
			</div>
			<FooterBackToTop />
		</footer>
	)
}

export { Footer }
