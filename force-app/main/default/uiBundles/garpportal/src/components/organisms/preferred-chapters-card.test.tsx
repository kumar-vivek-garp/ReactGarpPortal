import { screen, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { AccountView, ChapterOption } from "@/api/account/types"
import { PreferredChaptersCard } from "@/components/organisms/preferred-chapters-card"
import { accountView, completeness } from "@/testing/factories/account"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

const OPTIONS_PATH = "/services/apexrest/memberportal/options"
const PROFILE_PATH = "/services/apexrest/memberportal/profile"

const CHAPTERS: ChapterOption[] = [
	{ id: "ch-1", name: "New York", region: "Americas" },
	{ id: "ch-2", name: "London", region: "EMEA" },
	{ id: "ch-3", name: " ", region: null },
]

type ProfileBody = { values: Record<string, string | null> }

function serveOptions(chapters: ChapterOption[] = CHAPTERS) {
	server.use(
		http.get(OPTIONS_PATH, () =>
			HttpResponse.json(memberPortalEnvelope({ picklists: {}, chapters })),
		),
	)
}

function profileWire() {
	const wire = { bodies: [] as ProfileBody[] }
	server.use(
		http.post(PROFILE_PATH, async ({ request }) => {
			wire.bodies.push((await request.json()) as ProfileBody)
			return HttpResponse.json(
				memberPortalEnvelope({
					applied: [],
					rejected: [],
					completeness: completeness(),
				}),
			)
		}),
	)
	return wire
}

function chapterAccount(
	primary: string | null = null,
	secondary: string | null = null,
): AccountView {
	const account = accountView()
	account.chapters = { primary, secondary }
	return account
}

const primarySelect = () =>
	screen.getByRole("combobox", { name: "Primary Chapter" })
const secondarySelect = () =>
	screen.getByRole("combobox", { name: "Secondary Chapter" })

describe("PreferredChaptersCard — loading the options", () => {
	it("holds a labelled skeleton until the chapter list arrives", async () => {
		server.use(
			http.get(OPTIONS_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope({}))
			}),
		)
		await renderWithRouterProviders(<PreferredChaptersCard account={chapterAccount()} />)

		expect(screen.getByLabelText("Loading chapters")).toBeInTheDocument()
		expect(screen.queryByRole("combobox")).not.toBeInTheDocument()
	})

	it("labels each option with its region and drops blank chapter names", async () => {
		serveOptions()
		const user = userEvent.setup()
		await renderWithRouterProviders(<PreferredChaptersCard account={chapterAccount()} />)

		await user.click(await screen.findByRole("combobox", { name: "Primary Chapter" }))

		const listbox = await screen.findByRole("listbox")
		expect(
			within(listbox).getByRole("option", { name: "New York (Americas)" }),
		).toBeInTheDocument()
		expect(
			within(listbox).getByRole("option", { name: "London (EMEA)" }),
		).toBeInTheDocument()
		// The blank-name row and the explicit none row.
		expect(within(listbox).getAllByRole("option")).toHaveLength(3)
		expect(
			within(listbox).getByRole("option", { name: "Select Chapter" }),
		).toBeInTheDocument()
	})

	it("keeps a saved chapter selectable even when the org list no longer has it", async () => {
		serveOptions()
		await renderWithRouterProviders(
			<PreferredChaptersCard account={chapterAccount("Retired Chapter")} />,
		)

		expect(
			await screen.findByRole("combobox", { name: "Primary Chapter" }),
		).toHaveTextContent("Retired Chapter")
	})
})

describe("PreferredChaptersCard — saving", () => {
	it("saves a primary pick alongside the untouched secondary", async () => {
		serveOptions()
		const wire = profileWire()
		const user = userEvent.setup()
		await renderWithRouterProviders(
			<PreferredChaptersCard account={chapterAccount(null, "London")} />,
		)

		await user.click(
			await screen.findByRole("combobox", { name: "Primary Chapter" }),
		)
		await user.click(
			await screen.findByRole("option", { name: "New York (Americas)" }),
		)

		expect(wire.bodies[0]).toEqual({
			values: {
				KPI_Primary_Chapter_Name__c: "New York",
				KPI_Secondary_Chapter_Name__c: "London",
			},
		})
	})

	it("clearing the secondary posts null for it", async () => {
		serveOptions()
		const wire = profileWire()
		const user = userEvent.setup()
		await renderWithRouterProviders(
			<PreferredChaptersCard account={chapterAccount("New York", "London")} />,
		)

		await user.click(
			await screen.findByRole("combobox", { name: "Secondary Chapter" }),
		)
		await user.click(await screen.findByRole("option", { name: "Select Chapter" }))

		expect(wire.bodies[0]).toEqual({
			values: {
				KPI_Primary_Chapter_Name__c: "New York",
				KPI_Secondary_Chapter_Name__c: null,
			},
		})
	})

	it("locks both selects while the save is in flight", async () => {
		serveOptions()
		server.use(
			http.post(PROFILE_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope({}))
			}),
		)
		const user = userEvent.setup()
		await renderWithRouterProviders(<PreferredChaptersCard account={chapterAccount()} />)

		await user.click(
			await screen.findByRole("combobox", { name: "Primary Chapter" }),
		)
		await user.click(await screen.findByRole("option", { name: "London (EMEA)" }))

		expect(primarySelect()).toBeDisabled()
		expect(secondarySelect()).toBeDisabled()
	})
})
