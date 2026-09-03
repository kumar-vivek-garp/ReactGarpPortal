import { screen, waitFor, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import type { PortalCard } from "@/api/dashboard"
import type { ProgramExamNotification } from "@/api/programs/types"
import { DashboardCard } from "@/components/molecules/dashboard-card"
import { DASHBOARD_PROVIDER } from "@/lib/compose-dashboard-cards"
import { renderWithRouterProviders } from "@/testing/router"
import { skipSpringAnimations } from "@/testing/springs"

// Dialog/nudge springs settle instantly; no useSubpageTransition mounts here.
skipSpringAnimations()

function notice(index: number): ProgramExamNotification {
	return {
		notificationTitle: `Notice ${index}`,
		notificationDetails: `Details for notice ${index}`,
		notificationDate: "2026-08-0" + index,
	}
}

function notificationsCard(
	notifications: ProgramExamNotification[],
	overrides: Partial<PortalCard> = {},
): PortalCard {
	return {
		key: "notifications",
		page: "dashboard",
		provider: DASHBOARD_PROVIDER.notifications,
		rank: 1,
		title: "New Notifications",
		body: null,
		ctaLabel: null,
		ctaUrl: null,
		ctaIsExternal: false,
		imageUrl: null,
		eyebrow: null,
		badge: null,
		locked: false,
		dismissible: false,
		bullets: null,
		meta: { notifications },
		...overrides,
	}
}

describe("DashboardCard — notifications preview", () => {
	it("previews only the first two notices and counts the rest", async () => {
		await renderWithRouterProviders(
			<DashboardCard card={notificationsCard([notice(1), notice(2), notice(3)])} />,
		)

		expect(screen.getByText("Notice 1")).toBeInTheDocument()
		expect(screen.getByText("Notice 2")).toBeInTheDocument()
		expect(screen.queryByText("Notice 3")).not.toBeInTheDocument()
		expect(screen.getByText(/1\s+more/)).toBeInTheDocument()
	})

	it("shows no overflow count when everything fits the preview", async () => {
		await renderWithRouterProviders(
			<DashboardCard card={notificationsCard([notice(1)])} />,
		)

		expect(screen.getByText("Notice 1")).toBeInTheDocument()
		expect(screen.queryByText(/more/)).not.toBeInTheDocument()
	})
})

describe("DashboardCard — notifications dialog", () => {
	it("See All opens the dialog with every notice, and Escape closes it", async () => {
		const user = userEvent.setup()
		await renderWithRouterProviders(
			<DashboardCard card={notificationsCard([notice(1), notice(2), notice(3)])} />,
		)

		expect(screen.queryByRole("dialog")).not.toBeInTheDocument()

		await user.click(screen.getByRole("button", { name: "See All" }))

		const dialog = await screen.findByRole("dialog", { name: /notifications/i })
		expect(within(dialog).getByText("Notice 1")).toBeInTheDocument()
		expect(within(dialog).getByText("Notice 3")).toBeInTheDocument()
		expect(within(dialog).getByText("Details for notice 3")).toBeInTheDocument()

		await user.keyboard("{Escape}")
		await waitFor(() =>
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument(),
		)
	})

	it("uses the card's own CTA label for the trigger when Apex supplies one", async () => {
		const user = userEvent.setup()
		await renderWithRouterProviders(
			<DashboardCard
				card={notificationsCard([], { ctaLabel: "View notices" })}
			/>,
		)

		await user.click(screen.getByRole("button", { name: "View notices" }))

		const dialog = await screen.findByRole("dialog", { name: /notifications/i })
		expect(
			within(dialog).getByText("You have no notifications right now."),
		).toBeInTheDocument()
	})
})
