import { describe, expect, it } from "vitest"

import { EXAM_SETUP_MESSAGES } from "@/config/exam-setup"
import {
	examAdmin,
	examSetupIdInfo,
	examSetupSaveResult,
	examSetupView,
	examSite,
} from "@/testing/factories/exam-setup"

import {
	currentAdmin,
	currentSite,
	examSetupFeesTotal,
	examSetupProgramTypeFromSlug,
	examSetupViewState,
	examSetupViewStateFromStatus,
	hasPart,
	idDefaultsFrom,
	isFrmProgram,
	normalizeIdType,
	outcomeFrom,
	selectionDefaults,
	sitesFor,
	toIdInput,
	toSelectionInput,
	validateIdStep,
	validateSelectionStep,
	type ExamSetupIdFormValues,
} from "./exam-setup-presentation"

/* ===================== programme ===================== */

describe("examSetupProgramTypeFromSlug", () => {
	it("accepts the six programmes Apex normalises, case-insensitively", () => {
		for (const slug of ["frm", "erp", "scr", "raij", "rai", "riskai"]) {
			expect(examSetupProgramTypeFromSlug(slug.toUpperCase())).toBe(slug)
		}
	})

	it("rejects anything else so the page refuses before it fetches", () => {
		expect(examSetupProgramTypeFromSlug("ffr")).toBeNull()
		expect(examSetupProgramTypeFromSlug("")).toBeNull()
		expect(examSetupProgramTypeFromSlug(null)).toBeNull()
	})
})

describe("isFrmProgram", () => {
	it("is true only for FRM, which is the only programme demanding photo ID", () => {
		expect(isFrmProgram("frm")).toBe(true)
		expect(isFrmProgram("FRM")).toBe(true)
		expect(isFrmProgram("scr")).toBe(false)
	})
})

/* ===================== identity ===================== */

describe("normalizeIdType", () => {
	// Apex writes `Driver's License` and reads back `Driver License`. Left
	// unmapped, the radio matches nothing and renders blank — which reads as
	// "we lost your ID type" and invites the member to re-pick.
	it("maps every spelling of a licence onto the wire value", () => {
		for (const spelling of [
			"Driver License",
			"Driver's License",
			"Drivers License",
			"driver license",
		]) {
			expect(normalizeIdType(spelling)).toBe("driver license")
		}
	})

	it("lowercases a passport to the wire value", () => {
		expect(normalizeIdType("Passport")).toBe("passport")
	})

	it("returns empty for nothing stored", () => {
		expect(normalizeIdType(null)).toBe("")
		expect(normalizeIdType("   ")).toBe("")
	})
})

describe("idDefaultsFrom", () => {
	it("seeds both ID boxes from the stored number so it reads as a match", () => {
		const values = idDefaultsFrom(examSetupIdInfo({ idNumber: "45678" }))
		expect(values.idNumber).toBe("45678")
		expect(values.idNumberConfirm).toBe("45678")
	})

	it("normalises the stored ID type onto a radio value", () => {
		const values = idDefaultsFrom(examSetupIdInfo({ idType: "Driver License" }))
		expect(values.idType).toBe("driver license")
	})

	// A tick recorded against a disclosure the candidate did not read this time
	// is worthless.
	it("always starts the OSTA consent unticked", () => {
		expect(idDefaultsFrom(examSetupIdInfo()).ostaConsent).toBe(false)
	})

	it("passes ISO dates through — the read is already what the input binds to", () => {
		const values = idDefaultsFrom(
			examSetupIdInfo({ idExpireDate: "2030-01-01" }),
		)
		expect(values.idExpireDate).toBe("2030-01-01")
	})

	it("yields empty strings, never undefined, for an absent record", () => {
		expect(Object.values(idDefaultsFrom(null))).not.toContain(undefined)
	})
})

/* ===================== validation ===================== */

function values(
	overrides: Partial<ExamSetupIdFormValues> = {},
): ExamSetupIdFormValues {
	return {
		...idDefaultsFrom(examSetupIdInfo()),
		idType: "passport",
		...overrides,
	}
}

describe("validateIdStep", () => {
	const frm = { isFrm: true, isOSTA: false }

	it("passes a complete FRM form", () => {
		expect(validateIdStep(values(), frm)).toEqual({})
	})

	it("requires the name for every programme", () => {
		expect(
			validateIdStep(values({ idName: "  " }), { isFrm: false, isOSTA: false })
				.idName,
		).toBe(EXAM_SETUP_MESSAGES.idName)
	})

	// The pair is useless apart, so one message covers both and is reported
	// against the first control in the group.
	it("reports the mobile pair once, on the country code", () => {
		const errors = validateIdStep(values({ mobilePhoneNumber: " " }), frm)
		expect(errors.mobilePhoneLocation).toBe(EXAM_SETUP_MESSAGES.mobile)
		expect(errors.mobilePhoneNumber).toBeUndefined()
	})

	it("catches a mistyped confirmation", () => {
		expect(
			validateIdStep(values({ idNumberConfirm: "45679" }), frm).idNumberConfirm,
		).toBe(EXAM_SETUP_MESSAGES.idNumberConfirm)
	})

	it("requires the ID trio for FRM", () => {
		const errors = validateIdStep(
			values({ idType: "", idNumber: "", idNumberConfirm: "", idExpireDate: "" }),
			frm,
		)
		expect(errors.idType).toBe(EXAM_SETUP_MESSAGES.idType)
		expect(errors.idNumber).toBe(EXAM_SETUP_MESSAGES.idNumber)
		expect(errors.idExpireDate).toBe(EXAM_SETUP_MESSAGES.idExpireDate)
	})

	// A non-FRM candidate is never shown these controls, so enforcing them
	// would strand them on a step with nothing visible to fix.
	it("ignores the ID trio for a non-FRM programme", () => {
		const errors = validateIdStep(
			values({ idType: "", idNumber: "", idNumberConfirm: "", idExpireDate: "" }),
			{ isFrm: false, isOSTA: false },
		)
		expect(errors.idType).toBeUndefined()
		expect(errors.idNumber).toBeUndefined()
		expect(errors.idExpireDate).toBeUndefined()
	})

	it("requires the OSTA block, consent included, at a China centre", () => {
		const errors = validateIdStep(values(), { isFrm: true, isOSTA: true })
		expect(errors.ostaConsent).toBe(EXAM_SETUP_MESSAGES.ostaConsent)
		expect(errors.ostaIDLocation).toBe(EXAM_SETUP_MESSAGES.ostaIDLocation)
		expect(errors.ostaFullNameInChinese).toBe(
			EXAM_SETUP_MESSAGES.ostaFullNameInChinese,
		)
		expect(errors.ostaDateOfBirth).toBe(EXAM_SETUP_MESSAGES.ostaDateOfBirth)
		expect(errors.ostaGender).toBe(EXAM_SETUP_MESSAGES.ostaGender)
		expect(errors.ostaPhoneNumber).toBe(EXAM_SETUP_MESSAGES.ostaPhoneNumber)
	})

	it("leaves the OSTA free-text fields optional", () => {
		const errors = validateIdStep(
			values({
				ostaIDLocation: "China",
				ostaConsent: true,
				ostaFullNameInChinese: "阿达",
				ostaDateOfBirth: "1990-01-01",
				ostaGender: "Female",
				ostaPhoneNumber: "13800000000",
			}),
			{ isFrm: true, isOSTA: true },
		)
		expect(errors).toEqual({})
	})

	it("does not ask for OSTA details away from a China centre", () => {
		expect(validateIdStep(values(), frm)).toEqual({})
	})
})

describe("validateSelectionStep", () => {
	const empty = { a1: "", s1: "", a2: "", s2: "" }

	it("requires a Part I administration when the part exists", () => {
		expect(
			validateSelectionStep(empty, { hasPart1: true, twoPart: false }),
		).toBe(EXAM_SETUP_MESSAGES.selectAdmin)
	})

	it("requires Part II separately", () => {
		expect(
			validateSelectionStep(
				{ ...empty, a1: "admin-may" },
				{ hasPart1: true, twoPart: true },
			),
		).toBe(EXAM_SETUP_MESSAGES.selectAdminPart2)
	})

	// The site select is hidden until an administration with open sites is
	// chosen, so there would be nothing on screen to fix.
	it("does not require a site", () => {
		expect(
			validateSelectionStep(
				{ a1: "admin-may", s1: "", a2: "", s2: "" },
				{ hasPart1: true, twoPart: false },
			),
		).toBeNull()
	})
})

/* ===================== payload ===================== */

describe("toIdInput", () => {
	it("sends only the name and mobile for a non-FRM programme", () => {
		expect(
			toIdInput(values(), { isFrm: false, isOSTA: false }),
		).toEqual({
			idName: "Ada Lovelace",
			mobilePhoneLocation: "United States (+1)",
			mobilePhoneNumber: "5551234",
		})
	})

	it("adds the government-ID trio for FRM, with a US-format date", () => {
		const input = toIdInput(values(), { isFrm: true, isOSTA: false })
		expect(input).toMatchObject({
			idType: "passport",
			idNumber: "45678",
			// The read is ISO; the write is MM/dd/yyyy.
			idExpireDate: "01/01/2030",
		})
		expect(input.ostaIDLocation).toBeUndefined()
	})

	// A member with no China sitting must not have OSTA data written against
	// them just because the fields exist on the type.
	it("omits the OSTA block unless the centre requires it", () => {
		const input = toIdInput(
			values({ ostaGender: "Female" }),
			{ isFrm: true, isOSTA: false },
		)
		expect(input.ostaGender).toBeUndefined()
	})

	it("sends the OSTA block at a China centre", () => {
		const input = toIdInput(
			values({
				ostaIDLocation: "China",
				ostaGender: "Female",
				ostaFullNameInChinese: "阿达",
				ostaDateOfBirth: "1990-02-03",
				ostaPhoneNumber: "13800000000",
			}),
			{ isFrm: true, isOSTA: true },
		)
		expect(input).toMatchObject({
			ostaIDLocation: "China",
			ostaGender: "Female",
			ostaFullNameInChinese: "阿达",
			ostaDateOfBirth: "02/03/1990",
			ostaPhoneNumber: "13800000000",
		})
	})

	// Apex guards every write with `!= null`, and an empty string is not null —
	// so a blank optional must travel as null or it overwrites stored data.
	it("sends blank optional OSTA fields as null, never as an empty string", () => {
		const input = toIdInput(
			values({ ostaIDLocation: "China", ostaCompany: "   ", ostaSchool: "" }),
			{ isFrm: true, isOSTA: true },
		)
		expect(input.ostaCompany).toBeNull()
		expect(input.ostaSchool).toBeNull()
	})

	it("trims an optional OSTA value that was supplied", () => {
		const input = toIdInput(
			values({ ostaIDLocation: "China", ostaCompany: " Acme " }),
			{ isFrm: true, isOSTA: true },
		)
		expect(input.ostaCompany).toBe("Acme")
	})
})

describe("toSelectionInput", () => {
	it("turns a blank choice into null, which is how Apex reads 'no part'", () => {
		expect(
			toSelectionInput({ a1: "admin-may", s1: "site-london", a2: "", s2: "" }),
		).toEqual({
			selectedAdminPart1: "admin-may",
			selectedSitePart1: "site-london",
			selectedAdminPart2: null,
			selectedSitePart2: null,
		})
	})
})

/* ===================== selection ===================== */

describe("selection helpers", () => {
	const view = examSetupView()

	it("starts the selects wherever the member sits today", () => {
		expect(selectionDefaults(view)).toEqual({
			a1: "admin-may",
			s1: "site-london",
			a2: "",
			s2: "",
		})
	})

	it("reads the current administration and site from isSelected", () => {
		const admin = currentAdmin(view.examPart1SelectionInfo)
		expect(admin?.id).toBe("admin-may")
		expect(currentSite(admin)?.id).toBe("site-london")
	})

	it("lists the sites hanging off one administration", () => {
		expect(sitesFor(view.examPart1SelectionInfo, "admin-nov")).toEqual([
			examSite({ id: "site-berlin", name: "Berlin" }),
		])
	})

	it("has no sites for an unknown or unchosen administration", () => {
		expect(sitesFor(view.examPart1SelectionInfo, "")).toEqual([])
		expect(sitesFor(view.examPart1SelectionInfo, "admin-nope")).toEqual([])
	})

	it("knows whether a part is offered at all", () => {
		expect(hasPart(view.examPart1SelectionInfo)).toBe(true)
		expect(hasPart([])).toBe(false)
		expect(hasPart(null)).toBe(false)
	})

	it("has no defaults when nothing is selected yet", () => {
		expect(
			selectionDefaults(
				examSetupView({ examPart1SelectionInfo: [examAdmin()] }),
			),
		).toEqual({ a1: "", s1: "", a2: "", s2: "" })
	})
})

/* ===================== fees ===================== */

describe("examSetupFeesTotal", () => {
	it("counts a refund against the total so a net credit reads as one", () => {
		expect(
			examSetupFeesTotal([
				{
					name: "Change fee",
					type: "fee",
					amount: 250,
					description: null,
					productCode: null,
					glCode: null,
					accountingCode: null,
					examRegId: null,
					examSiteId: null,
				},
				{
					name: "OSTA Location Fee",
					type: "refund",
					amount: 40,
					description: null,
					productCode: null,
					glCode: null,
					accountingCode: null,
					examRegId: null,
					examSiteId: null,
				},
			]),
		).toBe(210)
	})

	it("is zero for no lines", () => {
		expect(examSetupFeesTotal(null)).toBe(0)
		expect(examSetupFeesTotal([])).toBe(0)
	})
})

/* ===================== outcomes ===================== */

describe("outcomeFrom", () => {
	it("routes each nextScreen the server can send", () => {
		expect(outcomeFrom(examSetupSaveResult({ nextScreen: "Pay Fees" }))).toBe(
			"pay-fees",
		)
		expect(
			outcomeFrom(examSetupSaveResult({ nextScreen: "Check Authorization" })),
		).toBe("scheduling")
		expect(
			outcomeFrom(examSetupSaveResult({ nextScreen: "Setup Complete" })),
		).toBe("complete")
	})

	// Apex is free to add a fourth. A member who has already been written to
	// should see a confirmation, not an error.
	it("treats an unrecognised or missing screen as complete", () => {
		expect(outcomeFrom(examSetupSaveResult({ nextScreen: "Something" }))).toBe(
			"complete",
		)
		expect(outcomeFrom(examSetupSaveResult({ nextScreen: null }))).toBe(
			"complete",
		)
		expect(outcomeFrom(null)).toBe("complete")
	})
})

/* ===================== view state ===================== */

describe("examSetupViewState", () => {
	it("maps each Apex status onto a screen", () => {
		expect(examSetupViewStateFromStatus(200)).toBe("ready")
		expect(examSetupViewStateFromStatus(501)).toBe("unsupported")
		expect(examSetupViewStateFromStatus(502)).toBe("pendingReschedule")
		expect(examSetupViewStateFromStatus(403)).toBe("unavailable")
		expect(examSetupViewStateFromStatus(null)).toBe("unavailable")
	})

	it("is ready when a part has something to offer", () => {
		expect(examSetupViewState(examSetupView())).toBe("ready")
	})

	it("downgrades a 200 with two empty lists to noAdmins", () => {
		expect(
			examSetupViewState(
				examSetupView({
					examPart1SelectionInfo: [],
					examPart2SelectionInfo: [],
				}),
			),
		).toBe("noAdmins")
	})

	it("keeps a refusal's own state ahead of the emptiness check", () => {
		expect(
			examSetupViewState(
				examSetupView({
					statusCode: 502,
					examPart1SelectionInfo: [],
					examPart2SelectionInfo: [],
				}),
			),
		).toBe("pendingReschedule")
	})

	it("is unavailable with no payload at all", () => {
		expect(examSetupViewState(null)).toBe("unavailable")
	})
})
