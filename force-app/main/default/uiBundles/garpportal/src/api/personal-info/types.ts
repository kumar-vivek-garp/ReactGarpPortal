/** Country option for the address selects (`GET /memberportal/options`). */
export type CountryOption = {
	/** Display label (country name). */
	label: string
	/** Value stored on Contact/Account country fields. */
	value: string
	/** Dialing code when present (e.g. "1"). */
	phoneCode: string | null
}

/**
 * One phone-code choice, `"United States (+1)"`. Label and value are the same
 * string because that is exactly what the org stores in
 * `Contact.Mobile_Phone_Code__c`.
 */
export type PhoneCodeOption = {
	label: string
	value: string
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

/** The identity fields as loaded, so a save can post only what changed. */
export type PersonalInfoIdentityBaseline = Pick<
	PersonalInfoEditData,
	"firstName" | "lastName" | "email" | "mobilePhoneCode" | "mobilePhone"
>

export type PersonalInfoSaveInput = {
	firstName: string
	lastName: string
	email: string
	mobilePhoneCode: string
	mobilePhone: string
	billing: AddressFormFields
	mailing: AddressFormFields
	sameAsBilling: boolean
}

/**
 * The Account's billing company — the one value `GET /memberportal/account`
 * does not carry, read separately so a save never blanks it.
 */
export type BillingCompany = {
	accountId: string | null
	billingCompany: string | null
}

/** One address as `POST /memberportal/addresses` takes it. */
export type AddressInput = {
	company: string | null
	street1: string | null
	street2: string | null
	street3: string | null
	city: string | null
	state: string | null
	postalCode: string | null
	country: string | null
	phone: string | null
}

export type AddressSubmission = {
	mailingAddress: AddressInput
	billingAddress: AddressInput
	isBillingAndMailingAddressSame: boolean
}

export type AddressResult = {
	statusMessage: string | null
	statusCode: number
	/** True when the billing values were copied onto the mailing fields. */
	appliedBillingToMailing: boolean
}

export type PhotoResult = {
	statusMessage: string | null
	statusCode: number
	photoUrl: string | null
}
