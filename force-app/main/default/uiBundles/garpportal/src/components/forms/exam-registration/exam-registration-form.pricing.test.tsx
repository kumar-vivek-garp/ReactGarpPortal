import { act, fireEvent, screen } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { afterEach, describe, expect, it, vi } from "vitest"

import type { FeesRequest } from "@/api/registration/exam-types"
import { formatMoney } from "@/lib/account-format"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { feesResult } from "@/testing/factories/exam"
import { renderExamForm } from "@/testing/exam-registration-ui"
import { EXAMREG_PATH } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { skipSpringAnimations } from "@/testing/springs"

/**
 * The pricing wiring as the candidate sees it: the 400ms debounce, the bar's
 * reserved total block, and `keepPreviousData` holding the old figure on
 * screen (labelled "Updating…") instead of blinking it away.
 *
 * Springs are skipped so `AnimatedAmount` lands on its end value. Timers are
 * faked (setTimeout only, per the `use-debounced-value.test.ts` recipe) — but
 * only AFTER the async router mount and the initial pricing have settled,
 * because `renderWithRouterProviders` awaits the router's own load and must
 * run under real timers.
 */
skipSpringAnimations()

afterEach(() => {
	vi.clearAllTimers()
	vi.useRealTimers()
})

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

const PRICE_100 = formatMoney(100, "USD") as string
const PRICE_200 = formatMoney(200, "USD") as string

const fakeTimers = () =>
	vi.useFakeTimers({ toFake: ["setTimeout", "clearTimeout"] })

describe("ExamRegistrationForm — pricing", () => {
	it("reserves the total block, prices once on mount, and re-prices a change only after 400ms", async () => {
		const spy = { hits: 0, bodies: [] as FeesRequest[] }
		server.use(
			http.post(`${EXAMREG_PATH}/fees`, async ({ request }) => {
				spy.hits += 1
				spy.bodies.push((await request.json()) as FeesRequest)
				return HttpResponse.json(
					memberPortalEnvelope(feesResult(spy.hits === 1 ? 100 : 200)),
				)
			}),
		)
		await renderExamForm()

		// Before pricing: the block is already there, at its fixed size, saying
		// nothing — not absent ("Total" renders in the bar and again as the
		// rail's placeholder row, both with an em-dash where a figure will go).
		expect(screen.getAllByText("Total").length).toBeGreaterThan(0)
		expect(screen.getAllByText("—").length).toBeGreaterThan(0)
		expect(
			screen.getByText("Choose your exam to see the total."),
		).toBeInTheDocument()

		// The initial cart prices immediately (the debounce passes the first
		// value straight through).
		await screen.findAllByText(PRICE_100)
		expect(spy.hits).toBe(1)
		expect(
			screen.queryByText("Choose your exam to see the total."),
		).not.toBeInTheDocument()

		// From here the debounce is under test — freeze the clock.
		fakeTimers()

		// Add the part-agnostic study material from the rail. `fireEvent`, not
		// userEvent: userEvent's internal waits deadlock against faked
		// setTimeout, and a plain button toggle needs no pointer simulation.
		fireEvent.click(screen.getByRole("button", { name: "Add" }))
		expect(screen.getByRole("button", { name: "Remove" })).toBeInTheDocument()

		// Inside the debounce window nothing is re-priced.
		await advance(399)
		expect(spy.hits).toBe(1)

		await advance(1)
		await settle()
		expect(spy.hits).toBe(2)
		expect(spy.bodies[1].materials).toEqual(["SM-GEN"])
		expect(screen.getAllByText(PRICE_200).length).toBeGreaterThan(0)
		expect(screen.queryByText(PRICE_100)).not.toBeInTheDocument()
	})

	it("holds the previous total on screen, marked Updating…, while the next one is in flight", async () => {
		let release!: () => void
		const gate = new Promise<void>((resolve) => {
			release = resolve
		})
		const spy = { hits: 0 }
		server.use(
			http.post(`${EXAMREG_PATH}/fees`, async () => {
				spy.hits += 1
				if (spy.hits > 1) {
					await gate
					return HttpResponse.json(memberPortalEnvelope(feesResult(200)))
				}
				return HttpResponse.json(memberPortalEnvelope(feesResult(100)))
			}),
		)
		await renderExamForm()

		await screen.findAllByText(PRICE_100)
		expect(screen.queryByText("Updating…")).not.toBeInTheDocument()

		fakeTimers()

		// Same fireEvent rationale as above.
		fireEvent.click(screen.getByRole("button", { name: "Add" }))
		await advance(400)
		await settle()

		// keepPreviousData: the old figure holds — updated, not blinked away —
		// and the written "Updating…" carries what the blur only hints at (it
		// replaces the bar's "Total" caption and joins the rail's card title).
		expect(spy.hits).toBe(2)
		expect(screen.getAllByText(PRICE_100).length).toBeGreaterThan(0)
		expect(screen.getAllByText("Updating…").length).toBeGreaterThan(0)

		// The debounce is spent; hand the clock back so the released response
		// can be awaited as a real signal rather than flushed by guesswork.
		release()
		vi.useRealTimers()
		expect((await screen.findAllByText(PRICE_200)).length).toBeGreaterThan(0)
		expect(screen.queryByText(PRICE_100)).not.toBeInTheDocument()
		expect(screen.queryByText("Updating…")).not.toBeInTheDocument()
	})
})
