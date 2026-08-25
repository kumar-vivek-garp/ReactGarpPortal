import { AppError } from "@/api/client"
import {
	EXAMREG_UNREACHABLE,
	examregFetch,
} from "@/api/registration/examreg-fetch"
import type {
	AffiliateRegisterRequest,
	AffiliateRegistrationLoad,
	RegisterResult,
	VerifyCustomerRequest,
	VerifyCustomerResult,
} from "@/api/registration/types"

/**
 * The programme key. `affiliate` is a row in `GARP_ExamReg_Program__mdt`
 * (`kind: "membership"`, `isAffiliate: true`, main product `AFREE`) — adding
 * or retiring a programme is a metadata change, so this key is the only part
 * of the registry the client is entitled to know.
 */
export const AFFILIATE_PROGRAM_TYPE = "affiliate"

/**
 * Opens the Affiliate registration form.
 *
 * Returns the country list the form's Location field needs, whether a session
 * is already signed in, and the server's eligibility verdict. There is no exam
 * selection, no study-material list and no pricing in this payload —
 * `GARP_ExamReg_LoadService` skips all three for a membership programme.
 */
export function fetchAffiliateRegistration(): Promise<AffiliateRegistrationLoad> {
	return examregFetch<AffiliateRegistrationLoad>(
		`/info?type=${encodeURIComponent(AFFILIATE_PROGRAM_TYPE)}`,
		{ method: "GET" },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Unable to open the registration form. Please try again.",
		},
	)
}

/**
 * Identifies the person before the account is written.
 *
 * Two things come back that the form acts on: `mustSignIn`, which means the
 * email already belongs to a member and the account has to be reached by
 * signing in rather than created again, and `sessionId` — the `Form_Data__c`
 * row that `register` must quote back.
 */
export function verifyAffiliateCustomer(
	input: Omit<VerifyCustomerRequest, "type">,
): Promise<VerifyCustomerResult> {
	return examregFetch<VerifyCustomerResult>(
		"/verifyCustomer",
		{
			method: "POST",
			body: JSON.stringify({
				type: AFFILIATE_PROGRAM_TYPE,
				email: input.email,
				firstName: input.firstName,
				lastName: input.lastName,
			} satisfies VerifyCustomerRequest),
		},
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Unable to check that email address. Please try again.",
		},
	)
}

/**
 * Writes the account, contact, order and Membership contract.
 *
 * Everything priced is re-derived server-side from the programme registry, so
 * the request carries identifiers and choices only. For affiliate that
 * resolves to a single AFREE line at USD 0 and a Membership contract with
 * `Membership_Type__c = 'Affiliate'` — which is why this form has no cart and
 * no payment step to show.
 */
export function registerAffiliate(
	input: Omit<AffiliateRegisterRequest, "type">,
): Promise<RegisterResult> {
	return examregFetch<RegisterResult>(
		"/register",
		{
			method: "POST",
			body: JSON.stringify({
				type: AFFILIATE_PROGRAM_TYPE,
				...input,
			} satisfies AffiliateRegisterRequest),
		},
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Unable to complete your registration. Please try again.",
		},
	)
}

/**
 * Closes the zero-total order.
 *
 * Not a payment step despite the name — `completeOfflineOrder` records the
 * USD 0 transaction that lets the order close, releases the contact's
 * `DO_NOT_FIRE__c` trigger hold and marks the form session Completed. Without
 * it the registration is written but the order never settles.
 *
 * Deliberately NOT retried: Apex refuses a second call on an order that has
 * already completed, and a duplicate would write a second approved
 * transaction — an order that looks paid twice.
 */
export async function completeAffiliateOrder(orderId: string): Promise<void> {
	if (!orderId) {
		throw new AppError({
			messages: ["No order was returned by the registration service."],
			status: 0,
		})
	}

	await examregFetch<{ completed?: boolean }>(
		"/payOrder",
		{ method: "POST", body: JSON.stringify({ orderId }) },
		{
			unreachable: EXAMREG_UNREACHABLE,
			fallback: "Your account was created but the order did not close.",
		},
	)
}
