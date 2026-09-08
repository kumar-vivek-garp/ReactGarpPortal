import { describe, expect, it } from "vitest"

import type { CpdClaim, CpdCycleInfo } from "@/api/cpd/types"
import { cycleCreditTotals, resolveCpdTab } from "./cpd-presentation"

function claim(credits: number | null): CpdClaim {
	return {
		claimId: `c-${credits}`,
		activityType: "at1",
		activityTypeName: "Webinar",
		dateOfCompletion: "2026-02-01",
		dateOfCompletionString: null,
		credits,
		areaOfStudy: null,
		comments: null,
		URL: null,
		provider: null,
		providerOther: null,
		title: null,
		organizationName: null,
		contactEmail: null,
		publication: null,
		approvalComments: null,
		isFRM: false,
		isERP: false,
		isSCR: false,
		isRAI: null,
	}
}

function cycle(overrides: Partial<CpdCycleInfo> = {}): CpdCycleInfo {
	return {
		programId: "p1",
		cycleName: "2025/2027",
		startYear: 2025,
		endYear: 2027,
		status: "active",
		isAttested: false,
		attestationID: null,
		isFRMActive: true,
		isERPActive: false,
		isSCRActive: false,
		isRAIActive: false,
		isFRMCompleted: false,
		isERPCompleted: false,
		isSCRCompleted: false,
		isRAICompleted: false,
		completedFRMCertURL: null,
		completedERPCertURL: null,
		completedSCRCertURL: null,
		completedRAICertURL: null,
		creditsSubmitted: null,
		creditsApproved: null,
		creditsRequired: null,
		creditsRequiredFRM: null,
		creditsRequiredERP: null,
		creditsRequiredSCR: null,
		creditsRequiredRAI: null,
		approvedClaims: null,
		pendingClaims: null,
		...overrides,
	}
}

describe("cycleCreditTotals", () => {
	it("counts pending from the claims when the cycle carries them", () => {
		expect(
			cycleCreditTotals(
				cycle({
					creditsApproved: 18,
					creditsRequired: 40,
					creditsSubmitted: 99,
					pendingClaims: [claim(2.5), claim(1)],
				}),
			),
		).toEqual({ approved: 18, pending: 3.5, required: 40, remaining: 22 })
	})

	/*
	 * Apex attaches pending claims only to the CURRENT cycle, but a closed
	 * cycle's `creditsSubmitted` still includes what was pending against it —
	 * so the difference is the only honest answer there.
	 */
	it("falls back to submitted-minus-approved when there are no claims", () => {
		expect(
			cycleCreditTotals(
				cycle({ creditsApproved: 30, creditsSubmitted: 34, creditsRequired: 40 }),
			).pending,
		).toBe(4)
	})

	it("never reports negative pending or remaining", () => {
		const over = cycleCreditTotals(
			cycle({ creditsApproved: 50, creditsSubmitted: 40, creditsRequired: 40 }),
		)
		expect(over.pending).toBe(0)
		expect(over.remaining).toBe(0)
	})

	it("reads a cycle with nothing on it as four zeroes", () => {
		expect(cycleCreditTotals(null)).toEqual({
			approved: 0,
			pending: 0,
			required: 0,
			remaining: 0,
		})
	})
})

describe("resolveCpdTab", () => {
	it("pins a closed cycle to approved, whatever the URL says", () => {
		// Apex never attaches pending claims to a past cycle, so a Pending tab
		// there is guaranteed empty and reads as data loss.
		expect(
			resolveCpdTab("pending", { isCurrent: false, pendingCount: 3 }),
		).toBe("approved")
	})

	it("honours an explicit tab on the current cycle", () => {
		expect(resolveCpdTab("approved", { isCurrent: true, pendingCount: 2 })).toBe(
			"approved",
		)
		expect(resolveCpdTab("pending", { isCurrent: true, pendingCount: 0 })).toBe(
			"pending",
		)
	})

	it("opens on whichever list has something in it", () => {
		expect(resolveCpdTab(undefined, { isCurrent: true, pendingCount: 1 })).toBe(
			"pending",
		)
		expect(resolveCpdTab(undefined, { isCurrent: true, pendingCount: 0 })).toBe(
			"approved",
		)
	})
})
