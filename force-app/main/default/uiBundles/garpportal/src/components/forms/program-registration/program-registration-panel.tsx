import { animated } from "@react-spring/web"

import { Card } from "@/components/atoms/card"
import { FrmRegistrationPanel } from "@/components/forms/frm/frm-registration-panel"
import {
	REGISTRATION_SCROLL,
	REGISTRATION_SHELL,
} from "@/components/forms/registration-shell"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { useSubpageTransition } from "@/hooks/use-subpage-transition"
import { cn } from "@/lib/utils"

/**
 * The placeholder branch's scroller, which sits *below* a
 * `ProgramsSubpageHeader` rather than starting flush — so it keeps the top
 * margin the shared `REGISTRATION_SCROLL` deliberately does not have, and does
 * not need its inset either: its header is outside the clip.
 */
const SUBPAGE_SCROLL =
	"mt-4 min-h-0 flex-1 space-y-6 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"

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
			<animated.div style={style} className={cn(REGISTRATION_SHELL, className)}>
				<div className={REGISTRATION_SCROLL}>
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
		<animated.div style={style} className={cn(REGISTRATION_SHELL, className)}>
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
