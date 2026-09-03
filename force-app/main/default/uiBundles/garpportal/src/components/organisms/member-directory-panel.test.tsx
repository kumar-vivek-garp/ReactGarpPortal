import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { MemberDirectoryPanel } from "@/components/organisms/member-directory-panel"
import {
	directoryMember,
	directorySearchResults,
	directoryView,
} from "@/testing/factories/directory"
import { memberPortalError } from "@/testing/factories/envelope"
import { DIRECTORY_SEARCH_PATH, directoryOrg } from "@/testing/msw/handlers/directory"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

describe("access", () => {
	it("shows the heading and results for an entitled member", async () => {
		const org = directoryOrg({
			respond: () => directorySearchResults({ members: [directoryMember()] }),
		})
		server.use(...org.handlers)
		renderWithProviders(<MemberDirectoryPanel />)

		expect(
			screen.getByRole("heading", { name: "Member Directory" }),
		).toBeInTheDocument()
		expect(
			await screen.findByRole("button", { name: "View Ada Lovelace" }),
		).toBeInTheDocument()
		expect(screen.getByText("Head of Risk · Analytical Engines · United Kingdom")).toBeInTheDocument()
		expect(screen.getByText("1–1 of 1")).toBeInTheDocument()
		expect(org.spy.bodies[0]).toMatchObject({ searchText: null, pageCurrent: 1, pageSize: 10 })
	})

	it("hides the heading when the membership tab owns it", async () => {
		const org = directoryOrg()
		server.use(...org.handlers)
		renderWithProviders(<MemberDirectoryPanel showHeading={false} />)

		await screen.findByRole("button", { name: "View Ada Lovelace" })
		// The rows carry their own h3s — only the page-level h1 must be gone.
		expect(screen.queryByRole("heading", { level: 1 })).not.toBeInTheDocument()
	})

	it("seeds the first search from initialTerm", async () => {
		const org = directoryOrg()
		server.use(...org.handlers)
		renderWithProviders(<MemberDirectoryPanel initialTerm="lovelace" />)

		await waitFor(() => expect(org.spy.hits).toBe(1))
		expect(org.spy.bodies[0].searchText).toBe("lovelace")
		expect(
			screen.getByRole("textbox", { name: "Search the member directory" }),
		).toHaveValue("lovelace")
	})

	it("shows the no-access state, never searches, and upsells an upgrade", async () => {
		const org = directoryOrg({
			view: directoryView({
				hasDirectoryAccess: false,
				upsellMembershipType: "Upgrade",
			}),
		})
		server.use(...org.handlers)
		renderWithProviders(<MemberDirectoryPanel />)

		expect(
			await screen.findByText("The directory is not available on your membership"),
		).toBeInTheDocument()
		const link = screen.getByRole("link", { name: "Upgrade" })
		expect(link).toHaveAttribute("href", "/membership")
		expect(
			screen.queryByRole("textbox", { name: "Search the member directory" }),
		).not.toBeInTheDocument()
		expect(org.spy.hits).toBe(0)
	})

	it("labels a lapsed Individual's upsell Renew Now", async () => {
		const org = directoryOrg({
			view: directoryView({
				hasDirectoryAccess: false,
				upsellMembershipType: "Renew",
			}),
		})
		server.use(...org.handlers)
		renderWithProviders(<MemberDirectoryPanel />)

		expect(
			await screen.findByRole("link", { name: "Renew Now" }),
		).toHaveAttribute("href", "/membership")
	})

	it("routes a pending membership order to its own page instead of a re-buy", async () => {
		const org = directoryOrg({
			view: directoryView({
				hasDirectoryAccess: false,
				upsellMembershipType: "Renew",
				pendingMembershipOrderId: "801A",
			}),
		})
		server.use(...org.handlers)
		renderWithProviders(<MemberDirectoryPanel />)

		expect(
			await screen.findByRole("link", { name: "View Order" }),
		).toHaveAttribute("href", "/order-details/801A")
	})
})

describe("results", () => {
	it("shows the zero state without a clear-filters action when none are set", async () => {
		const org = directoryOrg({
			respond: () => directorySearchResults({ members: [], total: 0, pages: 0 }),
		})
		server.use(...org.handlers)
		renderWithProviders(<MemberDirectoryPanel />)

		expect(await screen.findByText("No members found")).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: /Clear \d+ filter/ }),
		).not.toBeInTheDocument()
	})

	it("reports a failed search in place of the list", async () => {
		const org = directoryOrg()
		server.use(...org.handlers)
		server.use(
			http.post(DIRECTORY_SEARCH_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		renderWithProviders(<MemberDirectoryPanel />)

		expect(
			await screen.findByText(
				"We couldn't run that search. Please try again later.",
			),
		).toBeInTheDocument()
	})

	it("pages through the server's counts, resending only pageCurrent", async () => {
		const user = userEvent.setup()
		const org = directoryOrg({
			respond: (body) =>
				directorySearchResults({
					members: [directoryMember()],
					pages: 3,
					total: 25,
					pageCurrent: body.pageCurrent ?? 1,
				}),
		})
		server.use(...org.handlers)
		renderWithProviders(<MemberDirectoryPanel />)

		expect(await screen.findByText("Page 1 of 3")).toBeInTheDocument()
		expect(screen.getByText("1–10 of 25")).toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Previous" })).toBeDisabled()

		await user.click(screen.getByRole("button", { name: "Next" }))
		expect(await screen.findByText("Page 2 of 3")).toBeInTheDocument()
		expect(screen.getByText("11–20 of 25")).toBeInTheDocument()
		expect(screen.getByRole("button", { name: "Previous" })).toBeEnabled()
		expect(org.spy.bodies[1].pageCurrent).toBe(2)

		// Going back lands on the page-1 query key, still fresh in the cache —
		// the list restores without another wire hit.
		await user.click(screen.getByRole("button", { name: "Previous" }))
		expect(await screen.findByText("Page 1 of 3")).toBeInTheDocument()
		expect(org.spy.hits).toBe(2)
	})

	it("hides the pager for a single page", async () => {
		const org = directoryOrg()
		server.use(...org.handlers)
		renderWithProviders(<MemberDirectoryPanel />)

		await screen.findByRole("button", { name: "View Ada Lovelace" })
		expect(screen.queryByRole("button", { name: "Next" })).not.toBeInTheDocument()
	})
})

describe("member dialog", () => {
	it("opens the pressed member and closes back to the list", async () => {
		const user = userEvent.setup()
		const org = directoryOrg({
			respond: () =>
				directorySearchResults({
					members: [directoryMember({ canSendMessage: true, canInvite: true })],
				}),
		})
		server.use(...org.handlers)
		renderWithProviders(<MemberDirectoryPanel />)

		// The interactive Card defers onActivate past its press-spring settle.
		await user.click(
			await screen.findByRole("button", { name: "View Ada Lovelace" }),
		)
		const dialog = await screen.findByRole("dialog")
		expect(dialog).toHaveTextContent("Ada Lovelace")
		expect(
			screen.getByRole("button", { name: "Send Message" }),
		).toBeInTheDocument()
		expect(
			screen.getByRole("button", { name: "Invite to Connect" }),
		).toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: "Close" }))
		await waitFor(() => {
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
		})
		// The list is untouched by opening a member.
		expect(org.spy.hits).toBe(1)
	})

	it("clears the search box back to the full list", async () => {
		const user = userEvent.setup()
		const org = directoryOrg()
		server.use(...org.handlers)
		renderWithProviders(<MemberDirectoryPanel initialTerm="lovelace" />)

		await waitFor(() => expect(org.spy.hits).toBe(1))
		await user.click(screen.getByRole("button", { name: "Clear search" }))
		expect(
			screen.getByRole("textbox", { name: "Search the member directory" }),
		).toHaveValue("")
		await waitFor(() => expect(org.spy.hits).toBe(2))
		expect(org.spy.bodies[1]).toMatchObject({ searchText: null, pageCurrent: 1 })
	})
})

// Documents current behavior: while the entitlement check is still loading a
// DISABLED search query reports isLoading false (no fetch is in flight), so
// the panel renders the "No members found" zero state instead of the skeleton
// for that first frame. Suspected cosmetic bug — pinned, not fixed.
it("flashes the zero state, not the skeleton, while access is still loading", () => {
	const org = directoryOrg()
	server.use(...org.handlers)
	renderWithProviders(<MemberDirectoryPanel />)

	expect(screen.getByText("No members found")).toBeInTheDocument()
})
