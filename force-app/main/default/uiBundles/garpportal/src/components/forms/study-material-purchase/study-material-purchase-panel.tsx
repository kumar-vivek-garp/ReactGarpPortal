import { useEffect, useRef } from "react"
import { animated } from "@react-spring/web"
import { useQueryClient } from "@tanstack/react-query"
import { Link } from "@tanstack/react-router"
import { PackageX, TriangleAlert } from "lucide-react"

import { AppError } from "@/api/client"
import { invalidatePurchaseCaches } from "@/api/study-materials/invalidate-caches"
import { Button } from "@/components/atoms/button"
import {
	REGISTRATION_BAR_TITLE,
	REGISTRATION_BAR_TITLE_GROUP,
	REGISTRATION_SHELL,
	REGISTRATION_STICKY_BAR,
} from "@/components/forms/registration-shell"
import { RegistrationStatusPanel } from "@/components/forms/registration-status-panel"
import { StudyMaterialPurchaseForm } from "@/components/forms/study-material-purchase/study-material-purchase-form"
import { StudyMaterialPurchaseSkeleton } from "@/components/molecules/page-pending/study-material-purchase-pending"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import {
	DEFAULT_STUDY_MATERIALS_TAB,
	STUDY_MATERIAL_PURCHASE,
} from "@/config/study-materials"
import { useMaterialQuote } from "@/hooks/use-material-purchase"
import { useSubpageTransition } from "@/hooks/use-subpage-transition"
import { cn } from "@/lib/utils"

type StudyMaterialPurchasePanelProps = {
	productCode: string
	checkoutCancelled: boolean
	className?: string
}

/**
 * The same sticky-bar chrome the form carries — back link and the page's h1 —
 * wrapped around every non-form screen, so a refusal never floats
 * context-free in an empty page. The event panel's pattern.
 */
function ScreenChrome({
	onNavigateBack,
	children,
}: {
	onNavigateBack: (run: () => void) => void
	children: React.ReactNode
}) {
	return (
		<>
			<div className={REGISTRATION_STICKY_BAR}>
				<div className={REGISTRATION_BAR_TITLE_GROUP}>
					<ProgramsSubpageHeader
						back={{ kind: "studyMaterials" }}
						onNavigateBack={onNavigateBack}
						iconOnlyBackOnMobile
					/>
					<div className="hidden h-6 w-px shrink-0 bg-border sm:block" aria-hidden />
					<h1 className={REGISTRATION_BAR_TITLE}>{STUDY_MATERIAL_PURCHASE.title}</h1>
				</div>
			</div>
			<div className="mt-4 w-full">{children}</div>
		</>
	)
}

/**
 * Buying one study material — the React port of the legacy's
 * `#!/checkout/:prodCode` hand-off, minus the questions the member's own
 * record already answers, in the registration forms' checkout shell.
 */
function StudyMaterialPurchasePanel({
	productCode,
	checkoutCancelled,
	className,
}: StudyMaterialPurchasePanelProps) {
	const { style, exit } = useSubpageTransition()
	const quote = useMaterialQuote(productCode)
	const queryClient = useQueryClient()

	/*
	 * The cancel leg: under the immediate flow an unpaid order now exists, so
	 * Order History and the catalogue's flags are stale. Once — StrictMode
	 * runs effects twice.
	 */
	const invalidated = useRef(false)
	useEffect(() => {
		if (!checkoutCancelled || invalidated.current) return
		invalidated.current = true
		void invalidatePurchaseCaches(queryClient)
	}, [checkoutCancelled, queryClient])

	const backToListing = (
		<Button asChild variant="outline">
			<Link to="/study-materials" search={{ tab: DEFAULT_STUDY_MATERIALS_TAB }}>
				Study Materials
			</Link>
		</Button>
	)

	return (
		<animated.div style={style} className={cn(REGISTRATION_SHELL, className)}>
			<div>
				{quote.isPending ? <StudyMaterialPurchaseSkeleton /> : null}

				{quote.isError ? (
					<ScreenChrome onNavigateBack={exit}>
						<RegistrationStatusPanel
							icon={TriangleAlert}
							tone="error"
							title={STUDY_MATERIAL_PURCHASE.errorTitle}
							message={AppError.fromUnknown(quote.error).messages.join(" ")}
							action={
								<div className="flex flex-wrap justify-center gap-2">
									<Button type="button" onClick={() => void quote.refetch()}>
										Try again
									</Button>
									{backToListing}
								</div>
							}
						/>
					</ScreenChrome>
				) : null}

				{quote.isSuccess && quote.data === null ? (
					<ScreenChrome onNavigateBack={exit}>
						<RegistrationStatusPanel
							icon={PackageX}
							title={STUDY_MATERIAL_PURCHASE.unavailableTitle}
							message={STUDY_MATERIAL_PURCHASE.unavailableMessage}
							action={backToListing}
						/>
					</ScreenChrome>
				) : null}

				{quote.isSuccess && quote.data ? (
					<StudyMaterialPurchaseForm
						productCode={productCode}
						quote={quote.data}
						checkoutCancelled={checkoutCancelled}
						onNavigateBack={exit}
					/>
				) : null}
			</div>
		</animated.div>
	)
}

export { StudyMaterialPurchasePanel }
