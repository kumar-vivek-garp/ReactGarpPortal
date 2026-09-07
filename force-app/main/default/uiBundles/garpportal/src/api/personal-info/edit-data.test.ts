import { describe, expect, it } from "vitest"

import { toPersonalInfoEditData } from "@/api/personal-info/edit-data"
import {
	accountView,
	emptyPortalAddress,
	portalAddress,
} from "@/testing/factories/account"

describe("toPersonalInfoEditData", () => {
	it("maps identity, phones and both addresses, trimming as it goes", () => {
		const view = accountView({
			identity: { contactId: "003xx1" },
			personal: {
				firstName: " Ada ",
				lastName: "Lovelace",
				email: "ada@example.com",
				phone: "5550100",
				homePhone: "5550199",
				mobilePhone: "5550123",
				mobilePhoneCode: "United States (+1)",
				mailingCompany: "GARP",
				photoUrl: " /photo.png ",
			},
			billingAddress: portalAddress({ street1: "1 Main St", street2: "Suite 4" }),
			mailingAddress: portalAddress({
				street1: "2 Ship St",
				city: "Boston",
				state: "MA",
				postalCode: "02110",
			}),
			isBillingAndMailingAddressSame: false,
		})

		const data = toPersonalInfoEditData(view, "Analytical Engines Ltd")

		expect(data).toMatchObject({
			contactId: "003xx1",
			photoUrl: "/photo.png",
			firstName: "Ada",
			mobilePhoneCode: "United States (+1)",
			sameAsBilling: false,
		})
		expect(data.billing).toEqual({
			company: "Analytical Engines Ltd",
			address1: "1 Main St",
			address2: "Suite 4",
			address3: "",
			country: "United States",
			city: "Hoboken",
			state: "NJ",
			postalCode: "07030",
			phone: "5550100",
		})
		expect(data.mailing).toMatchObject({
			company: "GARP",
			address1: "2 Ship St",
			city: "Boston",
			phone: "5550199",
		})
	})

	it("takes same-as-billing from the server flag, not from comparing addresses", () => {
		const view = accountView({
			billingAddress: portalAddress(),
			mailingAddress: portalAddress({ city: "Boston" }),
			isBillingAndMailingAddressSame: true,
		})
		expect(toPersonalInfoEditData(view, null).sameAsBilling).toBe(true)
	})

	it("splits a joined street when the payload carries no separate lines", () => {
		const address = {
			...emptyPortalAddress(),
			street: "1 Main St\nSuite 4",
			isEmpty: false,
		}
		// The three-line form is absent altogether on an older payload.
		const legacy = { ...address } as Record<string, unknown>
		delete legacy.street1
		delete legacy.street2
		delete legacy.street3
		const view = accountView({ billingAddress: legacy as typeof address })

		expect(toPersonalInfoEditData(view, null).billing).toMatchObject({
			address1: "1 Main St",
			address2: "Suite 4",
			address3: "",
		})
	})

	it("hydrates an empty address block as blank strings, never throwing", () => {
		const data = toPersonalInfoEditData(accountView(), null)
		expect(data.billing.company).toBe("")
		expect(data.billing.address1).toBe("")
		expect(data.mailing.country).toBe("")
		expect(data.sameAsBilling).toBe(false)
	})
})
