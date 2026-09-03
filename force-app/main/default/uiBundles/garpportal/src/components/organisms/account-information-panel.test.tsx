import { screen, waitFor, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { AccountView } from "@/api/account/types"
import { personalInfoQueryKeys } from "@/api/personal-info/query-options"
import type { CountryOption } from "@/api/personal-info/types"
import { AccountInformationPanel } from "@/components/organisms/account-information-panel"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { accountView, completeness } from "@/testing/factories/account"
import { personalInfoEditData } from "@/testing/factories/personal-info"
import { server } from "@/testing/msw/server"
import { createTestQueryClient } from "@/testing/query-client"
import { renderWithRouterProviders } from "@/testing/router"

const OPTIONS_PATH = "/services/apexrest/memberportal/options"
const EXPERTISE_PATH = "/services/apexrest/memberportal/expertise"

const COUNTRIES: CountryOption[] = [
	{ label: "United States", value: "United States", phoneCode: "+1" },
]

/** The two queries the always-mounted cards fire on panel mount. */
function registerCardHandlers() {
	server.use(
		http.get(OPTIONS_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({ picklists: {}, chapters: [] }),
			),
		),
		http.get(EXPERTISE_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope({
					statusMessage: null,
					statusCode: 200,
					values: {},
					options: {},
					labels: {},
				}),
			),
		),
	)
}

async function renderPanel(account: AccountView = accountView()) {
	registerCardHandlers()
	const queryClient = createTestQueryClient()
	// The Personal dialog seeds from personal-info + countries; pre-cached so
	// opening it does not need the GraphQL transport.
	queryClient.setQueryData(
		personalInfoQueryKeys.edit(account.identity.contactId ?? ""),
		personalInfoEditData({ contactId: account.identity.contactId ?? "" }),
	)
	queryClient.setQueryData(personalInfoQueryKeys.countries, COUNTRIES)
	return renderWithRouterProviders(
		<AccountInformationPanel account={account} />,
		{ queryClient },
	)
}

function careerCard() {
	const card = document.getElementById("account-section-career")
	if (!card) throw new Error("career card not rendered")
	return within(card as HTMLElement)
}

describe("AccountInformationPanel — sections", () => {
	it("renders the hero and all six section cards", async () => {
		await renderPanel()

		expect(
			screen.getByRole("button", { name: "Edit Profile" }),
		).toBeInTheDocument()
		for (const label of [
			"Personal Information",
			"Career Information",
			"Membership",
			"Preferred Chapters",
			"Directory Settings",
			"Expertise",
		]) {
			expect(screen.getByText(label)).toBeInTheDocument()
		}
		// Empty addresses degrade to their empty sentences, no Other block.
		expect(
			screen.getByText("No mailing address on file."),
		).toBeInTheDocument()
		expect(
			screen.getByText("No billing address on file."),
		).toBeInTheDocument()
		expect(screen.queryByText("Other Address")).not.toBeInTheDocument()
	})

	it("shows held designations, including the annotated Other", async () => {
		const account = accountView()
		account.designations = {
			...account.designations,
			CFA: true,
			PMP: true,
			Other: true,
			otherQualifications: "PRM",
		}

		await renderPanel(account)

		expect(screen.getByText("CFA, PMP, Other (PRM)")).toBeInTheDocument()
	})

	it("badges the career card with the completeness shortfall", async () => {
		const account = accountView({
			completeness: completeness({
				isComplete: false,
				percentComplete: 80,
				missing: ["Job function", "School name"],
			}),
		})

		await renderPanel(account)

		expect(careerCard().getByText("2 left")).toBeInTheDocument()
	})
})

describe("AccountInformationPanel — edit dialogs", () => {
	it("opens the Personal dialog from the hero, seeded from personal-info", async () => {
		const user = userEvent.setup()
		await renderPanel()

		await user.click(screen.getByRole("button", { name: "Edit Profile" }))

		const dialog = await screen.findByRole("dialog", {
			name: "Edit Personal Information",
		})
		expect(
			await within(dialog).findByLabelText("First name"),
		).toHaveValue("Ada")
	})

	it("opens the Career dialog focused on the field behind an Add row", async () => {
		const user = userEvent.setup()
		await renderPanel()

		await user.click(
			careerCard().getByRole("button", { name: "Add Job Function" }),
		)

		await screen.findByRole("dialog", { name: "Edit Career Information" })
		// Focus lands only after the picklists arrive, beating Radix's own
		// dialog autofocus — that ordering is the behavior under test.
		await waitFor(() => {
			expect(document.activeElement?.id).toMatch(/-jobFunction$/)
		})
	})

	it("opens the Career dialog focused from a completeness chip", async () => {
		const account = accountView({
			completeness: completeness({
				isComplete: false,
				percentComplete: 80,
				missing: ["Job function"],
			}),
		})
		const user = userEvent.setup()
		await renderPanel(account)

		await user.click(screen.getByRole("button", { name: "Job function" }))

		await screen.findByRole("dialog", { name: "Edit Career Information" })
		await waitFor(() => {
			expect(document.activeElement?.id).toMatch(/-jobFunction$/)
		})
	})

	it("drops the focus target once the dialog closes — a plain Edit reopens unfocused", async () => {
		const user = userEvent.setup()
		await renderPanel()

		await user.click(
			careerCard().getByRole("button", { name: "Add Job Function" }),
		)
		const dialog = await screen.findByRole("dialog", {
			name: "Edit Career Information",
		})
		await waitFor(() => {
			expect(document.activeElement?.id).toMatch(/-jobFunction$/)
		})

		await user.click(within(dialog).getByRole("button", { name: "Close" }))
		await waitFor(() => {
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
		})

		await user.click(careerCard().getByRole("button", { name: "Edit" }))
		await screen.findByRole("dialog", { name: "Edit Career Information" })
		// Give the (now absent) focus effect the same window it had before.
		await waitFor(() => {
			expect(screen.getByRole("dialog")).toBeInTheDocument()
		})
		expect(document.activeElement?.id ?? "").not.toMatch(/-jobFunction$/)
	})

	it("never offers Add on rows the dialog cannot edit", async () => {
		await renderPanel()

		// Company City / Country have no editor; designations are display-only.
		expect(
			careerCard().queryByRole("button", { name: "Add Company City" }),
		).not.toBeInTheDocument()
		expect(
			careerCard().queryByRole("button", { name: "Add Company Country" }),
		).not.toBeInTheDocument()
		expect(
			careerCard().queryByRole("button", {
				name: "Add Professional designations",
			}),
		).not.toBeInTheDocument()
	})
})
