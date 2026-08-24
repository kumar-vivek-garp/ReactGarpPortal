import { afterEach, describe, expect, it, vi } from "vitest"

vi.mock("@/auth/sfdc-env", () => ({
	isLocalViteHost: vi.fn(),
	getSfdcEnv: vi.fn(() => undefined),
}))

vi.mock("@/lib/resolve-portal-asset-url", () => ({
	resolvePortalAssetUrl: vi.fn((url: string) => `resolved:${url}`),
}))

import { isLocalViteHost } from "@/auth/sfdc-env"
import {
	programDetailsHref,
	programDetailsPath,
	programExamSetupHref,
	programExamSetupMyGarpHref,
	programLearnMoreUrl,
	programOrderHref,
	programRegistrationHref,
	programTypeSlug,
	resolveExperienceHref,
	supportsInAppProgramDetail,
} from "./program-card-links"

const mockedLocal = vi.mocked(isLocalViteHost)

afterEach(() => {
	vi.clearAllMocks()
})

describe("programTypeSlug", () => {
	it("lowercases and trims", () => {
		expect(programTypeSlug("  RiskAI ")).toBe("riskai")
	})
})

describe("supportsInAppProgramDetail", () => {
	it("accepts Apex-supported types including rai alias", () => {
		expect(supportsInAppProgramDetail("FRM")).toBe(true)
		expect(supportsInAppProgramDetail("RiskAI")).toBe(true)
		expect(supportsInAppProgramDetail("rai")).toBe(true)
		expect(supportsInAppProgramDetail("RAIJ")).toBe(true)
	})

	it("rejects micro / FFR / FRR style types", () => {
		expect(supportsInAppProgramDetail("FFR")).toBe(false)
		expect(supportsInAppProgramDetail("FRR")).toBe(false)
		expect(supportsInAppProgramDetail("ABC")).toBe(false)
	})
})

describe("programDetailsPath", () => {
	it("returns in-app path for supported types", () => {
		expect(programDetailsPath("FRM")).toBe("/programs/frm")
		expect(programDetailsPath("RiskAI")).toBe("/programs/riskai")
		expect(programDetailsPath("rai")).toBe("/programs/riskai")
	})

	it("returns null for unsupported types", () => {
		expect(programDetailsPath("FFR")).toBeNull()
		expect(programDetailsPath("  ")).toBeNull()
	})
})

describe("programDetailsHref", () => {
	it("uses relative MyGarp hash route on Experience", () => {
		mockedLocal.mockReturnValue(false)
		expect(programDetailsHref("FRM")).toBe("/sfdcApp#!/myprograms/frm")
		expect(programDetailsHref("RiskAI")).toBe(
			"/sfdcApp#!/myprograms/riskai",
		)
	})

	it("prefixes sandbox host on local Vite", () => {
		mockedLocal.mockReturnValue(true)
		expect(programDetailsHref("FRM")).toBe(
			"https://garp--devjuly25a.sandbox.my.site.com/sfdcApp#!/myprograms/frm",
		)
	})

	it("returns null for blank type", () => {
		mockedLocal.mockReturnValue(false)
		expect(programDetailsHref("  ")).toBeNull()
	})
})

describe("programLearnMoreUrl", () => {
	it("maps riskai to rai on garp.org", () => {
		expect(programLearnMoreUrl("RiskAI")).toBe("https://www.garp.org/rai")
	})

	it("uses program slug for other types", () => {
		expect(programLearnMoreUrl("SCR")).toBe("https://www.garp.org/scr")
	})

	it("falls back to policyURL when type is blank", () => {
		expect(
			programLearnMoreUrl("  ", "https://www.garp.org/frm/exam-policies"),
		).toBe("https://www.garp.org/frm/exam-policies")
	})
})

describe("programRegistrationHref", () => {
	it("uses MyGarp registration hash on Experience", () => {
		mockedLocal.mockReturnValue(false)
		expect(programRegistrationHref("scr", "SCR")).toBe(
			"/sfdcApp#!/registration/scr",
		)
	})

	it("prefixes sandbox host on local Vite", () => {
		mockedLocal.mockReturnValue(true)
		expect(programRegistrationHref("frm", "FRM")).toBe(
			"https://garp--devjuly25a.sandbox.my.site.com/sfdcApp#!/registration/frm",
		)
	})

	it("maps riskai to rai when path missing", () => {
		mockedLocal.mockReturnValue(false)
		expect(programRegistrationHref(null, "RiskAI")).toBe(
			"/sfdcApp#!/registration/rai",
		)
	})

	it("prefixes micro courses when path missing", () => {
		mockedLocal.mockReturnValue(false)
		expect(programRegistrationHref("", "ABC", true)).toBe(
			"/sfdcApp#!/registration/micro/abc",
		)
	})

	it("returns null when nothing usable", () => {
		mockedLocal.mockReturnValue(false)
		expect(programRegistrationHref(null, "  ")).toBeNull()
	})
})

describe("programExamSetupHref", () => {
	it("builds the in-app wizard path, mapping rai to the riskai slug", () => {
		expect(programExamSetupHref("RAI")).toBe("/programs/riskai/exam-setup")
		expect(programExamSetupHref("scr")).toBe("/programs/scr/exam-setup")
		expect(programExamSetupHref("RiskAI")).toBe("/programs/riskai/exam-setup")
	})

	it("refuses a type Apex examSetup would not accept", () => {
		expect(programExamSetupHref("frr")).toBeNull()
		expect(programExamSetupHref("")).toBeNull()
	})

	it("does not depend on the host — it is a route, not a hand-off", () => {
		mockedLocal.mockReturnValue(true)
		expect(programExamSetupHref("scr")).toBe("/programs/scr/exam-setup")
	})
})

describe("programExamSetupMyGarpHref", () => {
	it("still points at the legacy wizard for the fee hand-off", () => {
		mockedLocal.mockReturnValue(false)
		expect(programExamSetupMyGarpHref("RAI")).toBe(
			"/sfdcApp#!/programs/exam-setup/riskai",
		)
		expect(programExamSetupMyGarpHref("scr")).toBe(
			"/sfdcApp#!/programs/exam-setup/scr",
		)
	})

	it("prefixes sandbox host on local Vite", () => {
		mockedLocal.mockReturnValue(true)
		expect(programExamSetupMyGarpHref("RiskAI")).toBe(
			"https://garp--devjuly25a.sandbox.my.site.com/sfdcApp#!/programs/exam-setup/riskai",
		)
	})
})

describe("programOrderHref", () => {
	it("builds in-app order detail path", () => {
		expect(programOrderHref("a1aXXX")).toBe("/my-account/orders/a1aXXX")
	})

	it("returns null for blank id", () => {
		expect(programOrderHref("  ")).toBeNull()
		expect(programOrderHref(null)).toBeNull()
	})
})

describe("resolveExperienceHref", () => {
	it("passes through absolute https URLs", () => {
		expect(resolveExperienceHref("https://www.garp.org/scr")).toBe(
			"https://www.garp.org/scr",
		)
	})

	it("prefixes Experience origin for SSO paths on local Vite", () => {
		mockedLocal.mockReturnValue(true)
		expect(resolveExperienceHref("/BenchPrepSSO?prog=SCR")).toBe(
			"https://garp--devjuly25a.sandbox.my.site.com/BenchPrepSSO?prog=SCR",
		)
	})

	it("keeps site-root relative paths on Experience", () => {
		mockedLocal.mockReturnValue(false)
		expect(resolveExperienceHref("/PearsonVue_SSO?id=abc")).toBe(
			"/PearsonVue_SSO?id=abc",
		)
	})

	it("delegates FileDownload to resolvePortalAssetUrl", () => {
		mockedLocal.mockReturnValue(false)
		expect(
			resolveExperienceHref(
				"/servlet/servlet.FileDownload?file=015xxx",
			),
		).toBe("resolved:/servlet/servlet.FileDownload?file=015xxx")
	})
})
