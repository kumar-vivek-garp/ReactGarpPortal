import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { PicklistOption } from "@/api/account/types"
import type { ExpertiseValues, ExpertiseView } from "@/api/expertise"
import { ExpertiseCard } from "@/components/organisms/expertise-card"
import { memberPortalEnvelope, memberPortalError } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const EXPERTISE_PATH = "/services/apexrest/memberportal/expertise"

const OPTIONS: Record<string, PicklistOption[]> = {
	Self_Identification_Topic_Tags__c: [
		{ label: "Credit Risk", value: "Credit Risk" },
		{ label: "Market Risk", value: "Market Risk" },
		{ label: "Ops &amp; Resilience", value: "Ops &amp; Resilience" },
	],
	Publishing_Experience__c: [
		{ label: "Books", value: "Books" },
		{ label: "Journals", value: "Journals" },
	],
	Teaching_Experience__c: [{ label: "University", value: "University" }],
	Expert_Participation__c: [{ label: "Panels", value: "Panels" }],
}

function expertiseView(
	values: Record<string, string | null>,
	options: Record<string, PicklistOption[]> = OPTIONS,
): ExpertiseView {
	return { statusMessage: null, statusCode: 200, values, options, labels: {} }
}

/**
 * GET serves the mutable server state; POST records each save and folds it
 * back in, so the refetch after a save reflects what was written.
 */
function expertiseOrg(
	initialValues: Record<string, string | null> = {},
	options: Record<string, PicklistOption[]> = OPTIONS,
) {
	const state = { values: { ...initialValues }, saves: [] as ExpertiseValues[] }
	server.use(
		http.get(EXPERTISE_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(expertiseView(state.values, options))),
		),
		http.post(EXPERTISE_PATH, async ({ request }) => {
			const { values } = (await request.json()) as { values: ExpertiseValues }
			state.saves.push(values)
			state.values = { ...state.values, ...values }
			return HttpResponse.json(
				memberPortalEnvelope({ statusMessage: null, statusCode: 200 }),
			)
		}),
	)
	return state
}

const areaTrigger = () => screen.getByRole("button", { name: "Area of Expertise" })
const item = (name: string) => screen.getByRole("menuitemcheckbox", { name })

describe("loading", () => {
	it("shows the skeleton, then the four selects seeded from the server", async () => {
		expertiseOrg({ Self_Identification_Topic_Tags__c: "Credit Risk;Market Risk" })
		renderWithProviders(<ExpertiseCard />)

		expect(screen.getByLabelText("Loading expertise")).toBeInTheDocument()

		expect(await screen.findByRole("button", { name: "Area of Expertise" })).toHaveTextContent("2 selected")
		expect(screen.queryByLabelText("Loading expertise")).not.toBeInTheDocument()

		// Server values arrive as chips; untouched fields keep their placeholder.
		expect(screen.getByRole("button", { name: "Remove Credit Risk" })).toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Remove Market Risk" })).toBeInTheDocument()
		expect(
			screen.getByRole("button", { name: "Publishing Experience" }),
		).toHaveTextContent("Select Publishing Experience")
		expect(screen.getByRole("button", { name: "Teaching Experience" })).toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Expert Participation" })).toBeInTheDocument()
	})

	it("reports a failed load in place of the selects", async () => {
		server.use(
			http.get(EXPERTISE_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		renderWithProviders(<ExpertiseCard />)

		expect(
			await screen.findByText(
				"We couldn't load your expertise. Please try again later.",
			),
		).toBeInTheDocument()
	})

	it("says so when a field has no options to offer", async () => {
		const user = userEvent.setup()
		expertiseOrg({}, { ...OPTIONS, Expert_Participation__c: [] })
		renderWithProviders(<ExpertiseCard />)

		await user.click(
			await screen.findByRole("button", { name: "Expert Participation" }),
		)
		expect(await screen.findByText("No options available.")).toBeInTheDocument()
	})
})

describe("draft and save on close", () => {
	it("accumulates picks while the menu is open and saves once on close", async () => {
		const user = userEvent.setup()
		const state = expertiseOrg()
		renderWithProviders(<ExpertiseCard />)

		await user.click(await screen.findByRole("button", { name: "Area of Expertise" }))
		await user.click(item("Credit Risk"))
		expect(item("Credit Risk")).toBeChecked()
		await user.click(item("Market Risk"))

		// The draft is on screen but nothing has gone to the wire yet.
		expect(state.saves).toHaveLength(0)

		await user.keyboard("{Escape}")
		await waitFor(() => expect(state.saves).toHaveLength(1))
		expect(state.saves[0]).toEqual({
			Self_Identification_Topic_Tags__c: "Credit Risk;Market Risk",
			Publishing_Experience__c: "",
			Teaching_Experience__c: "",
			Expert_Participation__c: "",
		})

		// After the refetch the server's copy drives the same chips.
		expect(areaTrigger()).toHaveTextContent("2 selected")
		expect(
			await screen.findByRole("button", { name: "Remove Credit Risk" }),
		).toBeInTheDocument()
	})

	it("saves nothing when the menu closes unchanged", async () => {
		const user = userEvent.setup()
		const state = expertiseOrg({ Self_Identification_Topic_Tags__c: "Credit Risk" })
		renderWithProviders(<ExpertiseCard />)

		await user.click(await screen.findByRole("button", { name: "Area of Expertise" }))
		await user.keyboard("{Escape}")

		await waitFor(() => {
			expect(screen.queryByRole("menu")).not.toBeInTheDocument()
		})
		expect(state.saves).toHaveLength(0)
	})

	it("saves nothing when a pick is toggled straight back off", async () => {
		const user = userEvent.setup()
		const state = expertiseOrg()
		renderWithProviders(<ExpertiseCard />)

		await user.click(await screen.findByRole("button", { name: "Area of Expertise" }))
		await user.click(item("Credit Risk"))
		await user.click(item("Credit Risk"))
		expect(item("Credit Risk")).not.toBeChecked()
		await user.keyboard("{Escape}")

		await waitFor(() => {
			expect(screen.queryByRole("menu")).not.toBeInTheDocument()
		})
		expect(state.saves).toHaveLength(0)
	})

	it("keeps each field's draft independent and saves them all in one payload", async () => {
		const user = userEvent.setup()
		const state = expertiseOrg({ Self_Identification_Topic_Tags__c: "Credit Risk" })
		renderWithProviders(<ExpertiseCard />)

		await user.click(
			await screen.findByRole("button", { name: "Publishing Experience" }),
		)
		await user.click(item("Books"))
		await user.keyboard("{Escape}")

		await waitFor(() => expect(state.saves).toHaveLength(1))
		expect(state.saves[0]).toEqual({
			Self_Identification_Topic_Tags__c: "Credit Risk",
			Publishing_Experience__c: "Books",
			Teaching_Experience__c: "",
			Expert_Participation__c: "",
		})
	})
})
