export type {
	ContactPreferencesData,
	UpdateSmsPreferencesInput,
} from "@/api/contact-preferences/types"
export { loadContactPreferences } from "@/api/contact-preferences/load-preferences"
export { requestEmailPreferences } from "@/api/contact-preferences/update-email-preference"
export { updateSmsPreferences } from "@/api/contact-preferences/update-sms-preferences"
export {
	contactPreferencesQueryKeys,
	contactPreferencesQueryOptions,
} from "@/api/contact-preferences/query-options"
export { invalidateContactPreferencesCaches } from "@/api/contact-preferences/invalidate-caches"
