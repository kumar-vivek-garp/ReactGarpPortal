import { useMemo, useState } from "react"
import { useForm, useWatch } from "react-hook-form"
import { Link, useRouterState } from "@tanstack/react-router"

import { AppError } from "@/api/client"
import type { ExamRegistrationLoad } from "@/api/registration/exam-types"
import type { PersonalInfoEditData } from "@/api/personal-info/types"
import { Alert, AlertDescription, AlertTitle } from "@/components/atoms/alert"
import { Button } from "@/components/atoms/button"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { AnimatedAmount } from "@/components/forms/frm/animated-amount"
import {
	toFrmFormValues,
	type FrmFormValues,
} from "@/components/forms/frm/frm-form-values"
import { AcknowledgementsSection } from "@/components/forms/frm/sections/acknowledgements-section"
import { AddressesSection } from "@/components/forms/frm/sections/addresses-section"
import { OstaSection } from "@/components/forms/frm/sections/osta-section"
import { PaymentSection } from "@/components/forms/frm/sections/payment-section"
import { RegistrationRail } from "@/components/forms/frm/sections/registration-rail"
import { YourDetailsSection } from "@/components/forms/frm/sections/your-details-section"
import { YourExamSection } from "@/components/forms/frm/sections/your-exam-section"
import { useExamRegistrationState } from "@/hooks/use-exam-registration"
import {
	MustSignInError,
	useExamRegistrationSubmit,
	type ExamSubmitOutcome,
} from "@/hooks/use-exam-registration-submit"
import { buildRegisterRequest } from "@/lib/registration-payloads"
import {
	isComplianceCountry as isComplianceCountryFor,
	showAddresses as showAddressesFor,
	showAutorenew as showAutorenewFor,
	submitLabel as submitLabelFor,
} from "@/lib/registration-presentation"
import { LOGIN_PATH } from "@/auth/constants"
import { getReturnPath } from "@/auth/return-path"

type FrmRegistrationFormProps = {
	load: ExamRegistrationLoad
	programType: string
	/** The member's own record, used to seed the form. Null while loading. */
	profile: PersonalInfoEditData | null
	regCode?: string
	/**
	 * Whether this browser has a portal session.
	 *
	 * Deliberately *not* `load.isAuthenticated`. That is the server's view, and
	 * it answers a different question: it decides what the registration module
	 * will accept at submit. This one decides where the page's own links may
	 * point and whether anything was prefilled — both pure client-routing
	 * questions. The two genuinely disagree on local dev, where the gateway
	 * signs in as a non-community user: the session is real, but Apex reports
	 * `isAuthenticated: false`.
	 */
	isAuthenticated: boolean
	/** Plays the page exit before Back navigates. */
	onNavigateBack: (run: () => void) => void
	onRegistered: (outcome: ExamSubmitOutcome) => void
}

/**
 * FRM registration.
 *
 * Laid out as a checkout rather than as a stack of cards: the form runs down
 * the main column and the cart is pinned beside it, because every choice
 * re-prices and a total the candidate has to scroll to find is a total nobody
 * checks. The submit sits in the header with the total, so the commitment and
 * its price are always on screen together.
 *
 * Mounted only once both the payload and the profile exist — react-hook-form
 * seeds `defaultValues` at mount, and re-seeding a live form does not reach
 * the Radix selects, which would keep their placeholder and post empty strings
 * over prefilled values.
 */
function FrmRegistrationForm({
	load,
	programType,
	profile,
	regCode,
	isAuthenticated,
	onNavigateBack,
	onRegistered,
}: FrmRegistrationFormProps) {
	const submit = useExamRegistrationSubmit()
	const [submitError, setSubmitError] = useState<string | null>(null)
	/* Only read to build the post-sign-in return path. */
	const location = useRouterState({ select: (state) => state.location })

	const {
		control,
		register,
		handleSubmit,
		getValues,
		setValue,
		formState: { errors, isValid },
	} = useForm<FrmFormValues>({
		defaultValues: toFrmFormValues(profile, load.countries),
		/*
		 * `onTouched`, not `onChange`: Register stays disabled until the form is
		 * valid, which needs validity recomputed as fields change — but `isValid`
		 * is only maintained when the mode is not `onSubmit`. `onTouched` waits
		 * for a first blur before showing a field's error, so nobody is told
		 * their email is invalid while they are still halfway through typing it,
		 * and it re-renders less than `onChange` on a form this size.
		 *
		 * Conditional sections are safe here: a field that unmounts (the address
		 * cards under a card payment, the compliance attestations outside a
		 * GDPR/CASL country) stops counting towards `isValid`, verified against
		 * this version rather than assumed. Were it otherwise, switching payment
		 * type would strand Register disabled with no visible field to fix.
		 */
		mode: "onTouched",
	})

	// `useWatch`, not the destructured `watch()` — the latter returns a fresh
	// function each render, which opts the whole component out of memoization.
	const country = useWatch({ control, name: "country" })
	const mobilePhoneCode = useWatch({ control, name: "mobilePhoneCode" })
	const paymentType = useWatch({ control, name: "paymentType" })
	const billing = useWatch({ control, name: "billing" })
	const shipping = useWatch({ control, name: "shipping" })
	const sameAsBilling = useWatch({ control, name: "billingAndShippingSame" })
	const autoRenew = useWatch({ control, name: "autoRenew" })
	const ostaIdType = useWatch({ control, name: "osta.idType" })
	const ostaWorkStatus = useWatch({ control, name: "osta.workStatus" })
	const ostaStudentStatus = useWatch({ control, name: "osta.studentStatus" })

	const state = useExamRegistrationState({
		load,
		programType,
		regCode,
		billingCountry: country,
		mobilePhoneCode,
		paymentType,
		billingAddress: billing,
		shippingAddress: shipping,
		billingAndShippingSame: sameAsBilling,
		autoRenew,
	})

	const { fees } = state
	const currency = fees?.currencyCode || "USD"
	const hasBilling = fees?.hasBilling === true
	const showAddresses = showAddressesFor(paymentType)
	const label = submitLabelFor(hasBilling, paymentType)

	/** The billing country actually in force — the address card, or Location. */
	const effectiveCountry = showAddresses ? billing.country : country
	const selectedCountry = useMemo(
		() =>
			load.countries.find(
				(candidate) => candidate.countryCode === effectiveCountry,
			) ?? null,
		[load.countries, effectiveCountry],
	)
	const isComplianceCountry = isComplianceCountryFor(
		load.countries,
		effectiveCountry,
	)
	const showAutorenew = showAutorenewFor(
		load.contact?.isAutoRenewEnabled,
		paymentType,
		fees?.hasCompMembership,
	)

	/*
	 * The exam choice is not a form field — it is cascading state owned by
	 * `useExamRegistrationState` — so `isValid` cannot see it. Registering with
	 * no sitting or no exam centre is exactly the order that fails server-side,
	 * so both halves have to agree before the button opens.
	 *
	 * A part with a single option is auto-resolved rather than shown as a
	 * one-entry select, and `state.selection` is the resolved view, so this
	 * reads true for those without the candidate having to click anything.
	 */
	const examChosen =
		Boolean(state.selection.partSelected) &&
		(!state.part1Active ||
			Boolean(state.selection.part1.rateId && state.selection.part1.siteId)) &&
		(!state.part2Active ||
			Boolean(state.selection.part2.rateId && state.selection.part2.siteId))

	const onSubmit = handleSubmit(async (values) => {
		setSubmitError(null)

		const billingAddress = {
			...values.billing,
			// A card order never shows the address card, so Location is the only
			// country there is.
			country: values.billing.country || values.country,
		}

		const request = buildRegisterRequest({
			type: programType,
			regCode,
			contactId: load.contact?.id ?? null,
			selection: state.selection,
			materials: state.materials,
			paymentType: values.paymentType,
			billingAddress,
			shippingAddress: values.billingAndShippingSame
				? billingAddress
				: values.shipping,
			billingAndShippingSame: values.billingAndShippingSame,
			autoRenew: values.autoRenew,
			membershipSelected: false,
			riskNetSelected: false,
			mobilePhoneCode: values.mobilePhoneCode,
			firstName: values.firstName,
			lastName: values.lastName,
			email: values.email,
			mobilePhone: values.mobilePhone,
			smsPromotionalUpdates: values.smsPromotionalUpdates,
			// Sent only when a chosen exam centre demands it — Apex writes the
			// block whenever an ID number is present, so an unwanted one would
			// silently overwrite the member's stored identity.
			personal: state.ostaRequired
				? {
						gender: values.osta.gender,
						idType: values.osta.idType,
						idLocation: values.osta.idLocation,
						idNumber: values.osta.idNumber.trim(),
						nameOnId: values.osta.nameOnId,
						ostaConsent: values.osta.ostaConsent,
						fullNameInChinese: values.osta.fullNameInChinese,
						dateOfBirth: values.osta.dateOfBirth || null,
						idExpireDate: values.osta.idExpireDate || null,
						phone: values.osta.phone,
						workStatus: values.osta.workStatus,
						companyName: values.osta.company,
						schoolName: values.osta.schoolName,
						studentStatus: values.osta.studentStatus,
						degreeName: values.osta.degreeName,
						businessEmail: "",
						professionalLevel: "",
						jobFunction: "",
						riskSpecialty: "",
					}
				: null,
			isComplianceCountry,
			attestPrivacyNotice: values.attestPrivacyNotice,
			attestLimitationOfLiability: values.attestLimitationOfLiability,
			attestReleaseAndWaiver: values.attestReleaseAndWaiver,
			examPolicy: values.examPolicy,
			candidateResponsibility: values.candidateResponsibility,
		})

		try {
			const outcome = await submit.mutateAsync({
				request,
				checkAddress:
					showAddresses &&
					load.program.addressVerificationDisabled !== true,
			})
			// A redirect means the browser is already leaving for the payment
			// provider; rendering a confirmation behind it would flash.
			if (outcome.kind !== "redirecting") onRegistered(outcome)
		} catch (error) {
			setSubmitError(AppError.fromUnknown(error).messages[0])
		}
	})

	const mustSignIn = submit.error instanceof MustSignInError
	const isBusy = submit.isPending
	const canSubmit =
		isValid && examChosen && !state.outOfOrder && Boolean(fees)

	return (
		<form className="flex flex-col gap-6" onSubmit={onSubmit} noValidate>
			{/*
			 * One bar: where you came from, what you are doing, what it costs and
			 * the commitment. Folding Back into it keeps all of that on a single
			 * line, leaving the viewport for the form itself.
			 *
			 * Two things here are deliberate and easy to "tidy" back into bugs:
			 * it is fully opaque, because content scrolling under a translucent
			 * bar reads as a rendering fault rather than as depth; and it has no
			 * negative margin, because bleeding it past the container makes it
			 * wider than its scroll parent, which buys a few pixels of horizontal
			 * scroll and clips the back arrow.
			 */}
			<div className="sticky top-0 z-30 flex flex-wrap items-center justify-between gap-x-6 gap-y-3 bg-background py-3">
				<div className="flex min-w-0 items-center gap-4">
					{/*
					 * No back link for a guest. Every in-app parent is behind the
					 * session guard, and sending them out to garp.org is not "back" —
					 * it is leaving, which is not what a back arrow promises halfway
					 * through a form. The divider goes with it; on its own it would
					 * sit in front of the title separating it from nothing.
					 */}
					{isAuthenticated ? (
						<>
							<ProgramsSubpageHeader
								onNavigateBack={onNavigateBack}
								back={{ kind: "programs" }}
							/>
							<div
								className="hidden h-6 w-px shrink-0 bg-border sm:block"
								aria-hidden
							/>
						</>
					) : null}
					<h2 className="truncate font-heading text-xl font-semibold">
						Register for the FRM Exam
					</h2>
				</div>

				<div className="flex items-center gap-4">
					{/*
					 * Always rendered, and pinned to the button's own height, so
					 * neither the arrival of a price nor a longer figure moves the bar.
					 */}
					<div
						className="flex h-10 shrink-0 flex-col items-end justify-center text-right"
						aria-live="polite"
						aria-busy={state.isPricing}
					>
						<p className="text-caption leading-none text-muted-foreground">
							{state.isPricing ? "Updating…" : "Total"}
						</p>
						{fees?.total != null ? (
							<AnimatedAmount
								amount={fees.total}
								currency={currency}
								pending={state.isPricing}
								className="text-lg leading-tight font-semibold text-primary"
							/>
						) : (
							<span className="text-lg leading-tight font-semibold text-muted-foreground">
								&mdash;
							</span>
						)}
					</div>
					{/*
					 * Blocked until the cart has priced: `register` re-prices
					 * server-side, so submitting before a total exists means agreeing
					 * to a figure nobody has seen. And blocked until every required
					 * answer is in, so the first thing a candidate learns about a
					 * missing field is not a failed submission.
					 */}
					<Button
						type="submit"
						size="lg"
						disabled={isBusy || !canSubmit}
						title={
							canSubmit || isBusy
								? undefined
								: "Complete the required fields to continue."
						}
					>
						{isBusy ? "Submitting…" : label}
					</Button>
				</div>
			</div>

			{mustSignIn ? (
				<Alert variant="destructive">
					<AlertTitle>You already have an account</AlertTitle>
					<AlertDescription className="flex flex-col items-start gap-3">
						<span>
							An account already exists for this email address. Please sign in
							before registering.
						</span>
						{/*
						 * Signing in is a full navigation and this form is not
						 * persisted, so the link is explicit about what it costs
						 * rather than quietly discarding what was typed.
						 */}
						<Button asChild size="sm" variant="outline">
							<Link
								to={LOGIN_PATH}
								search={{ startUrl: getReturnPath(location) }}
							>
								Sign in and start again
							</Link>
						</Button>
					</AlertDescription>
				</Alert>
			) : submitError ? (
				<Alert variant="destructive">
					<AlertTitle>Unable to complete your registration</AlertTitle>
					<AlertDescription>{submitError}</AlertDescription>
				</Alert>
			) : null}

			<div className="grid grid-cols-1 gap-6 lg:grid-cols-10">
				<div className="flex flex-col gap-6 lg:col-span-7">
					<YourDetailsSection
						register={register}
						control={control}
						errors={errors}
						countries={load.countries}
						isAuthenticated={isAuthenticated}
						disabled={isBusy}
					/>

					<YourExamSection
						partsAvailable={load.examSelection?.partsAvailable ?? []}
						partSelected={state.selection.partSelected}
						onSelectPart={state.selectPart}
						part1Title={state.part1?.title || "Part I"}
						part2Title={state.part2?.title || "Part II"}
						part1Admins={state.part1Admins}
						part2Admins={state.part2Admins}
						selection={state.selection}
						part1Active={state.part1Active}
						part2Active={state.part2Active}
						onSelectAdmin={state.selectAdmin}
						onSelectSite={state.selectSite}
						outOfOrder={state.outOfOrder}
						disabled={isBusy}
					/>

					{state.ostaRequired ? (
						<OstaSection
							register={register}
							control={control}
							errors={errors}
							getValues={getValues}
							idType={ostaIdType}
							workStatus={ostaWorkStatus}
							studentStatus={ostaStudentStatus}
							disabled={isBusy}
						/>
					) : null}

					{/* Nothing to pay means nothing to choose a payment method for. */}
					{hasBilling ? (
						<PaymentSection
							control={control}
							errors={errors}
							country={selectedCountry}
							useStripe={load.stripe?.useStripe === true}
							paymentType={paymentType}
							showAutorenew={showAutorenew}
							disabled={isBusy}
						/>
					) : null}

					{showAddresses ? (
						<AddressesSection
							register={register}
							control={control}
							errors={errors}
							countries={load.countries}
							sameAsBilling={sameAsBilling}
							onSameAsBillingChange={(next) => {
								setValue("billingAndShippingSame", next, { shouldDirty: true })
								// Copy on tick as well as at submit: the shipping fields go
								// read-only, and leaving stale values visible behind them
								// would misrepresent where the books are going.
								if (next) setValue("shipping", getValues("billing"))
							}}
							disabled={isBusy}
						/>
					) : null}

					<AcknowledgementsSection
						control={control}
						errors={errors}
						examPolicyUrl="https://www.garp.org/frm/exam-policies"
						isComplianceCountry={isComplianceCountry}
						submitLabel={label}
						disabled={isBusy}
					/>
				</div>

				{/*
				 * `h-fit` + `sticky` is what pins the rail: it sizes to its content
				 * and stays put while the main column scrolls past it.
				 */}
				<aside className="lg:sticky lg:top-28 lg:col-span-3 lg:h-fit">
					<RegistrationRail
						materials={state.visibleMaterials}
						onToggleMaterial={state.toggleMaterial}
						fees={fees}
						isPricing={state.isPricing}
						disabled={isBusy}
					/>
				</aside>
			</div>
		</form>
	)
}

export { FrmRegistrationForm }
