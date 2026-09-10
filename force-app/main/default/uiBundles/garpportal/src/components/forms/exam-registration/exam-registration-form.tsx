import { useCallback, useMemo, useState } from "react"
import { useForm, useWatch } from "react-hook-form"
import { useQuery } from "@tanstack/react-query"
import { Link, useRouterState } from "@tanstack/react-router"

import { AppError } from "@/api/client"
import type {
	ExamRegisterRequest,
	ExamRegistrationLoad,
} from "@/api/registration/exam-types"
import type { PersonalInfoEditData } from "@/api/personal-info/types"
import { Alert, AlertDescription, AlertTitle } from "@/components/atoms/alert"
import { Button } from "@/components/atoms/button"
import { ProgramBarIdentity } from "@/components/molecules/program-bar-identity"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { AnimatedAmount } from "@/components/forms/exam-registration/animated-amount"
import {
	toExamFormValues,
	toExamFormValuesFromRequest,
	type ExamFormValues,
} from "@/components/forms/exam-registration/exam-form-values"
import { AcknowledgementsSection } from "@/components/forms/exam-registration/sections/acknowledgements-section"
import { AddressesSection } from "@/components/forms/exam-registration/sections/addresses-section"
import { CompMembershipSection } from "@/components/forms/exam-registration/sections/comp-membership-section"
import { ConfirmRegistrationDialog } from "@/components/forms/exam-registration/sections/confirm-registration-dialog"
import { ExamPrepSection } from "@/components/forms/exam-registration/sections/exam-prep-section"
import { OstaSection } from "@/components/forms/exam-registration/sections/osta-section"
import { PaymentSection } from "@/components/forms/exam-registration/sections/payment-section"
import {
	REGISTRATION_BAR_CONTROL_GROUP,
	REGISTRATION_BAR_CONTROL_HEIGHT,
	REGISTRATION_BAR_SUBMIT,
	REGISTRATION_BAR_TITLE_GROUP,
	REGISTRATION_BAR_TOTAL_BLOCK,
	REGISTRATION_BAR_TOTAL_LEADING,
	REGISTRATION_GRID,
	REGISTRATION_MAIN_COLUMN,
	REGISTRATION_RAIL_COLUMN,
	REGISTRATION_RAIL_COLUMN_GUEST,
	REGISTRATION_RAIL_CONTROLS,
	REGISTRATION_RAIL_STACK,
	REGISTRATION_STICKY_BAR,
} from "@/components/forms/registration-shell"
import { MembershipOfferSection } from "@/components/forms/exam-registration/sections/membership-offer-section"
import { RegistrationRail } from "@/components/forms/exam-registration/sections/registration-rail"
import { RiskNetOfferSection } from "@/components/forms/exam-registration/sections/risk-net-offer-section"
import { YourDetailsSection } from "@/components/forms/exam-registration/sections/your-details-section"
import { YourExamSection } from "@/components/forms/exam-registration/sections/your-exam-section"
import { useExamRegistrationState } from "@/hooks/use-exam-registration"
import { useRevealInvalidField } from "@/hooks/use-reveal-invalid-field"
import {
	MustSignInError,
	useExamRegistrationSubmit,
	useVerifyExamCustomer,
	type ExamSubmitInput,
	type ExamSubmitOutcome,
} from "@/hooks/use-exam-registration-submit"
import { registrationChromeForSlug } from "@/lib/registration-chrome"
import { registrationOptionsQueryOptions } from "@/api/registration/query-options"
import {
	buildRegisterRequest,
	selectionFromInput,
} from "@/lib/registration-payloads"
import {
	compMembershipTerm,
	defaultPaymentType,
	examSelectionErrors,
	isExamKind,
	isMembershipKind,
	memberBackKind,
	railEmptyState,
	showAddresses as showAddressesFor,
	showAutorenew as showAutorenewFor,
	showCandidateAcknowledgements as showCandidateAcknowledgementsFor,
	showMembershipOffer,
	showRiskNet,
	submitLabel as submitLabelFor,
} from "@/lib/registration-presentation"
import {
	EMAIL_PATTERN,
	EXAM_REGISTRATION_COPY,
	MEMBERSHIP_REGISTRATION_COPY,
	OFFLINE_PAYMENT_COPY,
	type ExamProgramConfig,
} from "@/config/registration"
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
	 * The `?track_cta=` tag the entry link carried. Rides the identity call
	 * only — the blur check for a guest, the in-submit check for a member.
	 */
	trackCta?: string | null
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
	/**
	 * A staged registration to rebuild the form from (deferred flow — the
	 * candidate pressed Back on the payment page). Applied at mount over the
	 * profile seed, so the panel must not mount this form before it resolves.
	 * The staged id travels with the next submit so the retry reuses the row.
	 */
	resume?: { stagedId: string; request: ExamRegisterRequest } | null
	/**
	 * True when the shell above already renders the programme title — the guest
	 * banner does (`RegistrationBanner`, 2027 Reg Redesign). The sticky bar then
	 * drops its own `h1` so the page has exactly one.
	 *
	 * An explicit prop rather than the form reading the pathname: a form that
	 * inspects the route to decide what to render hides that coupling from both
	 * call sites. Defaults to `false`, so the member route — which has no banner
	 * and would otherwise be left with no `h1` at all — is unchanged.
	 */
	titleInBanner?: boolean
	/**
	 * True when the total and submit belong at the top of the ORDER RAIL rather
	 * than in the sticky bar — the 2027 layout, which every GUEST form uses.
	 *
	 * Deliberately separate from `titleInBanner`. That one tracks whether a
	 * banner exists, which only the redesigned programmes have; this one is a
	 * layout choice that applies to all of them, `raij` and `ffr` included. One
	 * flag doing both jobs would have tied the new layout to having artwork.
	 */
	controlsInRail?: boolean
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
	trackCta = null,
	isAuthenticated,
	onNavigateBack,
	onRegistered,
	resume = null,
	titleInBanner = false,
	controlsInRail = false,
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
		formState: { errors, submitCount },
	} = useForm<ExamFormValues>({
		defaultValues: resume
			? toExamFormValuesFromRequest(
					resume.request,
					toExamFormValues(profile),
				)
			: toExamFormValues(profile),
		/*
		 * `onTouched`: a field shows its error after its first blur, so nobody is
		 * told their email is invalid while still halfway through typing it, and
		 * it re-renders less than `onChange` on a form this size. After the first
		 * submit attempt every field re-validates on change, so a fixed field
		 * clears at once. Nothing here reads `isValid` any more — Register is
		 * never disabled for an incomplete form — which also spares the form a
		 * whole-form revalidation on every keystroke.
		 */
		mode: "onTouched",
		// One focus, ours — see `useRevealInvalidField`.
		shouldFocusError: false,
	})
	const { formRef } = useRevealInvalidField(submitCount)
	/*
	 * Whether Register has been pressed. The exam choice is not a form field,
	 * so react-hook-form's `isSubmitted` cannot gate its errors — this does.
	 * Never reset: once attempted, the section revalidates live, as RHF does.
	 */
	const [attempted, setAttempted] = useState(false)

	// `useWatch`, not the destructured `watch()` — the latter returns a fresh
	// function each render, which opts the whole component out of memoization.
	const paymentType = useWatch({ control, name: "paymentType" })
	const billing = useWatch({ control, name: "billing" })
	const shipping = useWatch({ control, name: "shipping" })
	const sameAsBilling = useWatch({ control, name: "billingAndShippingSame" })
	const autoRenew = useWatch({ control, name: "autoRenew" })
	const membershipSelected = useWatch({ control, name: "membershipSelected" })
	const riskNetSelected = useWatch({ control, name: "riskNetSelected" })
	const ostaIdType = useWatch({ control, name: "osta.idType" })
	const ostaWorkStatus = useWatch({ control, name: "osta.workStatus" })
	const ostaStudentStatus = useWatch({ control, name: "osta.studentStatus" })

	const state = useExamRegistrationState({
		load,
		programType,
		regCode,
		paymentType,
		billingAddress: billing,
		shippingAddress: shipping,
		billingAndShippingSame: sameAsBilling,
		autoRenew,
		membershipSelected,
		riskNetSelected,
		initialSelection: resume
			? selectionFromInput(resume.request.selection)
			: undefined,
		initialMaterialCodes: resume?.request.materials,
	})

	const { fees } = state
	const currency = fees?.currencyCode || "USD"
	const hasBilling = fees?.hasBilling === true
	const hasCompMembership = fees?.hasCompMembership === true
	/*
	 * Which sections apply at all. The server's `kind` decides, not our config:
	 * `GARP_ExamReg_RegService` requires a selection and the exam-policy
	 * attestation for `kind == 'exam'` and for nothing else, `LoadService`
	 * only builds a membership offer for a course, and only the membership
	 * programme carries the Risk.net add-on — where the membership IS the
	 * purchase, so the course upsell never applies.
	 */
	const isExam = isExamKind(load.program.kind)
	const isMembership = isMembershipKind(load.program.kind)
	const membershipOffer = showMembershipOffer(
		load.program.kind,
		load.membershipOffer,
	)
		? load.membershipOffer
		: null
	const riskNetOffer = showRiskNet(load.program.kind, load.riskNetOffer)
		? load.riskNetOffer
		: null
	const showAddresses = showAddressesFor(paymentType)
	const label = submitLabelFor(hasBilling, paymentType)

	/*
	 * The billing country in force. Since the Location select was removed, the
	 * billing address card is the only control that carries one — so this is
	 * that card's country for wire/ACH, and for a card order it is whatever the
	 * member's profile seeded. A guest on a card order has none.
	 *
	 * It no longer decides tax (Stripe derives that from the address it is
	 * sent, and the locally-taxed wire/ACH paths still show the card), and it no
	 * longer decides which attestations render either — the 2027 designs put the
	 * same ticks in front of every candidate. It survives only to name the
	 * country record the payment section shows.
	 */
	const selectedCountry = useMemo(
		() =>
			load.countries.find(
				(candidate) => candidate.countryCode === billing.country,
			) ?? null,
		[load.countries, billing.country],
	)
	const showAutorenew = showAutorenewFor(
		load.contact?.isAutoRenewEnabled,
		paymentType,
		fees?.hasCompMembership,
		// A course's membership upsell is also a membership worth renewing —
		// GarpAppv1's `form.membership` branch, lost once and re-wired.
		membershipSelected,
		// And the membership programme is one by definition — GarpAppv1's
		// `isMembership ||` clause, the one its own comment says was missed.
		isMembership,
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
	 * What the exam section should flag — computed always (it is cheap and it
	 * tells submit whether there is anything on screen to point at), shown only
	 * once Register has been pressed.
	 */
	const missingSelection = isExam
		? examSelectionErrors(
				{
					partsAvailable: load.examSelection?.partsAvailable ?? [],
					selection: state.selection,
					part1Active: state.part1Active,
					part2Active: state.part2Active,
					part1Admins: state.part1Admins,
					part2Admins: state.part2Admins,
				},
				EXAM_REGISTRATION_COPY,
			)
		: {}
	const selectionErrors = attempted ? missingSelection : {}

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
			trackCta,
		})
	}

	const onSubmit = handleSubmit(
		async (values) => {
			setSubmitError(null)
			setAttempted(true)

			/*
			 * The exam choice lives outside react-hook-form, so it is checked here,
			 * after RHF's own rules passed. Its messages are already on screen by
			 * the time this render commits (`attempted` batches with `submitCount`),
			 * and the reveal hook scrolls to the first of them. When there is no
			 * control to flag — no sittings published at all — say so at form level
			 * instead of doing nothing visible.
			 */
			if (!examChosen || state.outOfOrder) {
				if (!examChosen && Object.keys(missingSelection).length === 0) {
					setSubmitError(EXAM_REGISTRATION_COPY.noSittingAvailable)
				}
				return
			}
			// `register` re-prices server-side, so submitting before a total exists
			// means agreeing to a figure nobody has seen.
			if (!fees) {
				setSubmitError(EXAM_REGISTRATION_COPY.notPricedYet)
				return
			}

			// The address card is the only country source now; a card order simply
			// posts whatever the profile seeded, or nothing for a guest.
			const billingAddress = { ...values.billing }

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
				riskNetSelected: values.riskNetSelected,
				firstName: values.firstName,
				lastName: values.lastName,
				email: values.email,
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
				attestPolicies: values.attestPolicies,
				examPolicy: values.examPolicy,
				candidateResponsibility: values.candidateResponsibility,
				marketingEmails: values.marketingEmails,
				examPrepProviders: values.examPrepProviders,
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
				// Only set when this form was rebuilt from a staged registration, so
				// submitting again updates that row instead of stranding it.
				resumeStagedId: resume?.stagedId ?? null,
				// For the in-submit identity call — a member never blurred an email.
				trackCta,
			})
		},
		// RHF's rules failed: the errors render, the reveal hook lands on the first.
		() => setAttempted(true),
	)

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

	/*
	 * Either leg can say it: the blur check is advisory, the submit check
	 * binds. Both offers are for GUESTS only — "sign in" means nothing to
	 * someone who already has a session, and the mutation's toast has already
	 * carried the server's answer to them. (Locally the gateway signs as an
	 * admin, so Apex sees a non-community user and CAN answer a member with
	 * mustSignIn; on the deployed site a member's session carries through.)
	 */
	const mustSignIn =
		!isAuthenticated &&
		(submit.error instanceof MustSignInError ||
			verifyEmail.data?.mustSignIn === true)
	const existingCustomer =
		!isAuthenticated &&
		!mustSignIn &&
		verifyEmail.data?.isExistingCustomer === true
	/* A member's mustSignIn is toast-only: nothing inline they could act on. */
	const inlineSubmitError =
		isAuthenticated && submit.error instanceof MustSignInError ? null : submitError
	const isBusy = submit.isPending

	/*
	 * Whether the sticky bar has anything left to carry. It holds three things,
	 * each of which can move out: the back link (members only), the title (the
	 * banner takes it) and the controls (the rail takes them). A guest on a
	 * redesigned programme loses all three, so the bar is not rendered at all —
	 * an empty sticky bar would still paint a 5.5rem band over the page.
	 *
	 * A guest on a programme with no banner keeps it for the title alone, which
	 * is what preserves that page's only `h1`.
	 */
	const showBar = isAuthenticated || !titleInBanner || !controlsInRail

	/*
	 * The programme's seal and bar wash, for the signed-in bar. Undefined for a
	 * programme with no designed chrome, which then keeps the plain bar — the
	 * same fallback the guest pages use. Resolved from the slug, so it needs no
	 * API data.
	 */
	const chrome = registrationChromeForSlug(programType)?.chrome

	/*
	 * The total and the submit, defined once and placed differently by audience:
	 * a member gets them in the sticky bar, a guest at the top of the order rail
	 * (2027 Reg Redesign). One definition rather than two rendered copies — a
	 * duplicated submit button and a duplicated `aria-live` total would both be
	 * announced twice.
	 */
	const submitControls = (
		<div
			className={cn(
				controlsInRail
					? REGISTRATION_RAIL_CONTROLS
					: cn(REGISTRATION_BAR_CONTROL_GROUP, "sm:ml-auto"),
			)}
		>
			{/*
			 * Always rendered, and pinned to the button's own height, so
			 * neither the arrival of a price nor a longer figure moves the bar.
			 */}
			<div
				className={cn(
					REGISTRATION_BAR_CONTROL_HEIGHT,
					REGISTRATION_BAR_TOTAL_BLOCK,
					controlsInRail && REGISTRATION_BAR_TOTAL_LEADING,
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
			 * Never disabled for an incomplete form: the click runs validation
			 * and the first missing answer is scrolled to and focused instead.
			 * Held only while a price is being fetched — the total beside it
			 * reads "Updating…" at that moment, so the two agree — and while
			 * the registration itself is in flight.
			 */}
			<Button
				type="submit"
				size="lg"
				className={REGISTRATION_BAR_SUBMIT}
				disabled={isBusy || state.isPricing}
			>
				{isBusy ? "Submitting…" : label}
			</Button>
		</div>
	)

	return (
		<form
			ref={formRef}
			className="flex flex-col gap-6"
			onSubmit={onSubmit}
			noValidate
		>
			{/*
			 * The member bar: where you came from, what you are doing, what it
			 * costs and the commitment, on a single line.
			 *
			 * Not rendered for a guest at all. The 2027 designs put the total and
			 * submit at the top of the ORDER RAIL instead, and with the title in
			 * the banner the bar would have nothing else left to carry.
			 *
			 * Two things here are deliberate and easy to "tidy" back into bugs:
			 * it is fully opaque, because content scrolling under a translucent
			 * bar reads as a rendering fault rather than as depth; and its
			 * negative margin exactly cancels the container's gutter — both
			 * derive from `--shell-gutter`, so the bar keeps reaching the page
			 * edges even where the guest forms widen that gutter.
			 */}
			{showBar ? (
				<div className={cn(REGISTRATION_STICKY_BAR, chrome?.barWash)}>
					<div className={REGISTRATION_BAR_TITLE_GROUP}>
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
									back={{ kind: memberBackKind(load.program.kind) }}
									iconOnlyBackOnMobile
								/>
								<div
									className="hidden h-6 w-px shrink-0 bg-border sm:block"
									aria-hidden
								/>
							</>
						) : null}
						{/*
						 * Seal plus an `h1` — wherever this bar renders, that heading is
						 * the page's only one. Both stand down together when a banner is
						 * carrying the title above instead, so no page ends up with two
						 * headings, or — just as bad — none.
						 */}
						{titleInBanner ? null : (
							<ProgramBarIdentity chrome={chrome} heading={program.heading} />
						)}
					</div>
					{controlsInRail ? null : submitControls}
				</div>
			) : null}

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
			) : inlineSubmitError ? (
				<Alert variant="destructive">
					<AlertTitle>Unable to complete your registration</AlertTitle>
					<AlertDescription>{inlineSubmitError}</AlertDescription>
				</Alert>
			) : null}

			<div className={REGISTRATION_GRID}>
				<div className={REGISTRATION_MAIN_COLUMN}>
					{/*
					 * Guest-only. A member has their name and email on file, and the
					 * 2027 designs cut the rest of this card, so for them it would be
					 * a heading over nothing.
					 */}
					{isAuthenticated ? null : (
						<YourDetailsSection
							register={register}
							errors={errors}
							onIdentityBlur={handleIdentityBlur}
							disabled={isBusy}
						/>
					)}

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
							errors={selectionErrors}
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

					{/*
					 * The membership programme's one add-on, in the slot the course
					 * upsell takes on a course — GarpAppv1's order: details, offer,
					 * addresses, payment.
					 */}
					{riskNetOffer ? (
						<RiskNetOfferSection
							control={control}
							amount={riskNetOffer.amount}
							months={riskNetOffer.months}
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
							disabled={isBusy}
						/>
					) : null}

					{/*
					 * The free membership and the offer to keep it. Rendered when there
					 * is either a membership to announce or a renewal to offer — with
					 * both off the card would be a heading over nothing, and on the
					 * membership programme itself the first half is simply false.
					 */}
					{hasCompMembership || showAutorenew ? (
						<CompMembershipSection
							control={control}
							hasCompMembership={hasCompMembership}
							term={compMembershipTerm(fees?.compMembershipTermMonths)}
							showAutoRenew={showAutorenew}
							autoRenewLabel={
								isMembership
									? MEMBERSHIP_REGISTRATION_COPY.autoRenew
									: OFFLINE_PAYMENT_COPY.autoRenew
							}
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
					 * Optional, and only where GARP publishes a provider list to link
					 * to — FRM, SCR and RAI. Consenting to a network you cannot look
					 * at is consent in name only.
					 */}
					{program.examPrepProvidersUrl ? (
						<ExamPrepSection
							control={control}
							providersUrl={program.examPrepProvidersUrl}
							abbrev={program.heading.highlight}
							disabled={isBusy}
						/>
					) : null}

					{/*
					 * Never gated away: the card is never empty. Everyone ticks the
					 * policy and marketing lines, and an exam adds the candidate
					 * acknowledgements on top.
					 */}
					<AcknowledgementsSection
						control={control}
						errors={errors}
						examPolicyUrl={program.examPolicyUrl}
						showCandidateAcknowledgements={showCandidateAcknowledgementsFor(
							load.program.kind,
						)}
						disabled={isBusy}
					/>
				</div>

				{/*
				 * For a guest the rail is also where the total and submit live, so
				 * the column becomes a stack. Its pin offset follows the BAR, not the
				 * controls: `top-28` leaves room for a bar that is there, `top-6` is
				 * right only when nothing sits above the grid.
				 */}
				<aside
					className={cn(
						showBar ? REGISTRATION_RAIL_COLUMN : REGISTRATION_RAIL_COLUMN_GUEST,
						controlsInRail && REGISTRATION_RAIL_STACK,
					)}
				>
					{controlsInRail ? submitControls : null}
					<RegistrationRail
						materials={state.visibleMaterials}
						onToggleMaterial={state.toggleMaterial}
						fees={fees}
						isPricing={state.isPricing}
						emptyState={railEmptyState(load.program.kind)}
						disabled={isBusy}
					/>
				</aside>
			</div>
		</form>
	)
}

export { ExamRegistrationForm }
