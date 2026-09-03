import { act, fireEvent, screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

import { personalInfoQueryKeys } from "@/api/personal-info/query-options"
import { AccountInformationPanel } from "@/components/organisms/account-information-panel"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { accountView, completeness } from "@/testing/factories/account"
import { personalInfoEditData } from "@/testing/factories/personal-info"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"
import { renderWithRouterProviders } from "@/testing/router"

/**
 * The "review missing" jump: the hero's strip scrolls the career card into
 * view and holds a spotlight ring on it for 1.8s. jsdom lays nothing out, so
 * `scrollParent` finds no scrollable ancestor and the glide falls back to the
 * card's own `scrollIntoView` — spied on per element here.
 */

beforeEach(() => {
	vi.useFakeTimers({ toFake: ["setTimeout", "clearTimeout"] })
})

afterEach(() => {
	vi.clearAllTimers()
	vi.useRealTimers()
})

async function renderIncompletePanel() {
	server.use(
		http.get("/services/apexrest/memberportal/options", () =>
			HttpResponse.json(memberPortalEnvelope({ picklists: {}, chapters: [] })),
		),
		http.get("/services/apexrest/memberportal/expertise", () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					values: {},
					options: {},
					labels: {},
				}),
			),
		),
	)
	const account = accountView({
		completeness: completeness({
			isComplete: false,
			percentComplete: 80,
			missing: ["Job function", "School name"],
		}),
	})
	const queryClient = createTestQueryClient()
	queryClient.setQueryData(
		personalInfoQueryKeys.edit(account.identity.contactId ?? ""),
		personalInfoEditData(),
	)
	return renderWithRouterProviders(
		<AccountInformationPanel account={account} />,
		{ queryClient },
	)
}

describe("AccountInformationPanel — spotlight jump", () => {
	it("scrolls the career card into view from the review-missing strip", async () => {
		await renderIncompletePanel()

		const card = document.getElementById("account-section-career")
		if (!card) throw new Error("career card not rendered")
		const scrollSpy = vi
			.spyOn(card, "scrollIntoView")
			.mockImplementation(() => undefined)

		fireEvent.click(
			screen.getByRole("button", { name: "Complete your profile — 2 items left" }),
		)

		expect(scrollSpy).toHaveBeenCalledWith({ block: "start" })

		// The spotlight hold expires without touching the card again.
		act(() => {
			vi.advanceTimersByTime(1800)
		})
		expect(scrollSpy).toHaveBeenCalledTimes(1)
	})

	it("restarts the hold on a second jump instead of stacking timers", async () => {
		await renderIncompletePanel()

		const card = document.getElementById("account-section-career")
		if (!card) throw new Error("career card not rendered")
		const scrollSpy = vi
			.spyOn(card, "scrollIntoView")
			.mockImplementation(() => undefined)

		const strip = screen.getByRole("button", {
			name: "Complete your profile — 2 items left",
		})
		fireEvent.click(strip)
		act(() => {
			vi.advanceTimersByTime(1000)
		})
		fireEvent.click(strip)
		// The first timer was cleared by the state change; the hold expiring
		// re-scrolls nothing — each jump scrolled exactly once.
		act(() => {
			vi.advanceTimersByTime(1800)
		})
		expect(scrollSpy).toHaveBeenCalledTimes(2)
	})
})
