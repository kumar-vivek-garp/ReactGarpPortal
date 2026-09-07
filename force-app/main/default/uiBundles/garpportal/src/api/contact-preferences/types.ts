export type ContactPreferencesData = {
	contactId: string
	email: string | null
	mobilePhone: string | null
	mobilePhoneCode: string | null
	smsPromotional: boolean
	smsRegistration: boolean
}

export type UpdateSmsPreferencesInput = {
	smsPromotional: boolean
	smsRegistration: boolean
}

/** `POST /memberportal/emailPreferenceUpdate` payload. */
export type EmailPreferenceResult = {
	statusMessage: string | null
	statusCode: number
}
