/**
 * Shared driver for mounting and filling the exam registration FORM in
 * component tests. The form needs a router (Link, useRouterState) so it mounts
 * through `renderWithRouterProviders`; sections are driven through the
 * rendered UI (Radix selects, tiles, checkboxes), never by reaching into
 * react-hook-form.
 */

import { screen } from "@testing-library/react"
import type { UserEvent } from "@testing-library/user-event"
import { vi } from "vitest"

import type {
	ExamRegistrationLoad,
	RegistrationCountry,
} from "@/api/registration/exam-types"
import type { PersonalInfoEditData } from "@/api/personal-info/types"
import { ExamRegistrationForm } from "@/components/forms/exam-registration/exam-registration-form"
import { EXAM_PROGRAMS, type ExamProgramConfig } from "@/config/registration"
import { examLoad } from "@/testing/factories/exam"
import {
	personalInfoEditData,
	portalAddressFields,
} from "@/testing/factories/personal-info"
import { renderWithRouterProviders } from "@/testing/router"

/**
 * Countries with distinct payment permissions, so the country-cascade rules
 * have something to bite on:
 *
 * - United States: everything allowed, province select (required), postal
 *   code required — the member factory's own country.
 * - France: forbids card and ACH — switching to it must re-pick a selected
 *   Stripe to Wire Transfer.
 * - Germany: forbids card and wire, compliance-tagged — re-picks to ACH and
 *   demands the explicit policy ticks.
 */
export function paymentCountries(): RegistrationCountry[] {
	return [
		{
			id: "cc-us",
			name: "United States",
			countryCode: "United States",
			phoneCode: "1",
			creditCardAllowed: true,
			wireAllowed: true,
			achAllowed: true,
			provinces: [{ name: "NJ" }, { name: "NY" }],
			provinceRequired: true,
			postalCodeRequired: true,
		},
		{
			id: "cc-fr",
			name: "France",
			countryCode: "France",
			phoneCode: "33",
			creditCardAllowed: false,
			wireAllowed: true,
			achAllowed: false,
		},
		{
			id: "cc-de",
			name: "Germany",
			countryCode: "Germany",
			phoneCode: "49",
			creditCardAllowed: false,
			wireAllowed: false,
			achAllowed: true,
			compliance: true,
		},
	]
}

/** The FRM-shaped load with the richer country list above. */
export function pricedExamLoad(
	overrides: Partial<ExamRegistrationLoad> = {},
): ExamRegistrationLoad {
	return examLoad({ countries: paymentCountries(), ...overrides })
}

type RenderExamFormOptions = {
	load?: ExamRegistrationLoad
	/** The programme's own copy; FRM unless a test is about another kind. */
	program?: ExamProgramConfig
	/** The wire type the form posts; defaults to the programme's own. */
	programType?: string
	/** null = guest seed (nothing prefilled). */
	profile?: PersonalInfoEditData | null
	isAuthenticated?: boolean
	regCode?: string
	trackCta?: string | null
}

/** Mounts the form under router + query providers with spy callbacks. */
export async function renderExamForm({
	load = pricedExamLoad(),
	// One address on file: shipping mirrors billing, so the billing card is
	// the only Country control until a test unticks "same as billing".
	profile = personalInfoEditData({
		mailing: portalAddressFields(),
		sameAsBilling: true,
	}),
	program = EXAM_PROGRAMS.frm,
	programType = program.registrationType,
	isAuthenticated = true,
	regCode,
	trackCta,
}: RenderExamFormOptions = {}) {
	const onRegistered = vi.fn()
	const onNavigateBack = vi.fn()
	const rendered = await renderWithRouterProviders(
		<ExamRegistrationForm
			load={load}
			program={program}
			programType={programType}
			profile={profile}
			regCode={regCode}
			trackCta={trackCta}
			isAuthenticated={isAuthenticated}
			onNavigateBack={onNavigateBack}
			onRegistered={onRegistered}
		/>,
	)
	return { ...rendered, onRegistered, onNavigateBack }
}

/**
 * Picks one option from a Radix Select by the trigger's accessible name.
 * Driven by pointer; the jsdom stubs for pointer capture / scrollIntoView in
 * `vitest.setup.ts` are what make this work.
 */
export async function chooseSelectOption(
	user: UserEvent,
	comboboxName: string | RegExp,
	optionName: string | RegExp,
) {
	await user.click(screen.getByRole("combobox", { name: comboboxName }))
	await user.click(await screen.findByRole("option", { name: optionName }))
}

/**
 * Completes the exam choice for Part I: picks the part, and the exam centre
 * of its earliest sitting (the sitting itself is auto-resolved because
 * `resolvePartSelection` pre-selects the earliest one).
 */
export async function chooseExamPartAndSite(user: UserEvent) {
	await chooseSelectOption(user, "Exam part", "FRM Exam Part I")
	await chooseSelectOption(user, "Where you will sit", "Boston")
}

/** Ticks the two mandatory candidate acknowledgements. */
export async function tickExamAcknowledgements(user: UserEvent) {
	await user.click(
		screen.getByRole("checkbox", { name: /Candidate Responsibility/ }),
	)
	await user.click(screen.getByRole("checkbox", { name: /Exam Policies/ }))
}
