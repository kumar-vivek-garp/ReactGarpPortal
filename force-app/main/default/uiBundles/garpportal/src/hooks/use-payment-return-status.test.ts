import { describe, expect, it, vi } from "vitest"

import { AppError } from "@/api/client"
import type { PaymentStatusResult } from "@/api/registration/exam-types"
import { pollPaymentReturn } from "@/hooks/use-payment-return-status"
import {
	paymentStatusResult,
	stagedPaymentStatus,
} from "@/testing/factories/exam-payment"

/**
 * Driven through the exported loop with an injected clock rather than fake
 * timers: the rule under test is WHEN the loop stops, and a recorded sleep
 * says that directly.
 */
function harness(answers: Array<PaymentStatusResult | Error>) {
	const slept: number[] = []
	const fetchStatus = vi.fn(async () => {
		const next = answers.shift()
		if (next === undefined) throw new Error("poll asked more times than answers")
		if (next instanceof Error) throw next
		return next
	})
	const sleep = vi.fn(async (ms: number) => {
		slept.push(ms)
	})
	return { fetchStatus, sleep, slept }
}

describe("pollPaymentReturn", () => {
	it("settles on the first successful answer without sleeping", async () => {
		const { fetchStatus, sleep } = harness([paymentStatusResult()])

		const result = await pollPaymentReturn("801", { fetchStatus, sleep, delays: [10, 20] })

		expect(result).toEqual({ status: paymentStatusResult(), pollError: null, settled: true })
		expect(fetchStatus).toHaveBeenCalledTimes(1)
		expect(sleep).not.toHaveBeenCalled()
	})

	it("keeps polling on the widening delays while the webhook is quiet", async () => {
		const pending = stagedPaymentStatus({
			registrationStatus: "Awaiting Payment",
			isPaymentFound: false,
			isPaymentSuccess: false,
		})
		const { fetchStatus, sleep, slept } = harness([
			pending,
			pending,
			stagedPaymentStatus(),
		])

		const result = await pollPaymentReturn("a0H", {
			fetchStatus,
			sleep,
			delays: [10, 20, 30],
		})

		expect(result.settled).toBe(true)
		expect(result.status?.registrationStatus).toBe("Paid")
		expect(slept).toEqual([10, 20])
	})

	it("reports every interim answer so the reference can show early", async () => {
		const pending = stagedPaymentStatus({
			registrationStatus: "Awaiting Payment",
			isPaymentSuccess: false,
			isPaymentFound: false,
		})
		const { fetchStatus, sleep } = harness([pending, stagedPaymentStatus()])
		const seen: string[] = []

		await pollPaymentReturn("a0H", {
			fetchStatus,
			sleep,
			delays: [1, 1],
			onStatus: (status) => seen.push(status.registrationStatus ?? "?"),
		})

		expect(seen).toEqual(["Awaiting Payment", "Paid"])
	})

	it("settles as declined on Payment Failed rather than polling past it", async () => {
		const { fetchStatus, sleep } = harness([
			stagedPaymentStatus({ registrationStatus: "Payment Failed", isPaymentSuccess: false }),
		])

		const result = await pollPaymentReturn("a0H", { fetchStatus, sleep, delays: [10] })

		expect(result.settled).toBe(true)
		expect(result.status?.registrationStatus).toBe("Payment Failed")
		expect(sleep).not.toHaveBeenCalled()
	})

	it("stops at once on an answer with no trace of the registration", async () => {
		const { fetchStatus, sleep } = harness([{}])

		const result = await pollPaymentReturn("dead", { fetchStatus, sleep, delays: [10, 20] })

		expect(result).toEqual({
			status: {},
			pollError: "We could not find this registration.",
			settled: true,
		})
		expect(fetchStatus).toHaveBeenCalledTimes(1)
	})

	it("stops on a server refusal, keeping its message", async () => {
		const { fetchStatus, sleep } = harness([
			new AppError({ messages: ["Order not found"], status: 400 }),
		])

		const result = await pollPaymentReturn("801", { fetchStatus, sleep, delays: [10, 20] })

		expect(result).toEqual({ status: null, pollError: "Order not found", settled: true })
		expect(sleep).not.toHaveBeenCalled()
	})

	it("retries through a network hiccup", async () => {
		const { fetchStatus, sleep, slept } = harness([
			new AppError({ messages: ["Unable to reach"], status: 0 }),
			new TypeError("Failed to fetch"),
			paymentStatusResult(),
		])

		const result = await pollPaymentReturn("801", {
			fetchStatus,
			sleep,
			delays: [10, 20, 30],
		})

		expect(result.settled).toBe(true)
		expect(result.pollError).toBeNull()
		expect(slept).toEqual([10, 20])
	})

	it("runs dry as settled with the last answer and no error", async () => {
		const pending = paymentStatusResult({ isPaymentFound: false, isPaymentSuccess: false })
		const { fetchStatus, sleep } = harness([pending, pending])

		const result = await pollPaymentReturn("801", { fetchStatus, sleep, delays: [10, 20] })

		expect(result).toEqual({ status: pending, pollError: null, settled: true })
		expect(fetchStatus).toHaveBeenCalledTimes(2)
	})

	it("stops quietly, unsettled, once the screen has gone", async () => {
		const pending = paymentStatusResult({ isPaymentFound: false, isPaymentSuccess: false })
		const { fetchStatus, sleep } = harness([pending, paymentStatusResult()])
		let cancelled = false
		const sleepThenCancel = async (ms: number) => {
			await sleep(ms)
			cancelled = true
		}

		const result = await pollPaymentReturn("801", {
			fetchStatus,
			sleep: sleepThenCancel,
			delays: [10, 20],
			isCancelled: () => cancelled,
		})

		expect(result.settled).toBe(false)
		expect(fetchStatus).toHaveBeenCalledTimes(1)
	})
})
