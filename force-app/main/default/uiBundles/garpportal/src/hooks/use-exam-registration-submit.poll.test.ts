import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

import { AppError } from "@/api/client"
import {
	pollPaymentStatus,
	STATUS_POLL_ATTEMPTS,
	STATUS_POLL_DELAY_MS,
} from "@/hooks/use-exam-registration-submit"
import { examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"

describe("pollPaymentStatus", () => {
	it("throws 402 with the cancellation message after ONE call when rolled back", async () => {
		const status = examregPost("paymentStatus", () => ({
			isOrderFound: true,
			isOrderRolledback: true,
		}))
		server.use(status.handler)

		const failure = await pollPaymentStatus("801-rb").catch(
			(error: unknown) => error,
		)

		expect(failure).toBeInstanceOf(AppError)
		expect((failure as AppError).status).toBe(402)
		expect((failure as AppError).messages).toEqual([
			"Payment was not completed and your registration was cancelled.",
		])
		expect(status.spy.hits).toBe(1)
	})

	describe("with fake timers", () => {
		beforeEach(() => {
			vi.useFakeTimers({ toFake: ["setTimeout", "clearTimeout"] })
		})

		afterEach(() => {
			vi.clearAllTimers()
			vi.useRealTimers()
		})

		/**
		 * Lets in-flight MSW requests finish under fake timers: real macrotask
		 * yields (setImmediate is not faked) interleaved with zero-length timer
		 * runs, without ever advancing the 1500ms poll delay.
		 */
		async function flushNetwork(rounds = 6) {
			for (let round = 0; round < rounds; round += 1) {
				await vi.advanceTimersByTimeAsync(0)
				await new Promise<void>((resolve) => {
					setImmediate(resolve)
				})
			}
		}

		it("resolves after one delay when the payment shows up on attempt 2", async () => {
			const status = examregPost("paymentStatus", (_body, hits) => ({
				isOrderFound: true,
				isPaymentFound: hits >= 2,
			}))
			server.use(status.handler)

			let settled = false
			const poll = pollPaymentStatus("801-x").then(() => {
				settled = true
			})

			await flushNetwork()
			expect(status.spy.hits).toBe(1)
			expect(settled).toBe(false)

			await vi.advanceTimersByTimeAsync(STATUS_POLL_DELAY_MS)
			await flushNetwork()
			expect(status.spy.hits).toBe(2)

			await poll
			expect(settled).toBe(true)
		})

		it("gives up silently after STATUS_POLL_ATTEMPTS unconfirmed tries", async () => {
			const status = examregPost("paymentStatus", () => ({
				isOrderFound: true,
				isPaymentFound: false,
			}))
			server.use(status.handler)

			let settled = false
			const poll = pollPaymentStatus("801-x").then(() => {
				settled = true
			})

			await flushNetwork()
			expect(status.spy.hits).toBe(1)

			await vi.advanceTimersByTimeAsync(STATUS_POLL_DELAY_MS)
			await flushNetwork()
			expect(status.spy.hits).toBe(2)

			await vi.advanceTimersByTimeAsync(STATUS_POLL_DELAY_MS)
			await flushNetwork()
			expect(status.spy.hits).toBe(STATUS_POLL_ATTEMPTS)

			/*
			 * The loop sleeps after EVERY miss — the final attempt included — so
			 * a third (wasted) 1500ms delay stands between the last status call
			 * and resolution. Actual behavior; noted as a minor inefficiency.
			 */
			expect(settled).toBe(false)
			await vi.advanceTimersByTimeAsync(STATUS_POLL_DELAY_MS)
			await poll
			expect(settled).toBe(true)
			// Wire/ACH settle days later — an unconfirmed status is NOT an error.
			expect(status.spy.hits).toBe(STATUS_POLL_ATTEMPTS)
		})
	})
})
