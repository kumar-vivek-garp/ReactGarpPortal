import type {
	EventCountry,
	EventRegisterRequest,
	EventRegisterResult,
	EventVariant,
	EventView,
} from "@/api/registration/event-types"
import type { EventFormValues } from "@/components/forms/event-registration/event-form-values"
import {
	consentKind,
	resolveIsGdpr,
	showActivityCard,
	showActivityQuestion,
	showAddressCard,
	showAttendanceSelect,
	showDietary,
	showProfessionalFields,
	showQuestionCard,
} from "@/lib/event-registration-presentation"

type BuildContext = {
	variant: EventVariant
	eventId: string
	event: EventView
	/** The selected country's row — webcast only; null elsewhere. */
	selectedCountry: EventCountry | null
}

/**
 * Form state → wire payload.
 *
 * Constructed key by key, NEVER by spreading form values: the Apex DTO throws
 * on any field it does not declare, and a spread would post whatever the form
 * happens to hold. Fields whose section was not rendered are omitted entirely
 * (`JSON.stringify` drops `undefined`), so nothing is posted "as its default"
 * on someone's behalf — the §5 rule.
 *
 * `userQuestions` is the one deliberate fixed default: the DTO declares it,
 * nothing renders it anywhere, and the deployed client sends `""` always.
 */
export function buildEventRegisterRequest(
	values: EventFormValues,
	ctx: BuildContext,
): EventRegisterRequest {
	const { variant, event } = ctx

	const request: EventRegisterRequest = {
		variant,
		eventId: ctx.eventId,
		email: values.email.trim(),
		firstName: values.firstName.trim(),
		lastName: values.lastName.trim(),
		workPhone: values.workPhone.trim() || undefined,
		isGdpr: resolveIsGdpr(ctx.selectedCountry, event),
		userQuestions: "",
		privacyPolicyAttestation: values.privacyPolicyAttestation,
	}

	if (showProfessionalFields(variant, event)) {
		request.jobTitle = values.jobTitle.trim() || undefined
		request.company = values.company.trim() || undefined
	}

	if (showAttendanceSelect(event)) {
		request.attendanceMethod = values.attendanceMethod || undefined
	}

	if (showAddressCard(variant)) {
		request.address1 = values.address1.trim() || undefined
		request.address2 = values.address2.trim() || undefined
		request.city = values.city.trim() || undefined
		request.province = values.province.trim() || undefined
		request.postalCode = values.postalCode.trim() || undefined
		request.country = values.country || undefined
	}

	if (showActivityCard(variant, event)) {
		request.attendingActivity = values.attendingActivity
		if (values.attendingActivity && showDietary(event)) {
			request.dietaryRestriction = values.dietaryRestriction
			if (values.dietaryRestriction) {
				request.dietaryRestrictionDetails =
					values.dietaryRestrictionDetails.trim() || undefined
			}
		}
		if (values.attendingActivity && showActivityQuestion(event)) {
			request.activityQuestionResponse =
				values.activityQuestionResponse.trim() || undefined
		}
	}

	if (showQuestionCard(variant, event)) {
		request.eventQuestionResponse =
			values.eventQuestionResponse.trim() || undefined
	}

	if (consentKind(event) === "sponsor") {
		request.agreeToSponsorContact = values.agreeToSponsorContact
	} else {
		request.agreeToGarpContent = values.agreeToGarpContent
	}

	return request
}

/**
 * The checkout return addresses, built from wherever the form was served so
 * the provider comes back to the same route (whose guards suppress their
 * redirects on both legs).
 *
 * Unlike the exam flow, the CANCEL url is not bare: it carries the `oid` the
 * rollback depends on — without it the abandoned order's registration row
 * reports `alreadyRegistered` forever.
 */
export function buildEventCheckoutUrls(
	location: { origin: string; pathname: string },
	result: Pick<EventRegisterResult, "orderId" | "orderNumber">,
): { successUrl: string; cancelUrl: string } {
	const base = `${location.origin}${location.pathname}`
	const success = new URLSearchParams({
		stripe_return: "1",
		oid: result.orderId ?? "",
	})
	if (result.orderNumber) success.set("on", result.orderNumber)
	const cancel = new URLSearchParams({
		checkout_cancelled: "1",
		oid: result.orderId ?? "",
	})
	return {
		successUrl: `${base}?${success.toString()}`,
		cancelUrl: `${base}?${cancel.toString()}`,
	}
}
