import { useState } from "react"
import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import type { PicklistOption } from "@/api/account/types"
import {
	DirectoryFiltersDialog,
	EMPTY_DIRECTORY_FILTERS,
	type DirectoryFilterState,
} from "@/components/molecules/directory-filters-dialog"
import { renderWithProviders } from "@/testing/render"

const PICKLISTS: Record<string, PicklistOption[]> = {
	Area_of_Concentration__c: [
		{ label: "Banking", value: "Banking" },
		{ label: "Insurance", value: "Insurance" },
	],
	Job_Function__c: [{ label: "Analyst", value: "Analyst" }],
	Risk_Specialty__c: [],
	Corporate_Title__c: [],
}

/**
 * Owns the committed value the way the panel does, so the draft-vs-committed
 * contract — Cancel/close discards, Apply commits, reopen re-seeds from the
 * filters in effect — is observable through reopening.
 */
function Harness({
	picklists,
	onApplied,
	initial = EMPTY_DIRECTORY_FILTERS,
}: {
	picklists?: Record<string, PicklistOption[]>
	onApplied: (next: DirectoryFilterState) => void
	initial?: DirectoryFilterState
}) {
	const [open, setOpen] = useState(false)
	const [value, setValue] = useState(initial)
	return (
		<>
			<button type="button" onClick={() => setOpen(true)}>
				Open filters
			</button>
			<DirectoryFiltersDialog
				open={open}
				onOpenChange={setOpen}
				value={value}
				onApply={(next) => {
					onApplied(next)
					setValue(next)
				}}
				picklists={picklists}
			/>
		</>
	)
}

function renderDialog(options: {
	picklists?: Record<string, PicklistOption[]>
	initial?: DirectoryFilterState
} = {}) {
	const onApplied = vi.fn()
	renderWithProviders(<Harness onApplied={onApplied} {...options} />)
	return { onApplied }
}

async function openDialog(user: ReturnType<typeof userEvent.setup>) {
	await user.click(screen.getByRole("button", { name: "Open filters" }))
	return await screen.findByRole("dialog")
}

const cert = (code: string) => screen.getByRole("checkbox", { name: code })
const companyBox = () => screen.getByRole("textbox", { name: "Company" })
const showResults = () => screen.getByRole("button", { name: "Show results" })

describe("rendering", () => {
	it("shows certifications always, and only the picklist groups with options", async () => {
		const user = userEvent.setup()
		renderDialog({ picklists: PICKLISTS })
		await openDialog(user)

		expect(screen.getByRole("group", { name: "Certification" })).toBeInTheDocument()
		expect(screen.getByRole("group", { name: "Industry" })).toBeInTheDocument()
		expect(screen.getByRole("group", { name: "Job function" })).toBeInTheDocument()
		// Empty picklists render no group at all.
		expect(screen.queryByRole("group", { name: "Risk specialty" })).not.toBeInTheDocument()
		expect(screen.queryByRole("group", { name: "Professional level" })).not.toBeInTheDocument()

		for (const code of ["FRM", "ERP", "SCR", "RAI"]) {
			expect(cert(code)).not.toBeChecked()
		}
		expect(screen.getByRole("checkbox", { name: "Banking" })).toBeInTheDocument()
	})

	it("renders no picklist groups while the picklists are still undefined", async () => {
		const user = userEvent.setup()
		renderDialog()
		await openDialog(user)

		expect(screen.getByRole("group", { name: "Certification" })).toBeInTheDocument()
		expect(screen.queryByRole("group", { name: "Industry" })).not.toBeInTheDocument()
	})
})

describe("draft semantics", () => {
	it("keeps edits in the draft until Show results commits them and closes", async () => {
		const user = userEvent.setup()
		const { onApplied } = renderDialog({ picklists: PICKLISTS })
		await openDialog(user)

		await user.click(cert("FRM"))
		await user.click(screen.getByRole("checkbox", { name: "Banking" }))
		await user.type(companyBox(), "Acme")
		expect(onApplied).not.toHaveBeenCalled()

		await user.click(showResults())
		expect(onApplied).toHaveBeenCalledTimes(1)
		expect(onApplied).toHaveBeenCalledWith({
			company: "Acme",
			certifications: ["FRM"],
			values: {
				industries: ["Banking"],
				jobFunctions: [],
				riskSpecialties: [],
				corporateTitles: [],
			},
		})
		await waitFor(() => {
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
		})

		// Reopening starts from the filters now in effect.
		await openDialog(user)
		expect(cert("FRM")).toBeChecked()
		expect(companyBox()).toHaveValue("Acme")
	})

	it("toggling a ticked option off removes it from the draft", async () => {
		const user = userEvent.setup()
		const { onApplied } = renderDialog({ picklists: PICKLISTS })
		await openDialog(user)

		await user.click(cert("FRM"))
		await user.click(cert("ERP"))
		await user.click(cert("FRM"))
		await user.click(screen.getByRole("checkbox", { name: "Banking" }))
		await user.click(screen.getByRole("checkbox", { name: "Insurance" }))
		await user.click(screen.getByRole("checkbox", { name: "Banking" }))
		await user.click(showResults())

		expect(onApplied).toHaveBeenCalledWith(
			expect.objectContaining({
				certifications: ["ERP"],
				values: expect.objectContaining({ industries: ["Insurance"] }),
			}),
		)
	})

	it("Cancel discards the draft — reopening shows the committed values", async () => {
		const user = userEvent.setup()
		const { onApplied } = renderDialog({ picklists: PICKLISTS })
		await openDialog(user)

		await user.click(cert("FRM"))
		await user.type(companyBox(), "Acme")
		await user.click(screen.getByRole("button", { name: "Cancel" }))

		expect(onApplied).not.toHaveBeenCalled()
		await waitFor(() => {
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
		})

		await openDialog(user)
		expect(cert("FRM")).not.toBeChecked()
		expect(companyBox()).toHaveValue("")
	})

	it("closing with the X discards the draft too", async () => {
		const user = userEvent.setup()
		const { onApplied } = renderDialog({ picklists: PICKLISTS })
		await openDialog(user)

		await user.click(cert("SCR"))
		await user.click(screen.getByRole("button", { name: "Close" }))

		expect(onApplied).not.toHaveBeenCalled()
		await waitFor(() => {
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
		})
		await openDialog(user)
		expect(cert("SCR")).not.toBeChecked()
	})
})

describe("Clear all", () => {
	const committed: DirectoryFilterState = {
		company: "Acme",
		certifications: ["FRM"],
		values: {
			industries: ["Banking"],
			jobFunctions: [],
			riskSpecialties: [],
			corporateTitles: [],
		},
	}

	it("resets the draft only — abandoning it leaves the committed filters intact", async () => {
		const user = userEvent.setup()
		const { onApplied } = renderDialog({ picklists: PICKLISTS, initial: committed })
		await openDialog(user)

		expect(cert("FRM")).toBeChecked()
		await user.click(screen.getByRole("button", { name: "Clear all" }))
		expect(cert("FRM")).not.toBeChecked()
		expect(companyBox()).toHaveValue("")
		expect(onApplied).not.toHaveBeenCalled()

		await user.click(screen.getByRole("button", { name: "Cancel" }))
		await waitFor(() => {
			expect(screen.queryByRole("dialog")).not.toBeInTheDocument()
		})
		await openDialog(user)
		expect(cert("FRM")).toBeChecked()
		expect(companyBox()).toHaveValue("Acme")
	})

	it("commits the emptied filters once applied", async () => {
		const user = userEvent.setup()
		const { onApplied } = renderDialog({ picklists: PICKLISTS, initial: committed })
		await openDialog(user)

		await user.click(screen.getByRole("button", { name: "Clear all" }))
		await user.click(showResults())

		expect(onApplied).toHaveBeenCalledWith(EMPTY_DIRECTORY_FILTERS)
	})
})
