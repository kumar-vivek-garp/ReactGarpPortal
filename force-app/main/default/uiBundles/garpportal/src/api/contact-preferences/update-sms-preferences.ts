import { saveAccountProfile } from "@/api/account/save-profile"
import type { UpdateSmsPreferencesInput } from "@/api/contact-preferences/types"

/**
 * Saves the two SMS consents through `/memberportal/profile` — both are on
 * `GARP_Portal_ProfileService`'s allow-list. Both flags travel together so the
 * untouched one keeps its value. Resolves the flags as saved.
 */
export async function updateSmsPreferences(
	input: UpdateSmsPreferencesInput,
): Promise<UpdateSmsPreferencesInput> {
	await saveAccountProfile({
		SMS_Promotional_Updates__c: input.smsPromotional,
		SMS_Registration_Updates__c: input.smsRegistration,
	})
	return {
		smsPromotional: input.smsPromotional,
		smsRegistration: input.smsRegistration,
	}
}
