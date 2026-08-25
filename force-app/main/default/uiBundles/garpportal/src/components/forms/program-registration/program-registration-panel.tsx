import { animated } from "@react-spring/web"

import { Card } from "@/components/atoms/card"
import { FrmRegistrationPanel } from "@/components/forms/frm/frm-registration-panel"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { useSubpageTransition } from "@/hooks/use-subpage-transition"
import { cn } from "@/lib/utils"

/** The shell every programme subpage shares — fixed height, scrolling body. */
const SUBPAGE_SHELL =
	"-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
const SUBPAGE_SCROLL =
	"mt-4 min-h-0 flex-1 space-y-6 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
/**
 * No top margin — a form with its own sticky bar must start flush.
 *
 * The horizontal padding is not cosmetic. `overflow-y-auto` also clips the X
 * axis, and the back link inside the bar nudges 5px left on hover; sitting
 * flush against this edge, that nudge would be cut off. Insetting the whole
 * column keeps the bar and the cards aligned with each other and leaves the
 * hover somewhere to go. The pages that use `ProgramsSubpageHeader` above the
 * scroller never hit this — their header is outside the clip.
 */
const SUBPAGE_SCROLL_FLUSH =
	"min-h-0 flex-1 overflow-y-auto overscroll-contain px-2 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"

type ProgramRegistrationPanelProps = {
	programType: string
	regCode?: string
	/** Set when the browser has just come back from the payment provider. */
	paymentReturn?: { orderNumber?: string } | null
	className?: string
}

/**
 * Registration for one programme — the page shell only, for now.
 *
 * Back goes to the programmes listing rather than to programme detail, because
 * that is where Register Now is: the button only shows for programmes the
 * member is not enrolled in, which have no detail page to return to.
 *
 * One dynamic route serves every programme, so FRM, SCR, RAIJ and the rest all
 * land here. The form itself is deliberately not built yet.
 */
function ProgramRegistrationPanel({
	programType,
	regCode,
	paymentReturn,
	className,
}: ProgramRegistrationPanelProps) {
	const { style, exit } = useSubpageTransition()
	const slug = programType.trim().toLowerCase()
	const label = slug.toUpperCase()
	// One programme at a time. Everything else still gets the page and the
	// back link, so the route is never a dead end.
	const isBuilt = slug === "frm"

	// A built form folds Back into its own sticky bar, so rendering the shared
	// header above it would stack two headers and two back links.
	if (isBuilt) {
		return (
			<animated.div style={style} className={cn(SUBPAGE_SHELL, className)}>
				<div className={SUBPAGE_SCROLL_FLUSH}>
					<FrmRegistrationPanel
						programType={slug}
						regCode={regCode}
						paymentReturn={paymentReturn}
						onNavigateBack={exit}
					/>
				</div>
			</animated.div>
		)
	}

	return (
		<animated.div style={style} className={cn(SUBPAGE_SHELL, className)}>
			<ProgramsSubpageHeader
				title={`${label} Registration`}
				onNavigateBack={exit}
			/>

			<div className={SUBPAGE_SCROLL}>
				<Card className="p-6">
					<p className="text-body text-muted-foreground">
						The {label} registration form will be built here.
					</p>
				</Card>
			</div>
		</animated.div>
	)
}

export { ProgramRegistrationPanel }
