import { afterEach, describe, expect, it, vi } from "vitest"

vi.mock("@/auth/sfdc-env", () => ({
	isLocalViteHost: vi.fn(() => false),
	getSfdcEnv: vi.fn(() => undefined),
}))

vi.mock("@/lib/resolve-portal-asset-url", () => ({
	resolvePortalAssetUrl: vi.fn((url: string) => url),
}))

import type {
	CompletedProgram,
	EnrolledProgram,
	OtherProgram,
	ProgramInformation,
} from "@/api/programs"
import {
	DEFAULT_PROGRAMS_TAB,
	resolveProgramsTab,
	resolveProgramsView,
} from "@/config/programs"
import { programBrandSurface } from "@/config/program-brand"
import {
	buildProgramListingPresentation,
	programCodeLabel,
	programDisplayName,
	registrationOpensCopy,
} from "./program-listing-presentation"

function baseInfo(
	overrides: Partial<ProgramInformation> = {},
): ProgramInformation {
	return {
		programCode: "FRM",
		abbrevName: "FRM",
		formalName: "Financial Risk Manager (FRM<sup>&reg;</sup>)",
		informalName: "Financial Risk Manager",
		policyURL: null,
		regLogoURL: null,
		myProgramsLogoURL: null,
		description: "The global standard for financial risk professionals.",
		registrationPath: null,
		...overrides,
	}
}

function enrolled(overrides: Partial<EnrolledProgram> = {}): EnrolledProgram {
	return {
		programType: "FRM",
		adminPartIName: "November 2026",
		adminPartIIName: null,
		programInformation: baseInfo(),
		...overrides,
	}
}

function completed(overrides: Partial<CompletedProgram> = {}): CompletedProgram {
	return {
		programType: "SCR",
		programInformation: baseInfo({ abbrevName: "SCR" }),
		...overrides,
	}
}

function other(overrides: Partial<OtherProgram> = {}): OtherProgram {
	return {
		programType: "ERP",
		isRegistrationOpen: true,
		nextRegistrationOpenDate: null,
		nextRegistrationOpenAdminName: null,
		isMicroCourse: false,
		programInformation: baseInfo({ abbrevName: "ERP" }),
		...overrides,
	}
}

afterEach(() => {
	vi.useRealTimers()
})

describe("programDisplayName", () => {
	it("prefers formalName with entities decoded", () => {
		expect(programDisplayName(baseInfo())).toBe(
			"Financial Risk Manager (FRM®)",
		)
	})

	it("falls back through informal, abbrev, then programType", () => {
		expect(
			programDisplayName(
				baseInfo({ formalName: null, informalName: "  Energy Risk  " }),
			),
		).toBe("Energy Risk")
		expect(
			programDisplayName(
				baseInfo({ formalName: null, informalName: null, abbrevName: "ERP" }),
			),
		).toBe("ERP")
		expect(programDisplayName(null, "RAI")).toBe("RAI")
		expect(programDisplayName(null, null)).toBe("Program")
	})
})

describe("programCodeLabel", () => {
	it("uppercases abbrevName", () => {
		expect(programCodeLabel(baseInfo({ abbrevName: "scr" }), "SCR")).toBe("SCR")
	})

	it("falls back to programType when abbrevName is missing or blank", () => {
		expect(programCodeLabel(baseInfo({ abbrevName: null }), "riskai")).toBe(
			"RISKAI",
		)
		expect(programCodeLabel(baseInfo({ abbrevName: "   " }), "frm")).toBe("FRM")
		expect(programCodeLabel(null, "ERP")).toBe("ERP")
	})
})

describe("registrationOpensCopy", () => {
	it("counts down inside the 60-day window", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		expect(
			registrationOpensCopy(
				other({ isRegistrationOpen: false, nextRegistrationOpenDate: "2026-08-27" }),
			),
		).toBe("Registration opens in 9 days")
	})

	it("uses today / tomorrow wording at the boundary", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		expect(
			registrationOpensCopy(
				other({ isRegistrationOpen: false, nextRegistrationOpenDate: "2026-08-18" }),
			),
		).toBe("Registration opens today")
		expect(
			registrationOpensCopy(
				other({ isRegistrationOpen: false, nextRegistrationOpenDate: "2026-08-19" }),
			),
		).toBe("Registration opens tomorrow")
	})

	it("falls back to an absolute date beyond the window", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		const copy = registrationOpensCopy(
			other({
				isRegistrationOpen: false,
				nextRegistrationOpenDate: "2027-05-01",
				nextRegistrationOpenAdminName: "May 2027",
			}),
		)
		expect(copy).toContain("May 2027 registration opens")
	})

	it("handles a missing date with only an admin name", () => {
		expect(
			registrationOpensCopy(
				other({
					isRegistrationOpen: false,
					nextRegistrationOpenDate: null,
					nextRegistrationOpenAdminName: "November 2026",
				}),
			),
		).toBe("November 2026 registration is not open yet")
	})

	it("returns null when there is nothing to say", () => {
		expect(
			registrationOpensCopy(
				other({
					isRegistrationOpen: false,
					nextRegistrationOpenDate: null,
					nextRegistrationOpenAdminName: null,
				}),
			),
		).toBeNull()
	})
})

describe("buildProgramListingPresentation — in progress", () => {
	it("exposes status, code, description, and an in-app details link", () => {
		const result = buildProgramListingPresentation("inProgress", enrolled())
		expect(result.statusLabel).toBe("In progress")
		expect(result.statusTone).toBe("info")
		expect(result.codeLabel).toBe("FRM")
		expect(result.description).toBe(
			"The global standard for financial risk professionals.",
		)
		expect(result.detailsLink).toEqual({
			label: "View Details",
			url: "/programs/frm",
			isExternal: false,
		})
		expect(result.registrationLink).toBeNull()
		expect(result.learnMoreLink).toBeNull()
	})

	it("leaves a single administration unlabelled", () => {
		const result = buildProgramListingPresentation("inProgress", enrolled())
		expect(result.metaLines).toEqual([
			{ icon: "administration", text: "November 2026" },
		])
	})

	it("labels both parts when both sittings exist", () => {
		const result = buildProgramListingPresentation(
			"inProgress",
			enrolled({ adminPartIIName: "May 2027" }),
		)
		expect(result.metaLines).toEqual([
			{ icon: "administration", text: "Part I · November 2026" },
			{ icon: "administration", text: "Part II · May 2027" },
		])
	})

	it("drops blank administration names", () => {
		const result = buildProgramListingPresentation(
			"inProgress",
			enrolled({ adminPartIName: "   ", adminPartIIName: null }),
		)
		expect(result.metaLines).toEqual([])
	})

	/**
	 * This used to assert the opposite — that FFR left the app for MyGarp —
	 * because `programDetail` does not serve courses and nothing else did
	 * either. `courseDetail` has been live all along and now has a page, so a
	 * course is in-app like everything else.
	 */
	it("routes courses to the in-app course page, not MyGarp", () => {
		for (const programType of ["FFR", "FRR", "FRR25"]) {
			const result = buildProgramListingPresentation(
				"inProgress",
				enrolled({ programType }),
			)
			expect(result.detailsLink?.isExternal).toBe(false)
			expect(result.detailsLink?.url).toBe(
				`/courses/${programType.toLowerCase()}`,
			)
		}
	})

	/** A micro course code is passed through — Apex resolves it, we cannot. */
	it("routes a micro course code to the same page", () => {
		const result = buildProgramListingPresentation(
			"inProgress",
			enrolled({ programType: "ARPM" }),
		)
		expect(result.detailsLink?.url).toBe("/courses/arpm")
	})

	/** The two-part exam programmes are unaffected. */
	it("still routes exam programmes to program detail", () => {
		const result = buildProgramListingPresentation(
			"inProgress",
			enrolled({ programType: "FRM" }),
		)
		expect(result.detailsLink?.url).toBe("/programs/frm")
	})
})

describe("buildProgramListingPresentation — completed", () => {
	it("reports certification and still surfaces a description", () => {
		const result = buildProgramListingPresentation("completed", completed())
		expect(result.statusLabel).toBe("Certified")
		expect(result.statusTone).toBe("success")
		expect(result.description).not.toBeNull()
		expect(result.detailsLink?.url).toBe("/programs/scr")
		expect(result.metaLines).toEqual([])
	})

	it("tolerates a null programInformation", () => {
		const result = buildProgramListingPresentation(
			"completed",
			completed({ programInformation: null }),
		)
		expect(result.codeLabel).toBe("SCR")
		expect(result.displayName).toBe("SCR")
		expect(result.description).toBeNull()
	})
})

describe("buildProgramListingPresentation — explore", () => {
	it("offers registration and learn-more when open", () => {
		const result = buildProgramListingPresentation("other", other())
		expect(result.statusLabel).toBe("Registration open")
		expect(result.statusTone).toBe("success")
		expect(result.registrationLink?.label).toBe("Register Now")
		expect(result.registrationLink?.isExternal).toBe(true)
		expect(result.learnMoreLink?.url).toBe("https://www.garp.org/erp")
		expect(result.detailsLink).toBeNull()
		expect(result.metaLines).toEqual([
			{ icon: "registrationOpen", text: "Open for registration" },
		])
	})

	it("withholds registration and counts down when closed", () => {
		vi.useFakeTimers()
		vi.setSystemTime(new Date(2026, 7, 18))
		const result = buildProgramListingPresentation(
			"other",
			other({
				isRegistrationOpen: false,
				nextRegistrationOpenDate: "2026-08-25",
			}),
		)
		expect(result.statusLabel).toBe("Registration closed")
		expect(result.statusTone).toBe("neutral")
		expect(result.registrationLink).toBeNull()
		expect(result.metaLines).toEqual([
			{ icon: "opensLater", text: "Registration opens in 7 days" },
		])
	})

	it("flags micro courses ahead of the registration line", () => {
		const result = buildProgramListingPresentation(
			"other",
			other({ isMicroCourse: true }),
		)
		expect(result.metaLines[0]).toEqual({
			icon: "microCourse",
			text: "Micro course",
		})
	})

	it("maps riskai to the rai marketing slug", () => {
		const result = buildProgramListingPresentation(
			"other",
			other({ programType: "riskai" }),
		)
		expect(result.learnMoreLink?.url).toBe("https://www.garp.org/rai")
	})
})

describe("resolveProgramsTab", () => {
	it("honours an explicit tab", () => {
		expect(resolveProgramsTab("explore", 3)).toBe("explore")
		expect(resolveProgramsTab("all", 0)).toBe("all")
	})

	it("lands on in-progress only when the member has enrollments", () => {
		expect(resolveProgramsTab(undefined, 2)).toBe("in-progress")
		expect(resolveProgramsTab(undefined, 0)).toBe(DEFAULT_PROGRAMS_TAB)
	})
})

describe("resolveProgramsView", () => {
	it("honours an explicit view above everything else", () => {
		expect(resolveProgramsView("grid", "in-progress")).toBe("grid")
		expect(resolveProgramsView("list", "explore")).toBe("list")
		// URL wins even when a different layout is remembered.
		expect(resolveProgramsView("list", "explore", "grid")).toBe("list")
	})

	it("defaults personal buckets to list and browsing buckets to grid", () => {
		expect(resolveProgramsView(undefined, "in-progress")).toBe("list")
		expect(resolveProgramsView(undefined, "completed")).toBe("list")
		expect(resolveProgramsView(undefined, "explore")).toBe("grid")
		expect(resolveProgramsView(undefined, "all")).toBe("grid")
	})

	it("prefers a remembered choice over the per-bucket default", () => {
		// The reported bug: returning from a program detail page drops `?view=`,
		// so without the remembered choice In Progress snapped back to list.
		expect(resolveProgramsView(undefined, "in-progress", "grid")).toBe("grid")
		expect(resolveProgramsView(undefined, "completed", "grid")).toBe("grid")
		expect(resolveProgramsView(undefined, "explore", "list")).toBe("list")
		expect(resolveProgramsView(undefined, "all", "list")).toBe("list")
	})

	it("falls back to the per-bucket default when nothing is remembered", () => {
		expect(resolveProgramsView(undefined, "in-progress", null)).toBe("list")
		expect(resolveProgramsView(undefined, "explore", null)).toBe("grid")
	})
})

describe("programBrandSurface", () => {
	it("maps known program types to their brand token", () => {
		expect(programBrandSurface("FRM").surface).toContain("garp-cyan")
		expect(programBrandSurface("SCR").surface).toContain("success-green")
		expect(programBrandSurface("ERP").surface).toContain("garp-saffron")
		expect(programBrandSurface("RAI").surface).toContain("rai-orange")
		expect(programBrandSurface("RAIJ").surface).toContain("rai-blue")
	})

	it("is case insensitive", () => {
		expect(programBrandSurface("frm").surface).toBe(
			programBrandSurface("FRM").surface,
		)
	})

	it("falls back to the base code for year-suffixed types", () => {
		// Live data returns FRR25 for the FRR Series.
		expect(programBrandSurface("FRR25").surface).toContain("bright-purple")
		expect(programBrandSurface("FRR26").surface).toContain("bright-purple")
	})

	it("returns the neutral surface for unknown or empty types", () => {
		expect(programBrandSurface("ZZZ").surface).toBe("bg-muted/40")
		expect(programBrandSurface("").surface).toBe("bg-muted/40")
		expect(programBrandSurface(null).surface).toBe("bg-muted/40")
	})

	it("pairs every surface with a chip class", () => {
		for (const type of ["FRM", "SCR", "ERP", "RAI", "RAIJ", "FRR25", "ZZZ"]) {
			expect(programBrandSurface(type).chip).toBeTruthy()
		}
	})
})
