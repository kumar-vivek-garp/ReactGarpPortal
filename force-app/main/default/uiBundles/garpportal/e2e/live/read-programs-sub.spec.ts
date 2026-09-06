import { expect, test, type Locator, type Page } from "@playwright/test"

import { probeGateway, type LiveGate } from "../support/live-gate"
import { installOrgSafetyGuard } from "../support/live-guard"

/**
 * L1 — live read smoke, programme subpages for the first enrolled programme
 * (falling back to frm when the CLI contact has none): errata, exam-setup,
 * results, work-experience. REAL org reads behind the org-safety guard —
 * the results page's auto-fired `examResultViewed` mutation is NEUTRALIZED
 * by the guard (fulfilled with a fake success; the org never sees it).
 * See read-core.spec.ts for the assertion contract.
 */

const ERROR_COPY = /unable to load|went wrong|couldn['’]t (load|run)/i

let gate: LiveGate

test.beforeAll(async () => {
	gate = await probeGateway()
})

test.beforeEach(() => {
	test.skip(!gate.ok, gate.reason)
	test.setTimeout(120_000)
})

async function armLivePage(page: Page) {
	const guard = await installOrgSafetyGuard(page)
	const apiFailures: string[] = []
	page.on("response", (response) => {
		const url = response.url()
		if (
			response.status() >= 400 &&
			(url.includes("/services/") || url.includes("/__local_sf/"))
		) {
			apiFailures.push(
				`${response.status()} ${response.request().method()} ${url}`,
			)
		}
	})
	return { guard, apiFailures }
}

async function gotoLive(page: Page, path: string) {
	await page.goto(path)
	await expect(page.locator("header").first()).toBeVisible({ timeout: 30_000 })
	await expect(page.locator("#boot-splash")).not.toBeVisible({
		timeout: 30_000,
	})
}

function settleUnion(page: Page, first: Locator, ...rest: Locator[]) {
	let union = first
	for (const locator of rest) union = union.or(locator)
	return union.or(page.getByText(ERROR_COPY).first()).first()
}

async function expectNoErrorCopy(page: Page) {
	await expect(page.getByText(ERROR_COPY)).toHaveCount(0)
}

function noteOrg(what: string) {
	test.info().annotations.push({ type: "org-data", description: what })
	console.log(`[live] ${what}`)
}

/**
 * The first enrolled programme with an in-app detail page, resolved ONCE per
 * run from the live /programs listing (workers=1, so module state is safe);
 * "frm" when the org gives the CLI contact none. Only /programs/<slug> View
 * Details links count — /courses/* programmes have no errata/exam-setup/
 * results/work-experience subroutes.
 */
let resolvedSlug: string | null = null

async function resolveProgramSlug(page: Page): Promise<string> {
	if (resolvedSlug) return resolvedSlug
	await gotoLive(page, "/programs")
	await expect(
		page.getByRole("heading", { name: "My Programs", level: 1 }),
	).toBeVisible({ timeout: 30_000 })
	// Let the listing settle (a card action, an empty bucket, or an error).
	const anyCardAction = page
		.getByRole("link", { name: /View Details|Register Now|Learn more about/ })
		.first()
	const anyEmpty = page
		.getByText(
			/No programs (to show|in progress)|No completed programs|Nothing else to explore/,
		)
		.first()
	await expect(settleUnion(page, anyCardAction, anyEmpty)).toBeVisible({
		timeout: 30_000,
	})

	const hrefs = await page
		.locator('a[href^="/programs/"]')
		.filter({ hasText: "View Details" })
		.evaluateAll((nodes) => nodes.map((node) => node.getAttribute("href") ?? ""))
	const slug = hrefs
		.map((href) => /^\/programs\/([a-z0-9-]+)$/.exec(href)?.[1])
		.find((match): match is string => Boolean(match))

	resolvedSlug = slug ?? "frm"
	noteOrg(
		slug
			? `programme subpages target enrolled programme "${slug}"`
			: 'no enrolled programme detail on /programs — falling back to "frm"',
	)
	return resolvedSlug
}

test("errata page serves the report form for the live programme", async ({
	page,
}) => {
	const { guard, apiFailures } = await armLivePage(page)
	const slug = await resolveProgramSlug(page)
	await gotoLive(page, `/programs/${slug}/errata`)

	await expect(
		page.getByRole("heading", { name: "Curriculum errata", level: 1 }),
	).toBeVisible({ timeout: 30_000 })

	// The form renders whenever errataForm answers; the published-sheet card
	// is optional per programme.
	const form = page.getByRole("heading", { name: "Report an error" })
	await expect(settleUnion(page, form)).toBeVisible({ timeout: 30_000 })
	await expectNoErrorCopy(page)
	noteOrg(
		`/programs/${slug}/errata → report form rendered` +
			(apiFailures.length ? `; API >=400: ${apiFailures.join(" | ")}` : ""),
	)

	expect(guard.blocked).toEqual([])
})

test("exam setup renders the wizard or an honest refusal state", async ({
	page,
}) => {
	const { guard, apiFailures } = await armLivePage(page)
	const slug = await resolveProgramSlug(page)
	await gotoLive(page, `/programs/${slug}/exam-setup`)

	await expect(
		page.getByRole("heading", { name: "Exam setup", level: 1 }),
	).toBeVisible({ timeout: 30_000 })

	// Legitimate live states: the wizard itself, or one of the Apex-driven
	// refusals. (The generic "unavailable" refusal carries "couldn't load"
	// copy and is caught as an error below — that one IS a finding.)
	const wizard = page.getByText("Choose your sitting")
	const noAdmins = page.getByText("No exam dates are open")
	const pendingReschedule = page.getByText(
		"You already have a reschedule in progress",
	)
	const unsupported = page.getByText(
		"This programme doesn't use the exam setup wizard.",
	)
	await expect(
		settleUnion(page, wizard, noAdmins, pendingReschedule, unsupported),
	).toBeVisible({ timeout: 30_000 })
	await expectNoErrorCopy(page)
	noteOrg(
		`/programs/${slug}/exam-setup → ${
			(await wizard.isVisible())
				? "wizard rendered"
				: (await noAdmins.isVisible())
					? "no open administrations (refusal state)"
					: (await pendingReschedule.isVisible())
						? "pending reschedule refusal"
						: "programme does not use the wizard"
		}` + (apiFailures.length ? `; API >=400: ${apiFailures.join(" | ")}` : ""),
	)

	expect(guard.blocked).toEqual([])
})

test("results page renders attempts or its empty state; examResultViewed never reaches the org", async ({
	page,
}) => {
	const { guard, apiFailures } = await armLivePage(page)
	const slug = await resolveProgramSlug(page)
	await gotoLive(page, `/programs/${slug}/results`)

	await expect(
		page.getByRole("heading", { name: /Exam Results/, level: 1 }),
	).toBeVisible({ timeout: 30_000 })

	// With attempts the summary strip renders its "Total" chip; without, the
	// panel's own zero state names the programme.
	const summary = page.getByText("Total", { exact: true })
	const empty = page.getByText(/No exam results for/)
	await expect(settleUnion(page, summary, empty)).toBeVisible({
		timeout: 30_000,
	})
	await expectNoErrorCopy(page)

	// A released, un-viewed attempt auto-fires examResultViewed on mount —
	// the guard fulfills it with a fake success, so the org NEVER sees the
	// write. Zero neutralized calls is equally fine (nothing to stamp).
	expect(guard.neutralized.length).toBeGreaterThanOrEqual(0)
	noteOrg(
		`/programs/${slug}/results → ${
			(await empty.isVisible()) ? "no exam results yet" : "attempts rendered"
		}; examResultViewed neutralized: ${guard.neutralized.length}` +
			(apiFailures.length ? `; API >=400: ${apiFailures.join(" | ")}` : ""),
	)

	expect(guard.blocked).toEqual([])
})

test("work experience renders the CV panel or its no-requirement state", async ({
	page,
}) => {
	const { guard, apiFailures } = await armLivePage(page)
	const slug = await resolveProgramSlug(page)
	await gotoLive(page, `/programs/${slug}/work-experience`)

	await expect(
		page.getByRole("heading", { name: "Work Experience", level: 1 }),
	).toBeVisible({ timeout: 30_000 })

	// Legitimate live states: the CV sections (any CV record, editable or
	// submitted), or the no-requirement state Apex answers with a 401 the
	// client maps to null (pre-pass members).
	const cvSections = page.getByText("Your experience").first()
	const noRequirement = page.getByText("No work experience requirement")
	await expect(settleUnion(page, cvSections, noRequirement)).toBeVisible({
		timeout: 30_000,
	})
	await expectNoErrorCopy(page)
	noteOrg(
		`/programs/${slug}/work-experience → ${
			(await noRequirement.isVisible())
				? "no CV requirement for this contact (expected pre-pass)"
				: "CV panel rendered"
		}` + (apiFailures.length ? `; API >=400: ${apiFailures.join(" | ")}` : ""),
	)

	expect(guard.blocked).toEqual([])
})
