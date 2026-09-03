import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { toast } from "sonner"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"

// The app's real QueryClient: its MutationCache owns the toast policy.
import { queryClient as appQueryClient } from "@/api/client"
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
		{ label: "Ops &amp; Resilience", value: "Ops &amp; Resilience" },
	],
	Publishing_Experience__c: [],
	Teaching_Experience__c: [],
	Expert_Participation__c: [],
}

function expertiseView(values: Record<string, string | null>): ExpertiseView {
	return { statusMessage: null, statusCode: 200, values, options: OPTIONS, labels: {} }
}

function expertiseOrg(initialValues: Record<string, string | null> = {}) {
	const state = { values: { ...initialValues }, saves: [] as ExpertiseValues[] }
	server.use(
		http.get(EXPERTISE_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(expertiseView(state.values))),
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

function renderCard() {
	return renderWithProviders(<ExpertiseCard />, { queryClient: appQueryClient })
}

beforeEach(() => {
	vi.clearAllMocks()
})
afterEach(() => {
	appQueryClient.clear()
})

const areaTrigger = () => screen.getByRole("button", { name: "Area of Expertise" })

describe("chip removal", () => {
	it("commits the removal immediately, without opening the dropdown", async () => {
		const user = userEvent.setup()
		const state = expertiseOrg({
			Self_Identification_Topic_Tags__c: "Credit Risk;Ops & Resilience",
		})
		renderCard()

		await user.click(
			await screen.findByRole("button", { name: "Remove Credit Risk" }),
		)

		await waitFor(() => expect(state.saves).toHaveLength(1))
		expect(state.saves[0]).toEqual({
			Self_Identification_Topic_Tags__c: "Ops & Resilience",
			Publishing_Experience__c: "",
			Teaching_Experience__c: "",
			Expert_Participation__c: "",
		})
		expect(
			screen.queryByRole("button", { name: "Remove Credit Risk" }),
		).not.toBeInTheDocument()
		expect(areaTrigger()).toHaveTextContent("1 selected")
		await waitFor(() => {
			expect(vi.mocked(toast.success)).toHaveBeenCalledWith(
				"Expertise saved",
				undefined,
			)
		})
	})

	it("keeps the draft and toasts the server's message when the save fails", async () => {
		const user = userEvent.setup()
		expertiseOrg({ Self_Identification_Topic_Tags__c: "Credit Risk" })
		server.use(
			http.post(EXPERTISE_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Save exploded."), {
					status: 500,
				}),
			),
		)
		renderCard()

		await user.click(
			await screen.findByRole("button", { name: "Remove Credit Risk" }),
		)

		await waitFor(() => {
			expect(vi.mocked(toast.error)).toHaveBeenCalledWith(
				"Unable to save expertise",
				{ description: "Save exploded." },
			)
		})
		// The draft is not rolled back — the removal stays on screen unsaved.
		expect(
			screen.queryByRole("button", { name: "Remove Credit Risk" }),
		).not.toBeInTheDocument()
		expect(vi.mocked(toast.success)).not.toHaveBeenCalled()
	})
})

describe("in flight", () => {
	it("locks every control while a save is pending, then confirms Saved", async () => {
		const user = userEvent.setup()
		let release!: () => void
		const gate = new Promise<void>((resolve) => {
			release = resolve
		})
		expertiseOrg({ Self_Identification_Topic_Tags__c: "Credit Risk" })
		server.use(
			http.post(EXPERTISE_PATH, async () => {
				await gate
				return HttpResponse.json(
					memberPortalEnvelope({ statusMessage: null, statusCode: 200 }),
				)
			}),
		)
		renderCard()

		await user.click(
			await screen.findByRole("button", { name: "Remove Credit Risk" }),
		)

		const status = await screen.findByRole("status")
		expect(status).toHaveTextContent("Saving…")
		expect(areaTrigger()).toBeDisabled()

		release()
		await waitFor(() => {
			expect(screen.getByRole("status")).toHaveTextContent("Saved")
		})
		expect(areaTrigger()).toBeEnabled()
	})
})

describe("value fidelity", () => {
	it("decodes HTML entities for display but joins the decoded value on the wire", async () => {
		const user = userEvent.setup()
		const state = expertiseOrg()
		renderCard()

		await user.click(await screen.findByRole("button", { name: "Area of Expertise" }))
		await user.click(
			screen.getByRole("menuitemcheckbox", { name: "Ops & Resilience" }),
		)
		await user.keyboard("{Escape}")

		await waitFor(() => expect(state.saves).toHaveLength(1))
		expect(state.saves[0].Self_Identification_Topic_Tags__c).toBe(
			"Ops & Resilience",
		)
		expect(
			await screen.findByRole("button", { name: "Remove Ops & Resilience" }),
		).toBeInTheDocument()
	})

	it("shows a server value the picklist no longer offers, and can remove it", async () => {
		const user = userEvent.setup()
		const state = expertiseOrg({
			Self_Identification_Topic_Tags__c: "Legacy Topic",
		})
		renderCard()

		// Not in the options — the raw value is still the chip's label.
		await user.click(
			await screen.findByRole("button", { name: "Remove Legacy Topic" }),
		)

		await waitFor(() => expect(state.saves).toHaveLength(1))
		expect(state.saves[0].Self_Identification_Topic_Tags__c).toBe("")
		expect(areaTrigger()).toHaveTextContent("Select Area of Expertise")
	})
})
