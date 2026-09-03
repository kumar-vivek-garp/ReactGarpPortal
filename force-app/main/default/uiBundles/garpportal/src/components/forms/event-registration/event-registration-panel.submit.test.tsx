import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { personalInfoQueryKeys } from "@/api/personal-info/query-options"
import type { EventRegisterRequest } from "@/api/registration/event-types"
import { EventRegistrationPanel } from "@/components/forms/event-registration/event-registration-panel"
import { memberPortalError } from "@/testing/factories/envelope"
import {
	eventContact,
	eventLoad,
	eventRegisterResult,
} from "@/testing/factories/event"
import { personalInfoEditData } from "@/testing/factories/personal-info"
import { examregGet, examregPost } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"
import { renderWithRouterProviders } from "@/testing/router"

const REGISTER_PATH = "/services/apexrest/examreg/event/register"

const MEMBER: CurrentUser = {
	id: "005-member",
	name: "Ada Lovelace",
	garpId: "G-1",
	contactId: null,
	photoUrl: null,
}

function renderPanel(options: Parameters<typeof renderWithRouterProviders>[1]) {
	return renderWithRouterProviders(
		<EventRegistrationPanel
			variant="event"
			eventId="evt-1"
			paymentReturn={null}
			checkoutCancelled={null}
		/>,
		options,
	)
}

describe("EventRegistrationPanel — free submit, end to end", () => {
	it("posts the closed DTO for a member and shows the registered outcome with the server's message", async () => {
		const register = examregPost<EventRegisterRequest>("event/register", () =>
			eventRegisterResult({
				registrationNumber: "ER-7",
				message: "See you in Boston.",
			}),
		)
		server.use(
			examregGet("event/info", () =>
				eventLoad({ contact: eventContact() }),
			).handler,
			register.handler,
		)
		await renderPanel({ user: MEMBER })

		// Identity came from the record, so only the attestation stands between
		// the member and a valid form.
		expect(await screen.findByText("Contact details")).toBeInTheDocument()
		await userEvent.click(
			screen.getByRole("checkbox", { name: /GARP Privacy Notice/ }),
		)
		const submit = screen.getByRole("button", { name: "Complete Registration" })
		await waitFor(() => expect(submit).toBeEnabled())
		await userEvent.click(submit)

		expect(
			await screen.findByRole("heading", { name: "You're registered" }),
		).toBeInTheDocument()
		expect(screen.getByText("See you in Boston.")).toBeInTheDocument()
		expect(screen.getByText("ER-7")).toBeInTheDocument()

		// The wire payload is the whitelist — seeded identity travels, unrendered
		// sections are absent entirely, nothing is posted as a silent default.
		expect(register.spy.hits).toBe(1)
		expect(register.spy.bodies[0]).toEqual({
			variant: "event",
			eventId: "evt-1",
			email: "ada@example.test",
			firstName: "Ada",
			lastName: "Lovelace",
			jobTitle: "Analyst",
			company: "Analytical Engines",
			isGdpr: false,
			userQuestions: "",
			privacyPolicyAttestation: true,
			agreeToGarpContent: false,
		})
	})

	it("seeds identity from the member profile when the load carries no contact (local dev's admin gateway)", async () => {
		const withContact: CurrentUser = { ...MEMBER, contactId: "003-member" }
		const register = examregPost<EventRegisterRequest>("event/register", () =>
			eventRegisterResult(),
		)
		server.use(
			examregGet("event/info", () => eventLoad({ contact: null })).handler,
			register.handler,
		)
		const queryClient = createTestQueryClient(withContact)
		// The profile answers from the cache — its GraphQL read stays off the wire.
		queryClient.setQueryData(
			personalInfoQueryKeys.edit("003-member"),
			personalInfoEditData({
				contactId: "003-member",
				email: "grace@example.test",
				firstName: "Grace",
				lastName: "Hopper",
			}),
		)
		await renderPanel({ user: withContact, queryClient })

		expect(await screen.findByText("Contact details")).toBeInTheDocument()
		await userEvent.click(
			screen.getByRole("checkbox", { name: /GARP Privacy Notice/ }),
		)
		const submit = screen.getByRole("button", { name: "Complete Registration" })
		await waitFor(() => expect(submit).toBeEnabled())
		await userEvent.click(submit)

		await waitFor(() => expect(register.spy.hits).toBe(1))
		expect(register.spy.bodies[0]).toMatchObject({
			email: "grace@example.test",
			firstName: "Grace",
			lastName: "Hopper",
		})
	})

	it("keeps the form up with the server's own words when the registration fails", async () => {
		server.use(
			examregGet("event/info", () =>
				eventLoad({ contact: eventContact() }),
			).handler,
			http.post(REGISTER_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Capacity reached."), {
					status: 500,
				}),
			),
		)
		await renderPanel({ user: MEMBER })

		await screen.findByText("Contact details")
		await userEvent.click(
			screen.getByRole("checkbox", { name: /GARP Privacy Notice/ }),
		)
		const submit = screen.getByRole("button", { name: "Complete Registration" })
		await waitFor(() => expect(submit).toBeEnabled())
		await userEvent.click(submit)

		expect(await screen.findByRole("alert")).toHaveTextContent(
			"Capacity reached.",
		)
		// Still the form, not an outcome — the error must be fixable in place.
		expect(
			screen.getByRole("button", { name: "Complete Registration" }),
		).toBeInTheDocument()
	})
})
