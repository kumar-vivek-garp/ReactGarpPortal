import { describe, expect, it } from "vitest"

import {
	registrationChromeForPath,
	registrationChromeForSlug,
} from "./registration-chrome"

describe("registrationChromeForSlug", () => {
	it.each([
		["frm", "FRM", "FRM", "garp-cyan"],
		["scr", "SCR", "SCR", "garp-saffron"],
		["riskai", "RAI", "RAI", "rai-split"],
	])(
		"pairs %s's artwork with the title its banner renders",
		(slug, label, highlight, token) => {
			const guest = registrationChromeForSlug(slug)

			expect(guest?.chrome.label).toBe(label)
			// The heading comes from the registration registry, so the banner's
			// acronym tint matches the nav's without restating a hex.
			expect(guest?.heading.highlight).toBe(highlight)
			expect(guest?.heading.highlightToken).toBe(token)
			expect(guest?.heading.suffix).toBe(") Exam Registration")
		},
	)

	/*
	 * `/registration/rai` is a live marketing address that resolves to the
	 * `riskai` programme. A raw lookup would miss the chrome on a URL GARP
	 * actually publishes, so the slug is canonicalised first.
	 */
	it("resolves the legacy rai alias to the same chrome as riskai", () => {
		const alias = registrationChromeForSlug("rai")

		expect(alias).toBeDefined()
		expect(alias).toEqual(registrationChromeForSlug("riskai"))
	})

	/*
	 * Both halves must resolve. `raij` is the live example of the deferred case:
	 * a real programme with registration config but no frame in the redesign, so
	 * it keeps the GARP chrome rather than showing a half-redesigned page.
	 */
	it("withholds chrome until a programme has both artwork and config", () => {
		expect(registrationChromeForSlug("raij")).toBeUndefined()
		expect(registrationChromeForSlug("micro")).toBeUndefined()
		expect(registrationChromeForSlug("")).toBeUndefined()
		expect(registrationChromeForSlug(null)).toBeUndefined()
	})
})

describe("registrationChromeForPath", () => {
	/*
	 * The shell and the route must not disagree. The shell asks by pathname to
	 * decide the banner; the route asks by slug to set `titleInBanner`. If the
	 * two ever diverged, a page would end up with two `h1`s or none.
	 */
	it("agrees with the slug form on every public registration path", () => {
		for (const slug of ["frm", "scr", "rai", "riskai", "raij", "micro"]) {
			expect(registrationChromeForPath(`/registration/${slug}`)).toEqual(
				registrationChromeForSlug(slug),
			)
		}
	})

	it("gives no chrome to affiliate, the member twin, or any other page", () => {
		expect(registrationChromeForPath("/registration/affiliate")).toBeUndefined()
		expect(registrationChromeForPath("/programs/frm/register")).toBeUndefined()
		expect(registrationChromeForPath("/dashboard")).toBeUndefined()
		expect(registrationChromeForPath("/")).toBeUndefined()
	})
})
