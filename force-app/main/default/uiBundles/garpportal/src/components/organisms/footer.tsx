import { ArrowRight } from "lucide-react"

import { GarpLogoFull } from "@/components/atoms/garp-logo-full"
import { FooterBackToTop } from "@/components/molecules/footer-back-to-top"
import { FooterLegalBar } from "@/components/molecules/footer-legal-bar"
import { FooterNavSectionView } from "@/components/molecules/footer-nav-section"
import { FooterSocialLinks } from "@/components/molecules/footer-social-links"
import {
	FOOTER_CONTACT_LINK,
	FOOTER_COPYRIGHT,
	FOOTER_LEGAL_LINKS,
	FOOTER_SOCIAL_LINKS,
	FOOTER_TAGLINE,
} from "@/config/navigation/footer-misc-links"
import { FOOTER_NAV_SECTIONS } from "@/config/navigation/footer-nav-sections"

// The full lockup, matching the live footer. It used to be a dark-ink PNG,
// which was invisible against this footer's own dark-mode gradient; the inline
// version takes its colour from `text-foreground` and so works in both themes.

// Maps each section's data key to the live footer's own named grid-area (see
  // the `.footer-sections-grid` rule in styles/layout.css) — literal strings, not
// interpolated, so Tailwind's build-time class scanner can see them.
const SECTION_GRID_AREA_CLASS: Record<string, string> = {
	frm: "lg:[grid-area:frm]",
	scr: "lg:[grid-area:scr]",
	rai: "lg:[grid-area:rai]",
	membership: "lg:[grid-area:membership]",
	resources: "lg:[grid-area:resources]",
	events: "lg:[grid-area:events]",
	"additional-education": "lg:[grid-area:education]",
	"about-us": "lg:[grid-area:about]",
	"industry-engagement": "lg:[grid-area:industry]",
}

function Footer() {
	return (
		<footer className="bg-linear-to-b from-surface-gradient-start to-surface-gradient-end px-8 py-10 font-sans text-foreground">
			<div className="footer-sections-grid footer-container">
				<div className="flex flex-col gap-4 lg:[grid-area:logo]">
					<GarpLogoFull className="h-9 w-auto" />
					<p className="text-body text-foreground">{FOOTER_TAGLINE}</p>
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

				{FOOTER_NAV_SECTIONS.map((section) => (
					<FooterNavSectionView key={section.key} section={section} className={SECTION_GRID_AREA_CLASS[section.key]} />
				))}
			</div>

			<div className="footer-container mt-10">
				<FooterLegalBar links={FOOTER_LEGAL_LINKS} copyright={FOOTER_COPYRIGHT} />
			</div>
			<FooterBackToTop />
		</footer>
	)
}

export { Footer }
