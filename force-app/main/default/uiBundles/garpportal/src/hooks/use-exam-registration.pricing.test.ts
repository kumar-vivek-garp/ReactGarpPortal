import { act } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

import type { FeesRequest } from "@/api/registration/exam-types"
import { useExamRegistrationState } from "@/hooks/use-exam-registration"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import {
	examLoad,
	feesResult,
	registrationAddress,
} from "@/testing/factories/exam"
import { EXAMREG_PATH, examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

function stateProps(
	overrides: Partial<Parameters<typeof useExamRegistrationState>[0]> = {},
) {
	return {
		load: examLoad(),
		programType: "frm",
		billingCountry: "",
		mobilePhoneCode: "",
		paymentType: "",
		billingAddress: registrationAddress({ country: "" }),
		shippingAddress: registrationAddress({ country: "Canada" }),
		billingAndShippingSame: true,
		autoRenew: false,
		membershipSelected: false,
		...overrides,
	}
}

function renderState(
	overrides: Partial<Parameters<typeof useExamRegistrationState>[0]> = {},
) {
	return renderHookWithProviders(
		(props: ReturnType<typeof stateProps>) => useExamRegistrationState(props),
		{ initialProps: stateProps(overrides) },
	)
}

describe("useExamRegistrationState — priced request", () => {
	it("prices a card order against the Location country when the address has none", async () => {
		const fees = examregPost<FeesRequest>("fees", () => feesResult(100))
		server.use(fees.handler)

		renderState({ paymentType: "Stripe", billingCountry: "Japan" })

		await vi.waitFor(() => {
			expect(fees.spy.hits).toBeGreaterThan(0)
		})
		const body = fees.spy.bodies[0]
		expect(body.billingAddress.country).toBe("Japan")
		// billingAndShippingSame collapses shipping onto the PRICED billing.
		expect(body.shippingAddress).toEqual(body.billingAddress)
		expect(body.billingAndShippingSame).toBe(true)
	})

	it("keeps an explicit billing country and a distinct shipping address", async () => {
		const fees = examregPost<FeesRequest>("fees", () => feesResult(100))
		server.use(fees.handler)

		renderState({
			billingCountry: "Japan",
			billingAddress: registrationAddress({ country: "France" }),
			billingAndShippingSame: false,
		})

		await vi.waitFor(() => {
			expect(fees.spy.hits).toBeGreaterThan(0)
		})
		const body = fees.spy.bodies[0]
		expect(body.billingAddress.country).toBe("France")
		expect(body.shippingAddress.country).toBe("Canada")
	})
})

describe("useExamRegistrationState — debounced re-pricing", () => {
	beforeEach(() => {
		vi.useFakeTimers({ toFake: ["setTimeout", "clearTimeout"] })
	})

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

	it("waits 400ms before re-pricing and holds the previous total meanwhile", async () => {
		let release!: () => void
		const gate = new Promise<void>((resolve) => {
			release = resolve
		})
		const spy = { hits: 0, bodies: [] as FeesRequest[] }
		server.use(
			http.post(`${EXAMREG_PATH}/fees`, async ({ request }) => {
				spy.hits += 1
				spy.bodies.push((await request.json()) as FeesRequest)
				if (spy.hits > 1) {
					await gate
					return HttpResponse.json(memberPortalEnvelope(feesResult(200)))
				}
				return HttpResponse.json(memberPortalEnvelope(feesResult(100)))
			}),
		)

		const { result } = renderState()
		await settle()
		expect(spy.hits).toBe(1)
		expect(result.current.fees?.total).toBe(100)

		act(() => {
			result.current.toggleMaterial("SM-GEN")
		})

		await advance(399)
		expect(spy.hits).toBe(1) // still inside the debounce window

		await advance(1)
		await settle()
		expect(spy.hits).toBe(2)
		expect(spy.bodies[1].materials).toEqual(["SM-GEN"])

		// keepPreviousData: the old total stays up while the new one is in flight.
		expect(result.current.fees?.total).toBe(100)
		expect(result.current.isPricing).toBe(true)

		release()
		await settle()
		expect(result.current.fees?.total).toBe(200)
		expect(result.current.isPricing).toBe(false)
	})

	it("resets the timer on every change so only the final cart is priced", async () => {
		const fees = examregPost<FeesRequest>("fees", () => feesResult(100))
		server.use(fees.handler)

		const { result } = renderState()
		await settle()
		expect(fees.spy.hits).toBe(1)

		act(() => {
			result.current.toggleMaterial("SM-GEN")
		})
		await advance(200)
		act(() => {
			result.current.toggleMaterial("SM-P2")
		})

		// 399ms after the LAST change: the intermediate cart was never priced.
		await advance(399)
		expect(fees.spy.hits).toBe(1)

		await advance(1)
		await settle()
		expect(fees.spy.hits).toBe(2)
		expect(fees.spy.bodies[1].materials).toEqual(["SM-P2", "SM-GEN"])
	})
})
