import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import type { ProgramDetailView } from "@/api/programs"
import {
	examDeadline,
	examPartInfo,
	programDetail,
	programExamNotification,
} from "@/testing/factories/programs"
import { installMockOrg, refuse } from "../support/mock-org"
import { dashboardActionSet } from "../support/payloads"

/**
 * Programs module journeys: the listing renders both buckets from the typed
 * payload, `?tab=` / `?view=` drive the sections and layout, the FRM detail
 * page builds its hero and rail from `programDetail()`, and a detail failure
 * degrades with the chrome intact.
 */

/**
 * No floating alert over these pages — the alert bar's own journeys live in
 * dashboard.spec.ts, and its overlay card must not sit over the controls
 * these specs click.
 */
const NO_ALERT = {
	statusMessage: null,
	statusCode: 200,
	examType: null,
	examPart: null,
	alertStatus: null,
	deadline: null,
	orderId: null,
	route: null,
} satisfies AlertBarView

function baseActions(): Record<string, unknown> {
	return { ...dashboardActionSet(), alertBar: NO_ALERT }
}

/** `GET programDetail` — FRM mid-journey with scheduling open. */
function frmDetailData(): ProgramDetailView {
	return {
		statusMessage: null,
		statusCode: 200,
		programsDetailInfo: programDetail({
			programType: "FRM",
			programState: "ExamAttempt",
			programInformation: {
				programCode: "FRM",
				abbrevName: "FRM",
				formalName: null,
				informalName: "Financial Risk Manager",
				policyURL: null,
				regLogoURL: null,
				myProgramsLogoURL: null,
				description: "The global standard for financial risk.",
				registrationPath: null,
			},
			examPart1Info: examPartInfo({
				examPartState: "SchedulingOpen",
				isSchedulingOpen: true,
				schedulingIsComplete: false,
				schedulingDeadline: "2026-11-07",
			}),
			examDeadlines: [
				examDeadline({ schedulingDeadline: "2026-11-07" }),
			],
			examNotifications: [programExamNotification()],
		}),
	}
}

test.describe("programs listing", () => {
	test("a member's programs render, landing on In Progress, with no unhandled action", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: baseActions() })
		await page.goto("/programs")

		await expect(
			page.getByRole("heading", { name: "My Programs", level: 1 }),
		).toBeVisible()

		// Enrolled FRM puts the member on their own bucket, not the catalogue.
		await expect(
			page.getByRole("tab", { name: /In Progress/ }),
		).toHaveAttribute("aria-selected", "true")
		// `exact` matters: the nav's hidden mega-menu carries
		// "Financial Risk Manager (FRM®)" headings that substring-match.
		await expect(
			page.getByText("Financial Risk Manager", { exact: true }),
		).toBeVisible()

		// Audit surface: every memberportal action answered by a typed payload.
		expect(
			org.unhandled
				.filter((call) => call.kind === "action")
				.map((call) => call.key),
		).toEqual([])
	})

	test("?tab= selects a section and the pills switch it client-side", async ({
		page,
	}) => {
		await installMockOrg(page, { actions: baseActions() })
		await page.goto("/programs?tab=explore")

		// The explore bucket: both other programs, not the enrolled one.
		// `exact` keeps the nav's hidden mega-menu headings out of the match.
		await expect(
			page.getByText("Sustainability and Climate Risk", { exact: true }),
		).toBeVisible()
		await expect(page.getByText("Risk and AI", { exact: true })).toBeVisible()
		await expect(
			page.getByText("Financial Risk Manager", { exact: true }),
		).toBeHidden()

		await page.getByRole("tab", { name: /^All/ }).click()
		await expect(page).toHaveURL(/tab=all/)

		// "All" stacks every non-empty bucket under its own heading.
		await expect(
			page.getByRole("heading", { name: /In Progress/ }),
		).toBeVisible()
		await expect(
			page.getByRole("heading", { name: /Explore Other Programs/ }),
		).toBeVisible()
		await expect(
			page.getByText("Financial Risk Manager", { exact: true }),
		).toBeVisible()
	})

	test("the grid/list toggle writes ?view= and keeps the bucket rendered", async ({
		page,
	}) => {
		await installMockOrg(page, { actions: baseActions() })
		await page.goto("/programs")

		// In Progress defaults to the list layout; flip to grid and back.
		await page.getByRole("radio", { name: "Grid view" }).click()
		await expect(page).toHaveURL(/view=grid/)
		await expect(
			page.getByText("Financial Risk Manager", { exact: true }),
		).toBeVisible()

		await page.getByRole("radio", { name: "List view" }).click()
		await expect(page).toHaveURL(/view=list/)
		await expect(
			page.getByText("Financial Risk Manager", { exact: true }),
		).toBeVisible()
	})
})

test.describe("program detail", () => {
	test("FRM detail renders the hero, next step, and utility rail", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: { ...baseActions(), programDetail: frmDetailData() },
		})
		await page.goto("/programs/frm")

		// Hero: name, brand copy, and the part's scheduling state.
		await expect(
			page.getByRole("heading", { name: "Financial Risk Manager", level: 1 }),
		).toBeVisible()
		await expect(
			page.getByText("The global standard for financial risk."),
		).toBeVisible()
		await expect(page.getByText("Scheduling open")).toBeVisible()

		// The next-step card carries the in-app scheduling CTA.
		await expect(
			page.getByRole("heading", { name: "Schedule your exam" }),
		).toBeVisible()
		// Offered twice by design: the hero's next step, and again on the part
		// card so a second part's card can carry its own actions.
		const ctas = page.getByRole("link", { name: "Schedule Exam" })
		await expect(ctas).toHaveCount(2)
		await expect(ctas.first()).toBeVisible()
		await expect(ctas.first()).toHaveAttribute(
			"href",
			/\/programs\/frm\/exam-setup/,
		)

		// Desktop rail: notifications, deadlines, and the resources CTAs.
		// Each block renders twice (mobile + desktop slots); assert the visible one.
		await expect(
			page.getByText("Exam window update").filter({ visible: true }),
		).toHaveCount(1)
		await expect(
			page.getByText("Last Day to Schedule").filter({ visible: true }),
		).toHaveCount(1)
		const errata = page
			.getByRole("link", { name: "Submit Errata" })
			.filter({ visible: true })
		await expect(errata).toHaveCount(1)
		await expect(errata).toHaveAttribute("href", /\/programs\/frm\/errata/)

		// The detail was fetched for this programme, once.
		expect(org.hits("programDetail")).toBe(1)
		expect(org.of("programDetail")[0].url).toContain("programType=frm")
	})

	test("a programDetail failure shows the server's message with the chrome intact", async ({
		page,
	}) => {
		await installMockOrg(page, {
			actions: {
				...baseActions(),
				programDetail: refuse(500, "Program detail exploded"),
			},
		})
		await page.goto("/programs/frm")

		// The panel surfaces the SERVER's sentence (inline and via toast),
		// never a swallowed generic.
		await expect(
			page.getByText("Program detail exploded").first(),
		).toBeVisible()
		// Chrome survives: toolbar still mounted, no crash screen.
		await expect(page.locator("header").first()).toBeVisible()
	})
})
