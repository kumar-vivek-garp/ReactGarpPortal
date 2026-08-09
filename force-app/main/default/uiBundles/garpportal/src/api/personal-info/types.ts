/** Country / phone-code option from `Country_Code__c`. */
export type CountryOption = {
	/** Display label (country name). */
	label: string
	/** Value stored on Contact/Account country fields. */
	value: string
	/** Dialing code when present (e.g. "+1"). */
	phoneCode: string | null
}

export type AddressFormFields = {
	company: string
	address1: string
	address2: string
	address3: string
	country: string
	city: string
	state: string
	postalCode: string
	phone: string
}

/** Hydrated edit payload for the Personal Information dialog. */
export type PersonalInfoEditData = {
	contactId: string
	accountId: string | null
	photoUrl: string | null
	firstName: string
	lastName: string
	email: string
	mobilePhoneCode: string
	mobilePhone: string
	billing: AddressFormFields
	mailing: AddressFormFields
	sameAsBilling: boolean
}

export type PersonalInfoSaveInput = {
	contactId: string
	accountId: string
	firstName: string
	lastName: string
	email: string
	mobilePhoneCode: string
	mobilePhone: string
	billing: AddressFormFields
	mailing: AddressFormFields
	sameAsBilling: boolean
}
