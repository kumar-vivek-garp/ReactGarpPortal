import { act, waitFor } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { afterEach, describe, expect, it, vi } from "vitest"

import { useMyEBooks, useOpenEBook } from "@/hooks/use-ebook-archive"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

const MY_EBOOKS_PATH = "/services/apexrest/memberportal/myEBooks"
const EBOOK_ACCESS_PATH = "/services/apexrest/memberportal/eBookAccess"

afterEach(() => {
	vi.restoreAllMocks()
})

describe("useMyEBooks", () => {
	it("loads the year-keyed archive", async () => {
		server.use(
			http.get(MY_EBOOKS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusCode: 200,
						statusMessage: null,
						eBooks: {},
					}),
				),
			),
		)

		const { result } = renderHookWithProviders(() => useMyEBooks())
		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(result.current.data?.eBooks).toEqual({})
	})

	it("stays idle when disabled", () => {
		const { result } = renderHookWithProviders(() => useMyEBooks(false))
		expect(result.current.fetchStatus).toBe("idle")
	})
})

describe("useOpenEBook", () => {
	it("mints a fresh reader link and opens it in a new tab", async () => {
		const open = vi
			.spyOn(window, "open")
			.mockImplementation(() => null)
		server.use(
			http.get(EBOOK_ACCESS_PATH, ({ request }) => {
				expect(new URL(request.url).searchParams.get("vendorId")).toBe("V-1")
				return HttpResponse.json(
					memberPortalEnvelope({
						statusCode: 200,
						statusMessage: null,
						accessURL: "https://reader.example/book-1",
					}),
				)
			}),
		)

		const { result } = renderHookWithProviders(() => useOpenEBook())
		act(() => {
			result.current.mutate("V-1")
		})

		await waitFor(() => expect(result.current.isSuccess).toBe(true))
		expect(open).toHaveBeenCalledWith(
			"https://reader.example/book-1",
			"_blank",
			"noopener,noreferrer",
		)
	})
})
