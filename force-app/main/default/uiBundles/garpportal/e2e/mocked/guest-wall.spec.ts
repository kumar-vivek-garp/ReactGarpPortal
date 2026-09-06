import { expect, test } from "@playwright/test"

import { installMockOrg } from "../support/mock-org"

/**
 * The guest wall, parameterized: every `_appLayout` route bounces a guest to
 * /Login carrying a `startUrl` that round-trips (guard:
 * `src/pages/_appLayout/route.tsx` → `getReturnPath`), EXCEPT the
 * registration member routes, which hand off to their public twins with the
 * whole query string (`publicRegistrationFallback` in
 * `src/lib/registration-paths.ts`).
 */

/** Protected portal routes with no public twin → the sign-in wall. */
const WALLED_ROUTES = [
	"/dashboard",
	"/programs",
	"/programs/frm",
	"/my-account",
	"/membership",
	"/study-materials",
	"/cpd",
	"/events",
	"/help-center",
	"/member-directory",
	"/content",
	// The real deep order route in this app (/order-details/$orderNumber).
	"/order-details/12345",
	// NOT a route (no /my-account/orders/*), but the router fuzzy-matches the
	// unknown path under /my-account, so _appLayout's guard still runs and
	// walls the guest BEFORE the root not-found could render — verified
	// against the built app.
	"/my-account/orders/12345",
] as const

test.describe("guest wall → /Login with startUrl round-trip", () => {
	for (const path of WALLED_ROUTES) {
		test(`${path} redirects to /Login and startUrl carries the path`, async ({
			page,
		}) => {
			await installMockOrg(page, { identity: "guest" })
			await page.goto(path)
			await expect(page).toHaveURL(/\/Login\?/)
			const startUrl = new URL(page.url()).searchParams.get("startUrl")
			expect(startUrl).toContain(path)
		})
	}
})

type GuestTwin = {
	member: string
	destination: RegExp
	/** A search param that must survive the bounce (name, expected value). */
	carries?: readonly [name: string, value: string]
}

/**
 * Registration member routes hand a guest to the public twin, search intact.
 * `regCode` only rides the exam form — the event schemas accept no regCode
 * by design (src/config/event-registration.ts), so the event rows prove
 * search preservation with `oid`, a param their schema does keep.
 */
const GUEST_TWINS: readonly GuestTwin[] = [
	{
		member: "/programs/frm/register?regCode=TEAM24",
		destination: /\/registration\/frm/,
		carries: ["regCode", "TEAM24"],
	},
	{
		member: "/events/event/E1/register?oid=801",
		destination: /\/registration\/event\/E1/,
		carries: ["oid", "801"],
	},
	{
		member: "/events/webcast/W1/register",
		destination: /\/registration\/webcast\/W1/,
	},
	{
		member: "/events/chaptermeeting/C1/register",
		destination: /\/registration\/chaptermeeting\/C1/,
	},
]

test.describe("guest wall → public registration twins", () => {
	for (const twin of GUEST_TWINS) {
		test(`${twin.member} hands off to its public twin`, async ({ page }) => {
			await installMockOrg(page, { identity: "guest" })
			await page.goto(twin.member)
			await expect(page).toHaveURL(twin.destination)
			if (twin.carries) {
				const [name, value] = twin.carries
				// toContain, not toBe: the router's JSON search codec re-quotes
				// an all-digit string on serialization (oid=801 → oid="801") so
				// it stays a string on the next parse. The value survives; its
				// wire spelling is the codec's business.
				expect(new URL(page.url()).searchParams.get(name)).toContain(value)
			}
		})
	}
})
