import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import { eventContact, eventLoad, eventView } from "@/testing/factories/event"
import {
	accountViewFromPersonalInfo,
	billingCompanyGraphql,
	personalInfoEditData,
} from "@/testing/factories/personal-info"
import { installMockOrg, type MockOrgOptions } from "../support/mock-org"
import { programsListData } from "../support/payloads"

/**
 * The invite-only RSVP gate on a chapter meeting: Accept is client-side only
 * (it reveals the form with ZERO writes — nothing lands until that form
 * submits), while Decline records the reply server-side and leads to its own
 * declined screen (the deployed GarpAppv1 shows "You're registered" for a
 * decline — a ported bug this suite pins as fixed).
 */

function alertBarIdle(): AlertBarView {
	return {
		statusMessage: "No alerts found",
		statusCode: 200,
		examType: null,
		examPart: null,
		alertStatus: null,
		deadline: null,
		orderId: null,
		route: null,
	}
}

function memberBaseline(): Pick<MockOrgOptions, "actions" | "graphql"> {
	const profile = personalInfoEditData()
	return {
		actions: {
			programs: programsListData(),
			alertBar: alertBarIdle(),
			account: accountViewFromPersonalInfo(profile),
		},
		graphql: { BillingCompany: billingCompanyGraphql(profile) },
	}
}

/** An invite-only chapter meeting with a member contact on the load. */
function inviteOnlyLoad() {
	return eventLoad({
		isAuthenticated: true,
		contact: eventContact(),
		event_x: eventView({
			id: "C1",
			title: "London Chapter Meeting",
			isInviteOnly: true,
		}),
	})
}

test.describe("chapter meeting RSVP gate", () => {
	test("Accept reveals the form with zero writes", async ({ page }) => {
		const org = await installMockOrg(page, {
			...memberBaseline(),
			examreg: { "event/info": inviteOnlyLoad() },
		})
		await page.goto("/events/chaptermeeting/C1/register")

		// The gate stands between the invitation and the form.
		await expect(page.getByText("You're invited")).toBeVisible()
		await expect(
			page.getByText(
				"This event is by invitation. Let us know whether you will attend.",
			),
		).toBeVisible()
		await expect(
			page.getByRole("button", { name: "Complete Registration" }),
		).toHaveCount(0)

		await page.getByRole("button", { name: "Accept", exact: true }).click()

		// The form replaces the gate — member identity collapsed, attestation up.
		await expect(page.getByText("Contact details")).toBeVisible()
		await expect(
			page.getByRole("checkbox", { name: /GARP Privacy Notice/ }),
		).toBeVisible()
		await expect(page.getByText("You're invited")).toBeHidden()

		// Accept is client-side ONLY: nothing has been written.
		expect(org.hits("event/register")).toBe(0)
		expect(org.hits("event/rsvpDecline")).toBe(0)
	})

	test("Decline posts the reply and shows the declined screen", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			...memberBaseline(),
			examreg: {
				"event/info": inviteOnlyLoad(),
				"event/rsvpDecline": {},
			},
		})
		await page.goto("/events/chaptermeeting/C1/register")

		await expect(page.getByText("You're invited")).toBeVisible()
		await page.getByRole("button", { name: "Decline" }).click()

		// The declined screen, not GarpAppv1's misleading "You're registered".
		await expect(
			page.getByRole("heading", { name: "Thanks for letting us know" }),
		).toBeVisible()
		await expect(
			page.getByText("We've recorded that you won't be attending."),
		).toBeVisible()

		// One write, carrying exactly the id and the invitee's email.
		await expect.poll(() => org.hits("event/rsvpDecline")).toBe(1)
		const body: unknown = JSON.parse(
			org.of("event/rsvpDecline")[0].postData ?? "{}",
		)
		expect(body).toEqual({ eventId: "C1", userEmail: "ada@example.test" })
		expect(org.hits("event/register")).toBe(0)
	})
})
