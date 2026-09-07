import { describe, expect, it } from "vitest"

import {
	buildExamCheckoutUrls,
	isBilledResult,
	resolveSettlementId,
	resumeHref,
} from "@/lib/registration-checkout"

describe("resolveSettlementId", () => {
	it("prefers the order id when the flow was immediate", () => {
		expect(resolveSettlementId({ orderId: "801", stagedId: "a0H" })).toBe("801")
	})

	it("falls back to the staged id under the deferred flow", () => {
		expect(resolveSettlementId({ orderId: null, stagedId: "a0H" })).toBe("a0H")
	})

	it("treats empty strings as absent", () => {
		expect(resolveSettlementId({ orderId: "", stagedId: "" })).toBeNull()
		expect(resolveSettlementId({})).toBeNull()
	})
})

describe("isBilledResult", () => {
	it("needs both a billing flag and a positive total", () => {
		expect(isBilledResult({ hasBilling: true, total: 750 })).toBe(true)
		expect(isBilledResult({ hasBilling: true, total: 0 })).toBe(false)
		expect(isBilledResult({ hasBilling: false, total: 750 })).toBe(false)
		expect(isBilledResult({ hasBilling: true, total: null })).toBe(false)
	})
})

describe("buildExamCheckoutUrls", () => {
	const location = { origin: "https://portal.example", pathname: "/programs/frm/register" }

	it("puts stripe_return and oid — and nothing else — on the success leg", () => {
		const { successUrl } = buildExamCheckoutUrls(location, "801-order")
		const url = new URL(successUrl)
		expect(`${url.origin}${url.pathname}`).toBe(
			"https://portal.example/programs/frm/register",
		)
		expect([...url.searchParams.keys()].sort()).toEqual(["oid", "stripe_return"])
		expect(url.searchParams.get("stripe_return")).toBe("1")
		expect(url.searchParams.get("oid")).toBe("801-order")
	})

	it("carries oid on the cancel leg so the page can roll the order back", () => {
		const { cancelUrl } = buildExamCheckoutUrls(location, "801-order")
		const url = new URL(cancelUrl)
		expect(url.pathname).toBe("/programs/frm/register")
		expect(url.searchParams.get("checkout_cancelled")).toBe("1")
		expect(url.searchParams.get("oid")).toBe("801-order")
	})

	it("encodes an id that is not URL-safe", () => {
		const { successUrl } = buildExamCheckoutUrls(location, "a b&c")
		expect(new URL(successUrl).searchParams.get("oid")).toBe("a b&c")
	})
})

describe("resumeHref", () => {
	it("links back to the same form with the staged id", () => {
		expect(resumeHref("/registration/frm", "a0H-staged")).toBe(
			"/registration/frm?resume=a0H-staged",
		)
	})
})
