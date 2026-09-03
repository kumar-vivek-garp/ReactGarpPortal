import { screen, waitFor, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { CpdPanel } from "@/components/organisms/cpd-panel"
import { cpdClaim, cpdCycleInfo, cpdProgramView } from "@/testing/factories/cpd"
import { memberPortalError } from "@/testing/factories/envelope"
import { CPD_PROGRAM_PATH, cpdProgramOrg } from "@/testing/msw/handlers/cpd"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

/** A current cycle with one pending and one approved claim, plus a past one. */
function twoCycles() {
	return cpdProgramView({
		currentCycle: "2025/2027",
		cycles: [
			cpdCycleInfo({
				cycleName: "2025/2027",
				pendingClaims: [cpdClaim({ claimId: "claim-p", title: "Pending Row" })],
				approvedClaims: [
					cpdClaim({
						claimId: "claim-a",
						title: "Approved Row",
						approvalComments: "Verified by GARP.",
					}),
				],
			}),
			cpdCycleInfo({
				cycleName: "2023/2025",
				status: "completed",
				approvedClaims: [
					cpdClaim({ claimId: "claim-old", title: "Old Approved Row" }),
				],
			}),
		],
	})
}

/** The claim/view dialogs key their fields off the admin-configured labels. */
const WEBINAR_TYPE = {
	id: "type-webinar",
	name: "Webinar",
	organizationLabel: null,
	providerLabel: null,
	publicationLabel: null,
	titleLabel: "Title",
	contactEmailLabel: null,
}

async function renderPanel(
	props: { cycle?: string } = {},
	org = cpdProgramOrg({ view: twoCycles(), activityTypes: [WEBINAR_TYPE] }),
) {
	server.use(...org.handlers)
	const rendered = await renderWithRouterProviders(<CpdPanel {...props} />, {
		path: "/cpd",
	})
	await screen.findByRole("heading", {
		name: "Continuing Professional Development",
	})
	return { ...rendered, org }
}

describe("the current cycle", () => {
	it("offers the manage box and both activity sections", async () => {
		await renderPanel()

		await screen.findByRole("button", { name: "Add Credits" })
		expect(
			screen.getByRole("link", { name: "Download Handbook" }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: "Browse Credit Opportunities" }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("heading", { name: /Pending Activities/ }),
		).toBeInTheDocument()
		expect(screen.getByText("Pending Row")).toBeInTheDocument()
		expect(screen.getByText("Approved Row")).toBeInTheDocument()
	})

	it("locks a past cycle down to its approved history", async () => {
		await renderPanel({ cycle: "2023/2025" })

		expect(await screen.findByText("Old Approved Row")).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: "Add Credits" }),
		).not.toBeInTheDocument()
		expect(
			screen.queryByRole("heading", { name: /Pending Activities/ }),
		).not.toBeInTheDocument()
	})

	it("writes a cycle switch into the URL without refetching", async () => {
		const user = userEvent.setup()
		const { router, org } = await renderPanel()
		await screen.findByRole("button", { name: "Add Credits" })
		const before = org.deleteSpy.hits

		await user.click(screen.getByRole("combobox", { name: "Cycle:" }))
		await user.click(await screen.findByRole("option", { name: "2023/2025" }))

		await waitFor(() => {
			expect(
				(router.state.location.search as { cycle?: string }).cycle,
			).toBe("2023/2025")
		})
		expect(org.deleteSpy.hits).toBe(before)
	})
})

describe("nothing to show", () => {
	it("greets a member with no CPD cycle instead of an empty grid", async () => {
		await renderPanel({}, cpdProgramOrg({ view: cpdProgramView({ cycles: [] }) }))
		expect(await screen.findByText("No CPD cycle yet")).toBeInTheDocument()
	})

	it("admits failure in words", async () => {
		server.use(
			http.get(CPD_PROGRAM_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		await renderWithRouterProviders(<CpdPanel />, { path: "/cpd" })
		expect(
			await screen.findByText(/couldn.t load your CPD record/),
		).toBeInTheDocument()
	})
})

describe("one dialog at a time", () => {
	it("opens Add Credits empty and closes it clean", async () => {
		const user = userEvent.setup()
		await renderPanel()

		await user.click(await screen.findByRole("button", { name: "Add Credits" }))
		const dialog = await screen.findByRole("dialog", { name: "Credit Details" })
		expect(
			within(dialog).getByText(/Log an activity for your current CPD cycle/),
		).toBeInTheDocument()

		await user.click(within(dialog).getByRole("button", { name: "Cancel" }))
		await waitFor(() => {
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
		})
	})

	it("shows an approved claim read-only, reviewer comments included", async () => {
		const user = userEvent.setup()
		await renderPanel()

		await user.click(await screen.findByRole("button", { name: "Details" }))
		const dialog = await screen.findByRole("dialog", { name: "Credit Details" })
		expect(within(dialog).getByText("Approved Row")).toBeInTheDocument()
		expect(within(dialog).getByText("Reviewer Comments")).toBeInTheDocument()
		expect(within(dialog).getByText("Verified by GARP.")).toBeInTheDocument()
	})

	it("deletes a pending claim only after the confirm, then closes", async () => {
		const user = userEvent.setup()
		const { org } = await renderPanel()

		await user.click(
			await screen.findByRole("button", { name: "Delete Pending Row" }),
		)
		const dialog = await screen.findByRole("dialog", {
			name: "Delete this submission?",
		})
		expect(org.deleteSpy.hits).toBe(0)

		await user.click(within(dialog).getByRole("button", { name: "Delete" }))
		await waitFor(() => {
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
		})
		expect(org.deleteSpy.bodies).toEqual([{ claimId: "claim-p" }])
	})

	it("keeps the delete dialog open when the server refuses", async () => {
		const user = userEvent.setup()
		await renderPanel(
			{},
			cpdProgramOrg({
				view: twoCycles(),
				deleteRespond: () =>
					HttpResponse.json(memberPortalError(500, "Cannot delete."), {
						status: 500,
					}),
			}),
		)

		await user.click(
			await screen.findByRole("button", { name: "Delete Pending Row" }),
		)
		await user.click(screen.getByRole("button", { name: "Delete" }))

		expect(
			await screen.findByRole("dialog", { name: "Delete this submission?" }),
		).toBeInTheDocument()
	})

	it("opens Edit seeded with the pending claim", async () => {
		const user = userEvent.setup()
		await renderPanel()

		await user.click(
			await screen.findByRole("button", { name: "Edit Pending Row" }),
		)
		const dialog = await screen.findByRole("dialog", { name: "Credit Details" })
		expect(
			within(dialog).getByText(/Update this activity/),
		).toBeInTheDocument()
	})
})
