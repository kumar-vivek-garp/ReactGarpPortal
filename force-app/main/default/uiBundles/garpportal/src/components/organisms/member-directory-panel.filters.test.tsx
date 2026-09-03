import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import type { PicklistOption } from "@/api/account/types"
import { MemberDirectoryPanel } from "@/components/organisms/member-directory-panel"
import {
	directoryMember,
	directorySearchResults,
	directoryView,
} from "@/testing/factories/directory"
import { directoryOrg } from "@/testing/msw/handlers/directory"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const PICKLISTS: Record<string, PicklistOption[]> = {
	Area_of_Concentration__c: [{ label: "Banking", value: "Banking" }],
	Job_Function__c: [],
	Risk_Specialty__c: [],
	Corporate_Title__c: [],
}

function filtersOrg(options: Parameters<typeof directoryOrg>[0] = {}) {
	const org = directoryOrg({ picklists: PICKLISTS, ...options })
	server.use(...org.handlers)
	return org
}

const filtersButton = () => screen.getByRole("button", { name: /^Filters/ })

async function mounted(org: ReturnType<typeof filtersOrg>) {
	renderWithProviders(<MemberDirectoryPanel />)
	await waitFor(() => expect(org.spy.hits).toBe(1))
}

/** Applies the draft and waits out the dialog's exit spring — while it is
 * still leaving, Radix keeps the page behind it aria-hidden. */
async function apply(user: ReturnType<typeof userEvent.setup>) {
	await user.click(screen.getByRole("button", { name: "Show results" }))
	await waitFor(() => {
		expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
	})
}

describe("filters dialog wiring", () => {
	it("applies the drafted filters as one search, surfacing them as chips and a count", async () => {
		const user = userEvent.setup()
		const org = filtersOrg()
		await mounted(org)

		await user.click(filtersButton())
		await screen.findByRole("dialog")
		await user.click(screen.getByRole("checkbox", { name: "FRM" }))
		await user.click(screen.getByRole("checkbox", { name: "Banking" }))
		await user.type(screen.getByRole("textbox", { name: "Company" }), "Acme")
		// Drafting alone runs nothing.
		expect(org.spy.hits).toBe(1)

		await apply(user)
		await waitFor(() => expect(org.spy.hits).toBe(2))
		expect(org.spy.bodies[1]).toMatchObject({
			FRMOnly: true,
			ERPOnly: false,
			company: "Acme",
			industries: ["Banking"],
			pageCurrent: 1,
		})

		expect(screen.getByRole("button", { name: /FRM.*Remove filter/ })).toBeInTheDocument()
		expect(screen.getByRole("button", { name: /Company: Acme.*Remove filter/ })).toBeInTheDocument()
		expect(screen.getByRole("button", { name: /Banking.*Remove filter/ })).toBeInTheDocument()
		expect(filtersButton()).toHaveTextContent("Filters3")
	})

	it("returns to page 1 when filters change", async () => {
		const user = userEvent.setup()
		const org = filtersOrg({
			respond: (body) =>
				directorySearchResults({
					members: [directoryMember()],
					pages: 3,
					total: 25,
					pageCurrent: body.pageCurrent ?? 1,
				}),
		})
		await mounted(org)

		await user.click(screen.getByRole("button", { name: "Next" }))
		await waitFor(() => expect(org.spy.hits).toBe(2))
		expect(org.spy.bodies[1].pageCurrent).toBe(2)

		await user.click(filtersButton())
		await user.click(await screen.findByRole("checkbox", { name: "SCR" }))
		await apply(user)

		await waitFor(() => expect(org.spy.hits).toBe(3))
		expect(org.spy.bodies[2]).toMatchObject({ SCROnly: true, pageCurrent: 1 })
	})

	it("removes one filter from its chip and reruns the search", async () => {
		const user = userEvent.setup()
		const org = filtersOrg()
		await mounted(org)

		await user.click(filtersButton())
		await user.click(await screen.findByRole("checkbox", { name: "FRM" }))
		await user.click(screen.getByRole("checkbox", { name: "RAI" }))
		await apply(user)
		await waitFor(() => expect(org.spy.hits).toBe(2))

		await user.click(screen.getByRole("button", { name: /^FRM.*Remove filter/ }))
		await waitFor(() => expect(org.spy.hits).toBe(3))
		expect(org.spy.bodies[2]).toMatchObject({
			FRMOnly: false,
			RAIOnly: true,
			pageCurrent: 1,
		})
		expect(
			screen.queryByRole("button", { name: /^FRM.*Remove filter/ }),
		).not.toBeInTheDocument()
		expect(filtersButton()).toHaveTextContent("Filters1")
	})

	it("clears every chip at once from the list's own Clear all", async () => {
		const user = userEvent.setup()
		const org = filtersOrg()
		await mounted(org)

		await user.click(filtersButton())
		await user.click(await screen.findByRole("checkbox", { name: "FRM" }))
		await user.click(screen.getByRole("checkbox", { name: "ERP" }))
		await apply(user)
		await waitFor(() => expect(org.spy.hits).toBe(2))

		// Two chips bring the chip row's own Clear all with them.
		await user.click(screen.getByRole("button", { name: "Clear all" }))
		await waitFor(() => {
			expect(
				screen.queryByRole("button", { name: /Remove filter/ }),
			).not.toBeInTheDocument()
		})
		// Cleared filters are the mount key again — served from cache.
		expect(filtersButton()).toHaveTextContent(/^Filters$/)
	})

	it("offers to clear the filters when they filter everyone out", async () => {
		const user = userEvent.setup()
		const org = filtersOrg({
			respond: (body) =>
				body.FRMOnly
					? directorySearchResults({ members: [], total: 0, pages: 0 })
					: directorySearchResults({ members: [directoryMember()] }),
		})
		await mounted(org)

		await user.click(filtersButton())
		await user.click(await screen.findByRole("checkbox", { name: "FRM" }))
		await apply(user)

		expect(await screen.findByText("No members found")).toBeInTheDocument()
		await user.click(screen.getByRole("button", { name: "Clear 1 filter" }))

		expect(
			await screen.findByRole("button", { name: "View Ada Lovelace" }),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: /Remove filter/ }),
		).not.toBeInTheDocument()
	})

	it("offers no Filters button without advanced-search access", async () => {
		const org = filtersOrg({
			view: directoryView({ hasDirectoryAdvancedSearchAccess: false }),
		})
		await mounted(org)

		expect(
			screen.queryByRole("button", { name: /^Filters/ }),
		).not.toBeInTheDocument()
	})
})
