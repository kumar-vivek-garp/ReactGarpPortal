import { describe, expect, it } from "vitest"

import type { DirectoryMember, DirectoryView } from "@/api/directory"
import {
	activeFilterCount,
	directoryCredentials,
	directoryMemberSubtitle,
	directoryPageState,
	directoryUpsell,
	memberInitials,
	toDirectorySearchParams,
} from "./directory-presentation"

function member(over: Partial<DirectoryMember> = {}): DirectoryMember {
	return {
		id: "003", garpId: "1", name: "Ada Lovelace", firstName: "Ada",
		lastName: "Lovelace", mailingCity: "London", mailingCountry: "United Kingdom",
		photoUrl: null, membershipType: "Individual", membershipSince: null,
		isFRMCertified: false, frmCertifiedDate: null,
		isERPCertified: false, erpCertifiedDate: null,
		isSCRHolder: false, scrCompletionDate: null,
		isRAIHolder: false, raiCompletionDate: null,
		cpeRequirementStatus: null, cpeCurrentCycle: null,
		cpeLastCompletedCycle: null, jobFunction: null, riskSpecialty: null,
		areaOfConcentration: null, corporateTitle: "Head of Risk",
		company: "Abrdn plc", designations: null, otherQualifications: null,
		canSendMessage: false, canInvite: false,
		...over,
	}
}

describe("directoryMemberSubtitle", () => {
	it("joins what is present", () => {
		expect(directoryMemberSubtitle(member())).toBe(
			"Head of Risk · Abrdn plc · United Kingdom",
		)
	})

	/** Apex redacts per row against the SUBJECT's privacy switches. */
	it("skips fields the subject chose not to share", () => {
		expect(
			directoryMemberSubtitle(member({ corporateTitle: null, company: null })),
		).toBe("United Kingdom")
	})
})

describe("directoryCredentials", () => {
	it("lists held certifications then other designations", () => {
		expect(
			directoryCredentials(
				member({
					isFRMCertified: true,
					isSCRHolder: true,
					designations: ["CFA", "CPA"],
				}),
			),
		).toEqual(["FRM", "SCR", "CFA", "CPA"])
	})

	it("returns nothing for a member with none", () => {
		expect(directoryCredentials(member())).toEqual([])
	})
})

describe("directoryPageState", () => {
	it("describes the visible range from the server's counts", () => {
		const state = directoryPageState({
			pageCurrent: 2, pageSize: 10, pages: 9, total: 84,
		})
		expect(state.rangeLabel).toBe("11–20 of 84")
		expect(state.hasPrevious).toBe(true)
		expect(state.hasNext).toBe(true)
	})

	it("clamps the last page to the total", () => {
		expect(
			directoryPageState({ pageCurrent: 9, pageSize: 10, pages: 9, total: 84 })
				.rangeLabel,
		).toBe("81–84 of 84")
	})

	it("offers no range and no paging when nothing matched", () => {
		const state = directoryPageState({
			pageCurrent: 1, pageSize: 10, pages: 0, total: 0,
		})
		expect(state.rangeLabel).toBeNull()
		expect(state.hasNext).toBe(false)
		expect(state.hasPrevious).toBe(false)
	})

	it("survives an absent result set", () => {
		expect(directoryPageState(null).pageCurrent).toBe(1)
	})
})

describe("directoryUpsell", () => {
	const view = (over: Partial<DirectoryView>): DirectoryView =>
		({
			statusMessage: null, statusCode: 200, settings: null, preview: null,
			hasDirectoryAccess: true, hasDirectoryCPDAccess: false,
			hasDirectoryConnectAccess: false, hasDirectoryAdvancedSearchAccess: false,
			hasDirectoryNonCertifiedAccess: false, hasDirectorySettingsAccess: false,
			upsellMembershipType: null, pendingMembershipOrderId: null,
			...over,
		}) as DirectoryView

	it("offers nothing to a member in good standing", () => {
		expect(directoryUpsell(view({}))).toBeNull()
	})

	it("says Renew for a lapsed Individual and Upgrade for anyone else", () => {
		expect(directoryUpsell(view({ upsellMembershipType: "Renew" }))?.label).toBe(
			"Renew Now",
		)
		expect(
			directoryUpsell(view({ upsellMembershipType: "Affiliate" }))?.label,
		).toBe("Upgrade")
	})

	/** Sending someone to buy again when they have already ordered is the legacy's bug. */
	it("points at the pending order instead of selling again", () => {
		expect(
			directoryUpsell(
				view({
					upsellMembershipType: "Renew",
					pendingMembershipOrderId: "006XYZ",
				}),
			),
		).toEqual({ label: "View Order", orderId: "006XYZ" })
	})
})

describe("toDirectorySearchParams", () => {
	const base = {
		searchText: "  ada  ", company: "", industries: [], jobFunctions: [],
		riskSpecialties: [], corporateTitles: [], certifications: [],
		pageCurrent: 3,
	}

	it("maps each certification onto its own flag", () => {
		const params = toDirectorySearchParams({
			...base,
			certifications: ["FRM", "SCR"],
		})
		expect(params.FRMOnly).toBe(true)
		expect(params.SCROnly).toBe(true)
		expect(params.ERPOnly).toBe(false)
		expect(params.RAIOnly).toBe(false)
	})

	it("trims the term and sends null rather than an empty string", () => {
		expect(toDirectorySearchParams(base).searchText).toBe("ada")
		expect(
			toDirectorySearchParams({ ...base, searchText: "   " }).searchText,
		).toBeNull()
	})

	/** Page 0 or negative would be clamped server-side anyway; do not send it. */
	it("never sends a page below 1", () => {
		expect(
			toDirectorySearchParams({ ...base, pageCurrent: 0 }).pageCurrent,
		).toBe(1)
	})
})

describe("activeFilterCount", () => {
	const state = {
		company: "",
		certifications: [] as string[],
		values: {
			industries: [] as string[],
			jobFunctions: [] as string[],
			riskSpecialties: [] as string[],
			corporateTitles: [] as string[],
		},
	}

	it("is zero when nothing is set", () => {
		expect(activeFilterCount(state)).toBe(0)
	})

	it("counts company, certifications and every picklist value", () => {
		expect(
			activeFilterCount({
				...state,
				company: "Abrdn",
				certifications: ["FRM", "SCR"],
				values: { ...state.values, jobFunctions: ["Risk Management"] },
			}),
		).toBe(4)
	})

	/** A whitespace-only company is not a filter. */
	it("ignores a blank company", () => {
		expect(activeFilterCount({ ...state, company: "   " })).toBe(0)
	})
})

describe("memberInitials", () => {
	it("uses first and last name when Apex gave them", () => {
		expect(memberInitials(member())).toBe("AL")
	})

	/** A redacted row can carry a display name and no name parts. */
	it("falls back to the display name", () => {
		expect(
			memberInitials(
				member({ firstName: null, lastName: null, name: "Grace Hopper" }),
			),
		).toBe("GH")
	})

	it("handles a single-word name and an empty one", () => {
		expect(
			memberInitials(member({ firstName: null, lastName: null, name: "Ada" })),
		).toBe("AD")
		expect(
			memberInitials(member({ firstName: null, lastName: null, name: null })),
		).toBe("GA")
	})
})
