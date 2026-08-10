export type ContactPreferencesData = {
	contactId: string
	email: string | null
	mobilePhone: string | null
	mobilePhoneCode: string | null
	smsPromotional: boolean
	smsRegistration: boolean
}

export type UpdateSmsPreferencesInput = {
	contactId: string
	smsPromotional: boolean
	smsRegistration: boolean
}
