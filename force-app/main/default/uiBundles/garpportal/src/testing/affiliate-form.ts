/**
 * Drives the rendered Affiliate registration form the way a person does —
 * shared by the form's aspect-split test files, which all need "a completely
 * filled form" as their starting point.
 *
 * Any test that calls `fillAffiliateForm` MUST have a `verifyCustomer`
 * handler registered first: blurring a valid email fires the identity check,
 * and MSW runs strict.
 */

import { screen } from "@testing-library/react"
import type { UserEvent } from "@testing-library/user-event"

/** Click-open a Radix Select and choose an option by its accessible name. */
export async function pickRadixOption(
	user: UserEvent,
	trigger: HTMLElement,
	optionName: string | RegExp,
) {
	await user.click(trigger)
	await user.click(await screen.findByRole("option", { name: optionName }))
}

export type AffiliateFill = {
	firstName: string
	lastName: string
	email: string
	/** Option label in the dial-code select, e.g. `"United States (+1)"`. */
	phoneCodeOption: string
	mobilePhone: string
	/** Display name in the Location select. */
	countryName: string
}

export const DEFAULT_AFFILIATE_FILL: AffiliateFill = {
	firstName: "Ada",
	lastName: "Lovelace",
	email: "ada@garp.org",
	phoneCodeOption: "United States (+1)",
	mobilePhone: "5551234",
	countryName: "United States",
}

/**
 * Fills every required control. Typing the email and moving on blurs it, so
 * exactly one identity check fires along the way for the default values.
 */
export async function fillAffiliateForm(
	user: UserEvent,
	overrides: Partial<AffiliateFill> = {},
) {
	const fill = { ...DEFAULT_AFFILIATE_FILL, ...overrides }

	await user.type(
		screen.getByRole("textbox", { name: /first name/i }),
		fill.firstName,
	)
	await user.type(
		screen.getByRole("textbox", { name: /last name/i }),
		fill.lastName,
	)
	await user.type(
		screen.getByRole("textbox", { name: /email address/i }),
		fill.email,
	)
	await pickRadixOption(
		user,
		screen.getByRole("combobox", { name: /location/i }),
		fill.countryName,
	)
	await pickRadixOption(
		user,
		screen.getByRole("combobox", { name: /mobile phone country code/i }),
		fill.phoneCodeOption,
	)
	await user.type(
		screen.getByRole("textbox", { name: /mobile phone/i }),
		fill.mobilePhone,
	)
}

/** The one submit control the sticky bar carries. */
export function registerButton() {
	return screen.getByRole("button", { name: "Register" })
}
