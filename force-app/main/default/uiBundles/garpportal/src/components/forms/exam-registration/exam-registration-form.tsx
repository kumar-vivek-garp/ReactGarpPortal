import { useCallback, useMemo, useState } from "react"
import { useForm, useWatch } from "react-hook-form"
import { useQuery } from "@tanstack/react-query"
import { Link, useRouterState } from "@tanstack/react-router"

import { AppError } from "@/api/client"
import type { ExamRegistrationLoad } from "@/api/registration/exam-types"
import type { PersonalInfoEditData } from "@/api/personal-info/types"
import { Alert, AlertDescription, AlertTitle } from "@/components/atoms/alert"
import { Button } from "@/components/atoms/button"
import { MegaMenuHeadingText } from "@/components/molecules/mega-menu-heading"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { AnimatedAmount } from "@/components/forms/exam-registration/animated-amount"
import {
	toExamFormValues,
	type ExamFormValues,
} from "@/components/forms/exam-registration/exam-form-values"
import { AcknowledgementsSection } from "@/components/forms/exam-registration/sections/acknowledgements-section"
import { AddressesSection } from "@/components/forms/exam-registration/sections/addresses-section"
import { ConfirmRegistrationDialog } from "@/components/forms/exam-registration/sections/confirm-registration-dialog"
import { OstaSection } from "@/components/forms/exam-registration/sections/osta-section"
import { PaymentSection } from "@/components/forms/exam-registration/sections/payment-section"
import {
	REGISTRATION_BAR_CONTROL_HEIGHT,
	REGISTRATION_GRID,
	REGISTRATION_MAIN_COLUMN,
	REGISTRATION_RAIL_COLUMN,
	REGISTRATION_STICKY_BAR,
} from "@/components/forms/registration-shell"
import { MembershipOfferSection } from "@/components/forms/exam-registration/sections/membership-offer-section"
import { RegistrationRail } from "@/components/forms/exam-registration/sections/registration-rail"
import { YourDetailsSection } from "@/components/forms/exam-registration/sections/your-details-section"
import { YourExamSection } from "@/components/forms/exam-registration/sections/your-exam-section"
import { useExamRegistrationState } from "@/hooks/use-exam-registration"
import {
	MustSignInError,
	useExamRegistrationSubmit,
	useVerifyExamCustomer,
	type ExamSubmitInput,
	type ExamSubmitOutcome,
} from "@/hooks/use-exam-registration-submit"
import { registrationOptionsQueryOptions } from "@/api/registration/query-options"
import { buildRegisterRequest } from "@/lib/registration-payloads"
import {
	defaultPaymentType,
	isComplianceCountry as isComplianceCountryFor,
	isExamKind,
	showAddresses as showAddressesFor,
	showAutorenew as showAutorenewFor,
	showCandidateAcknowledgements as showCandidateAcknowledgementsFor,
	submitLabel as submitLabelFor,
} from "@/lib/registration-presentation"
import { EMAIL_PATTERN, type ExamProgramConfig } from "@/config/registration"
import { LOGIN_PATH } from "@/auth/constants"
import { getReturnPath } from "@/auth/return-path"
import { cn } from "@/lib/utils"

type ExamRegistrationFormProps = {
	load: ExamRegistrationLoad
	/**
	 * The programme's own copy — title, guest byline, exam policies.
	 *
	 * Everything else on this form comes from the load payload, which is why
	 * one form serves every exam programme: these three are the only values
	 * the registration module does not send. Not to be confused with
	 * `load.program`, which is the server's view of the same programme.
	 */
	program: ExamProgramConfig
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
function ExamRegistrationForm({
	load,
	program,
	programType,
	profile,
	regCode,
	isAuthenticated,
	onNavigateBack,
	onRegistered,
}: ExamRegistrationFormProps) {
	const submit = useExamRegistrationSubmit()
	const verifyEmail = useVerifyExamCustomer()
	const [submitError, setSubmitError] = useState<string | null>(null)
	/** Built and validated, waiting on the confirmation dialog. */
	const [pendingSubmit, setPendingSubmit] = useState<ExamSubmitInput | null>(
		null,
	)
	/* Only read to build the post-sign-in return path. */
	const location = useRouterState({ select: (state) => state.location })

	const {
		control,
		register,
		handleSubmit,
		getValues,
		setValue,
		trigger,
		formState: { errors, isValid },
	} = useForm<ExamFormValues>({
		defaultValues: toExamFormValues(profile, load.countries),
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
	const membershipSelected = useWatch({ control, name: "membershipSelected" })
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
		membershipSelected,
	})

	const { fees } = state
	const currency = fees?.currencyCode || "USD"
	const hasBilling = fees?.hasBilling === true
	/*
	 * Which sections apply at all. The server's `kind` decides, not our config:
	 * `GARP_ExamReg_RegService` requires a selection and the exam-policy
	 * attestation for `kind == 'exam'` and for nothing else, and
	 * `LoadService` only builds a membership offer for a course.
	 */
	const isExam = isExamKind(load.program.kind)
	const membershipOffer = load.membershipOffer ?? null
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
		// A course's membership upsell is also a membership worth renewing —
		// GarpAppv1's `form.membership` branch, lost once and re-wired.
		membershipSelected,
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
	/*
	 * The OSTA typeahead lists — fetched only once the card is actually on
	 * screen (a second, ~2,000-row request the page should not wait for), and
	 * the load payload's own lists cover any org that inlines them instead.
	 */
	const ostaOptions = useQuery({
		...registrationOptionsQueryOptions,
		enabled: isExam && state.ostaRequired,
	})

	const examChosen =
		!isExam ||
		(Boolean(state.selection.partSelected) &&
			(!state.part1Active ||
				Boolean(state.selection.part1.rateId && state.selection.part1.siteId)) &&
			(!state.part2Active ||
				Boolean(state.selection.part2.rateId && state.selection.part2.siteId)))

	/*
	 * Changing the billing country has three consequences, all of which the
	 * legacy app applies together and none of which are optional:
	 *
	 * 1. the address card's country follows it — they are the same country;
	 * 2. the province is cleared, because it belonged to the old country;
	 * 3. the payment method is re-picked. The new country may forbid what was
	 *    already selected, and the tile only *renders* as unselected in that
	 *    case — the value stays put, so without this the order is priced and
	 *    submitted with a method the country does not allow, and fails at the
	 *    server instead of at the point of choosing.
	 */
	const handleCountryChange = useCallback(
		(countryCode: string) => {
			/*
			 * Field by field, not one `setValue("billing", {...})`: writing the
			 * parent object leaves the individually-registered inputs showing
			 * their old text, so the province from the previous country stays on
			 * screen and gets submitted with the new one.
			 */
			setValue("billing.country", countryCode, { shouldDirty: true })
			setValue("billing.province", "", { shouldDirty: true })
			/*
			 * Re-run the rules the new country changes: a postal-code or province
			 * error raised under the old country would otherwise survive the
			 * switch (validate closures only run when triggered) and hold submit
			 * disabled against a requirement that no longer exists. No-ops while
			 * the address card is unmounted.
			 */
			void trigger(["billing.province", "billing.postalCode"])
			const country = load.countries.find(
				(candidate) => candidate.countryCode === countryCode,
			)
			if (!country) return
			setValue(
				"paymentType",
				defaultPaymentType(
					country,
					load.stripe?.useStripe === true,
					getValues("paymentType"),
				),
				{ shouldDirty: true, shouldValidate: true },
			)
		},
		[getValues, setValue, trigger, load.countries, load.stripe?.useStripe],
	)

	/**
	 * The identity check GarpAppv1 runs on blur, so a guest who already has an
	 * account is told before filling the rest of the form rather than at
	 * submit. Skipped for members (their email IS the account), while the
	 * address is not yet a valid email, and when this exact address was
	 * already checked — the result doubles as the registration's session, so
	 * a normal fill-and-submit makes one identity call, not two.
	 */
	const handleIdentityBlur = () => {
		if (isAuthenticated) return
		const email = getValues("email").trim()
		if (!EMAIL_PATTERN.test(email)) return
		if (verifyEmail.data?.email === email) return
		verifyEmail.mutate({
			type: programType,
			email,
			firstName: getValues("firstName"),
			lastName: getValues("lastName"),
		})
	}

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
			membershipSelected: values.membershipSelected,
			/* See the note in `use-exam-registration` — `mem` is not served here. */
			riskNetSelected: false,
			mobilePhoneCode: values.mobilePhoneCode,
			firstName: values.firstName,
			lastName: values.lastName,
			email: values.email,
			mobilePhone: values.mobilePhone,
			smsPromotionalUpdates: values.smsPromotionalUpdates,
			// No controls behind these — they ride through from the member's own
			// record, exactly as the legacy carries them. Posting `""` instead
			// would blank the contact's stored values on an OSTA registration.
			title: load.contact?.title ?? "",
			company: load.contact?.company ?? "",
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
						// From the contact record, not "" — Apex writes this block
						// whenever it arrives, and the legacy prefills all four.
						businessEmail: load.contact?.businessEmail ?? "",
						professionalLevel: load.contact?.professionalLevel ?? "",
						jobFunction: load.contact?.jobFunction ?? "",
						riskSpecialty: load.contact?.riskSpecialty ?? "",
					}
				: null,
			isComplianceCountry,
			attestPrivacyNotice: values.attestPrivacyNotice,
			attestLimitationOfLiability: values.attestLimitationOfLiability,
			attestReleaseAndWaiver: values.attestReleaseAndWaiver,
			examPolicy: values.examPolicy,
			candidateResponsibility: values.candidateResponsibility,
		})

		/*
		 * Staged, not sent. Everything past this point writes records — the order
		 * is created and `payOrder` cannot be called twice — so the figures get
		 * one more look first. Validation has already run: `handleSubmit` only
		 * reaches here on a valid form.
		 */
		setPendingSubmit({
			request,
			checkAddress:
				showAddresses && load.program.addressVerificationDisabled !== true,
			// The blur check's answer, reused when it covered this same email.
			session: verifyEmail.data ?? null,
		})
	})

	const confirmSubmit = async () => {
		if (!pendingSubmit) return
		try {
			const outcome = await submit.mutateAsync(pendingSubmit)
			setPendingSubmit(null)
			// A redirect means the browser is already leaving for the payment
			// provider; rendering a confirmation behind it would flash.
			if (outcome.kind !== "redirecting") onRegistered(outcome)
		} catch (error) {
			// Close, so the failure is read against the form it has to be fixed
			// in rather than behind a dialog offering to try again.
			setPendingSubmit(null)
			setSubmitError(AppError.fromUnknown(error).messages[0])
		}
	}

	// Either leg can say it: the blur check is advisory, the submit check binds.
	const mustSignIn =
		submit.error instanceof MustSignInError ||
		verifyEmail.data?.mustSignIn === true
	const existingCustomer =
		!mustSignIn && verifyEmail.data?.isExistingCustomer === true
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
			<div className={REGISTRATION_STICKY_BAR}>
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
					{/*
					 * An `h1`, not an `h2`: on the public route this is the page's
					 * only heading, and that page is linked from marketing email.
					 * It was previously the sole `h2` on a document with no `h1`.
					 *
					 * Same title for both audiences — it names the certification in
					 * full, so the supporting line a guest used to get underneath it
					 * would now just repeat the title.
					 */}
					<h1 className="truncate font-heading text-2xl font-semibold">
						<MegaMenuHeadingText heading={program.heading} />
					</h1>
				</div>

				<div className="flex items-center gap-4">
					{/*
					 * Always rendered, and pinned to the button's own height, so
					 * neither the arrival of a price nor a longer figure moves the bar.
					 */}
					<div
						className={cn(
							REGISTRATION_BAR_CONTROL_HEIGHT,
							"flex shrink-0 flex-col items-end justify-center text-right",
						)}
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

			{/*
			 * Guest-only, and above the form rather than beside the email field:
			 * signing in is a full navigation that discards whatever has been
			 * typed, so the offer has to arrive before anyone starts typing.
			 */}
			{isAuthenticated ? null : (
				<Alert>
					<AlertDescription>
						{program.publicByLine}{" "}
						<Link
							to={LOGIN_PATH}
							search={{ startUrl: getReturnPath(location) }}
							className="font-medium text-primary underline underline-offset-2"
						>
							Sign in
						</Link>
					</AlertDescription>
				</Alert>
			)}

			<ConfirmRegistrationDialog
				open={pendingSubmit !== null}
				onOpenChange={(next) => {
					if (!next) setPendingSubmit(null)
				}}
				fees={fees}
				submitLabel={label}
				paymentType={paymentType}
				isPending={isBusy}
				onConfirm={() => void confirmSubmit()}
			/>

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
			) : existingCustomer ? (
				<Alert>
					<AlertTitle>We found your record</AlertTitle>
					<AlertDescription>
						This email is already in our system, so your registration will be
						added to your existing record.
					</AlertDescription>
				</Alert>
			) : submitError ? (
				<Alert variant="destructive">
					<AlertTitle>Unable to complete your registration</AlertTitle>
					<AlertDescription>{submitError}</AlertDescription>
				</Alert>
			) : null}

			<div className={REGISTRATION_GRID}>
				<div className={REGISTRATION_MAIN_COLUMN}>
					<YourDetailsSection
						register={register}
						control={control}
						errors={errors}
						countries={load.countries}
						isAuthenticated={isAuthenticated}
						showLocation={!showAddresses}
						onCountryChange={handleCountryChange}
						onIdentityBlur={handleIdentityBlur}
						disabled={isBusy}
					/>

					{isExam ? (
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
					) : null}

					{/*
					 * A course sells membership alongside it. Not cosmetic: the same
					 * flag re-prices the course itself, because `courseMainLine`
					 * reads it to choose the member or non-member product.
					 */}
					{membershipOffer ? (
						<MembershipOfferSection
							control={control}
							amount={membershipOffer.amount}
							disabled={isBusy}
						/>
					) : null}

					{isExam && state.ostaRequired ? (
						<OstaSection
							register={register}
							control={control}
							errors={errors}
							getValues={getValues}
							idType={ostaIdType}
							workStatus={ostaWorkStatus}
							studentStatus={ostaStudentStatus}
							companies={
								ostaOptions.data?.companies?.length
									? ostaOptions.data.companies
									: (load.companies ?? [])
							}
							schools={
								ostaOptions.data?.schools?.length
									? ostaOptions.data.schools
									: (load.schools ?? [])
							}
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
							getValues={getValues}
							errors={errors}
							countries={load.countries}
							onCountryChange={handleCountryChange}
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

					{/*
					 * Never gated away: the card is never actually empty. An exam adds
					 * the candidate acknowledgements, a compliance country adds the
					 * three ticks, and everyone else still gets the implicit "by
					 * selecting Register you agree…" paragraph — which the legacy
					 * shows for every kind, and which is the only agreement a course
					 * registrant outside a GDPR/CASL country ever sees.
					 */}
					<AcknowledgementsSection
						control={control}
						errors={errors}
						examPolicyUrl={program.examPolicyUrl}
						showCandidateAcknowledgements={showCandidateAcknowledgementsFor(
							load.program.kind,
						)}
						isComplianceCountry={isComplianceCountry}
						submitLabel={label}
						disabled={isBusy}
					/>
				</div>

				<aside className={REGISTRATION_RAIL_COLUMN}>
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

export { ExamRegistrationForm }
