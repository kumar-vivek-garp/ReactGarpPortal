import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import type { EventOptions } from "@/api/registration/event-types"
import {
	eventContact,
	eventCountry,
	eventLoad,
	eventRegisterResult,
	eventView,
} from "@/testing/factories/event"
import {
	accountViewFromPersonalInfo,
	billingCompanyGraphql,
	personalInfoEditData,
} from "@/testing/factories/personal-info"
import {
	installMockOrg,
	refuse,
	type MockOrgOptions,
} from "../support/mock-org"
import { programsListData } from "../support/payloads"

/**
 * Member event/webcast registration: the free journey end to end (GET wiring,
 * form, POST body, outcome), the webcast-only variant plumbing (`eventType` in
 * the query, the country-options read, the location card), and the two
 * non-form screens — already registered, and a load failure.
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

/**
 * Every member spec's floor: sidebar programs + quiet alert bar, and the
 * profile hydrate the register panel waits on for a session with a contact
 * (unanswered it errors and toasts "Unable to load personal information").
 */
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

test.describe("member event registration — free journey", () => {
	test("loads without eventType, posts the closed DTO, and shows the registered outcome", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			...memberBaseline(),
			examreg: {
				"event/info": eventLoad({
					isAuthenticated: true,
					contact: eventContact(),
				}),
				"event/register": eventRegisterResult({
					registrationNumber: "ER-1001",
					message: "See you there.",
				}),
			},
		})
		await page.goto("/events/event/E1/register")

		// The event's title is the page's h1; identity came from the record so
		// the member sees the collapsed contact card, not name/email inputs.
		await expect(
			page.getByRole("heading", { name: "Risk Summit 2026", level: 1 }),
		).toBeVisible()
		await expect(page.getByText("Contact details")).toBeVisible()

		// GET wiring: the id travels, `eventType` does NOT — omitting it is the
		// Apex default for plain events, and sending it would change the record
		// family the server writes.
		const info = org.of("event/info")
		expect(info.length).toBeGreaterThan(0)
		expect(info[0].url).toContain("eventId=E1")
		expect(info[0].url).not.toContain("eventType")

		// Only the attestation stands between a member and a valid form.
		const submit = page.getByRole("button", { name: "Complete Registration" })
		await expect(submit).toBeDisabled()
		await page.getByRole("checkbox", { name: /GARP Privacy Notice/ }).click()
		await expect(submit).toBeEnabled()
		await submit.click()

		await expect(
			page.getByRole("heading", { name: "You're registered" }),
		).toBeVisible()
		await expect(page.getByText("See you there.")).toBeVisible()
		await expect(page.getByText("ER-1001")).toBeVisible()

		// The wire payload is the whitelist: seeded identity travels, unrendered
		// sections are absent entirely, nothing posts as a silent default.
		expect(org.hits("event/register")).toBe(1)
		const body: unknown = JSON.parse(
			org.of("event/register")[0].postData ?? "{}",
		)
		expect(body).toEqual({
			variant: "event",
			eventId: "E1",
			email: "ada@example.test",
			firstName: "Ada",
			lastName: "Lovelace",
			jobTitle: "Analyst",
			company: "Analytical Engines",
			isGdpr: false,
			userQuestions: "",
			privacyPolicyAttestation: true,
			agreeToGarpContent: false,
		})

		// The country-options read is webcast-only — a plain event never asks.
		expect(org.hits("event/options")).toBe(0)
	})
})

test.describe("member webcast registration — variant plumbing", () => {
	test("sends eventType=webcast, fetches the country options, and renders the location card", async ({
		page,
	}) => {
		const options: EventOptions = {
			countries: [
				eventCountry(),
				eventCountry({
					id: "cty-de",
					name: "Germany",
					countryCode: "DE",
					compliance: true,
				}),
			],
			professionalLevels: [],
			jobFunctions: [],
			riskSpecialties: [],
		}
		const org = await installMockOrg(page, {
			...memberBaseline(),
			examreg: {
				"event/info": eventLoad({
					isAuthenticated: true,
					contact: eventContact(),
					event_x: eventView({ id: "W1", title: "Climate Webcast" }),
				}),
				"event/options": options,
			},
		})
		await page.goto("/events/webcast/W1/register")

		await expect(
			page.getByRole("heading", { name: "Climate Webcast", level: 1 }),
		).toBeVisible()

		// The variant rides in the query string, never the body.
		const info = org.of("event/info")
		expect(info.length).toBeGreaterThan(0)
		expect(info[0].url).toContain("eventType=webcast")
		expect(info[0].url).toContain("eventId=W1")
		await expect.poll(() => org.hits("event/options")).toBe(1)

		// The webcast-only "Your location" card, populated from the payload.
		await expect(page.getByText("Your location")).toBeVisible()
		const country = page.getByRole("combobox", { name: "Country" })
		await country.click()
		await page.getByRole("option", { name: "Germany" }).click()
		await expect(country).toHaveText(/Germany/)
	})
})

test.describe("member event registration — non-form screens", () => {
	test("an existing registration renders its own screen instead of the form", async ({
		page,
	}) => {
		await installMockOrg(page, {
			...memberBaseline(),
			examreg: {
				"event/info": eventLoad({
					isAuthenticated: true,
					contact: eventContact(),
					alreadyRegistered: true,
					existingRegistrationId: "reg-9",
				}),
			},
		})
		await page.goto("/events/event/E1/register")

		await expect(
			page.getByRole("heading", { name: "You're already registered" }),
		).toBeVisible()
		await expect(
			page.getByText("We have your place. There's nothing more to do here."),
		).toBeVisible()
		// The form never mounts behind an existing registration.
		await expect(
			page.getByRole("button", { name: "Complete Registration" }),
		).toHaveCount(0)
	})

	test("a load failure degrades to the error screen with the server's message", async ({
		page,
	}) => {
		await installMockOrg(page, {
			...memberBaseline(),
			examreg: { "event/info": refuse(500, "Event service exploded") },
		})
		await page.goto("/events/event/E1/register")

		await expect(
			page.getByRole("heading", { name: "We couldn't open this registration" }),
		).toBeVisible()
		// The failure toasts with the SERVER's message, never a swallowed generic.
		await expect(page.getByText("Event service exploded")).toBeVisible()
		// Chrome survives: the app header is still standing.
		await expect(page.locator("header").first()).toBeVisible()
	})
})
