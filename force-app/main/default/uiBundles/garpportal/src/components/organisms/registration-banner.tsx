import type { MegaMenuHeading } from "@/config/navigation/types"
import type { ProgramChrome } from "@/config/program-chrome"
import { MegaMenuHeadingText } from "@/components/molecules/mega-menu-heading"
import { cn } from "@/lib/utils"

/**
 * The programme banner above a guest registration form — artwork, the
 * certification seal, and the page's `h1`.
 *
 * It carries the `h1` because on the public route this is the only heading the
 * document has, and that page is linked from GARP marketing email. The sticky
 * submit bar below drops its own title when this is on screen
 * (`titleInBanner`), so the page never has two.
 *
 * Full-bleed by construction: the outer band has no gutter and the inner row
 * uses `page-container`, so the seal's left edge lands on the same gutter as
 * the form cards beneath it. Rendered inside `<main>` rather than above it, so
 * the heading sits within the landmark it titles.
 *
 * The artwork is an `<img>` rather than a CSS background: it is photographic
 * with a line pattern over it, no gradient reproduces it, and an element can
 * carry `object-cover` plus async decoding. Both images are decorative — the
 * heading already names the programme — so neither takes an accessible name.
 *
 * **The banner art is stored PRE-CROPPED to this strip's aspect ratio, and it
 * has to stay that way.** Figma composites the source art (1600×999) at
 * `top: -46px` inside a 166px window, so what the design actually shows is a
 * narrow band near the TOP of the image — which is where FRM's rust bloom
 * sits. Dropping the full-height source in here instead leaves `object-cover`
 * centring vertically on the plain teal middle, and the bloom disappears with
 * no error: the banner just looks flatter than the design. Cropping the asset
 * (rather than dialling in an `object-position` percentage) keeps the framing
 * correct at every width and cut the file from 144KB to 44KB.
 *
 * Knockout text uses `text-corporate-navy-foreground`, the mode-invariant white
 * `AuthShell` uses for the same reason: the art behind it is dark in either
 * theme, so the tint must not follow `--toolbar-foreground`.
 */
function RegistrationBanner({
	chrome,
	heading,
	className,
}: {
	chrome: ProgramChrome
	heading: MegaMenuHeading
	className?: string
}) {
	return (
		<div
			className={cn(
				"relative isolate flex min-h-30 items-center overflow-hidden app:min-h-41.5",
				className,
			)}
		>
			<img
				src={chrome.bannerArt}
				alt=""
				aria-hidden="true"
				decoding="async"
				fetchPriority="high"
				className="absolute inset-0 -z-10 size-full object-cover"
			/>

			<div className="page-container flex items-center gap-4 py-5 sm:gap-6">
				<img
					src={chrome.seal}
					alt=""
					aria-hidden="true"
					width={117}
					height={116}
					decoding="async"
					fetchPriority="high"
					className="size-16 shrink-0 object-contain sm:size-20 app:size-29.25"
				/>
				{/*
				 * `font-sans`, not the heading font: the designs set this in Nunito
				 * Sans ExtraBold, and `base.css` would otherwise give an h1 Klinic
				 * Slab. `text-title` is the existing 1.875rem/30px semantic role and
				 * is exactly what FRM's and SCR's frames set; stepped down below
				 * `app:` so the longest title (SCR's) does not wrap to three lines on
				 * a phone. RAI's frame asks for 40px, which it supplies as
				 * `titleSizeClass` — only the desktop step varies, since the phone
				 * sizes are driven by wrapping rather than by the design.
				 */}
				<h1
					className={cn(
						"font-sans text-lg font-extrabold text-corporate-navy-foreground sm:text-2xl",
						chrome.titleSizeClass ?? "app:text-title",
					)}
				>
					<MegaMenuHeadingText heading={heading} />
				</h1>
			</div>
		</div>
	)
}

export { RegistrationBanner }
