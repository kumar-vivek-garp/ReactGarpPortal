import { screen, waitFor, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { CpdPanel } from "@/components/organisms/cpd-panel"
import type { CpdTab } from "@/config/cpd"
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
	props: { cycle?: string; tab?: CpdTab } = {},
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
	it("offers the header actions and opens on the tab that has something in it", async () => {
		await renderPanel()

		await screen.findByRole("button", { name: "Add Credits" })
		expect(
			screen.getByRole("link", { name: "Download Handbook" }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: "Browse Credit Opportunities" }),
		).toBeInTheDocument()

		/*
		 * One list at a time now. This cycle has a pending claim, so Pending is
		 * the tab that opens and the approved row sits behind its own tab
		 * rather than stacked under a second heading.
		 */
		expect(
			screen.getByRole("tab", { name: /Pending/, selected: true }),
		).toBeInTheDocument()
		expect(screen.getByText("Pending Row")).toBeInTheDocument()
		expect(screen.queryByText("Approved Row")).not.toBeInTheDocument()
	})

	/*
	 * The click is asserted through the URL, not through the panel contents:
	 * the swap is a react-spring cross-fade and jsdom does not drive it to
	 * completion — the same reason `/programs` and `/membership` assert their
	 * tab switches this way. What the chosen tab RENDERS is covered below by
	 * mounting on it directly, which is a first mount and so deterministic.
	 */
	it("writes the chosen tab into the URL", async () => {
		const user = userEvent.setup()
		const { router } = await renderPanel()
		await screen.findByText("Pending Row")

		await user.click(screen.getByRole("tab", { name: /Approved/ }))

		await waitFor(() => {
			expect(router.state.location.search).toMatchObject({ tab: "approved" })
		})
	})

	it("mounts on the approved list when the URL asks for it", async () => {
		await renderPanel({ tab: "approved" })

		expect(await screen.findByText("Approved Row")).toBeInTheDocument()
		expect(screen.queryByText("Pending Row")).not.toBeInTheDocument()
		expect(
			screen.getByRole("tab", { name: /Approved/, selected: true }),
		).toBeInTheDocument()
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
		await renderPanel({ tab: "approved" })

		/*
		 * An approved row's only action is "see the rest of it", so the row IS
		 * the control — there is no Details button beside it any more. Mounted
		 * straight onto the approved tab so no cross-fade is in flight.
		 */
		await user.click(
			await screen.findByRole("button", { name: "View Approved Row" }),
		)
		const dialog = await screen.findByRole("dialog", { name: "Credit Details" })
		/*
		 * `findBy`: the claim's own title is a DYNAMIC row, built from the
		 * activity type's labels, and that query only starts when the dialog
		 * opens — so the row lands a tick after the dialog does.
		 */
		expect(await within(dialog).findByText("Approved Row")).toBeInTheDocument()
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
