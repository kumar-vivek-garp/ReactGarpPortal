import type { AccountView } from "@/api/account/types"
import type { ContactPreferencesData } from "@/api/contact-preferences/types"

function trimOrNull(value: string | null | undefined): string | null {
	const trimmed = value?.trim()
	return trimmed ? trimmed : null
}

/**
 * The Contact Preferences tab's slice of the composed account view. Pure and
 * total — it runs as a React Query `select` on the shared account query.
 */
export function toContactPreferences(view: AccountView): ContactPreferencesData {
	return {
		contactId: view.identity.contactId,
		email: trimOrNull(view.personal.email),
		mobilePhone: trimOrNull(view.personal.mobilePhone),
		mobilePhoneCode: trimOrNull(view.personal.mobilePhoneCode),
		smsPromotional: view.preferences.smsPromotional === true,
		smsRegistration: view.preferences.smsRegistration === true,
	}
}
