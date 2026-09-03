import { fireEvent, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import type { PortalCard } from "@/api/dashboard"
import { DashboardCard } from "@/components/molecules/dashboard-card"
import { DASHBOARD_PROVIDER } from "@/lib/compose-dashboard-cards"
import { renderWithRouterProviders } from "@/testing/router"
import { skipSpringAnimations } from "@/testing/springs"

// Widget springs (meter fill, CTA nudge, CPD bars) settle instantly; the card
// mounts no useSubpageTransition (verified in source).
skipSpringAnimations()

function card(overrides: Partial<PortalCard> = {}): PortalCard {
	return {
		key: "card-key",
		page: "dashboard",
		provider: null,
		rank: 1,
		title: "Card Title",
		body: "Card body copy.",
		ctaLabel: "Open",
		ctaUrl: "/programs",
		ctaIsExternal: false,
		imageUrl: null,
		eyebrow: null,
		badge: null,
		locked: false,
		dismissible: false,
		bullets: null,
		meta: {},
		...overrides,
	}
}

describe("DashboardCard — per-provider widgets", () => {
	it("profile: renders the completeness meter from meta", async () => {
		await renderWithRouterProviders(
			<DashboardCard
				card={card({
					provider: DASHBOARD_PROVIDER.profile,
					meta: { percentComplete: 65, missing: ["Photo"] },
				})}
			/>,
		)

		const meter = screen.getByRole("progressbar", {
			name: "Profile completeness",
		})
		expect(meter).toHaveAttribute("aria-valuenow", "65")
		expect(screen.getByText(/still needed: photo/i)).toBeInTheDocument()
	})

	it("profile: no meter when Apex sent no percentage", async () => {
		await renderWithRouterProviders(
			<DashboardCard card={card({ provider: DASHBOARD_PROVIDER.profile })} />,
		)

		expect(screen.queryByRole("progressbar")).not.toBeInTheDocument()
	})

	it("enrolled: lists programmes, or explains the empty state", async () => {
		const enrolled = card({
			provider: DASHBOARD_PROVIDER.enrolled,
			meta: {
				enrolledPrograms: [
					{
						programType: "FRM",
						name: "Financial Risk Manager",
						adminPartIName: null,
						adminPartIIName: null,
					},
				],
			},
		})
		const { unmount } = await renderWithRouterProviders(
			<DashboardCard card={enrolled} />,
		)
		expect(
			screen.getByRole("link", { name: /financial risk manager/i }),
		).toBeInTheDocument()
		unmount()

		await renderWithRouterProviders(
			<DashboardCard card={card({ provider: DASHBOARD_PROVIDER.enrolled })} />,
		)
		expect(
			screen.getByText("Programs you enroll in will show up here."),
		).toBeInTheDocument()
	})

	it("events: lists upcoming events, or explains the empty state", async () => {
		const events = card({
			provider: DASHBOARD_PROVIDER.events,
			meta: {
				upcomingEvents: [
					{
						eventId: "evt-1",
						eventType: "Webcast",
						eventName: "Climate Risk Briefing",
						eventStartDate: "2026-10-01",
						eventUrl: "https://www.garp.org/events/climate-risk",
					},
				],
			},
		})
		const { unmount } = await renderWithRouterProviders(
			<DashboardCard card={events} />,
		)
		expect(
			screen.getByRole("link", { name: "Climate Risk Briefing" }),
		).toHaveAttribute("href", "https://www.garp.org/events/climate-risk")
		unmount()

		await renderWithRouterProviders(
			<DashboardCard card={card({ provider: DASHBOARD_PROVIDER.events })} />,
		)
		expect(
			screen.getByText("Events you register for will show up here."),
		).toBeInTheDocument()
	})

	it("cpd: renders credit bars plus the remaining line only when rows exist", async () => {
		const cpd = card({
			provider: DASHBOARD_PROVIDER.cpd,
			meta: {
				cpdRows: [{ designation: "FRM", approved: 10, required: 40 }],
				cpdRemaining: "30 credits to go",
			},
		})
		const { unmount } = await renderWithRouterProviders(
			<DashboardCard card={cpd} />,
		)
		expect(screen.getByText("10 / 40")).toBeInTheDocument()
		expect(screen.getByText("30 credits to go")).toBeInTheDocument()
		unmount()

		await renderWithRouterProviders(
			<DashboardCard card={card({ provider: DASHBOARD_PROVIDER.cpd })} />,
		)
		expect(screen.queryByText("10 / 40")).not.toBeInTheDocument()
	})

	it("directory: mounts the search box only when meta enables it", async () => {
		const directory = card({
			provider: DASHBOARD_PROVIDER.directory,
			meta: { searchEnabled: true },
		})
		const { unmount } = await renderWithRouterProviders(
			<DashboardCard card={directory} />,
		)
		expect(
			screen.getByRole("textbox", { name: "Search the member directory" }),
		).toBeInTheDocument()
		unmount()

		await renderWithRouterProviders(
			<DashboardCard card={card({ provider: DASHBOARD_PROVIDER.directory })} />,
		)
		expect(screen.queryByRole("textbox")).not.toBeInTheDocument()
	})

	it("exam: shows the sitting facts and a deliberately inert CTA", async () => {
		await renderWithRouterProviders(
			<DashboardCard
				card={card({
					provider: DASHBOARD_PROVIDER.exam,
					badge: "Registered",
					ctaLabel: "Register Now",
					ctaUrl: "/Login?start=registration/frm",
					meta: { examType: "FRM", administrationName: "May 2026" },
				})}
			/>,
		)

		expect(screen.getByText("FRM · May 2026")).toBeInTheDocument()
		expect(screen.getByText("Registered")).toBeInTheDocument()
		// The exam CTA renders as a disabled span, never a navigable link.
		expect(
			screen.queryByRole("link", { name: /register now/i }),
		).not.toBeInTheDocument()
		expect(screen.getByText("Register Now")).toBeInTheDocument()
	})
})

describe("DashboardCard — image, copy and dismiss wiring", () => {
	it("renders eyebrow, bullets and the image; a broken image hides itself", async () => {
		await renderWithRouterProviders(
			<DashboardCard
				card={card({
					eyebrow: "Recommended for you",
					bullets: ["First fact", "Second fact"],
					imageUrl: "https://www.garp.org/hero.jpg",
				})}
			/>,
		)

		expect(screen.getByText("Recommended for you")).toBeInTheDocument()
		expect(screen.getByText("First fact")).toBeInTheDocument()

		const image = screen.getByRole("presentation")
		expect(image).toHaveAttribute("src", "https://www.garp.org/hero.jpg")
		fireEvent.error(image)
		expect(image).not.toBeVisible()
	})

	it("dismissible cards call onDismiss with their own key", async () => {
		const onDismiss = vi.fn()
		const user = userEvent.setup()
		await renderWithRouterProviders(
			<DashboardCard
				card={card({ key: "profile-card", dismissible: true })}
				onDismiss={onDismiss}
			/>,
		)

		await user.click(screen.getByRole("button", { name: "Dismiss this card" }))

		expect(onDismiss).toHaveBeenCalledTimes(1)
		expect(onDismiss).toHaveBeenCalledWith("profile-card")
	})

	it("offers no dismiss affordance when the card is not dismissible, or no handler came", async () => {
		const { unmount } = await renderWithRouterProviders(
			<DashboardCard card={card({ dismissible: false })} onDismiss={vi.fn()} />,
		)
		expect(
			screen.queryByRole("button", { name: "Dismiss this card" }),
		).not.toBeInTheDocument()
		unmount()

		await renderWithRouterProviders(
			<DashboardCard card={card({ dismissible: true })} />,
		)
		expect(
			screen.queryByRole("button", { name: "Dismiss this card" }),
		).not.toBeInTheDocument()
	})
})
