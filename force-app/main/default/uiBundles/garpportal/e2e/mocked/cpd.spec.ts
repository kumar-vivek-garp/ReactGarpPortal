import { expect, test } from "@playwright/test"

import type { AlertBarView } from "@/api/alert-bar"
import { cpdClaim, cpdCycleInfo, cpdProgramView } from "@/testing/factories/cpd"
import { installMockOrg, refuse } from "../support/mock-org"
import { dashboardActionSet } from "../support/payloads"

/**
 * The /cpd page: the current cycle renders from one `cpdProgram` payload,
 * `?cycle=` opens a past cycle (read-only — no manage box, no pending
 * section), the picker switches cycles client-side WITHOUT refetching, and a
 * cpdProgram failure degrades with the chrome intact.
 */

/** No floating alert over these pages — its journeys live in dashboard.spec.ts. */
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

/**
 * Two cycles in one payload: the live 2025/2027 (one pending, one approved
 * claim) and a closed, attested 2023/2025 with an approved claim only —
 * Apex never attaches pending claims to a closed cycle.
 */
function cpdProgramData() {
	return cpdProgramView({
		currentCycle: "2025/2027",
		cycles: [
			cpdCycleInfo({
				pendingClaims: [
					cpdClaim({ claimId: "claim-1", title: "Climate Risk Webinar" }),
				],
				approvedClaims: [
					cpdClaim({ claimId: "claim-2", title: "Approved Course", credits: 4 }),
				],
			}),
			cpdCycleInfo({
				programId: "prog-0",
				cycleName: "2023/2025",
				startYear: 2023,
				endYear: 2025,
				status: "completed",
				isAttested: true,
				creditsApproved: 40,
				approvedClaims: [cpdClaim({ claimId: "claim-3", title: "Old Reading" })],
			}),
		],
	})
}

function baseActions(): Record<string, unknown> {
	return {
		...dashboardActionSet(),
		alertBar: NO_ALERT,
		cpdProgram: cpdProgramData(),
	}
}

test.describe("cpd page", () => {
	test("the current cycle renders summary, manage box and claims, with no unhandled action", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: baseActions() })
		await page.goto("/cpd")

		await expect(
			page.getByRole("heading", {
				name: "Continuing Professional Development",
				level: 1,
			}),
		).toBeVisible()

		// The picker opens on the server's currentCycle.
		await expect(
			page.getByRole("combobox", { name: "Cycle:" }),
		).toContainText("2025/2027")

		// Manage box — current cycle only.
		await expect(page.getByText("Manage CPD Credits")).toBeVisible()
		await expect(page.getByRole("button", { name: "Add Credits" })).toBeVisible()

		// Claims, bucketed with their counts.
		await expect(
			page.getByRole("heading", { name: /Pending Activities/ }),
		).toBeVisible()
		await expect(page.getByText("Climate Risk Webinar")).toBeVisible()
		await expect(
			page.getByRole("heading", { name: /Approved Activities/ }),
		).toBeVisible()
		await expect(page.getByText("Approved Course")).toBeVisible()

		// The credit summary card: title plus the FRM bar's approved/required.
		await expect(page.getByText("2025/2027 Credit Summary")).toBeVisible()
		await expect(page.getByText("8 / 40")).toBeVisible()

		// Healthy org: no stray "Unable to load ..." toast anywhere.
		await expect(page.getByText(/unable to load/i)).toHaveCount(0)

		// Audit surface: every memberportal action answered by a typed payload.
		expect(
			org.unhandled
				.filter((call) => call.kind === "action")
				.map((call) => call.key),
		).toEqual([])
	})

	test("?cycle= opens a past cycle read-only — no manage box, no pending section", async ({
		page,
	}) => {
		await installMockOrg(page, { actions: baseActions() })
		await page.goto("/cpd?cycle=2023%2F2025")

		await expect(page.getByText("Old Reading")).toBeVisible()
		await expect(page.getByText("2023/2025 Credit Summary")).toBeVisible()
		await expect(
			page.getByRole("combobox", { name: "Cycle:" }),
		).toContainText("2023/2025")

		// A closed cycle cannot be managed and carries no pending claims.
		await expect(page.getByRole("button", { name: "Add Credits" })).toBeHidden()
		await expect(
			page.getByRole("heading", { name: /Pending Activities/ }),
		).toBeHidden()
	})

	test("the cycle picker writes ?cycle= and switches without refetching", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: baseActions() })
		await page.goto("/cpd")

		await expect(page.getByText("Climate Risk Webinar")).toBeVisible()

		await page.getByRole("combobox", { name: "Cycle:" }).click()
		await page.getByRole("option", { name: "2023/2025" }).click()

		await expect(page).toHaveURL(/cycle=2023(%2F|\/)2025/)
		await expect(page.getByText("Old Reading")).toBeVisible()
		await expect(page.getByText("2023/2025 Credit Summary")).toBeVisible()

		// Every cycle arrived in the one payload — switching must not refetch.
		expect(org.hits("cpdProgram")).toBe(1)
	})

	test("a cpdProgram failure shows the error state with the chrome intact", async ({
		page,
	}) => {
		await installMockOrg(page, {
			actions: {
				...baseActions(),
				cpdProgram: refuse(500, "CPD service exploded"),
			},
		})
		await page.goto("/cpd")

		await expect(
			page.getByText(/couldn.t load your CPD record/i),
		).toBeVisible()
		// The failure toasts with the SERVER's message, never a swallowed generic.
		await expect(page.getByText("CPD service exploded").first()).toBeVisible()
		// Chrome survives: toolbar still mounted, no crash screen.
		await expect(page.locator("header").first()).toBeVisible()
	})
})
