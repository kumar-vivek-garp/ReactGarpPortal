import { animated } from "@react-spring/web"

import { Card } from "@/components/atoms/card"
import { ExamRegistrationPanel } from "@/components/forms/exam-registration/exam-registration-panel"
import {
	REGISTRATION_SCROLL,
	REGISTRATION_SHELL,
} from "@/components/forms/registration-shell"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { resolveExamProgram } from "@/lib/registration-programs"
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
 * One dynamic route serves every programme, so FRM, SCR, RAI, RAIJ and the
 * rest all land here, and the slug is what picks the programme. Anything the
 * registry does not cover — the courses and the membership kinds, whose forms
 * are still to be written — gets a placeholder rather than a dead end.
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
	/*
	 * Resolved rather than compared: this also applies the legacy slug
	 * aliases, so `/registration/rai` reaches Risk AI instead of asking the
	 * registration module for a type it rejects.
	 */
	const program = resolveExamProgram(slug)

	// A built form folds Back into its own sticky bar, so rendering the shared
	// header above it would stack two headers and two back links.
	if (program) {
		return (
			<animated.div style={style} className={cn(REGISTRATION_SHELL, className)}>
				<div className={REGISTRATION_SCROLL}>
					<ExamRegistrationPanel
						program={program}
						programType={program.registrationType}
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
