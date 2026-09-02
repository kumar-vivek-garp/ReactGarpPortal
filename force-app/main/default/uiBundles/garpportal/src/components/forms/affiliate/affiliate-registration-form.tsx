import { useMemo } from "react"
import { useForm, useWatch, type SubmitHandler } from "react-hook-form"
import { Link, useRouterState } from "@tanstack/react-router"

import { AppError } from "@/api/client"
import type { AffiliateRegistrationLoad } from "@/api/registration"
import { Alert, AlertDescription, AlertTitle } from "@/components/atoms/alert"
import { Button } from "@/components/atoms/button"
import {
	EMPTY_AFFILIATE_VALUES,
	type AffiliateFormValues,
} from "@/components/forms/affiliate/affiliate-form-values"
import {
	REGISTRATION_BAR_CONTROL_GROUP,
	REGISTRATION_BAR_CONTROL_HEIGHT,
	REGISTRATION_BAR_SUBMIT,
	REGISTRATION_BAR_TITLE,
	REGISTRATION_BAR_TOTAL_BLOCK,
	REGISTRATION_GRID,
	REGISTRATION_MAIN_COLUMN,
	REGISTRATION_RAIL_COLUMN,
	REGISTRATION_STICKY_BAR,
} from "@/components/forms/registration-shell"
import { AffiliateRail } from "@/components/forms/affiliate/sections/affiliate-rail"
import { ConsentSection } from "@/components/forms/affiliate/sections/consent-section"
import { YourDetailsSection } from "@/components/forms/affiliate/sections/your-details-section"
import { LOGIN_PATH } from "@/auth/constants"
import { getReturnPath } from "@/auth/return-path"
import { cn } from "@/lib/utils"
import {
	AFFILIATE_REGISTRATION,
	AFFILIATE_REGISTRATION_HEADING,
	EMAIL_PATTERN,
} from "@/config/registration"
import {
	MustSignInError,
	useAffiliateSignUp,
	useVerifyAffiliateEmail,
} from "@/hooks/use-affiliate-registration"

type AffiliateRegistrationFormProps = {
	load: AffiliateRegistrationLoad
	onRegistered: () => void
}

/**
 * Affiliate membership sign-up — this app's "Create Account".
 *
 * Laid out as the exam forms are, not as the narrow auth card it used to be:
 * the same sticky bar carrying the title and the commitment, the same 60/40
 * split with a pinned rail. It is a registration in everything but price, and
 * squeezing eight fields plus three attestations into a 2xl splash card made a
 * short form feel like a long one.
 *
 * What it does *not* borrow is a cart. The affiliate programme's only order
 * line is AFREE, a zero-price product settled server-side, so there is no
 * pricing call, no payment section and no debounce — the rail states the offer
 * and the total is the constant "Free".
 *
 * Two rules come from the server payload rather than from this file:
 *
 * 1. **Whether the policy checkboxes appear.** `Country_Code__c.Compliance__c`
 *    is a tag ("GDPR", "CASL") rather than a flag; countries carrying one need
 *    explicit ticks, and everyone else gets the implicit notice above the
 *    button. Picking a different location switches between them mid-form.
 * 2. **Whether an email may register at all.** The affiliate programme does
 *    not set `allowMemberPublicRegistration`, so an email that already belongs
 *    to a member comes back `mustSignIn` and is answered with a link to sign
 *    in — not a retry.
 */
function AffiliateRegistrationForm({
	load,
	onRegistered,
}: AffiliateRegistrationFormProps) {
	const signUp = useAffiliateSignUp()
	const verifyEmail = useVerifyAffiliateEmail()
	/* Only read to build the post-sign-in return path. */
	const location = useRouterState({ select: (state) => state.location })

	const {
		control,
		register,
		handleSubmit,
		getValues,
		formState: { errors, isValid },
	} = useForm<AffiliateFormValues>({
		defaultValues: EMPTY_AFFILIATE_VALUES,
		/*
		 * `onTouched`, not `onSubmit`: the button below stays disabled until the
		 * form is valid, and `isValid` is only maintained when the mode is not
		 * `onSubmit`. `onTouched` waits for a first blur before showing a field's
		 * error, so nobody is told their email is invalid halfway through typing
		 * it, and it re-renders far less than `onChange`.
		 */
		mode: "onTouched",
	})

	// `useWatch`, not the destructured `watch()` — the latter returns a fresh
	// function each render, which opts the whole component out of memoization.
	const selectedCountry = useWatch({ control, name: "country" })

	const isComplianceCountry = useMemo(
		() =>
			load.countries.some(
				(country) =>
					country.countryCode === selectedCountry && country.compliance === true,
			),
		[load.countries, selectedCountry],
	)

	/**
	 * Identity check on blur, as GarpAppv1 does it — so somebody who already
	 * has an account learns that before filling the rest of the form. Skipped
	 * when the address is not yet a valid email, or when this exact address was
	 * already checked (the result is reused as the registration's session, so a
	 * normal fill-and-submit makes one identity call, not two).
	 */
	const handleIdentityBlur = () => {
		const { email, firstName, lastName } = getValues()
		const trimmed = email.trim()
		if (!EMAIL_PATTERN.test(trimmed)) return
		if (verifyEmail.data?.email === trimmed) return
		verifyEmail.mutate({ email: trimmed, firstName, lastName })
	}

	const onSubmit: SubmitHandler<AffiliateFormValues> = async (values) => {
		try {
			await signUp.mutateAsync({
				firstName: values.firstName,
				lastName: values.lastName,
				email: values.email,
				mobilePhoneCode: values.mobilePhoneCode,
				mobilePhone: values.mobilePhone,
				smsPromotionalUpdates: values.smsPromotionalUpdates,
				country: values.country,
				session: verifyEmail.data ?? null,
				// The three ticks are one consent server-side; on a non-compliance
				// country there are no ticks and submitting IS the agreement, which
				// is what the notice above the button says.
				privacyPolicy: isComplianceCountry
					? values.attestPrivacyNotice &&
						values.attestLimitationOfLiability &&
						values.attestReleaseAndWaiver
					: true,
			})
			onRegistered()
		} catch {
			// Rendered inline below — `mustSignIn` is a routine answer, not a toast.
		}
	}

	const isBusy = signUp.isPending
	const label = AFFILIATE_REGISTRATION.submitLabel
	// Either leg can say it: the blur check is advisory, the submit check binds.
	const mustSignIn =
		signUp.error instanceof MustSignInError ||
		verifyEmail.data?.mustSignIn === true
	const existingCustomer =
		!mustSignIn && verifyEmail.data?.isExistingCustomer === true
	const failureMessage =
		signUp.error && !mustSignIn
			? AppError.fromUnknown(signUp.error).messages[0]
			: null

	return (
		<form
			className="flex flex-col gap-6"
			onSubmit={(event) => {
				void handleSubmit(onSubmit)(event)
			}}
			noValidate
		>
			{/*
			 * One bar: what you are doing, what it costs and the commitment.
			 *
			 * Fully opaque, because content scrolling under a translucent bar reads
			 * as a rendering fault rather than as depth; and no negative margin,
			 * because bleeding it past the container makes it wider than its scroll
			 * parent and buys a few pixels of horizontal scroll.
			 *
			 * No back link, unlike the exam forms' bar. Every in-app parent is
			 * behind the session guard and this route is guest-only, so the only
			 * "back" available is off to garp.org — which is leaving, not going
			 * back, and not what a back arrow promises mid-form.
			 */}
			<div className={REGISTRATION_STICKY_BAR}>
				{/*
				 * An `h1`, not an `h2`: this is the page's only heading, and the page
				 * is linked from marketing email and from the Login card.
				 */}
				<h1
					className={cn(
						"w-full min-w-0 sm:w-auto sm:flex-1",
						REGISTRATION_BAR_TITLE,
					)}
				>
					<span className="text-garp-cyan">
						{AFFILIATE_REGISTRATION_HEADING.highlight}
					</span>
					{AFFILIATE_REGISTRATION_HEADING.suffix}
				</h1>

				<div className={REGISTRATION_BAR_CONTROL_GROUP}>
					{/*
					 * Pinned to the button's own height, matching the exam forms' total
					 * block, so the two bars line up. Nothing arrives late here — the
					 * figure is a constant — but the geometry is shared.
					 */}
					<div
						className={cn(
							REGISTRATION_BAR_CONTROL_HEIGHT,
							REGISTRATION_BAR_TOTAL_BLOCK,
						)}
					>
						<p className="text-caption leading-none text-muted-foreground">
							Total
						</p>
						<span className="text-lg leading-tight font-semibold text-primary">
							Free
						</span>
					</div>

					{/*
					 * Disabled until every required answer is in, so the first thing
					 * somebody learns about a missing field is not a failed submission.
					 * Everything this form validates is owned by react-hook-form, so
					 * `isValid` alone is the whole answer — unlike the exam forms,
					 * whose exam selection lives outside it.
					 */}
					<Button
						type="submit"
						size="lg"
						className={REGISTRATION_BAR_SUBMIT}
						disabled={isBusy || !isValid}
						title={
							isValid || isBusy
								? undefined
								: "Complete the required fields to continue."
						}
					>
						{isBusy ? "Registering…" : label}
					</Button>
				</div>
			</div>

			{/*
			 * Above the form rather than beside the email field: signing in is a
			 * full navigation that discards whatever has been typed, so the offer
			 * has to arrive before anyone starts typing.
			 */}
			<Alert>
				<AlertDescription>
					{AFFILIATE_REGISTRATION.byline}{" "}
					<Link
						to={LOGIN_PATH}
						search={{ startUrl: getReturnPath(location) }}
						className="font-medium text-primary underline underline-offset-2"
					>
						Already have an account? Sign in
					</Link>
				</AlertDescription>
			</Alert>

			{/*
			 * GarpAppv1 raises a modal for any returning customer but only
			 * `mustSignIn` actually blocks — so this states both cases inline and
			 * only the second one carries a way out.
			 */}
			{mustSignIn ? (
				<Alert variant="destructive">
					<AlertTitle>You already have an account</AlertTitle>
					<AlertDescription className="flex flex-col items-start gap-3">
						<span>
							An account already exists for this email address. Please sign in
							instead — you will start again from the sign-in page, so nothing
							typed here is kept.
						</span>
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
						We already hold a record for this email address. You can carry on —
						this membership will be added to it.
					</AlertDescription>
				</Alert>
			) : null}

			{failureMessage ? (
				<Alert variant="destructive">
					<AlertTitle>Unable to complete your registration</AlertTitle>
					<AlertDescription>{failureMessage}</AlertDescription>
				</Alert>
			) : null}

			<div className={REGISTRATION_GRID}>
				<div className={REGISTRATION_MAIN_COLUMN}>
					<YourDetailsSection
						register={register}
						control={control}
						errors={errors}
						countries={load.countries}
						onIdentityBlur={handleIdentityBlur}
						disabled={isBusy}
					/>

					<ConsentSection
						control={control}
						errors={errors}
						isComplianceCountry={isComplianceCountry}
						submitLabel={label}
						disabled={isBusy}
					/>
				</div>

				{/*
				 * `h-fit` + `sticky` is what pins the rail: it sizes to its content
				 * and stays put while the main column scrolls past it. `top-22` is
				 * the sticky bar (4rem) plus the grid gap (1.5rem) — a larger `top`
				 * pushes the rail down below the column beside it on first paint.
				 */}
				<aside className={REGISTRATION_RAIL_COLUMN}>
					<AffiliateRail />
				</aside>
			</div>
		</form>
	)
}

export { AffiliateRegistrationForm }
