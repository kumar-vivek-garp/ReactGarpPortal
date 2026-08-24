import { describe, expect, it } from "vitest"

import type {
	ExamAdmin,
	ExamSetupIdInfo,
	ExamSetupIdSaveResult,
	ExamSetupView,
} from "@/api/exam-setup"
import { EXAM_SETUP_FEES } from "@/config/exam-setup"
import {
	canChangeAdmin,
	currentAdmin,
	currentSite,
	examSetupPayFeesFallback,
	examSetupProgramTypeFromSlug,
	examSetupViewState,
	hasIdOnFile,
	hasSelectionChanges,
	idDefaultsFrom,
	isSameAdministration,
	isValidIdNumber,
	normalizeIdType,
	outcomeFrom,
	predictFee,
	selectionDefaults,
	sitesFor,
	toIdInput,
} from "./exam-setup-presentation"

const MAY = "a0A_may"
const NOV = "a0A_nov"
const LONDON = "a0S_london"
const SHANGHAI = "a0S_shanghai"

function admin(overrides: Partial<ExamAdmin> = {}): ExamAdmin {
	return {
		id: MAY,
		name: "May 2026 FRM Exam",
		isSelected: false,
		examSites: [
			{ id: LONDON, name: "London", isSelected: false },
			{ id: SHANGHAI, name: "Shanghai", isSelected: false },
		],
		...overrides,
	}
}

function view(overrides: Partial<ExamSetupView> = {}): ExamSetupView {
	return {
		statusMessage: "Success",
		statusCode: 200,
		allowAdminModPart1: true,
		allowAdminModPart2: true,
		examPart1SelectionInfo: [
			admin({
				isSelected: true,
				examSites: [
					{ id: LONDON, name: "London", isSelected: true },
					{ id: SHANGHAI, name: "Shanghai", isSelected: false },
				],
			}),
			admin({ id: NOV, name: "November 2026 FRM Exam" }),
		],
		examPart2SelectionInfo: [],
		idInfo: null,
		...overrides,
	}
}

function idInfo(
	overrides: Partial<ExamSetupIdInfo> = {},
): ExamSetupIdInfo {
	return {
		isOSTA: false,
		isIDRequired: true,
		idName: "Ada",
		idNumber: "AB1234567",
		idType: "Driver License",
		idExpireDate: "2030-04-09",
		mobilePhoneLocation: null,
		mobilePhoneNumber: null,
		ostaIDLocation: null,
		ostaGender: null,
		ostaFullNameInChinese: null,
		ostaDateOfBirth: "1815-12-10",
		ostaPhoneNumber: null,
		ostaCurrentWorkingStatus: null,
		ostaCompany: null,
		ostaCurrentSchoolStatus: null,
		ostaSchool: null,
		ostaDegreeProgramName: null,
		mobilePhoneLocations: null,
		...overrides,
	}
}

const NO_CHANGE = {
	selectedAdminPart1: MAY,
	selectedSitePart1: LONDON,
	selectedAdminPart2: null,
	selectedSitePart2: null,
}

describe("examSetupProgramTypeFromSlug", () => {
	it("accepts every type Apex normalises", () => {
		for (const slug of ["frm", "erp", "scr", "raij", "rai", "riskai"]) {
			expect(examSetupProgramTypeFromSlug(slug)).toBe(slug)
		}
	})

	it("is case- and whitespace-insensitive", () => {
		expect(examSetupProgramTypeFromSlug("  FRM ")).toBe("frm")
	})

	it("rejects anything else", () => {
		expect(examSetupProgramTypeFromSlug("frr")).toBeNull()
		expect(examSetupProgramTypeFromSlug("")).toBeNull()
		expect(examSetupProgramTypeFromSlug(null)).toBeNull()
	})
})

describe("normalizeIdType", () => {
	it("maps the apostrophe-less form Apex reads out back to the option value", () => {
		expect(normalizeIdType("Driver License")).toBe("Driver's License")
	})

	it("leaves the option value alone", () => {
		expect(normalizeIdType("Driver's License")).toBe("Driver's License")
		expect(normalizeIdType("Passport")).toBe("Passport")
	})

	it("passes an unknown value through rather than blanking it", () => {
		expect(normalizeIdType("National ID")).toBe("National ID")
	})

	it("is empty for nothing", () => {
		expect(normalizeIdType(null)).toBe("")
		expect(normalizeIdType("   ")).toBe("")
	})
})

describe("isValidIdNumber", () => {
	it("requires a passport to be 9 alphanumerics", () => {
		expect(isValidIdNumber("Passport", "AB1234567")).toBe(true)
		expect(isValidIdNumber("Passport", "AB123456")).toBe(false)
	})

	it("rejects I and O in a passport number", () => {
		expect(isValidIdNumber("Passport", "AI1234567")).toBe(false)
		expect(isValidIdNumber("Passport", "AO1234567")).toBe(false)
	})

	it("applies the passport rule to the value Apex reads out too", () => {
		expect(isValidIdNumber("Passport", "ab1234567")).toBe(true)
	})

	it("only requires a value for anything else", () => {
		expect(isValidIdNumber("Driver License", "X")).toBe(true)
		expect(isValidIdNumber("Driver's License", "")).toBe(false)
	})

	it("accepts blank when one is already stored — blank means leave it alone", () => {
		expect(isValidIdNumber("Passport", "", true)).toBe(true)
		expect(isValidIdNumber("Passport", "   ", true)).toBe(true)
	})

	it("still validates a replacement typed over a stored one", () => {
		expect(isValidIdNumber("Passport", "AB12345", true)).toBe(false)
		expect(isValidIdNumber("Passport", "AB1234567", true)).toBe(true)
	})
})

describe("toIdInput", () => {
	const base = {
		idName: " Ada Lovelace ",
		idNumber: " AB1234567 ",
		idType: "Driver License",
		idExpireDate: "2030-04-09",
		mobilePhoneLocation: "United States (+1)",
		mobilePhoneNumber: "5551234567",
	}

	it("converts ISO dates to MM/dd/yyyy on the way out", () => {
		expect(toIdInput(base).idExpireDate).toBe("04/09/2030")
	})

	it("converts the OSTA date of birth the same way", () => {
		expect(
			toIdInput({ ...base, ostaDateOfBirth: "1815-12-10" }).ostaDateOfBirth,
		).toBe("12/10/1815")
	})

	it("normalises the ID type back to the spelling Apex stores", () => {
		expect(toIdInput(base).idType).toBe("Driver's License")
	})

	it("trims", () => {
		expect(toIdInput(base).idName).toBe("Ada Lovelace")
		expect(toIdInput(base).idNumber).toBe("AB1234567")
	})

	/**
	 * The data-safety half. Apex guards each write with `!= null`, and `""` is
	 * not null — posting a blank for an untouched field overwrites the stored
	 * value. Every one of these must be absent from the payload, not empty.
	 */
	it("omits an empty field from the posted body rather than blanking it", () => {
		// Asserted on the serialised body, because that is what Apex actually
		// receives: `JSON.stringify` drops undefined keys, so the field never
		// travels and the `if (i.field != null)` guard leaves the Contact alone.
		const wire = JSON.parse(
			JSON.stringify(toIdInput({ ...base, mobilePhoneLocation: "  ", idName: "" })),
		)
		expect(wire).not.toHaveProperty("mobilePhoneLocation")
		expect(wire).not.toHaveProperty("idName")
		expect(wire.idNumber).toBe("AB1234567")
	})

	it("omits every OSTA field the member never filled in", () => {
		const out = toIdInput(base)
		expect(out.ostaGender).toBeUndefined()
		expect(out.ostaCompany).toBeUndefined()
		expect(out.ostaDateOfBirth).toBeUndefined()
	})

	/**
	 * Apex applies idType and the expiry INSIDE its `idNumber != null` branch,
	 * so sending them without a number silently does nothing — and sending a
	 * blank number would blank the stored ID.
	 */
	it("drops the number, type and expiry together when the number is blank", () => {
		const out = toIdInput({ ...base, idNumber: "" })
		expect(out.idNumber).toBeUndefined()
		expect(out.idType).toBeUndefined()
		expect(out.idExpireDate).toBeUndefined()
	})

	it("keeps the type and expiry when a number IS supplied", () => {
		const out = toIdInput(base)
		expect(out.idNumber).toBe("AB1234567")
		expect(out.idType).toBe("Driver's License")
		expect(out.idExpireDate).toBe("04/09/2030")
	})
})

describe("idDefaultsFrom", () => {
	it("passes ISO dates straight through — the read is already ISO", () => {
		const defaults = idDefaultsFrom(idInfo({
			isOSTA: false,
			isIDRequired: true,
			idName: "Ada",
			idNumber: "AB1234567",
			idType: "Driver License",
			idExpireDate: "2030-04-09",
			mobilePhoneLocation: null,
			mobilePhoneNumber: null,
			ostaIDLocation: null,
			ostaGender: null,
			ostaFullNameInChinese: null,
			ostaDateOfBirth: "1815-12-10",
			ostaPhoneNumber: null,
			ostaCurrentWorkingStatus: null,
			ostaCompany: null,
			ostaCurrentSchoolStatus: null,
			ostaSchool: null,
			ostaDegreeProgramName: null,
		}))
		expect(defaults.idExpireDate).toBe("2030-04-09")
		expect(defaults.ostaDateOfBirth).toBe("1815-12-10")
		expect(defaults.idType).toBe("Driver's License")
	})

	/**
	 * The read returns only the last five characters in the clear. Seeding the
	 * box with them means the next save writes those five over a real ID.
	 */
	it("never seeds the ID number, even when one comes back", () => {
		expect(idDefaultsFrom(idInfo({ idNumber: "34567" })).idNumber).toBe("")
	})

	it("is all-empty for a missing payload", () => {
		expect(idDefaultsFrom(null).idName).toBe("")
		expect(idDefaultsFrom(undefined).idExpireDate).toBe("")
	})
})

describe("hasIdOnFile", () => {
	it("is true only when a number came back", () => {
		expect(hasIdOnFile(idInfo({ idNumber: "34567" }))).toBe(true)
		expect(hasIdOnFile(idInfo({ idNumber: null }))).toBe(false)
		expect(hasIdOnFile(idInfo({ idNumber: "  " }))).toBe(false)
		expect(hasIdOnFile(null)).toBe(false)
	})
})

describe("current selection", () => {
	it("reads the member's sitting off isSelected", () => {
		expect(currentAdmin(view().examPart1SelectionInfo)?.id).toBe(MAY)
		expect(currentSite(currentAdmin(view().examPart1SelectionInfo))?.id).toBe(
			LONDON,
		)
	})

	it("defaults the selects to where the member sits today", () => {
		expect(selectionDefaults(view())).toEqual(NO_CHANGE)
	})

	it("lists the sites under one administration", () => {
		expect(sitesFor(view().examPart1SelectionInfo, NOV)).toHaveLength(2)
		expect(sitesFor(view().examPart1SelectionInfo, null)).toEqual([])
	})
})

describe("predictFee", () => {
	it("is null when nothing moved", () => {
		expect(predictFee("frm", view(), NO_CHANGE)).toBeNull()
	})

	it("is null for a site-only change — that is free", () => {
		expect(
			predictFee("frm", view(), { ...NO_CHANGE, selectedSitePart1: SHANGHAI }),
		).toBeNull()
	})

	it("charges the FRM rate when Part I moves administration", () => {
		const fee = predictFee("frm", view(), {
			...NO_CHANGE,
			selectedAdminPart1: NOV,
		})
		expect(fee?.amount).toBe(EXAM_SETUP_FEES.frmDeferral)
		expect(fee?.reason).toContain("Part I")
	})

	it("charges the single-part rate for the other programmes", () => {
		expect(
			predictFee("scr", view(), { ...NO_CHANGE, selectedAdminPart1: NOV })
				?.amount,
		).toBe(EXAM_SETUP_FEES.singlePartDeferral)
		expect(
			predictFee("raij", view(), { ...NO_CHANGE, selectedAdminPart1: NOV })
				?.amount,
		).toBe(EXAM_SETUP_FEES.singlePartDeferral)
	})

	it("charges once, not twice, when both FRM parts move", () => {
		const twoPart = view({
			examPart2SelectionInfo: [
				admin({ isSelected: true }),
				admin({ id: NOV, name: "November 2026 FRM Exam" }),
			],
		})
		const fee = predictFee("frm", twoPart, {
			selectedAdminPart1: NOV,
			selectedSitePart1: LONDON,
			selectedAdminPart2: NOV,
			selectedSitePart2: LONDON,
		})
		expect(fee?.amount).toBe(EXAM_SETUP_FEES.frmDeferral)
		expect(fee?.reason).toContain("Part I and Part II")
	})

	it("does not fire when a part has no current administration to move from", () => {
		const noCurrent = view({
			examPart1SelectionInfo: [admin({ id: NOV })],
		})
		expect(
			predictFee("frm", noCurrent, { ...NO_CHANGE, selectedAdminPart1: NOV }),
		).toBeNull()
	})
})

describe("hasSelectionChanges", () => {
	it("is false on the untouched form", () => {
		expect(hasSelectionChanges(view(), NO_CHANGE)).toBe(false)
	})

	it("is true for a free site-only move", () => {
		expect(
			hasSelectionChanges(view(), { ...NO_CHANGE, selectedSitePart1: SHANGHAI }),
		).toBe(true)
	})
})

describe("isSameAdministration", () => {
	it("is true only when both parts land on one administration", () => {
		expect(
			isSameAdministration({ ...NO_CHANGE, selectedAdminPart2: MAY }),
		).toBe(true)
		expect(isSameAdministration(NO_CHANGE)).toBe(false)
	})
})

describe("outcomeFrom", () => {
	function result(
		overrides: Partial<ExamSetupIdSaveResult> = {},
	): ExamSetupIdSaveResult {
		return {
			statusMessage: "ID Info Updated",
			statusCode: 200,
			nextScreen: "Setup Complete",
			paymentRequired: false,
			schedulingRequired: false,
			examModificationId: null,
			...overrides,
		}
	}

	it("maps all three screens Apex can name", () => {
		expect(outcomeFrom(result())).toBe("complete")
		expect(outcomeFrom(result({ nextScreen: "Pay Fees" }))).toBe("pay-fees")
		expect(outcomeFrom(result({ nextScreen: "Check Authorization" }))).toBe(
			"scheduling",
		)
	})

	it("treats an unknown screen as complete rather than an error", () => {
		expect(outcomeFrom(result({ nextScreen: "Something New" }))).toBe("complete")
	})

	it("trusts the flags when the screen name disagrees", () => {
		expect(
			outcomeFrom(result({ nextScreen: "Setup Complete", paymentRequired: true })),
		).toBe("pay-fees")
	})

	it("is unknown when nothing was reported", () => {
		expect(outcomeFrom(result({ nextScreen: null }))).toBe("unknown")
		expect(outcomeFrom(null)).toBe("unknown")
	})

	it("surfaces the raised modification on the pay-fees fallback", () => {
		expect(
			examSetupPayFeesFallback(
				result({ nextScreen: "Pay Fees", examModificationId: "a0M1" }),
			),
		).toEqual({ modificationId: "a0M1" })
		expect(examSetupPayFeesFallback(result())).toBeNull()
	})
})

describe("examSetupViewState", () => {
	it("is ready when a part has administrations", () => {
		expect(examSetupViewState(view())).toBe("ready")
	})

	it("maps 501 to unsupported and 502 to the pending reschedule", () => {
		expect(examSetupViewState(view({ statusCode: 501 }))).toBe("unsupported")
		expect(examSetupViewState(view({ statusCode: 502 }))).toBe(
			"pendingReschedule",
		)
	})

	it("falls back to unavailable for anything else", () => {
		expect(examSetupViewState(view({ statusCode: 500 }))).toBe("unavailable")
		expect(examSetupViewState(null)).toBe("unavailable")
	})

	it("is noAdmins when 200 comes back with nothing to offer", () => {
		expect(
			examSetupViewState(
				view({ examPart1SelectionInfo: [], examPart2SelectionInfo: [] }),
			),
		).toBe("noAdmins")
	})
})

describe("canChangeAdmin", () => {
	it("reads the per-part flag", () => {
		const locked = view({ allowAdminModPart1: false })
		expect(canChangeAdmin(locked, 1)).toBe(false)
		expect(canChangeAdmin(locked, 2)).toBe(true)
	})

	it("is false when the flag is absent", () => {
		expect(canChangeAdmin(view({ allowAdminModPart1: null }), 1)).toBe(false)
		expect(canChangeAdmin(null, 1)).toBe(false)
	})
})
