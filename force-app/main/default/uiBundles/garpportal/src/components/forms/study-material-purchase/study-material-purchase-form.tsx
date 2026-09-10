import { useEffect } from "react"
import { useForm } from "react-hook-form"
import { Link } from "@tanstack/react-router"

import { AppError } from "@/api/client"
import type { MaterialQuote } from "@/api/study-materials/types"
import { Alert, AlertDescription, AlertTitle } from "@/components/atoms/alert"
import { Button } from "@/components/atoms/button"
import { AnimatedAmount } from "@/components/forms/exam-registration/animated-amount"
import {
	REGISTRATION_BAR_CONTROL_GROUP,
	REGISTRATION_BAR_CONTROL_HEIGHT,
	REGISTRATION_BAR_SUBMIT,
	REGISTRATION_BAR_TITLE,
	REGISTRATION_BAR_TITLE_GROUP,
	REGISTRATION_BAR_TOTAL_BLOCK,
	REGISTRATION_GRID,
	REGISTRATION_MAIN_COLUMN,
	REGISTRATION_RAIL_COLUMN,
	REGISTRATION_STICKY_BAR,
} from "@/components/forms/registration-shell"
import {
	toPurchaseFormValues,
	toShipTo,
	type PurchaseFormValues,
} from "@/components/forms/study-material-purchase/purchase-form-values"
import { PurchaseItemSection } from "@/components/forms/study-material-purchase/sections/purchase-item-section"
import { PurchaseSummaryRail } from "@/components/forms/study-material-purchase/sections/purchase-summary-rail"
import { ShippingAddressSection } from "@/components/forms/study-material-purchase/sections/shipping-address-section"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { STUDY_MATERIAL_PURCHASE } from "@/config/study-materials"
import {
	CheckoutUnavailableError,
	useMaterialPurchaseSubmit,
} from "@/hooks/use-material-purchase"
import { useRevealInvalidField } from "@/hooks/use-reveal-invalid-field"
import { orderDetailsPath } from "@/lib/order-paths"
import { cn } from "@/lib/utils"

type StudyMaterialPurchaseFormProps = {
	productCode: string
	quote: MaterialQuote
	/** The provider's cancel leg brought the member back here. */
	checkoutCancelled: boolean
	/** `useSubpageTransition().exit` — plays the spring, then runs the navigation. */
	onNavigateBack?: (run: () => void) => void
}

function failureMessage(error: unknown): string {
	if (error instanceof AppError) return error.messages.join(" ")
	return "This purchase could not be started. Please try again."
}

/**
 * Confirm what is being bought, confirm where it goes, pay — in the
 * registration forms' own checkout shape: the sticky bar carries the back
 * link, the h1, the total and the submit; the item and the address take the
 * main column; the money is pinned in the rail.
 *
 * No confirm dialog, deliberately: one line item, and the total sits beside
 * the Pay button, so the page IS the confirmation. Protection against a
 * second order comes from the button — disabled while the purchase is in
 * flight AND after it succeeds (the browser is leaving), and never retried
 * on the member's behalf.
 */
function StudyMaterialPurchaseForm({
	productCode,
	quote,
	checkoutCancelled,
	onNavigateBack,
}: StudyMaterialPurchaseFormProps) {
	const submit = useMaterialPurchaseSubmit()
	const {
		register,
		control,
		handleSubmit,
		formState: { errors, submitCount },
	} = useForm<PurchaseFormValues>({
		mode: "onTouched",
		// One focus, ours — see `useRevealInvalidField`.
		shouldFocusError: false,
		defaultValues: toPurchaseFormValues(quote),
	})
	const { formRef } = useRevealInvalidField(submitCount)

	/*
	 * Back from the hosted checkout restores this page from the browser's
	 * back-forward cache — JavaScript state and all, so the "leaving" state
	 * below would otherwise be frozen on screen. `pageshow` with `persisted`
	 * is that restore, and the only time this fires; a fresh load starts idle.
	 */
	const resetSubmit = submit.reset
	useEffect(() => {
		const onPageShow = (event: PageTransitionEvent) => {
			if (event.persisted) resetSubmit()
		}
		window.addEventListener("pageshow", onPageShow)
		return () => window.removeEventListener("pageshow", onPageShow)
	}, [resetSubmit])

	// Disabled after success too: the browser is on its way to the provider,
	// and a re-armed button in that gap is a second order. Never disabled for
	// an incomplete address: the click lands on the first missing line.
	const busy = submit.isPending || submit.isSuccess

	// The order exists but checkout would not open: point at the order, never
	// at a second Pay.
	const savedOrderPath =
		submit.error instanceof CheckoutUnavailableError
			? orderDetailsPath(
					submit.error.purchase.orderNumber ?? submit.error.purchase.orderId,
				)
			: null

	const onSubmit = handleSubmit((values) => {
		void submit
			.mutateAsync({ productCode, shipTo: toShipTo(values) })
			.catch(() => undefined)
	})

	return (
		<form ref={formRef} noValidate onSubmit={onSubmit}>
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

				<div className={REGISTRATION_BAR_CONTROL_GROUP}>
					{/* Pinned to the button's height so nothing moves the bar. The
					    figure is fixed at load — no repricing for a single item. */}
					<div
						className={cn(
							REGISTRATION_BAR_CONTROL_HEIGHT,
							REGISTRATION_BAR_TOTAL_BLOCK,
						)}
					>
						<p className="text-caption leading-none text-muted-foreground">
							Total
						</p>
						<AnimatedAmount
							amount={quote.total}
							currency={STUDY_MATERIAL_PURCHASE.currency}
							pending={false}
							className="text-lg leading-tight font-semibold text-primary"
						/>
					</div>
					{savedOrderPath ? (
						<Button asChild size="lg" className={REGISTRATION_BAR_SUBMIT}>
							<Link to={savedOrderPath}>View order</Link>
						</Button>
					) : (
						<Button
							type="submit"
							size="lg"
							className={REGISTRATION_BAR_SUBMIT}
							disabled={busy}
						>
							{busy
								? STUDY_MATERIAL_PURCHASE.payBusyLabel
								: STUDY_MATERIAL_PURCHASE.payLabel}
						</Button>
					)}
				</div>
			</div>

			{submit.isError ? (
				<p role="alert" className="mt-2 text-sm text-destructive">
					{failureMessage(submit.error)}
				</p>
			) : null}

			<div className={cn(REGISTRATION_GRID, "mt-4 pb-6")}>
				<div className={REGISTRATION_MAIN_COLUMN}>
					{checkoutCancelled ? (
						<Alert>
							<AlertTitle>{STUDY_MATERIAL_PURCHASE.cancelledTitle}</AlertTitle>
							<AlertDescription>
								{STUDY_MATERIAL_PURCHASE.cancelledMessage}
							</AlertDescription>
						</Alert>
					) : null}

					<PurchaseItemSection quote={quote} />

					{quote.isShippable ? (
						<>
							<ShippingAddressSection
								register={register}
								control={control}
								errors={errors}
								shippableCountries={quote.shippableCountries}
								recordCountry={quote.shipTo?.country ?? null}
								disabled={busy}
							/>
						</>
					) : null}
				</div>

				<aside className={REGISTRATION_RAIL_COLUMN}>
					<PurchaseSummaryRail quote={quote} />
				</aside>
			</div>
		</form>
	)
}

export { StudyMaterialPurchaseForm }
