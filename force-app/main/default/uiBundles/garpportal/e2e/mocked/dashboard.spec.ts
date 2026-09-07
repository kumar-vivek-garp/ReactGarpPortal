import { expect, test } from "@playwright/test"

import { installMockOrg, refuse } from "../support/mock-org"
import {
	dashboardActionSet,
	dismissResultData,
	restoreResultData,
} from "../support/payloads"

/**
 * Dashboard module journeys against the built app: the card manifest renders,
 * no stray "Unable to load" toast fires on a healthy org, the notifications
 * card carries its notices, dismiss/undo round-trips through the real
 * dismissCard/restoreCard actions, a dashboard failure degrades without
 * taking the chrome down, and the alert bar minimises into the toolbar.
 */

const PROFILE_CARD_TITLE = "Your Profile Is Missing Information"

test.describe("dashboard cards", () => {
	test("a member's manifest renders its cards with no load-error toast", async ({
		page,
	}) => {
		const org = await installMockOrg(page, { actions: dashboardActionSet() })
		await page.goto("/dashboard")

		await expect(
			page.getByRole("heading", { name: "Dashboard", level: 1 }),
		).toBeVisible()

		// Card kinds by their visible names, in the server-ranked manifest.
		// `exact` matters: the cards' own CTA labels ("See all enrolled
		// programs") substring-match the titles otherwise.
		await expect(page.getByText(PROFILE_CARD_TITLE)).toBeVisible()
		await expect(
			page.getByText("Enrolled Programs", { exact: true }),
		).toBeVisible()
		await expect(page.getByText("My Events", { exact: true })).toBeVisible()
		await expect(page.getByText("2025/2027 CPD Credits")).toBeVisible()
		await expect(page.getByText("Take the SCR exam")).toBeVisible()

		// The alert bar floats over the page with its message.
		await expect(
			page.getByText("You have not booked a seat for your exam yet."),
		).toBeVisible()
		// The deadline line under the programme name ("Schedule by November 7,
		// 2026"). The message alone would also match the notification copy,
		// so anchor on the deadline as well.
		await expect(page.getByText(/Schedule by/)).toBeVisible()

		// The known artifact this spec exists to kill: a healthy org must not
		// toast "Unable to load ..." anywhere (cpd/notifications were the usual
		// offenders when their payloads fell through to the mock's {} default).
		await expect(page.getByText(/unable to load/i)).toHaveCount(0)

		// Audit surface: every memberportal action the page fired was answered
		// by a typed payload, not the permissive-but-wrong default.
		expect(
			org.unhandled
				.filter((call) => call.kind === "action")
				.map((call) => call.key),
		).toEqual([])
	})

	test("the notifications card previews the mocked notices", async ({
		page,
	}) => {
		await installMockOrg(page, { actions: dashboardActionSet() })
		await page.goto("/dashboard")

		await expect(page.getByText("New Notifications")).toBeVisible()
		await expect(page.getByText("Exam window update")).toBeVisible()
		await expect(page.getByText("Admission ticket available")).toBeVisible()
		await expect(
			page.getByText(/FRM Part I exam window has been extended/),
		).toBeVisible()
	})

	test("dismissing a card hits dismissCard and undo restores it", async ({
		page,
	}) => {
		const org = await installMockOrg(page, {
			actions: {
				...dashboardActionSet(),
				dismissCard: dismissResultData("Dashboard_Profile_Completeness"),
				restoreCard: restoreResultData("Dashboard_Profile_Completeness"),
			},
		})
		await page.goto("/dashboard")

		await expect(page.getByText(PROFILE_CARD_TITLE)).toBeVisible()
		await page
			.getByRole("button", { name: "Dismiss this card" })
			.click()

		// Optimistically hidden, then the undo toast once Apex confirmed.
		await expect(page.getByText(PROFILE_CARD_TITLE)).toBeHidden()
		await expect(page.getByText("Card hidden for 60 days.")).toBeVisible()
		await expect.poll(() => org.hits("dismissCard")).toBe(1)

		await page.getByRole("button", { name: "Undo" }).click()

		await expect.poll(() => org.hits("restoreCard")).toBe(1)
		await expect(page.getByText(PROFILE_CARD_TITLE)).toBeVisible()
	})

	test("a dashboard failure shows the error state with the chrome intact", async ({
		page,
	}) => {
		await installMockOrg(page, {
			actions: {
				...dashboardActionSet(),
				dashboard: refuse(500, "Dashboard service exploded"),
			},
		})
		await page.goto("/dashboard")

		await expect(
			page.getByText(/couldn.t load your dashboard/i),
		).toBeVisible()
		// The failure toasts with the SERVER's message, never a swallowed generic.
		await expect(page.getByText("Dashboard service exploded")).toBeVisible()
		// Chrome survives: toolbar still mounted, no crash screen.
		await expect(page.locator("header").first()).toBeVisible()
	})
})

test.describe("alert bar", () => {
	test("the alert minimises into the toolbar trigger and restores", async ({
		page,
	}) => {
		await installMockOrg(page, { actions: dashboardActionSet() })
		await page.goto("/dashboard")

		const message = page.getByText(
			"You have not booked a seat for your exam yet.",
		)
		await expect(message).toBeVisible()

		// Desktop and mobile toolbars each hold a trigger; only the visible
		// toolbar's one counts. Both are aria-hidden until the card lands.
		const trigger = page
			.getByRole("button", { name: "Show 1 alert" })
			.filter({ visible: true })

		await page.getByRole("button", { name: "Minimise alert" }).click()
		await expect(trigger).toHaveCount(1)

		await trigger.click()
		await expect(trigger).toHaveCount(0)
		await expect(message).toBeVisible()
	})
})
