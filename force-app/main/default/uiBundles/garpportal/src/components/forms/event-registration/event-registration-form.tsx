import { useMemo, useState } from "react"
import { useQuery } from "@tanstack/react-query"
import { Link, useLocation } from "@tanstack/react-router"
import { useForm } from "react-hook-form"

import type { PersonalInfoEditData } from "@/api/personal-info/types"
import type {
	EventCountry,
	EventRegistrationLoad,
	EventVariant,
	EventView,
} from "@/api/registration/event-types"
import { eventOptionsQueryOptions } from "@/api/registration/query-options"
import { LOGIN_PATH } from "@/auth/constants"
import { getReturnPath } from "@/auth/return-path"
import { Alert, AlertDescription } from "@/components/atoms/alert"
import { Button } from "@/components/atoms/button"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
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
	toEventFormValues,
	type EventFormValues,
} from "@/components/forms/event-registration/event-form-values"
import { IndividualDetailsSection } from "@/components/forms/event-registration/sections/individual-details-section"
import { AttendanceSection } from "@/components/forms/event-registration/sections/attendance-section"
import { AddressSection } from "@/components/forms/event-registration/sections/address-section"
import { ActivitySection } from "@/components/forms/event-registration/sections/activity-section"
import { QuestionSection } from "@/components/forms/event-registration/sections/question-section"
import { ConsentSection } from "@/components/forms/event-registration/sections/consent-section"
import { AttestationSection } from "@/components/forms/event-registration/sections/attestation-section"
import { ConfirmEventRegistrationDialog } from "@/components/forms/event-registration/sections/confirm-event-registration-dialog"
import { EventSummaryRail } from "@/components/forms/event-registration/sections/event-summary-rail"
import { EVENT_REGISTRATION_TITLES } from "@/config/event-registration"
import {
	showActivityCard,
	showAddressCard,
	showAttendanceSelect,
	showProfessionalFields,
	showQuestionCard,
	submitLabel,
} from "@/lib/event-registration-presentation"
import { formatMoney } from "@/lib/account-format"
import { cn } from "@/lib/utils"

type EventRegistrationFormProps = {
	variant: EventVariant
	load: EventRegistrationLoad
	event: EventView
	/** The member's profile — the seed for identity when the load has none. */
	profile: PersonalInfoEditData | null
	/** The CLIENT session — decides links and prefill chrome, never submit rules. */
	isClientAuthenticated: boolean
	/** `useSubpageTransition().exit` — plays the spring, then runs the navigation. */
	onNavigateBack?: (run: () => void) => void
	submitting: boolean
	submitError: string | null
	onSubmit: (values: EventFormValues, selectedCountry: EventCountry | null) => void
}

/**
 * The form itself — react-hook-form owner, one card per concern, single
 * column. The sticky bar carries the page's h1 (on the public route it is the
 * document's only heading), the fixed fee, and the submit.
 */
function EventRegistrationForm({
	variant,
	load,
	event,
	profile,
	isClientAuthenticated,
	onNavigateBack,
	submitting,
	submitError,
	onSubmit,
}: EventRegistrationFormProps) {
	const seededValues = toEventFormValues(load.contact, profile)
	const {
		register,
		control,
		handleSubmit,
		formState: { errors, isValid },
	} = useForm<EventFormValues>({
		mode: "onTouched",
		defaultValues: seededValues,
	})

	// The disabled-query trap: only a webcast ever asks for countries, and a
	// disabled query sits `pending` forever — so it exists only for webcasts
	// and nothing outside the address card waits on it.
	const wantsCountries = showAddressCard(variant)
	const options = useQuery({
		...eventOptionsQueryOptions,
		enabled: wantsCountries,
	})
	const countries = useMemo(
		() => (wantsCountries ? (options.data?.countries ?? []) : []),
		[wantsCountries, options.data],
	)
	const findCountry = useMemo(() => {
		const byKey = new Map<string, EventCountry>()
		for (const country of countries) {
			if (country.countryCode) byKey.set(country.countryCode, country)
			byKey.set(country.name, country)
		}
		return (value: string) => byKey.get(value) ?? null
	}, [countries])

	const amountDue = load.rates?.amountDue ?? 0
	const location = useLocation()

	/**
	 * Hide the identity fields when they prefilled from the member's record —
	 * registering does not change the record, so showing them invites edits
	 * that look saved to the account but are not (the exam form's rule). The
	 * seeded values stay in form state and still travel with the registration.
	 *
	 * Both conditions on purpose: the client session says who is looking, and
	 * a seeded email (from the event load OR the member profile) guarantees
	 * there are real values to travel — hiding empty fields would post an
	 * empty identity.
	 */
	const hideIdentityFields =
		isClientAuthenticated && Boolean(seededValues.email.trim())

	/**
	 * A PAID submit is staged behind the confirm dialog — everything past
	 * `register` writes records, so the figure gets one more look. Free events
	 * submit directly. Confirm closes the dialog as it fires, so a failure
	 * renders against the form rather than behind a modal.
	 */
	const [pendingSubmit, setPendingSubmit] = useState<{
		values: EventFormValues
		selectedCountry: EventCountry | null
	} | null>(null)

	const submit = handleSubmit((values) => {
		const selectedCountry = wantsCountries ? findCountry(values.country) : null
		if (amountDue > 0) {
			setPendingSubmit({ values, selectedCountry })
			return
		}
		onSubmit(values, selectedCountry)
	})

	const confirmSubmit = () => {
		if (!pendingSubmit) return
		const staged = pendingSubmit
		setPendingSubmit(null)
		onSubmit(staged.values, staged.selectedCountry)
	}

	return (
		<form noValidate onSubmit={submit}>
			<div className={REGISTRATION_STICKY_BAR}>
				<div className={REGISTRATION_BAR_TITLE_GROUP}>
					{/*
					 * No back link for a guest — every in-app parent is behind the
					 * session guard, and garp.org is leaving, not "back". The divider
					 * goes with it, same as the exam form.
					 */}
					{isClientAuthenticated ? (
						<>
							<ProgramsSubpageHeader
								back={{ kind: "events" }}
								onNavigateBack={onNavigateBack}
								iconOnlyBackOnMobile
							/>
							<div
								className="hidden h-6 w-px shrink-0 bg-border sm:block"
								aria-hidden
							/>
						</>
					) : null}
					<h1 className={REGISTRATION_BAR_TITLE}>
						{event.title ?? EVENT_REGISTRATION_TITLES[variant]}
					</h1>
				</div>

				<div className={REGISTRATION_BAR_CONTROL_GROUP}>
					{/* Pinned to the button's height so nothing moves the bar. The
					    figure is fixed at load — no repricing for events. */}
					<div
						className={cn(
							REGISTRATION_BAR_CONTROL_HEIGHT,
							REGISTRATION_BAR_TOTAL_BLOCK,
						)}
					>
						<p className="text-caption leading-none text-muted-foreground">
							Total
						</p>
						<span
							className={cn(
								"text-lg leading-tight font-semibold",
								amountDue > 0 ? "text-primary" : "text-muted-foreground",
							)}
						>
							{amountDue > 0 ? formatMoney(amountDue, "USD") : "Free"}
						</span>
					</div>
					<Button
						type="submit"
						size="lg"
						className={REGISTRATION_BAR_SUBMIT}
						disabled={submitting || !isValid}
						title={
							!isValid ? "Complete the required fields to continue." : undefined
						}
					>
						{submitting ? "Submitting…" : submitLabel(amountDue)}
					</Button>
				</div>
			</div>

			{/*
			 * Guest-only, above the form rather than beside the email field:
			 * signing in is a full navigation that discards whatever has been
			 * typed, so the offer has to arrive before anyone starts typing.
			 */}
			{isClientAuthenticated ? null : (
				<Alert>
					<AlertDescription>
						Already have a GARP account? Signing in prefills your details and
						links this registration to your record.{" "}
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

			{submitError ? (
				<p role="alert" className="mt-2 text-sm text-destructive">
					{submitError}
				</p>
			) : null}

			{/* The exam form's 60/40: form left, pinned summary rail right —
			    the running facts and total stay on screen while the form scrolls. */}
			<div className={cn(REGISTRATION_GRID, "mt-4 pb-6")}>
				<div className={REGISTRATION_MAIN_COLUMN}>
					<IndividualDetailsSection
						register={register}
						errors={errors}
						hideIdentityFields={hideIdentityFields}
						showProfessionalFields={showProfessionalFields(variant, event)}
					/>

					{showAttendanceSelect(event) ? (
						<AttendanceSection control={control} errors={errors} />
					) : null}

					{showAddressCard(variant) ? (
						<AddressSection
							register={register}
							control={control}
							errors={errors}
							countries={countries}
							findCountry={findCountry}
						/>
					) : null}

					{showActivityCard(variant, event) ? (
						<ActivitySection
							register={register}
							control={control}
							event={event}
						/>
					) : null}

					{showQuestionCard(variant, event) ? (
						<QuestionSection register={register} event={event} />
					) : null}

					<ConsentSection control={control} event={event} />

					<AttestationSection control={control} errors={errors} />
				</div>

				<aside className={REGISTRATION_RAIL_COLUMN}>
					<EventSummaryRail event={event} rates={load.rates} />
				</aside>
			</div>

			<ConfirmEventRegistrationDialog
				open={pendingSubmit !== null}
				eventTitle={event.title ?? EVENT_REGISTRATION_TITLES[variant]}
				amountDue={amountDue}
				confirming={submitting}
				onConfirm={confirmSubmit}
				onCancel={() => setPendingSubmit(null)}
			/>
		</form>
	)
}

export { EventRegistrationForm }
