import { useMemo, useState } from "react"
import {
	Controller,
	useForm,
	useWatch,
	type SubmitHandler,
} from "react-hook-form"
import { Link } from "@tanstack/react-router"
import { CheckCircle2 } from "lucide-react"

import { AppError } from "@/api/client"
import type { RegistrationCountry } from "@/api/registration"
import { Alert, AlertDescription, AlertTitle } from "@/components/atoms/alert"
import { Button } from "@/components/atoms/button"
import {
	Card,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { Checkbox } from "@/components/atoms/checkbox"
import { Input } from "@/components/atoms/input"
import { Label } from "@/components/atoms/label"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { Skeleton } from "@/components/atoms/skeleton"
import {
	AFFILIATE_REGISTRATION,
	EMAIL_PATTERN,
	isEnglishName,
	PHONE_PATTERN,
	POLICY_LINKS,
	REGISTRATION_LIMITS,
	SMS_COPY,
} from "@/config/registration"
import {
	MustSignInError,
	useAffiliateRegistration,
	useAffiliateSignUp,
	useVerifyAffiliateEmail,
} from "@/hooks/use-affiliate-registration"

type AffiliateFormValues = {
	email: string
	firstName: string
	lastName: string
	/** `"<countryCode> (+<phoneCode>)"` — GarpAppv1's own option value format. */
	mobilePhoneCode: string
	mobilePhone: string
	smsPromotionalUpdates: boolean
	/** `RegistrationCountry.countryCode`, not the display name. */
	country: string
	attestPrivacyNotice: boolean
	attestLimitationOfLiability: boolean
	attestReleaseAndWaiver: boolean
}

function FieldError({ message }: { message?: string }) {
	if (!message) return null
	return (
		<p className="text-caption text-destructive" role="alert">
			{message}
		</p>
	)
}

function Field({
	id,
	label,
	error,
	children,
}: {
	id: string
	label: string
	error?: string
	children: React.ReactNode
}) {
	return (
		<div className="flex flex-col gap-2">
			<Label htmlFor={id} className="font-bold">
				{label}
				<span className="text-destructive" aria-hidden>
					{" "}
					*
				</span>
			</Label>
			{children}
			<FieldError message={error} />
		</div>
	)
}

function PolicyLink({ href, children }: { href: string; children: string }) {
	return (
		<a
			href={href}
			target="_blank"
			rel="noreferrer"
			className="font-semibold text-primary hover:underline"
		>
			{children}
		</a>
	)
}

/** One attestation row — a checkbox whose label carries the policy link. */
function Attestation({
	id,
	checked,
	onCheckedChange,
	invalid,
	disabled,
	children,
}: {
	id: string
	checked: boolean
	onCheckedChange: (value: boolean) => void
	invalid: boolean
	disabled: boolean
	children: React.ReactNode
}) {
	return (
		<div className="flex items-start gap-3">
			<Checkbox
				id={id}
				checked={checked}
				onCheckedChange={(value) => {
					onCheckedChange(value === true)
				}}
				aria-invalid={invalid ? true : undefined}
				disabled={disabled}
				className="mt-0.5"
			/>
			<Label htmlFor={id} className="text-body leading-5 font-normal">
				{children}
			</Label>
		</div>
	)
}

function AffiliateRegistrationSkeleton() {
	return (
		<div className="flex flex-col gap-4" aria-busy>
			{/* Mirrors the real grid so the card does not resize when data lands. */}
			<div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
				{Array.from({ length: 4 }).map((_, index) => (
					<div key={index} className="flex flex-col gap-2">
						<Skeleton className="h-4 w-32" />
						<Skeleton className="h-10 w-full rounded-xl" />
					</div>
				))}
				<div className="flex flex-col gap-2 sm:col-span-2">
					<Skeleton className="h-4 w-32" />
					<Skeleton className="h-10 w-full rounded-xl" />
				</div>
			</div>
			<Skeleton className="h-[60px] w-full rounded-xl" />
		</div>
	)
}

/**
 * Free Affiliate membership sign-up — the portal's "Create Account".
 *
 * Deliberately has no cart, no fee table and no payment step. The affiliate
 * programme's only line is AFREE, a zero-price product, so the order settles
 * server-side with nothing to charge; the flow behind the single submit is
 * verify → register → close order (see `useAffiliateSignUp`).
 *
 * Two rules come from the server payload rather than from this file:
 *
 * 1. **Whether the policy checkboxes appear.** `Country_Code__c.Compliance__c`
 *    is a tag ("GDPR", "CASL") rather than a flag; countries carrying one need
 *    explicit ticks, and everyone else gets the implicit notice above the
 *    button. Picking a different country switches between them mid-form.
 * 2. **Whether an email may register at all.** The affiliate programme does
 *    not set `allowMemberPublicRegistration`, so an email that already belongs
 *    to a member comes back `mustSignIn` and is answered with a link to sign
 *    in — not a retry.
 */
function AffiliateRegistrationForm() {
	const load = useAffiliateRegistration()
	const signUp = useAffiliateSignUp()
	const verifyEmail = useVerifyAffiliateEmail()
	const [completed, setCompleted] = useState(false)

	const {
		control,
		register,
		handleSubmit,
		getValues,
		formState: { errors, isSubmitting },
	} = useForm<AffiliateFormValues>({
		defaultValues: {
			email: "",
			firstName: "",
			lastName: "",
			mobilePhoneCode: "",
			mobilePhone: "",
			smsPromotionalUpdates: false,
			country: "",
			attestPrivacyNotice: false,
			attestLimitationOfLiability: false,
			attestReleaseAndWaiver: false,
		},
		mode: "onSubmit",
	})

	const countries = useMemo<RegistrationCountry[]>(
		() =>
			[...(load.data?.countries ?? [])].sort((a, b) =>
				a.name.localeCompare(b.name),
			),
		[load.data?.countries],
	)

	/**
	 * Only countries that actually carry a dial code. Value format is
	 * GarpAppv1's: `"<countryCode> (+<phoneCode>)"` — Apex reads the digits
	 * back out of it, so the country half has to travel with them.
	 */
	const phoneCodeOptions = useMemo(
		() =>
			countries
				.filter((country) => Boolean(country.phoneCode))
				.map((country) => ({
					value: `${country.countryCode} (+${country.phoneCode})`,
					label: `${country.name} (+${country.phoneCode})`,
				})),
		[countries],
	)

	// `useWatch`, not the destructured `watch()` — the latter returns a fresh
	// function each render, which opts the whole component out of memoization.
	const selectedCountry = useWatch({ control, name: "country" })
	const needsAttestations = useMemo(
		() =>
			countries.some(
				(country) =>
					country.countryCode === selectedCountry && country.compliance === true,
			),
		[countries, selectedCountry],
	)

	/**
	 * Identity check on blur, as GarpAppv1 does it — so somebody who already
	 * has an account learns that before filling the rest of the form. Skipped
	 * when the address is not yet a valid email, or when this exact address was
	 * already checked (the result is reused as the registration's session).
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
				privacyPolicy: needsAttestations
					? values.attestPrivacyNotice &&
						values.attestLimitationOfLiability &&
						values.attestReleaseAndWaiver
					: true,
			})
			setCompleted(true)
		} catch {
			// Rendered inline below — `mustSignIn` is a routine answer, not a toast.
		}
	}

	const isPending = signUp.isPending || isSubmitting
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

	if (completed) {
		return (
			<Card className="w-full max-w-2xl bg-secondary">
				<CardContent className="flex flex-col items-center gap-4 py-8 text-center">
					<CheckCircle2 className="size-10 text-success-green" aria-hidden />
					<CardTitle className="font-sans text-title font-medium">
						You&rsquo;re an Affiliate Member
					</CardTitle>
					<p className="text-body text-muted-foreground">
						Your Affiliate membership is active. Check your inbox for the
						welcome email with your GARP ID.
					</p>
					<Button asChild className="mt-2 h-[60px] w-full max-w-sm">
						<Link to="/Login">Go to Sign In</Link>
					</Button>
				</CardContent>
			</Card>
		)
	}

	const ineligible =
		load.data && load.data.eligibility.isEligible === false
			? (load.data.eligibility.message ??
				"Affiliate registration is not available right now.")
			: null

	return (
		/*
		 * Scrolled INSIDE the card so a tall form never drags the GARP logo and
		 * footer off screen — only the field area moves.
		 *
		 * The 17rem is the shell's chrome around this card (logo, footer, the
		 * gaps between them and the page padding), so at a normal viewport the
		 * page itself does not scroll at all. `svh` rather than `vh` because a
		 * mobile browser's collapsing address bar makes `vh` taller than what
		 * is actually visible. The floor stops the card collapsing to a slit on
		 * a short window — below that the page scrolls again, which is the
		 * right trade at that size.
		 */
		<Card className="flex max-h-[calc(100svh-17rem)] min-h-[20rem] w-full max-w-2xl flex-col bg-secondary">
			<CardHeader className="shrink-0">
				<CardTitle className="font-sans text-center text-title font-medium">
					{AFFILIATE_REGISTRATION.title}
				</CardTitle>
				<p className="text-center text-body text-muted-foreground">
					{AFFILIATE_REGISTRATION.byline}
				</p>
			</CardHeader>
			<CardContent className="flex-1 overflow-y-auto">
				{load.isPending ? <AffiliateRegistrationSkeleton /> : null}

				{load.isError ? (
					<Alert variant="destructive">
						<AlertTitle>Unable to open registration</AlertTitle>
						<AlertDescription>
							{AppError.fromUnknown(load.error).messages[0]}
						</AlertDescription>
					</Alert>
				) : null}

				{ineligible ? (
					<Alert variant="destructive">
						<AlertTitle>Registration unavailable</AlertTitle>
						<AlertDescription>{ineligible}</AlertDescription>
					</Alert>
				) : null}

				{load.data && !ineligible ? (
					<form
						className="flex flex-col gap-4"
						onSubmit={(event) => {
							void handleSubmit(onSubmit)(event)
						}}
						noValidate
					>
						{/*
						 * GarpAppv1's Returning card. It renders a modal for any
						 * returning customer but only `mustSignIn` actually blocks —
						 * so this states both cases and only blocks on the second.
						 */}
						{mustSignIn || existingCustomer ? (
							<Alert variant={mustSignIn ? "destructive" : "default"}>
								<AlertTitle>
									{mustSignIn
										? "You already have an account"
										: "We found your record"}
								</AlertTitle>
								<AlertDescription>
									An account already exists for this email address.{" "}
									{mustSignIn
										? "Please sign in to continue."
										: "Sign in to keep this registration on your existing record."}{" "}
									<Link
										to="/Login"
										className="font-semibold text-primary hover:underline"
									>
										Sign In
									</Link>
								</AlertDescription>
							</Alert>
						) : null}

						{failureMessage ? (
							<Alert variant="destructive">
								<AlertTitle>Registration failed</AlertTitle>
								<AlertDescription>{failureMessage}</AlertDescription>
							</Alert>
						) : null}

						{/*
						 * Two columns from `sm` up, one below. Names lead so that by
						 * the time the email field blurs and fires the identity check,
						 * it has a first and last name to send with it.
						 */}
						<div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
							<Field
								id="firstName"
								label="First Name"
								error={errors.firstName?.message}
							>
								<Input
									id="firstName"
									autoComplete="given-name"
									placeholder="First Name / Given Name"
									maxLength={REGISTRATION_LIMITS.nameMaxLength}
									disabled={isPending}
									aria-invalid={errors.firstName ? true : undefined}
									className="h-10 rounded-xl bg-background"
									{...register("firstName", {
										required: "Please enter your first name / given name.",
										minLength: {
											value: REGISTRATION_LIMITS.nameMinLength,
											message: "Your first name must be more than 1 character.",
										},
										validate: (value) =>
											isEnglishName(value) ||
											"Please enter only English characters.",
										onBlur: handleIdentityBlur,
									})}
								/>
							</Field>

							<Field
								id="lastName"
								label="Last Name"
								error={errors.lastName?.message}
							>
								<Input
									id="lastName"
									autoComplete="family-name"
									placeholder="Last Name / Surname"
									maxLength={REGISTRATION_LIMITS.nameMaxLength}
									disabled={isPending}
									aria-invalid={errors.lastName ? true : undefined}
									className="h-10 rounded-xl bg-background"
									{...register("lastName", {
										required: "Please enter your last name / surname.",
										minLength: {
											value: REGISTRATION_LIMITS.nameMinLength,
											message: "Your last name must be more than 1 character.",
										},
										validate: (value) =>
											isEnglishName(value) ||
											"Please enter only English characters.",
										onBlur: handleIdentityBlur,
									})}
								/>
							</Field>

							<Field
								id="email"
								label="Email Address"
								error={errors.email?.message}
							>
								<Input
									id="email"
									type="email"
									autoComplete="email"
									placeholder="Name@example.com"
									maxLength={REGISTRATION_LIMITS.emailMaxLength}
									disabled={isPending}
									aria-invalid={errors.email ? true : undefined}
									className="h-10 rounded-xl bg-background"
									{...register("email", {
										required: "Email address is required.",
										pattern: {
											value: EMAIL_PATTERN,
											message: "Please enter a valid email address.",
										},
										onBlur: handleIdentityBlur,
									})}
								/>
							</Field>

							<Field
								id="country"
								label="Location"
								error={errors.country?.message}
							>
								<Controller
									control={control}
									name="country"
									rules={{ required: "Please select your location." }}
									render={({ field }) => (
										<Select
											value={field.value}
											onValueChange={field.onChange}
											disabled={isPending}
										>
											<SelectTrigger
												id="country"
												aria-invalid={errors.country ? true : undefined}
												className="h-10 w-full rounded-xl bg-background"
											>
												<SelectValue placeholder="Select Location" />
											</SelectTrigger>
											<SelectContent>
												{countries.map((country) => (
													<SelectItem
														key={country.id}
														value={country.countryCode}
													>
														{country.name}
													</SelectItem>
												))}
											</SelectContent>
										</Select>
									)}
								/>
							</Field>

							{/*
							 * Spans the grid: the dial code and the number are one field
							 * split 1:2, so pairing it with anything else would give four
							 * controls on one row.
							 *
							 * Required on every GarpAppv1 registration kind, affiliate
							 * included — its validation sits outside the guest-only block
							 * in useExamRegistrationForm.sectionErrors.
							 */}
							<div className="flex flex-col gap-2 sm:col-span-2">
								<Label htmlFor="mobilePhone" className="font-bold">
									Mobile Phone
									<span className="text-destructive" aria-hidden>
										{" "}
										*
									</span>
								</Label>
								<div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
									<Controller
										control={control}
										name="mobilePhoneCode"
										rules={{ required: "Please select a country code." }}
										render={({ field }) => (
											<Select
												value={field.value}
												onValueChange={field.onChange}
												disabled={isPending}
											>
												<SelectTrigger
													id="mobilePhoneCode"
													aria-label="Mobile phone country code"
													aria-invalid={
														errors.mobilePhoneCode ? true : undefined
													}
													className="h-10 w-full rounded-xl bg-background"
												>
													<SelectValue placeholder="Select a Country Code" />
												</SelectTrigger>
												<SelectContent>
													{phoneCodeOptions.map((option) => (
														<SelectItem
															key={option.value}
															value={option.value}
														>
															{option.label}
														</SelectItem>
													))}
												</SelectContent>
											</Select>
										)}
									/>
									<div className="sm:col-span-2">
										<Input
											id="mobilePhone"
											type="tel"
											inputMode="numeric"
											autoComplete="tel"
											disabled={isPending}
											aria-invalid={errors.mobilePhone ? true : undefined}
											className="h-10 rounded-xl bg-background"
											{...register("mobilePhone", {
												required:
													"Please select a country code and enter a mobile phone number.",
												pattern: {
													value: PHONE_PATTERN,
													message: "Please enter between 7 and 15 numbers.",
												},
											})}
										/>
									</div>
								</div>
								<FieldError
									message={
										errors.mobilePhoneCode?.message ??
										errors.mobilePhone?.message
									}
								/>
								<p className="text-caption text-muted-foreground">
									{SMS_COPY.notice}
								</p>
							</div>

							<div className="flex flex-col gap-2 sm:col-span-2">
								<p className="text-body font-bold">
									{SMS_COPY.promotionalHeading}
								</p>
								<Controller
									control={control}
									name="smsPromotionalUpdates"
									render={({ field }) => (
										<Attestation
											id="smsPromotionalUpdates"
											checked={field.value}
											onCheckedChange={field.onChange}
											invalid={false}
											disabled={isPending}
										>
											{SMS_COPY.promotionalOptIn}
										</Attestation>
									)}
								/>
							</div>
						</div>

						{needsAttestations ? (
							<fieldset className="flex flex-col gap-3">
								<legend className="sr-only">Policy attestations</legend>
								<Controller
									control={control}
									name="attestPrivacyNotice"
									rules={{
										required: "You must confirm you have read our policies.",
									}}
									render={({ field }) => (
										<Attestation
											id="attestPrivacyNotice"
											checked={field.value}
											onCheckedChange={field.onChange}
											invalid={Boolean(errors.attestPrivacyNotice)}
											disabled={isPending}
										>
											Yes, I have read GARP&rsquo;s{" "}
											<PolicyLink href={POLICY_LINKS.privacyNotice}>
												Privacy Notice
											</PolicyLink>{" "}
											and{" "}
											<PolicyLink href={POLICY_LINKS.codeOfConduct}>
												Code of Conduct
											</PolicyLink>
											.
										</Attestation>
									)}
								/>
								<Controller
									control={control}
									name="attestLimitationOfLiability"
									rules={{
										required: "You must confirm you have read our policies.",
									}}
									render={({ field }) => (
										<Attestation
											id="attestLimitationOfLiability"
											checked={field.value}
											onCheckedChange={field.onChange}
											invalid={Boolean(errors.attestLimitationOfLiability)}
											disabled={isPending}
										>
											Yes, I have read GARP&rsquo;s{" "}
											<PolicyLink href={POLICY_LINKS.limitationOfLiability}>
												Limitation of Liability
											</PolicyLink>
											.
										</Attestation>
									)}
								/>
								<Controller
									control={control}
									name="attestReleaseAndWaiver"
									rules={{
										required: "You must confirm you have read our policies.",
									}}
									render={({ field }) => (
										<Attestation
											id="attestReleaseAndWaiver"
											checked={field.value}
											onCheckedChange={field.onChange}
											invalid={Boolean(errors.attestReleaseAndWaiver)}
											disabled={isPending}
										>
											Yes, I have read GARP&rsquo;s{" "}
											<PolicyLink href={POLICY_LINKS.releaseAndWaiver}>
												Waiver and Release
											</PolicyLink>
											.
										</Attestation>
									)}
								/>
								{errors.attestPrivacyNotice ||
								errors.attestLimitationOfLiability ||
								errors.attestReleaseAndWaiver ? (
									<FieldError message="You must confirm you have read our policies." />
								) : null}
							</fieldset>
						) : (
							<p className="text-caption text-muted-foreground">
								By clicking{" "}
								<strong>{AFFILIATE_REGISTRATION.submitLabel}</strong> you agree
								to the{" "}
								<PolicyLink href={POLICY_LINKS.privacyNotice}>
									Privacy Notice
								</PolicyLink>
								,{" "}
								<PolicyLink href={POLICY_LINKS.codeOfConduct}>
									Code of Conduct
								</PolicyLink>
								,{" "}
								<PolicyLink href={POLICY_LINKS.limitationOfLiability}>
									Limitation of Liability
								</PolicyLink>{" "}
								and{" "}
								<PolicyLink href={POLICY_LINKS.releaseAndWaiver}>
									Waiver and Release
								</PolicyLink>
								, and to receiving emails from GARP and select third party
								providers with news, special offers, promotions and future
								messages that may be of interest to you.
							</p>
						)}

						<Button type="submit" className="mt-2 h-[60px]" disabled={isPending}>
							{isPending ? "Registering…" : AFFILIATE_REGISTRATION.submitLabel}
						</Button>

						<div className="flex items-center justify-center gap-2 text-body">
							<span className="text-muted-foreground">
								Already have an account?
							</span>
							<Link
								to="/Login"
								className="font-semibold text-primary hover:underline"
							>
								Sign In
							</Link>
						</div>
					</form>
				) : null}
			</CardContent>
		</Card>
	)
}

export { AffiliateRegistrationForm }
