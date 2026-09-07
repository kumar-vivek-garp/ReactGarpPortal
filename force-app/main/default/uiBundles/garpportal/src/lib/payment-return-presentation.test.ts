import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import {
	isNothingFound,
	isSettledStatus,
	isTransientNetworkError,
	paymentReference,
	resolvePaymentReturnOutcome,
	type PaymentReturnState,
} from "@/lib/payment-return-presentation"
import {
	paymentStatusResult,
	stagedPaymentStatus,
} from "@/testing/factories/exam-payment"

describe("isSettledStatus", () => {
	it("settles on a landed payment, a rollback, or a terminal staged status", () => {
		expect(isSettledStatus(paymentStatusResult())).toBe(true)
		expect(
			isSettledStatus(paymentStatusResult({ isPaymentSuccess: false, isOrderRolledback: true })),
		).toBe(true)
		expect(isSettledStatus(stagedPaymentStatus({ registrationStatus: "Failed", isPaymentSuccess: false }))).toBe(true)
		expect(
			isSettledStatus(stagedPaymentStatus({ registrationStatus: "Payment Failed", isPaymentSuccess: false })),
		).toBe(true)
	})

	it("keeps polling while the webhook has not answered", () => {
		expect(
			isSettledStatus(stagedPaymentStatus({ registrationStatus: "Awaiting Payment", isPaymentFound: false, isPaymentSuccess: false })),
		).toBe(false)
		expect(
			isSettledStatus(paymentStatusResult({ isPaymentFound: false, isPaymentSuccess: false })),
		).toBe(false)
	})
})

describe("isNothingFound", () => {
	it("is true only when the answer carries no trace of a registration", () => {
		expect(isNothingFound({})).toBe(true)
		expect(isNothingFound({ isOrderFound: true })).toBe(false)
		expect(isNothingFound({ isPaymentFound: true })).toBe(false)
		expect(isNothingFound({ registrationStatus: "Awaiting Payment" })).toBe(false)
	})
})

describe("isTransientNetworkError", () => {
	it("retries only an unreachable service", () => {
		expect(isTransientNetworkError(new TypeError("Failed to fetch"))).toBe(true)
		expect(
			isTransientNetworkError(new AppError({ messages: ["down"], status: 0 })),
		).toBe(true)
		expect(
			isTransientNetworkError(new AppError({ messages: ["Order not found"], status: 400 })),
		).toBe(false)
		expect(isTransientNetworkError(new Error("x"))).toBe(false)
	})
})

describe("resolvePaymentReturnOutcome", () => {
	const base: PaymentReturnState = {
		statusId: "801",
		settled: true,
		status: null,
		pollError: null,
	}

	it("is confirming until the poll settles", () => {
		expect(resolvePaymentReturnOutcome({ ...base, settled: false })).toBe("confirming")
	})

	it("is an issue when the endpoint refused, or never saw the registration", () => {
		expect(resolvePaymentReturnOutcome({ ...base, pollError: "Order not found" })).toBe("issue")
		expect(resolvePaymentReturnOutcome({ ...base, status: {} })).toBe("issue")
		expect(resolvePaymentReturnOutcome({ ...base, status: null })).toBe("issue")
	})

	it("is an issue with no id at all — nothing confirmed a payment", () => {
		expect(resolvePaymentReturnOutcome({ ...base, statusId: undefined, status: null })).toBe("issue")
	})

	it("is declined on Payment Failed — the row is still payable", () => {
		expect(
			resolvePaymentReturnOutcome({
				...base,
				status: stagedPaymentStatus({ registrationStatus: "Payment Failed", isPaymentSuccess: false }),
			}),
		).toBe("declined")
	})

	it("succeeds only on a clean payment", () => {
		expect(resolvePaymentReturnOutcome({ ...base, status: paymentStatusResult() })).toBe("succeeded")
		expect(resolvePaymentReturnOutcome({ ...base, status: stagedPaymentStatus() })).toBe("succeeded")
	})

	it("fails when paid but rolled back or the records could not be written", () => {
		expect(
			resolvePaymentReturnOutcome({ ...base, status: paymentStatusResult({ isOrderRolledback: true }) }),
		).toBe("failed")
		expect(
			resolvePaymentReturnOutcome({
				...base,
				status: stagedPaymentStatus({ registrationStatus: "Failed" }),
			}),
		).toBe("failed")
		// A transaction that exists and did not succeed, without a staged status.
		expect(
			resolvePaymentReturnOutcome({ ...base, status: paymentStatusResult({ isPaymentSuccess: false }) }),
		).toBe("failed")
	})
})

describe("paymentReference", () => {
	it("prefers the order number, then the REG- reference, then the URL", () => {
		expect(paymentReference(paymentStatusResult({ orderNumber: "ORD-9" }), "W1")).toBe("ORD-9")
		expect(paymentReference(stagedPaymentStatus({ orderNumber: null }), "W1")).toBe("REG-000123")
		expect(paymentReference({}, "W1")).toBe("W1")
		expect(paymentReference(null, undefined)).toBeNull()
	})
})
