import { act, fireEvent, screen } from "@testing-library/react"
import { afterEach, describe, expect, it, vi } from "vitest"

import { MemberDirectoryPanel } from "@/components/organisms/member-directory-panel"
import {
	directoryMember,
	directorySearchResults,
} from "@/testing/factories/directory"
import { directoryOrg } from "@/testing/msw/handlers/directory"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

/**
 * The search-as-you-type wiring: the input stays live while the query key
 * trails on the 350ms debounce, so a fast typist costs exactly one request.
 *
 * Per the `use-debounced-value.test.ts` recipe, only setTimeout/clearTimeout
 * are faked — and only AFTER mount and the initial search settle under real
 * timers. Interactions use `fireEvent`: userEvent's internal waits deadlock
 * against faked setTimeout.
 */

afterEach(() => {
	vi.clearAllTimers()
	vi.useRealTimers()
})

const fakeTimers = () =>
	vi.useFakeTimers({ toFake: ["setTimeout", "clearTimeout"] })

async function advance(ms: number) {
	await act(async () => {
		await vi.advanceTimersByTimeAsync(ms)
	})
}

/** Lets in-flight MSW requests finish without advancing the debounce. */
async function settle(rounds = 6) {
	await act(async () => {
		for (let round = 0; round < rounds; round += 1) {
			await vi.advanceTimersByTimeAsync(0)
			await new Promise<void>((resolve) => {
				setImmediate(resolve)
			})
		}
	})
}

function pagedOrg() {
	const org = directoryOrg({
		respond: (body) =>
			directorySearchResults({
				members: [directoryMember()],
				pages: 3,
				total: 25,
				pageCurrent: body.pageCurrent ?? 1,
			}),
	})
	server.use(...org.handlers)
	return org
}

const searchBox = () =>
	screen.getByRole("textbox", { name: "Search the member directory" })

async function mountSettled(org: ReturnType<typeof pagedOrg>) {
	renderWithProviders(<MemberDirectoryPanel />)
	await screen.findByRole("button", { name: "View Ada Lovelace" })
	expect(org.spy.hits).toBe(1)
	fakeTimers()
}

describe("search debounce", () => {
	it("sends nothing during the window, then one request for the settled term", async () => {
		const org = pagedOrg()
		await mountSettled(org)

		fireEvent.change(searchBox(), { target: { value: "a" } })
		fireEvent.change(searchBox(), { target: { value: "ad" } })
		fireEvent.change(searchBox(), { target: { value: "ada" } })
		// The input is live even though no request has gone out.
		expect(searchBox()).toHaveValue("ada")

		await advance(349)
		await settle()
		expect(org.spy.hits).toBe(1)

		await advance(1)
		await settle()
		expect(org.spy.hits).toBe(2)
		expect(org.spy.bodies[1].searchText).toBe("ada")
	})

	it("restarts the window on every keystroke — the mid-flight term never lands", async () => {
		const org = pagedOrg()
		await mountSettled(org)

		fireEvent.change(searchBox(), { target: { value: "smi" } })
		await advance(200)
		fireEvent.change(searchBox(), { target: { value: "smith" } })

		// 349ms after the LAST change: "smi" must never have been sent.
		await advance(349)
		await settle()
		expect(org.spy.hits).toBe(1)

		await advance(1)
		await settle()
		expect(org.spy.hits).toBe(2)
		expect(org.spy.bodies.map((body) => body.searchText)).toEqual([null, "smith"])
	})

	it("returns to page 1 when the term changes", async () => {
		const org = pagedOrg()
		await mountSettled(org)

		fireEvent.click(screen.getByRole("button", { name: "Next" }))
		await settle()
		expect(org.spy.hits).toBe(2)
		expect(org.spy.bodies[1].pageCurrent).toBe(2)

		fireEvent.change(searchBox(), { target: { value: "ada" } })
		await advance(350)
		await settle()
		expect(org.spy.hits).toBe(3)
		expect(org.spy.bodies[2]).toMatchObject({
			searchText: "ada",
			pageCurrent: 1,
		})
	})

	it("restores the everyone list from cache when the term is emptied", async () => {
		const org = pagedOrg()
		await mountSettled(org)

		fireEvent.change(searchBox(), { target: { value: "ada" } })
		await advance(350)
		await settle()
		expect(org.spy.hits).toBe(2)

		fireEvent.change(searchBox(), { target: { value: "" } })
		await advance(350)
		await settle()
		// The emptied term is the mount key again — still fresh, so the full
		// list comes back without another wire hit.
		expect(org.spy.hits).toBe(2)
		expect(searchBox()).toHaveValue("")
		expect(
			screen.getByRole("button", { name: "View Ada Lovelace" }),
		).toBeInTheDocument()
	})
})
