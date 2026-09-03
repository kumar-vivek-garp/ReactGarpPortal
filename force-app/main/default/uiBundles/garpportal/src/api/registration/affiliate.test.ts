import { describe, expect, it } from "vitest"

import { completeAffiliateOrder } from "@/api/registration/affiliate"
import { AppError } from "@/api/client"

describe("completeAffiliateOrder", () => {
	/**
	 * `payOrder` must never fire without an order id — Apex refuses a second
	 * call on a completed order, so a blind retry against "" would be worse
	 * than failing here with the truth.
	 */
	it("refuses a missing order id before it reaches the network", async () => {
		const failure = completeAffiliateOrder("")
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["No order was returned by the registration service."],
		})
	})
})
