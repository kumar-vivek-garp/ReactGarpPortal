import { useMutation, useQuery } from "@tanstack/react-query"

import { AppError } from "@/api/client"
import {
	affiliateRegistrationQueryOptions,
	completeAffiliateOrder,
	registerAffiliate,
	verifyAffiliateCustomer,
	type RegisterResult,
	type VerifyCustomerResult,
} from "@/api/registration"

/** Countries, session state and eligibility for the Affiliate form. */
export function useAffiliateRegistration() {
	return useQuery(affiliateRegistrationQueryOptions)
}

/** A `verifyCustomer` answer, tagged with the email it was obtained for. */
export type VerifiedSession = VerifyCustomerResult & { email: string }

export type VerifyAffiliateEmailInput = {
	email: string
	firstName: string
	lastName: string
}

/**
 * The email-blur identity check, matching GarpAppv1's `onEmailBlur`.
 *
 * Run early so someone who already has an account is told before they fill the
 * rest of the form, rather than at submit. The result is reused as the
 * registration's session, so a successful blur check means `register` does not
 * open a second `Form_Data__c` row.
 */
export function useVerifyAffiliateEmail() {
	return useMutation<VerifiedSession, unknown, VerifyAffiliateEmailInput>({
		mutationFn: async (input) => {
			const email = input.email.trim()
			const result = await verifyAffiliateCustomer({
				email,
				firstName: input.firstName.trim(),
				lastName: input.lastName.trim(),
			})
			return { ...result, email }
		},
	})
}

export type AffiliateSignUpInput = {
	firstName: string
	lastName: string
	email: string
	/** `"<countryCode> (+<phoneCode>)"`, as GarpAppv1 sends it. */
	mobilePhoneCode: string
	mobilePhone: string
	smsPromotionalUpdates: boolean
	/** `RegistrationCountry.countryCode`, not the display name. */
	country: string
	/** Privacy notice + limitation of liability + waiver, combined. */
	privacyPolicy: boolean
	/** A session from the blur check, reused when it is for this same email. */
	session?: VerifiedSession | null
}

/** Raised when the email already belongs to a member, so signing in is the way in. */
export class MustSignInError extends AppError {
	constructor() {
		super({
			messages: [
				"An account already exists for this email address. Please sign in instead.",
			],
			status: 409,
		})
		this.name = "MustSignInError"
	}
}

/**
 * The whole sign-up, as one mutation: verify, register, close the order.
 *
 * Three calls rather than one because that is the module's contract — the
 * `Form_Data__c` session `verifyCustomer` opens is what `register` quotes
 * back, and a zero-total order still has to be settled by `payOrder` before
 * it closes. Sequencing them here keeps that out of the form.
 *
 * The verify step is skipped when the blur check already ran for this exact
 * email, so a normal fill-and-submit makes one identity call, not two.
 *
 * Errors are surfaced by the caller, not toasted globally: `mustSignIn` is a
 * routine answer that belongs next to the email field, not in a red toast.
 */
export function useAffiliateSignUp() {
	return useMutation<RegisterResult, unknown, AffiliateSignUpInput>({
		mutationFn: async (input) => {
			const email = input.email.trim()
			const firstName = input.firstName.trim()
			const lastName = input.lastName.trim()

			const verified =
				input.session && input.session.email === email
					? input.session
					: await verifyAffiliateCustomer({ email, firstName, lastName })

			if (verified.mustSignIn) {
				throw new MustSignInError()
			}

			const registered = await registerAffiliate({
				sessionId: verified.sessionId,
				customer: {
					contactId: verified.contactId,
					accountId: verified.accountId,
					leadId: verified.leadId,
					firstName,
					lastName,
					email,
					mobilePhoneCode: input.mobilePhoneCode,
					mobilePhone: input.mobilePhone.trim(),
					smsPromotionalUpdates: input.smsPromotionalUpdates,
				},
				billingAddress: { country: input.country },
				billingAndShippingSame: true,
				consent: { privacyPolicy: input.privacyPolicy },
			})

			if (registered.orderId) {
				await completeAffiliateOrder(registered.orderId)
			}

			return registered
		},
	})
}
