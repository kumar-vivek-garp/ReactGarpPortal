import {
	EXAMREG_UNREACHABLE,
	examregFetch,
} from "@/api/registration/examreg-fetch"
import type {
	AddressCheckResult,
	CheckoutResult,
	ExamRegisterRequest,
	ExamRegisterResult,
	ExamRegistrationLoad,
	ExamVerifyCustomerRequest,
	FeesRequest,
	FeesResult,
	PaymentStatusResult,
	RegistrationOptions,
	VerifyCustomerResult,
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

/**
 * Identifies the customer before the order is written.
 *
 * Returns `mustSignIn` when the email already belongs to a member and the
 * programme forbids public registration, plus the `Form_Data__c` session id
 * that `register` quotes back. Also opens the session that carries UTM
 * attribution, which is why it is called once rather than on every keystroke.
 */
export function verifyExamCustomer(
	request: ExamVerifyCustomerRequest,
): Promise<VerifyCustomerResult> {
	return examregFetch<VerifyCustomerResult>(
		"/verifyCustomer",
		{ method: "POST", body: JSON.stringify(request) },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Unable to check that email address. Please try again.",
		},
	)
}

/**
 * Checks the address against the country's rules.
 *
 * Only the COUNTRY is checked — that it is present, known, and permits
 * billing and shipping. Street, city and postal code never reach the server,
 * so the form owns those rules entirely.
 *
 * Takes the identical body as `register`, not a subset.
 */
export function verifyExamAddress(
	request: ExamRegisterRequest,
): Promise<AddressCheckResult> {
	return examregFetch<AddressCheckResult>(
		"/verifyAddress",
		{ method: "POST", body: JSON.stringify(request) },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Please check your address.",
		},
	)
}

/**
 * Writes the Opportunity, line items, contracts and exam attempts.
 *
 * Re-derives eligibility and re-prices the whole cart server-side first, so
 * the total shown in the form is only ever a preview — tampering with it
 * changes nothing.
 */
export function registerExam(
	request: ExamRegisterRequest,
): Promise<ExamRegisterResult> {
	return examregFetch<ExamRegisterResult>(
		"/register",
		{ method: "POST", body: JSON.stringify(request) },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Unable to complete your registration. Please try again.",
		},
	)
}

/**
 * Opens a Stripe-HOSTED checkout session for a pending order.
 *
 * Not the same mechanism as the orders page, which redirects to an Experience
 * Cloud `/stripe_checkout` page with a session cookie. This returns a URL on
 * Stripe's own domain, and the org's existing webhook finalises the order by
 * `metadata[orderid]` — the bundle never sees card details.
 *
 * `successUrl` / `cancelUrl` are ours to choose, so the browser comes back to
 * whichever route served the form.
 */
export function startExamCheckout(args: {
	orderId: string
	successUrl: string
	cancelUrl: string
}): Promise<CheckoutResult> {
	return examregFetch<CheckoutResult>(
		"/checkout",
		{ method: "POST", body: JSON.stringify(args) },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Unable to start checkout.",
		},
	)
}

/**
 * Completes a wire / ACH / zero-total order server-side.
 *
 * Takes no money — it records the transaction that lets the order close and
 * releases the contact's trigger hold.
 *
 * NOT idempotent, and must never be retried: Apex refuses a second call on an
 * order that has already completed, and a duplicate writes a second approved
 * transaction, which is how an order ends up looking paid twice.
 */
export function payExamOrder(
	orderId: string,
	paymentType: string | null,
): Promise<Record<string, unknown>> {
	return examregFetch<Record<string, unknown>>(
		"/payOrder",
		{ method: "POST", body: JSON.stringify({ orderId, paymentType }) },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Unable to complete your order.",
		},
	)
}

/** Order + latest transaction state, polled on the payment return leg. */
export function fetchExamPaymentStatus(
	orderId: string,
): Promise<PaymentStatusResult> {
	return examregFetch<PaymentStatusResult>(
		"/paymentStatus",
		{ method: "POST", body: JSON.stringify({ orderId }) },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Unable to check the payment status.",
		},
	)
}

/** Cancels an unpaid registration and the exam attempts it created. */
export function rollbackExamRegistration(
	orderId: string,
	reason = "Cancel Registration",
): Promise<unknown> {
	return examregFetch<unknown>(
		"/rollback",
		{ method: "POST", body: JSON.stringify({ orderId, reason }) },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Unable to cancel the registration.",
		},
	)
}
