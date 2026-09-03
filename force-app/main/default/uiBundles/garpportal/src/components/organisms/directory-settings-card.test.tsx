import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { delay, http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import type { AccountView } from "@/api/account/types"
import { DirectorySettingsCard } from "@/components/organisms/directory-settings-card"
import { accountView, completeness } from "@/testing/factories/account"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"
import { renderWithProviders } from "@/testing/render"

const PROFILE_PATH = "/services/apexrest/memberportal/profile"

type ProfileBody = { values: Record<string, boolean> }

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

function optedInAccount(): AccountView {
	const account = accountView()
	account.directory = {
		optedIn: true,
		connectFeature: true,
		showJobInformation: false,
		showProfessionalBackground: true,
		showAdditionalDetail: false,
	}
	return account
}

const optIn = () =>
	screen.getByRole("checkbox", { name: "Member directory opt-in" })
const orgExpertise = () =>
	screen.getByRole("checkbox", { name: "Show my organization type & expertise" })
const jobCompany = () =>
	screen.getByRole("checkbox", { name: "Show my job title and company" })
const connect = () =>
	screen.getByRole("checkbox", { name: "Allow other members to contact me" })

describe("DirectorySettingsCard — reading the flags", () => {
	it("keeps the privacy flags visually off while the member is opted out", () => {
		const account = accountView()
		account.directory = {
			optedIn: false,
			// Stale truthy flags on the record must not read as on while opted out.
			connectFeature: true,
			showJobInformation: true,
			showProfessionalBackground: true,
			showAdditionalDetail: true,
		}
		renderWithProviders(<DirectorySettingsCard account={account} />)

		expect(optIn()).not.toBeChecked()
		expect(orgExpertise()).not.toBeChecked()
		expect(orgExpertise()).toBeDisabled()
		expect(jobCompany()).toBeDisabled()
		expect(connect()).toBeDisabled()
	})

	it("shows each dependent flag once opted in", () => {
		renderWithProviders(<DirectorySettingsCard account={optedInAccount()} />)

		expect(optIn()).toBeChecked()
		expect(orgExpertise()).not.toBeChecked()
		expect(jobCompany()).toBeChecked()
		expect(connect()).toBeChecked()
		expect(orgExpertise()).toBeEnabled()
	})
})

describe("DirectorySettingsCard — saving", () => {
	it("opting in posts all five fields, keeping the others off", async () => {
		const wire = profileWire()
		const user = userEvent.setup()
		const account = accountView() // optedIn null = off
		renderWithProviders(<DirectorySettingsCard account={account} />)

		await user.click(optIn())

		expect(wire.bodies[0]).toEqual({
			values: {
				GARP_Directory_Opt_In__c: true,
				GARP_Dir_Privacy_Job_Information__c: false,
				GARP_Dir_Privacy_Prof_Background__c: false,
				GARP_Directory_Connect_Feature__c: false,
				GARP_Dir_Privacy_Additional_Detail__c: false,
			},
		})
	})

	it("opting out forces every dependent flag off in the same save", async () => {
		const wire = profileWire()
		const user = userEvent.setup()
		renderWithProviders(<DirectorySettingsCard account={optedInAccount()} />)

		await user.click(optIn())

		expect(wire.bodies[0]).toEqual({
			values: {
				GARP_Directory_Opt_In__c: false,
				GARP_Dir_Privacy_Job_Information__c: false,
				GARP_Dir_Privacy_Prof_Background__c: false,
				GARP_Directory_Connect_Feature__c: false,
				GARP_Dir_Privacy_Additional_Detail__c: false,
			},
		})
	})

	it("toggling one dependent flag preserves the others as they stand", async () => {
		const wire = profileWire()
		const user = userEvent.setup()
		renderWithProviders(<DirectorySettingsCard account={optedInAccount()} />)

		await user.click(orgExpertise())

		expect(wire.bodies[0]).toEqual({
			values: {
				GARP_Directory_Opt_In__c: true,
				GARP_Dir_Privacy_Job_Information__c: true,
				GARP_Dir_Privacy_Prof_Background__c: true,
				GARP_Directory_Connect_Feature__c: true,
				GARP_Dir_Privacy_Additional_Detail__c: false,
			},
		})
	})

	it("locks every control while a save is in flight", async () => {
		server.use(
			http.post(PROFILE_PATH, async () => {
				await delay("infinite")
				return HttpResponse.json(memberPortalEnvelope({}))
			}),
		)
		const user = userEvent.setup()
		renderWithProviders(<DirectorySettingsCard account={optedInAccount()} />)

		await user.click(connect())

		expect(optIn()).toBeDisabled()
		expect(orgExpertise()).toBeDisabled()
		expect(connect()).toBeDisabled()
	})
})
