import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { beforeEach, describe, expect, it } from "vitest"

import type { Benefit, MembershipView } from "@/api/membership/types"
import { MembershipPanel } from "@/components/organisms/membership-panel"
import type { MembershipTab } from "@/config/membership"
import type { ListView } from "@/config/list-view"
import { useListViewStore } from "@/store/list-view-store"
import { directoryOrg } from "@/testing/msw/handlers/directory"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { identity, membershipView } from "@/testing/factories/identity"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const MEMBERSHIP_PATH = "/services/apexrest/memberportal/membership"

function benefit(overrides: Partial<Benefit> = {}): Benefit {
	return {
		id: "b1",
		title: "GARP Careers",
		section: "Career",
		sortOrder: 1,
		paragraphs: [],
		bullets: [],
		imageUrl: null,
		ctaLabel: null,
		ctaUrl: null,
		ctaIsExternal: false,
		opensInNewWindow: false,
		promoCode: null,
		locked: false,
		membershipRequired: false,
		...overrides,
	}
}

function serveMembership(view: MembershipView = membershipView()) {
	server.use(
		http.get(MEMBERSHIP_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(view)),
		),
	)
}

const twoBenefitView = () =>
	membershipView({
		sections: [
			{
				name: "Career",
				benefits: [
					benefit(),
					benefit({ id: "b2", title: "Networking Events" }),
				],
			},
		],
	})

async function renderPanel(tab: MembershipTab = "benefits", view?: ListView) {
	return renderWithRouterProviders(<MembershipPanel tab={tab} view={view} />, {
		path: "/membership",
	})
}

beforeEach(() => {
	window.localStorage.clear()
	useListViewStore.setState({ preferred: {} })
})

describe("MembershipPanel — benefits tab", () => {
	it("renders the section with its count and every benefit card", async () => {
		serveMembership(twoBenefitView())
		await renderPanel()

		expect(
			await screen.findByRole("heading", { name: /Career.*\(2\)/ }),
		).toBeInTheDocument()
		expect(screen.getByText("GARP Careers")).toBeInTheDocument()
		expect(screen.getByText("Networking Events")).toBeInTheDocument()
		// The pill for this tab counts the benefits.
		expect(
			screen.getByRole("tab", { name: /Member Benefits.*\(2\)/ }),
		).toBeInTheDocument()
	})

	it("shows the empty state when GARP has published nothing", async () => {
		serveMembership()
		await renderPanel()

		expect(
			await screen.findByText("No benefits published yet"),
		).toBeInTheDocument()
	})

	it("shows the error line when the payload fails", async () => {
		server.use(
			http.get(MEMBERSHIP_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		await renderPanel()

		expect(
			await screen.findByText(/couldn't load your membership benefits/),
		).toBeInTheDocument()
	})

	it("remembers a layout switch and writes it into ?view=", async () => {
		const user = userEvent.setup()
		serveMembership(twoBenefitView())
		const { router } = await renderPanel()
		await screen.findByText("GARP Careers")

		await user.click(screen.getByRole("radio", { name: "List view" }))

		await waitFor(() => {
			expect(router.state.location.search).toMatchObject({ view: "list" })
		})
		expect(useListViewStore.getState().preferred.membership).toBe("list")
		// The rows still carry the same facts.
		expect(screen.getByText("GARP Careers")).toBeInTheDocument()
	})

	it("a remembered list preference applies when the URL has no ?view=", async () => {
		useListViewStore.setState({ preferred: { membership: "list" } })
		serveMembership(twoBenefitView())
		await renderPanel()
		await screen.findByText("GARP Careers")

		expect(
			screen.getByRole("radio", { name: "List view" }),
		).toHaveAttribute("aria-checked", "true")
	})
})

describe("MembershipPanel — directory tab", () => {
	it("mounts the real directory panel without the layout toggle", async () => {
		serveMembership(twoBenefitView())
		server.use(...directoryOrg().handlers)
		await renderPanel("directory")

		expect(
			await screen.findByText(/Find and connect with opted-in members/),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("radio", { name: "Grid view" }),
		).not.toBeInTheDocument()
	})

	it("notes limited access for a member without Individual Membership", async () => {
		serveMembership(
			membershipView({ identity: identity({ isIndividualMember: false }) }),
		)
		server.use(...directoryOrg().handlers)
		await renderPanel("directory")

		expect(
			await screen.findByText(/Full directory access is an Individual Membership benefit/),
		).toBeInTheDocument()
	})

	it("does not show the access note to an Individual member", async () => {
		serveMembership(twoBenefitView())
		server.use(...directoryOrg().handlers)
		await renderPanel("directory")

		await screen.findByText(/Find and connect with opted-in members/)
		expect(
			screen.queryByText(/Full directory access is an Individual Membership benefit/),
		).not.toBeInTheDocument()
	})

	it("switching tabs writes ?tab= into the URL", async () => {
		const user = userEvent.setup()
		serveMembership(twoBenefitView())
		server.use(...directoryOrg().handlers)
		const { router } = await renderPanel("benefits")
		await screen.findByText("GARP Careers")

		await user.click(screen.getByRole("tab", { name: /Member Directory/ }))

		await waitFor(() => {
			expect(router.state.location.search).toMatchObject({ tab: "directory" })
		})
	})
})
