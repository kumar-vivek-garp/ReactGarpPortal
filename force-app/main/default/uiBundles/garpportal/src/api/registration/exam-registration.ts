import {
	EXAMREG_UNREACHABLE,
	examregFetch,
} from "@/api/registration/examreg-fetch"
import type {
	ExamRegistrationLoad,
	FeesRequest,
	FeesResult,
	RegistrationOptions,
} from "@/api/registration/exam-types"

/**
 * Opens a registration form.
 *
 * A reg code that resolves to nothing does NOT fail the request — it comes
 * back 200 with `eligibility.isEligible: false` and no `examSelection`, so the
 * caller renders the refusal rather than an error.
 */
export function fetchExamRegistration(
	type: string,
	regCode?: string,
	courseCode?: string,
): Promise<ExamRegistrationLoad> {
	const params = new URLSearchParams({ type })
	if (regCode) params.set("regCode", regCode)
	if (courseCode) params.set("courseCode", courseCode)

	return examregFetch<ExamRegistrationLoad>(
		`/info?${params.toString()}`,
		{ method: "GET" },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Unable to open the registration form. Please try again.",
		},
	)
}

/**
 * Prices the cart. Re-run on every selection change.
 *
 * Everything is re-derived server-side, so the request carries ids and choices
 * only — the total shown here is a preview, and `register` prices again from
 * scratch when the order is written.
 */
export function calculateFees(request: FeesRequest): Promise<FeesResult> {
	return examregFetch<FeesResult>(
		"/fees",
		{ method: "POST", body: JSON.stringify(request) },
		{ unreachable: EXAMREG_UNREACHABLE, fallback: "Could not calculate fees." },
	)
}

/**
 * Company and school typeaheads. A second request on purpose: ~2,000 rows are
 * kept out of the load payload so the page paints first.
 */
export function fetchRegistrationOptions(): Promise<RegistrationOptions> {
	return examregFetch<RegistrationOptions>(
		"/options",
		{ method: "GET" },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Unable to load company and school suggestions.",
		},
	)
}
