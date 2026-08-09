/** Street / address helpers for Personal Information GraphQL save. */

import type { AddressFormFields } from "@/api/personal-info/types"

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

export function addressesMatch(a: AddressFormFields, b: AddressFormFields): boolean {
	return (
		a.company.trim() === b.company.trim() &&
		a.address1.trim() === b.address1.trim() &&
		a.address2.trim() === b.address2.trim() &&
		a.address3.trim() === b.address3.trim() &&
		a.country.trim() === b.country.trim() &&
		a.city.trim() === b.city.trim() &&
		a.state.trim() === b.state.trim() &&
		a.postalCode.trim() === b.postalCode.trim() &&
		a.phone.trim() === b.phone.trim()
	)
}

export function copyAddress(source: AddressFormFields): AddressFormFields {
	return { ...source }
}

export function str(value: string | null | undefined): string {
	return value?.trim() ?? ""
}
