/**
 * The click-through ends in `window.location.href = gatedUrl`. jsdom's
 * Location is [LegacyUnforgeable], so the assignment can be neither spied on
 * nor replaced — it executes, jsdom logs "Not implemented: navigation" to
 * stderr, and the test asserts the observable side effect instead: the cookie
 * is cleared. Same posture as `use-membership-auto-renew.test.ts`.
 */
import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { beforeEach, describe, expect, it } from "vitest"

import type { Identity } from "@/api/account/types"
import type { MembershipView } from "@/api/membership/types"
import { GatedContentPanel } from "@/components/organisms/gated-content-panel"
import { memberPortalEnvelope, memberPortalError } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const MEMBERSHIP_PATH = "/services/apexrest/memberportal/membership"
const ARTICLE_URL = "https://www.garp.org/article/climate-risk"

function identity(overrides: Partial<Identity> = {}): Identity {
	return {
		contactId: "003XX0000012345",
		firstName: "Ada",
		lastName: "Lovelace",
		fullName: "Ada Lovelace",
		email: "ada@example.com",
		garpId: "123456",
		membershipType: "Individual",
		membershipStatus: "Active",
		membershipExpiration: "2027-01-01",
		memberSince: "2020-01-01",
		autoRenew: false,
		isMember: true,
		isIndividualMember: true,
		isAffiliateMember: false,
		isMemberInGoodStanding: true,
		audience: "Individual",
		photoUrl: null,
		...overrides,
	}
}

function membershipView(overrides: Partial<Identity> = {}): MembershipView {
	return {
		identity: identity(overrides),
		hero: null,
		sections: [],
		lockedCount: 0,
	}
}

function serveMembership(overrides: Partial<Identity> = {}) {
	server.use(
		http.get(MEMBERSHIP_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(membershipView(overrides))),
		),
	)
}

function setGatedCookie(value: string) {
	document.cookie = `garp_gated_url=${encodeURIComponent(value)}`
}

beforeEach(() => {
	// jsdom keeps cookies across tests in a file — start each one clean.
	document.cookie =
		"garp_gated_url=; Path=/; Expires=Thu, 01 Jan 1970 00:00:01 GMT"
})

describe("GatedContentPanel — entitled member", () => {
	it("offers the content link once membership confirms good standing", async () => {
		setGatedCookie(ARTICLE_URL)
		serveMembership()
		await renderWithRouterProviders(<GatedContentPanel />)

		expect(
			await screen.findByRole("button", { name: /continue to your content/i }),
		).toBeInTheDocument()
		expect(
			screen.getByText("Your membership gives you access to this content."),
		).toBeInTheDocument()
	})

	it("clicking through clears the cookie so the link is single-use", async () => {
		setGatedCookie(ARTICLE_URL)
		serveMembership()
		const user = userEvent.setup()
		await renderWithRouterProviders(<GatedContentPanel />)

		await user.click(
			await screen.findByRole("button", { name: /continue to your content/i }),
		)

		expect(document.cookie).not.toContain("garp_gated_url")
	})

	it("captures the gated URL once — a re-render does not re-read the cookie", async () => {
		setGatedCookie(ARTICLE_URL)
		serveMembership()
		const { queryClient } = await renderWithRouterProviders(
			<GatedContentPanel />,
		)
		await screen.findByRole("button", { name: /continue to your content/i })

		// The cookie disappears (used elsewhere, expired, cleared) …
		document.cookie =
			"garp_gated_url=; Path=/; Expires=Thu, 01 Jan 1970 00:00:01 GMT"
		// … and the panel re-renders when the membership query refreshes.
		await queryClient.invalidateQueries()
		await waitFor(() => expect(queryClient.isFetching()).toBe(0))

		expect(
			screen.getByRole("button", { name: /continue to your content/i }),
		).toBeInTheDocument()
		expect(screen.queryByText("This link has expired")).not.toBeInTheDocument()
	})
})

describe("GatedContentPanel — not in good standing", () => {
	it("upsells renewal to a lapsed individual, carrying the article along", async () => {
		setGatedCookie(ARTICLE_URL)
		serveMembership({ isMemberInGoodStanding: false, isIndividualMember: true })
		await renderWithRouterProviders(<GatedContentPanel />)

		const renew = await screen.findByRole("link", {
			name: "Renew your membership",
		})
		expect(renew.getAttribute("href")).toContain("track_cta=PortalGatedContent")
		expect(renew.getAttribute("href")).toContain(
			encodeURIComponent(ARTICLE_URL),
		)
		expect(
			screen.getByRole("link", { name: "My Account" }),
		).toBeInTheDocument()
	})

	it("upsells an upgrade to a non-individual member", async () => {
		setGatedCookie(ARTICLE_URL)
		serveMembership({
			isMemberInGoodStanding: false,
			isIndividualMember: false,
		})
		await renderWithRouterProviders(<GatedContentPanel />)

		expect(
			await screen.findByRole("link", { name: "Upgrade your membership" }),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("link", { name: "Renew your membership" }),
		).not.toBeInTheDocument()
	})
})

describe("GatedContentPanel — nothing to hand over", () => {
	it("reports an expired link when no cookie was set, even for a member", async () => {
		serveMembership()
		await renderWithRouterProviders(<GatedContentPanel />)

		expect(await screen.findByText("This link has expired")).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: /back to garp\.org/i }),
		).toHaveAttribute("href", "https://www.garp.org")
	})

	it("treats a failed membership read as an expired link, not a guess", async () => {
		setGatedCookie(ARTICLE_URL)
		server.use(
			http.get(MEMBERSHIP_PATH, () =>
				HttpResponse.json(memberPortalError(500, "boom"), { status: 500 }),
			),
		)
		await renderWithRouterProviders(<GatedContentPanel />)

		expect(await screen.findByText("This link has expired")).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: /continue to your content/i }),
		).not.toBeInTheDocument()
	})
})
