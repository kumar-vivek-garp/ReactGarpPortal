import {
	saveAccountProfile,
	type AccountProfileValues,
} from "@/api/account/save-profile"
import { copyAddress, toAddressInput } from "@/api/personal-info/address-utils"
import { saveAddresses } from "@/api/personal-info/save-addresses"
import type {
	AddressResult,
	PersonalInfoIdentityBaseline,
	PersonalInfoSaveInput,
} from "@/api/personal-info/types"

const IDENTITY_FIELDS: ReadonlyArray<
	[keyof PersonalInfoIdentityBaseline, string]
> = [
	["firstName", "FirstName"],
	["lastName", "LastName"],
	["email", "Email"],
	["mobilePhoneCode", "Mobile_Phone_Code__c"],
	["mobilePhone", "MobilePhone"],
]

/**
 * The identity fields to post to `/memberportal/profile` — only what differs
 * from the hydrated baseline, so a save never rewrites an untouched field.
 * Without a baseline every field is sent.
 */
export function changedIdentityFields(
	input: PersonalInfoSaveInput,
	baseline?: PersonalInfoIdentityBaseline,
): AccountProfileValues {
	const values: AccountProfileValues = {}
	for (const [key, apiName] of IDENTITY_FIELDS) {
		const next = input[key].trim()
		if (baseline && next === baseline[key].trim()) continue
		values[apiName] = next || null
	}
	return values
}

/**
 * The Personal Information save, in the order GarpAppv1 runs it: the changed
 * identity fields through `profile` (skipped when nothing changed), then the
 * two addresses through `addresses` — always, since the address action also
 * owns `Phone` / `HomePhone`. `profile` refusing a field aborts before any
 * address is written.
 */
export async function savePersonalInfo(
	input: PersonalInfoSaveInput,
	baseline?: PersonalInfoIdentityBaseline,
): Promise<AddressResult> {
	const changed = changedIdentityFields(input, baseline)
	if (Object.keys(changed).length > 0) {
		await saveAccountProfile(changed)
	}

	const mailing = input.sameAsBilling ? copyAddress(input.billing) : input.mailing
	return saveAddresses({
		mailingAddress: toAddressInput(mailing),
		billingAddress: toAddressInput(input.billing),
		isBillingAndMailingAddressSame: input.sameAsBilling,
	})
}
