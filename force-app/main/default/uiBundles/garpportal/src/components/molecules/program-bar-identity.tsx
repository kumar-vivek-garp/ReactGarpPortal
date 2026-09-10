import type { MegaMenuHeading } from "@/config/navigation/types"
import type { ProgramChrome } from "@/config/program-chrome"
import { MegaMenuHeadingText } from "@/components/molecules/mega-menu-heading"
import { REGISTRATION_BAR_TITLE } from "@/components/forms/registration-shell"
import { cn } from "@/lib/utils"

/**
 * The programme's seal and title, as they appear in a signed-in registration or
 * exam-setup bar.
 *
 * A molecule rather than inline JSX because three places render it and they
 * must not drift: the registration bar, the Exam Setup bar, and the loading
 * skeleton that mirrors both. That skeleton exists precisely so the page does
 * not step sideways when the payload lands, and it has already been wrong for
 * that reason once.
 *
 * The seal is decorative: the `h1` beside it names the programme in full, so
 * announcing the image as well would just say it twice. `chrome` is optional
 * and the seal simply does not render without it — programmes with no designed
 * chrome keep the plain bar, which is the same fallback the guest pages use.
 *
 * There is no banner here on purpose. Unlike the guest banner, which carries
 * only white text, this bar also holds the purple total and the purple submit;
 * artwork behind those makes them muddy. The identity comes from the seal plus
 * `chrome.barWash` on the bar itself.
 */
function ProgramBarIdentity({
	chrome,
	heading,
	className,
}: {
	chrome?: ProgramChrome
	heading: MegaMenuHeading
	className?: string
}) {
	return (
		<>
			{chrome ? (
				<img
					src={chrome.seal}
					alt=""
					aria-hidden="true"
					width={117}
					height={116}
					decoding="async"
					/*
					 * Fixed height, and `shrink-0` so a long title cannot squash it.
					 * `size-9` keeps the bar at its 5.5rem — the height
					 * `REGISTRATION_RAIL_COLUMN`'s `lg:top-28` is derived from, so a
					 * taller seal would silently unpin the order rail.
					 */
					className="size-9 shrink-0 object-contain"
				/>
			) : null}
			<h1 className={cn(REGISTRATION_BAR_TITLE, className)}>
				<MegaMenuHeadingText heading={heading} />
			</h1>
		</>
	)
}

export { ProgramBarIdentity }
