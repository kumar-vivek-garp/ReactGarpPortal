import { screen } from "@testing-library/react"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { NotFoundPage } from "@/components/organisms/not-found-page"
import {
	LOCAL_CLI_GRAPHQL_URL,
	LOCAL_CLI_ME_URL,
} from "@/testing/msw/handlers/auth"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

describe("NotFoundPage — cold load", () => {
	it("shows the boot splash while the session is still resolving", async () => {
		// Session probe never settles: neither chrome may be guessed at yet.
		server.use(
			http.post(LOCAL_CLI_GRAPHQL_URL, async () => {
				await delay("infinite")
				return HttpResponse.json({})
			}),
			http.get(LOCAL_CLI_ME_URL, async () => {
				await delay("infinite")
				return HttpResponse.json({})
			}),
		)

		await renderWithRouterProviders(<NotFoundPage />, {
			path: "/no-such-page",
		})

		expect(
			screen.getByRole("status", { name: "Loading GARP" }),
		).toBeInTheDocument()
		expect(screen.queryByText("Page not found")).not.toBeInTheDocument()
	})
})
