/** Street / address helpers for the Personal Information dialog. */

import type { AddressFormFields, AddressInput } from "@/api/personal-info/types"

export function emptyAddress(): AddressFormFields {
	return {
		company: "",
		address1: "",
		address2: "",
		address3: "",
		country: "",
		city: "",
		state: "",
		postalCode: "",
		phone: "",
	}
}

/** Split Salesforce multi-line street into up to three form lines. */
export function splitStreet(street: string | null | undefined): [string, string, string] {
	const parts = (street ?? "").split(/\r?\n/)
	return [parts[0]?.trim() ?? "", parts[1]?.trim() ?? "", parts[2]?.trim() ?? ""]
}

/** Join up to three address lines into a Salesforce street TextArea. */
export function joinStreet(address1: string, address2: string, address3: string): string {
	return [address1, address2, address3]
		.map((line) => line.trim())
		.filter(Boolean)
		.join("\n")
}

/**
 * One address as `POST /memberportal/addresses` takes it: trimmed, blanks as
 * null, and always the three-line street form so a cleared line actually
 * clears rather than falling back to the previously joined value.
 */
export function toAddressInput(fields: AddressFormFields): AddressInput {
	const orNull = (value: string) => value.trim() || null
	return {
		company: orNull(fields.company),
		street1: orNull(fields.address1),
		street2: orNull(fields.address2),
		street3: orNull(fields.address3),
		city: orNull(fields.city),
		state: orNull(fields.state),
		postalCode: orNull(fields.postalCode),
		country: orNull(fields.country),
		phone: orNull(fields.phone),
	}
}

export function copyAddress(source: AddressFormFields): AddressFormFields {
	return { ...source }
}

export function str(value: string | null | undefined): string {
	return value?.trim() ?? ""
}
