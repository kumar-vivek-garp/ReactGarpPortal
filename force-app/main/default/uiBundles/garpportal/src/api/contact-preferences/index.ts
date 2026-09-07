export type {
	ContactPreferencesData,
	EmailPreferenceResult,
	UpdateSmsPreferencesInput,
} from "@/api/contact-preferences/types"
export { toContactPreferences } from "@/api/contact-preferences/preferences"
export { requestEmailPreferences } from "@/api/contact-preferences/update-email-preference"
export { updateSmsPreferences } from "@/api/contact-preferences/update-sms-preferences"
export { invalidateContactPreferencesCaches } from "@/api/contact-preferences/invalidate-caches"
