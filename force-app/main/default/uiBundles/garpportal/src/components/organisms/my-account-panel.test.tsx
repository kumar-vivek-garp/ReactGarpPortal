import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { MyAccountPanel } from "@/components/organisms/my-account-panel"
import { accountView } from "@/testing/factories/account"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const ACCOUNT_PATH = "/services/apexrest/memberportal/account"

const MEMBER: CurrentUser = {
	id: "005-member",
	name: "Ada Lovelace",
	garpId: "G-1",
	contactId: "003-member",
	photoUrl: null,
}

function serveAccount() {
	server.use(
		http.get(ACCOUNT_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(accountView())),
		),
	)
}

describe("MyAccountPanel — tab routing", () => {
	it("switching tab writes ?tab= into the URL instead of local state", async () => {
		serveAccount()
		const user = userEvent.setup()
		const { router } = await renderWithRouterProviders(
			<MyAccountPanel tab="account-information" />,
			{ path: "/my-account/", user: MEMBER },
		)

		expect(
			screen.getByRole("heading", { level: 1, name: "My Account" }),
		).toBeInTheDocument()

		await user.click(screen.getByRole("tab", { name: /Contact Preferences/ }))

		await waitFor(() => {
			expect(router.state.location.search).toMatchObject({
				tab: "contact-preferences",
			})
		})
	})
})
