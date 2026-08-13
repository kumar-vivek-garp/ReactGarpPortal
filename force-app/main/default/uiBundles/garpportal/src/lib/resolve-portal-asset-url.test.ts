import { afterEach, describe, expect, it, vi } from "vitest"

vi.mock("@/auth/sfdc-env", () => ({
	getSfdcEnv: vi.fn(),
	isLocalViteHost: vi.fn(),
}))

import { getSfdcEnv, isLocalViteHost } from "@/auth/sfdc-env"
import { resolvePortalAssetUrl } from "./resolve-portal-asset-url"

const mockedEnv = vi.mocked(getSfdcEnv)
const mockedLocal = vi.mocked(isLocalViteHost)

afterEach(() => {
	vi.clearAllMocks()
})

describe("resolvePortalAssetUrl", () => {
	it("returns undefined for blank input", () => {
		mockedLocal.mockReturnValue(false)
		mockedEnv.mockReturnValue({ basePath: "/garpportal" })
		expect(resolvePortalAssetUrl(null)).toBeUndefined()
		expect(resolvePortalAssetUrl("  ")).toBeUndefined()
	})

	it("passes through absolute http(s) and data URLs", () => {
		mockedLocal.mockReturnValue(false)
		mockedEnv.mockReturnValue({ basePath: "/garpportal" })
		expect(resolvePortalAssetUrl("https://cdn.example/a.png")).toBe(
			"https://cdn.example/a.png",
		)
		expect(resolvePortalAssetUrl("data:image/png;base64,abc")).toBe(
			"data:image/png;base64,abc",
		)
	})

	it("prefixes Experience site basePath for FileDownload paths", () => {
		mockedLocal.mockReturnValue(false)
		mockedEnv.mockReturnValue({ basePath: "/garpportal/" })
		expect(
			resolvePortalAssetUrl(
				"/servlet/servlet.FileDownload?file=00PgP000006Q6hRUAS",
			),
		).toBe(
			"/garpportal/servlet/servlet.FileDownload?file=00PgP000006Q6hRUAS",
		)
	})

	it("does not double-prefix when basePath is already present", () => {
		mockedLocal.mockReturnValue(false)
		mockedEnv.mockReturnValue({ basePath: "/garpportal" })
		expect(
			resolvePortalAssetUrl(
				"/garpportal/servlet/servlet.FileDownload?file=00Pxxx",
			),
		).toBe("/garpportal/servlet/servlet.FileDownload?file=00Pxxx")
	})

	it("maps FileDownload to Attachment Body on local Vite", () => {
		mockedLocal.mockReturnValue(true)
		mockedEnv.mockReturnValue(undefined)
		expect(
			resolvePortalAssetUrl(
				"/servlet/servlet.FileDownload?file=00PgP000006Q6hRUAS",
			),
		).toBe(
			"/__local_sf/services/data/v67.0/sobjects/Attachment/00PgP000006Q6hRUAS/Body",
		)
	})
})
