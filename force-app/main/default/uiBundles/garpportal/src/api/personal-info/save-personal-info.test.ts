import { describe, expect, it } from "vitest"

import {
	changedIdentityFields,
	savePersonalInfo,
} from "@/api/personal-info/save-personal-info"
import type { PersonalInfoSaveInput } from "@/api/personal-info/types"
import {
	personalInfoEditData,
	portalAddressFields,
} from "@/testing/factories/personal-info"
import { myAccountOrg } from "@/testing/msw/handlers/account"
import { personalInfoWriteHandlers } from "@/testing/msw/handlers/personal-info"
import { server } from "@/testing/msw/server"

const BASELINE = personalInfoEditData()

function input(overrides: Partial<PersonalInfoSaveInput> = {}): PersonalInfoSaveInput {
	return {
		firstName: BASELINE.firstName,
		lastName: BASELINE.lastName,
		email: BASELINE.email,
		mobilePhoneCode: BASELINE.mobilePhoneCode,
		mobilePhone: BASELINE.mobilePhone,
		billing: portalAddressFields(),
		mailing: portalAddressFields({ address1: "2 Ship St", city: "Boston" }),
		sameAsBilling: false,
		...overrides,
	}
}

function serveOrg(options: Parameters<typeof myAccountOrg>[0] = {}) {
	const account = myAccountOrg(options)
	const writes = personalInfoWriteHandlers()
	server.use(...account.handlers, ...writes.handlers)
	return { profileSpy: account.profileSpy, addressesSpy: writes.addressesSpy }
}

describe("changedIdentityFields", () => {
	it("posts only what differs from the baseline, blanks as null", () => {
		expect(
			changedIdentityFields(input({ firstName: " Grace ", email: " " }), BASELINE),
		).toEqual({ FirstName: "Grace", Email: null })
	})

	it("posts every field when there is no baseline", () => {
		expect(Object.keys(changedIdentityFields(input()))).toEqual([
			"FirstName",
			"LastName",
			"Email",
			"Mobile_Phone_Code__c",
			"MobilePhone",
		])
	})
})

describe("savePersonalInfo", () => {
	it("posts the changed identity fields, then both addresses", async () => {
		const org = serveOrg()

		await savePersonalInfo(input({ firstName: "Grace" }), BASELINE)

		expect(org.profileSpy.bodies).toEqual([{ FirstName: "Grace" }])
		expect(org.addressesSpy.bodies[0]).toMatchObject({
			isBillingAndMailingAddressSame: false,
			billingAddress: { street1: "1 Main St", city: "Hoboken", phone: "5551234" },
			mailingAddress: { street1: "2 Ship St", city: "Boston" },
		})
	})

	it("skips the profile write when nothing about the identity changed", async () => {
		const org = serveOrg()

		await savePersonalInfo(input(), BASELINE)

		expect(org.profileSpy.hits).toBe(0)
		expect(org.addressesSpy.hits).toBe(1)
	})

	it("copies billing over mailing when same-as-billing is ticked", async () => {
		const org = serveOrg()

		await savePersonalInfo(input({ sameAsBilling: true }), BASELINE)

		const body = org.addressesSpy.bodies[0]
		expect(body.isBillingAndMailingAddressSame).toBe(true)
		expect(body.mailingAddress).toEqual(body.billingAddress)
	})

	it("stops before the addresses when the profile write is refused", async () => {
		const org = serveOrg({
			profileRespond: () => ({
				applied: [],
				rejected: ["Email"],
				completeness: {
					percentComplete: 0,
					earnedWeight: 0,
					totalWeight: 11,
					isComplete: false,
					muted: false,
					missing: [],
					missingBySection: {},
				},
			}),
		})

		await expect(
			savePersonalInfo(input({ email: "grace@example.org" }), BASELINE),
		).rejects.toMatchObject({
			messages: ["These fields could not be saved: Email."],
		})
		expect(org.addressesSpy.hits).toBe(0)
	})
})
