import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import type { ExamAdminView } from "@/api/registration/exam-types"
import { YourExamSection } from "@/components/forms/exam-registration/sections/your-exam-section"
import { renderWithProviders } from "@/testing/render"

const may = (overrides: Partial<ExamAdminView> = {}): ExamAdminView => ({
	id: "rate-1a",
	adminId: "adm-1a",
	name: "May 2027",
	amount: 600,
	priceWindow: "Early",
	examDates: "May 8 - 14, 2027",
	examStartEpoch: 100,
	sites: [
		{ id: "site-a1", name: "Boston" },
		{ id: "site-a2", name: "Chicago" },
	],
	...overrides,
})

const november = (): ExamAdminView =>
	may({
		id: "rate-1b",
		adminId: "adm-1b",
		name: "November 2027",
		priceWindow: "Standard",
		examDates: "November 14 - 20, 2027",
		examStartEpoch: 200,
		sites: [{ id: "site-b1", name: "London" }],
	})

type SectionProps = Parameters<typeof YourExamSection>[0]

function renderSection(overrides: Partial<SectionProps> = {}) {
	const onSelectPart = vi.fn()
	const onSelectAdmin = vi.fn()
	const onSelectSite = vi.fn()
	renderWithProviders(
		<YourExamSection
			partsAvailable={["FRM Exam Part I"]}
			partSelected="FRM Exam Part I"
			onSelectPart={onSelectPart}
			part1Title="FRM Exam Part I"
			part2Title="FRM Exam Part II"
			part1Admins={[may(), november()]}
			part2Admins={[]}
			selection={{ part1: { rateId: "", siteId: "" }, part2: { rateId: "", siteId: "" } }}
			part1Active
			part2Active={false}
			onSelectAdmin={onSelectAdmin}
			onSelectSite={onSelectSite}
			outOfOrder={false}
			{...overrides}
		/>,
	)
	return { onSelectPart, onSelectAdmin, onSelectSite }
}

describe("YourExamSection — the part chooser", () => {
	it("offers a select only when there is a real choice of parts", async () => {
		const user = userEvent.setup()
		const { onSelectPart } = renderSection({
			partsAvailable: ["FRM Exam Part I", "FRM Exam Part II"],
			partSelected: "",
			part1Active: false,
		})

		await user.click(screen.getByRole("combobox", { name: /Exam part/ }))
		await user.click(
			await screen.findByRole("option", { name: "FRM Exam Part II" }),
		)

		expect(onSelectPart).toHaveBeenCalledWith("FRM Exam Part II")
	})

	it("a single-part programme states nothing twice — no select at all", () => {
		renderSection()

		expect(screen.queryByRole("combobox", { name: /Exam part/ })).toBeNull()
	})

	it("says so when no exams are on offer at all", () => {
		renderSection({
			partsAvailable: [],
			partSelected: "",
			part1Admins: [],
			part1Active: false,
		})

		expect(screen.getByText("No exams available")).toBeInTheDocument()
	})

	it("warns about travel when both parts are being sat together", () => {
		renderSection({
			partsAvailable: ["FRM Exam Part I and FRM Exam Part II"],
			partSelected: "FRM Exam Part I and FRM Exam Part II",
			part2Admins: [may({ id: "rate-2a", sites: [{ id: "s", name: "Paris" }] })],
			part2Active: true,
		})

		expect(screen.getByRole("note")).toHaveTextContent(
			/plan for travel between centres/,
		)
	})
})

describe("YourExamSection — sittings inside a part", () => {
	it("multiple sittings become radios labelled with window and price", () => {
		renderSection()

		const early = /May 8 - 14, 2027.*Early registration · \$600\.00/
		expect(screen.getByRole("radio", { name: early })).toBeInTheDocument()
		expect(
			screen.getByRole("radio", { name: /November 14 - 20, 2027/ }),
		).toBeInTheDocument()
	})

	it("picking a sitting reports the rate id upward", async () => {
		const user = userEvent.setup()
		const { onSelectAdmin } = renderSection()

		await user.click(screen.getByRole("radio", { name: /November 14 - 20/ }))

		expect(onSelectAdmin).toHaveBeenCalledWith(1, "rate-1b")
	})

	it("a lone sitting is stated as fact, not asked as a question", () => {
		renderSection({ part1Admins: [may()] })

		expect(screen.queryByRole("radio")).not.toBeInTheDocument()
		expect(screen.getByText("May 8 - 14, 2027")).toBeInTheDocument()
		expect(screen.getByText(/Early registration · \$600\.00/)).toBeInTheDocument()
	})

	it("an unpriced, unnamed sitting degrades to the generic label, no amount", () => {
		renderSection({
			part1Admins: [may({ amount: null, examDates: null, name: null })],
		})

		expect(screen.getByText("Exam sitting")).toBeInTheDocument()
		expect(screen.getByText("Early registration")).toBeInTheDocument()
		expect(screen.queryByText(/\$/)).not.toBeInTheDocument()
	})

	it("flags Part II selected out of order, on Part II only", () => {
		renderSection({
			partsAvailable: ["FRM Exam Part I and FRM Exam Part II"],
			partSelected: "FRM Exam Part I and FRM Exam Part II",
			part2Admins: [may({ id: "rate-2a" })],
			part2Active: true,
			outOfOrder: true,
		})

		expect(
			screen.getAllByText("Part II cannot be taken before Part I."),
		).toHaveLength(1)
	})
})

describe("YourExamSection — exam centres for the chosen sitting", () => {
	it("no centre list until a sitting is chosen", () => {
		renderSection()

		expect(screen.queryByText(/Where you will sit/)).not.toBeInTheDocument()
	})

	it("several centres become a select that reports the site upward", async () => {
		const user = userEvent.setup()
		const { onSelectSite } = renderSection({
			selection: { part1: { rateId: "rate-1a", siteId: "" }, part2: { rateId: "", siteId: "" } },
		})

		await user.click(screen.getByRole("combobox", { name: /Where you will sit/ }))
		await user.click(await screen.findByRole("option", { name: "Chicago" }))

		expect(onSelectSite).toHaveBeenCalledWith(1, "site-a2")
	})

	it("a lone centre is stated, and no OSTA notice for a non-OSTA site", () => {
		renderSection({
			part1Admins: [may({ sites: [{ id: "site-b1", name: "London" }] })],
			selection: { part1: { rateId: "rate-1a", siteId: "site-b1" }, part2: { rateId: "", siteId: "" } },
		})

		expect(screen.getByText("London")).toBeInTheDocument()
		expect(screen.queryByRole("combobox")).not.toBeInTheDocument()
		expect(screen.queryByRole("note")).not.toBeInTheDocument()
	})

	it("an OSTA centre brings up the exam-language notice", () => {
		renderSection({
			part1Admins: [
				may({ sites: [{ id: "site-cn", name: "Shanghai", isOSTA: true }] }),
			],
			selection: { part1: { rateId: "rate-1a", siteId: "site-cn" }, part2: { rateId: "", siteId: "" } },
		})

		expect(screen.getByRole("note")).toHaveTextContent(
			/Simplified Chinese or American English/,
		)
	})

	it("Part II routes its own picks upward as part 2, not part 1", async () => {
		const user = userEvent.setup()
		const { onSelectAdmin, onSelectSite } = renderSection({
			partsAvailable: ["FRM Exam Part I and FRM Exam Part II"],
			partSelected: "FRM Exam Part I and FRM Exam Part II",
			part1Admins: [may()],
			part2Admins: [
				may({ id: "rate-2a", examDates: "May 15 - 21, 2027" }),
				may({ id: "rate-2b", examDates: "November 21 - 27, 2027" }),
			],
			part2Active: true,
			selection: { part1: { rateId: "rate-1a", siteId: "" }, part2: { rateId: "rate-2a", siteId: "" } },
		})

		await user.click(
			screen.getByRole("radio", { name: /November 21 - 27, 2027/ }),
		)
		expect(onSelectAdmin).toHaveBeenCalledWith(2, "rate-2b")

		// Two site selects are up (one per part); the second belongs to Part II.
		const siteSelects = screen.getAllByRole("combobox", {
			name: /Where you will sit/,
		})
		await user.click(siteSelects[1])
		await user.click(await screen.findByRole("option", { name: "Chicago" }))
		expect(onSelectSite).toHaveBeenCalledWith(2, "site-a2")
	})

	it("admits when a sitting has no centres at all", () => {
		renderSection({
			part1Admins: [may({ sites: [] })],
			selection: { part1: { rateId: "rate-1a", siteId: "" }, part2: { rateId: "", siteId: "" } },
		})

		expect(screen.getByText("No exam centres available")).toBeInTheDocument()
	})
})
