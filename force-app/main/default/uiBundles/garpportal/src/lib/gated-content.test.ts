import { afterEach, describe, expect, it } from "vitest"

import { GATED_URL_COOKIE } from "@/config/gated-content"
import {
	gatedUpsellHref,
	isAllowedGatedUrl,
	readGatedUrl,
} from "./gated-content"

function setCookie(value: string) {
	document.cookie = `${GATED_URL_COOKIE}=${value}; path=/`
}

afterEach(() => {
	document.cookie = `${GATED_URL_COOKIE}=; path=/; Expires=Thu, 01 Jan 1970 00:00:01 GMT`
})

describe("isAllowedGatedUrl", () => {
	it("accepts garp.org and its subdomains over https", () => {
		expect(isAllowedGatedUrl("https://www.garp.org/risk-intelligence/x")).toBe(
			true,
		)
		expect(isAllowedGatedUrl("https://garp.org/a")).toBe(true)
		expect(isAllowedGatedUrl("https://info.garp.org/a")).toBe(true)
	})

	/**
	 * The security check this page turns on. The value comes from a cookie and
	 * is handed to `window.location`, so an unvalidated one is an open redirect
	 * fired at the exact moment a member expects to be forwarded.
	 */
	it("rejects another host", () => {
		expect(isAllowedGatedUrl("https://evil.example/x")).toBe(false)
	})

	/** `garp.org.evil.example` must not pass as a subdomain of garp.org. */
	it("rejects a lookalike host that merely contains the domain", () => {
		expect(isAllowedGatedUrl("https://garp.org.evil.example/x")).toBe(false)
		expect(isAllowedGatedUrl("https://notgarp.org/x")).toBe(false)
	})

	/** A protocol-relative URL parses with the OTHER host, not ours. */
	it("rejects protocol-relative and non-https schemes", () => {
		expect(isAllowedGatedUrl("//evil.example/x")).toBe(false)
		expect(isAllowedGatedUrl("http://www.garp.org/x")).toBe(false)
		expect(isAllowedGatedUrl("javascript:alert(1)")).toBe(false)
		expect(isAllowedGatedUrl("data:text/html,<script>")).toBe(false)
	})

	it("rejects nothing at all", () => {
		expect(isAllowedGatedUrl(null)).toBe(false)
		expect(isAllowedGatedUrl(undefined)).toBe(false)
		expect(isAllowedGatedUrl("   ")).toBe(false)
		expect(isAllowedGatedUrl("/relative/path")).toBe(false)
	})
})

describe("readGatedUrl", () => {
	it("reads and decodes the cookie", () => {
		setCookie(encodeURIComponent("https://www.garp.org/a?b=c&d=e"))
		expect(readGatedUrl()).toBe("https://www.garp.org/a?b=c&d=e")
	})

	/** The legacy stores the value wrapped in quotes on some paths. */
	it("strips surrounding single and double quotes", () => {
		setCookie(encodeURIComponent(`"https://www.garp.org/a"`))
		expect(readGatedUrl()).toBe("https://www.garp.org/a")
		setCookie(encodeURIComponent(`'https://www.garp.org/b'`))
		expect(readGatedUrl()).toBe("https://www.garp.org/b")
	})

	/**
	 * An unusable link and a missing one are the same thing from the member's
	 * side, and saying more would describe our own check to whoever set it.
	 */
	it("reports a disallowed destination as absent", () => {
		setCookie(encodeURIComponent("https://evil.example/x"))
		expect(readGatedUrl()).toBeNull()
	})

	it("returns null when there is no cookie", () => {
		expect(readGatedUrl()).toBeNull()
	})
})

describe("gatedUpsellHref", () => {
	/** Only the `track_cta` shapes carry attribution; the four are not swappable. */
	it("keeps the tracking tag and carries the article along", () => {
		const href = gatedUpsellHref("https://www.garp.org/a?b=c")
		expect(href).toContain("track_cta=PortalGatedContent")
		expect(href).toContain("registration/membership")
		expect(href).toContain(
			`garp_gated_url=${encodeURIComponent("https://www.garp.org/a?b=c")}`,
		)
	})

	it("still offers membership when there is no article to return to", () => {
		expect(gatedUpsellHref(null)).toContain("registration/membership")
		expect(gatedUpsellHref(null)).not.toContain("garp_gated_url")
	})
})
