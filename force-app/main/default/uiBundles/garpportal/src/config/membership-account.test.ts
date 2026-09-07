import { describe, expect, it } from "vitest"

import { buildAutoRenewReturnUrl } from "@/config/membership-account"

describe("buildAutoRenewReturnUrl", () => {
	it("returns to the page that started the flow, tagged with the setup status", () => {
		expect(
			buildAutoRenewReturnUrl({
				origin: "https://portal.example",
				pathname: "/garpportal/my-account",
			}),
		).toBe("https://portal.example/garpportal/my-account?status=autorenewsetupcomplete")
	})

	it("drops any search the page already carried — the tag is the whole query", () => {
		expect(
			buildAutoRenewReturnUrl({ origin: "http://localhost:5173", pathname: "/my-account" }),
		).toBe("http://localhost:5173/my-account?status=autorenewsetupcomplete")
	})
})
