import { screen, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import type { CurrentUser } from "@/api/auth/current-user"
import { programsQueryKeys } from "@/api/programs"
import type { ProgramsView } from "@/api/programs/types"
import { MobileNavPanel } from "@/components/molecules/mobile-nav-panel"
import { TOP_NAV_ITEMS } from "@/config/navigation/top-nav-items"
import type { TopNavItem } from "@/config/navigation/types"
import {
	LOCAL_CLI_GRAPHQL_URL,
	LOCAL_CLI_ME_URL,
} from "@/testing/msw/handlers/auth"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"
import { renderWithRouterProviders } from "@/testing/router"

function member(overrides: Partial<CurrentUser> = {}): CurrentUser {
	return {
		id: "005XX0000000001",
		name: "Ada Lovelace",
		garpId: "654321",
		contactId: "003XX0000000001",
		photoUrl: null,
		...overrides,
	}
}

function programsView(hasCPDProgram: boolean): ProgramsView {
	return {
		statusMessage: null,
		statusCode: 200,
		enrolledPrograms: [],
		completedPrograms: [],
		otherPrograms: [],
		hasCPDProgram,
		hasExamResults: false,
		microCourseConfig: null,
	}
}

async function renderPanel(
	options: {
		/** Omit the key entirely for "session not yet fetched". */
		user?: CurrentUser | null
		hasCpd?: boolean
		onBrowse?: (item: TopNavItem) => void
	} = {},
) {
	const onBrowse = options.onBrowse ?? vi.fn()
	const queryClient = createTestQueryClient(
		"user" in options ? options.user : member(),
	)
	// Seed programs fresh so `useHasCpdProgram` never fetches (same as AppSidebar).
	queryClient.setQueryData(
		programsQueryKeys.view,
		programsView(options.hasCpd ?? false),
	)
	const rendered = await renderWithRouterProviders(
		<MobileNavPanel onBrowse={onBrowse} />,
		{ queryClient },
	)
	return { ...rendered, onBrowse }
}

describe("MobileNavPanel — who you are", () => {
	it("shows the member's name and GARP ID on the profile row", async () => {
		await renderPanel()

		expect(screen.getByText("Ada Lovelace")).toBeInTheDocument()
		expect(screen.getByText(/GARP ID 654321/)).toBeInTheDocument()
	})

	it("degrades blank identity fields to the placeholder row, not empty strings", async () => {
		await renderPanel({ user: member({ name: "  ", garpId: "" }) })

		expect(screen.getByText("GARP Member")).toBeInTheDocument()
		expect(screen.getByText(/GARP ID —/)).toBeInTheDocument()
	})

	it("holds the profile skeleton while the session is still resolving", async () => {
		// Session never resolves: the identity probe hangs, so isPending stays true.
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
		await renderPanel({ user: undefined })

		expect(screen.queryByText("GARP Member")).not.toBeInTheDocument()
		expect(document.querySelector("[aria-busy='true']")).not.toBeNull()
	})
})

describe("MobileNavPanel — where you can go", () => {
	it("lists the account destinations without CPD by default", async () => {
		await renderPanel()

		const nav = screen.getByRole("navigation", { name: "Account" })
		for (const label of [
			"Dashboard",
			"Programs",
			"Study Materials",
			"Membership Benefits",
			"Events",
			"Help Center",
		]) {
			expect(within(nav).getByRole("link", { name: label })).toBeInTheDocument()
		}
		expect(
			within(nav).queryByRole("link", { name: "CPD Credits" }),
		).not.toBeInTheDocument()
	})

	it("adds CPD Credits when the member has a CPD program", async () => {
		await renderPanel({ hasCpd: true })

		expect(
			screen.getByRole("link", { name: "CPD Credits" }),
		).toBeInTheDocument()
	})

	it("offers Sign Out and the Browse & Explore grid", async () => {
		await renderPanel()

		expect(screen.getByRole("button", { name: /Sign Out/ })).toBeInTheDocument()
		expect(
			screen.getByRole("heading", { name: "Browse & Explore" }),
		).toBeInTheDocument()
	})

	it("hands the picked garp.org section to onBrowse for the drill-down", async () => {
		const user = userEvent.setup()
		const { onBrowse } = await renderPanel()

		await user.click(
			screen.getByRole("button", { name: new RegExp(TOP_NAV_ITEMS[0].title) }),
		)

		expect(onBrowse).toHaveBeenCalledWith(TOP_NAV_ITEMS[0])
	})
})
