import { describe, expect, it } from "vitest"

import frmLogo from "@/assets/brand/programs/FRM.png"
import raiLogo from "@/assets/brand/programs/RAI.webp"
import scrLogo from "@/assets/brand/programs/SCR.webp"
import { localizeProgramLogoUrl } from "@/config/program-logos"

describe("localizeProgramLogoUrl", () => {
	it("returns undefined for missing or blank input", () => {
		expect(localizeProgramLogoUrl(null)).toBeUndefined()
		expect(localizeProgramLogoUrl(undefined)).toBeUndefined()
		expect(localizeProgramLogoUrl("   ")).toBeUndefined()
	})

	it("rewrites known HubSpot art to the bundled asset", () => {
		expect(
			localizeProgramLogoUrl("https://www.garp.org/hubfs/programs/FRM.png"),
		).toBe(frmLogo)
	})

	it("matches with a trailing query string", () => {
		expect(
			localizeProgramLogoUrl("https://www.garp.org/hubfs/SCR.webp?width=200"),
		).toBe(scrLogo)
	})

	it("matches case-insensitively", () => {
		expect(
			localizeProgramLogoUrl("https://www.garp.org/hubfs/frm.png"),
		).toBe(frmLogo)
	})

	it("matches a percent-encoded URL after decoding", () => {
		expect(
			localizeProgramLogoUrl("https://www.garp.org/hubfs%2FRAI.webp"),
		).toBe(raiLogo)
	})

	it("passes unknown URLs through trimmed", () => {
		expect(
			localizeProgramLogoUrl("  https://cdn.example/other/ERP.png "),
		).toBe("https://cdn.example/other/ERP.png")
	})

	it("survives a malformed percent-encoding without throwing", () => {
		expect(localizeProgramLogoUrl("https://cdn.example/a%ZZb.png")).toBe(
			"https://cdn.example/a%ZZb.png",
		)
	})
})
