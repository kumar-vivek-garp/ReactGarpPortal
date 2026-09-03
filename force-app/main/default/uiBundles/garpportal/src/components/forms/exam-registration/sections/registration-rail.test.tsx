import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import type { FeesResult } from "@/api/registration/exam-types"
import type { SelectableMaterial } from "@/hooks/use-exam-registration"
import { RegistrationRail } from "@/components/forms/exam-registration/sections/registration-rail"
import { feesResult } from "@/testing/factories/exam"
import { renderWithProviders } from "@/testing/render"

function material(
	overrides: Partial<SelectableMaterial> = {},
): SelectableMaterial {
	return {
		productCode: "SM-P1",
		title: "Part I Books",
		price: 295,
		selected: false,
		...overrides,
	}
}

function renderRail({
	materials = [] as SelectableMaterial[],
	fees = null as FeesResult | null,
	isPricing = false,
	disabled = false,
} = {}) {
	const onToggleMaterial = vi.fn()
	renderWithProviders(
		<RegistrationRail
			materials={materials}
			onToggleMaterial={onToggleMaterial}
			fees={fees}
			isPricing={isPricing}
			disabled={disabled}
		/>,
	)
	return { onToggleMaterial }
}

describe("RegistrationRail — the offer list", () => {
	it("prices an offered item and toggles Add ⇄ Remove through the callback", async () => {
		const user = userEvent.setup()
		const { onToggleMaterial } = renderRail({ materials: [material()] })

		expect(screen.getByText("$295.00")).toBeInTheDocument()
		const add = screen.getByRole("button", { name: /Add/ })
		expect(add).toHaveAttribute("aria-pressed", "false")

		await user.click(add)
		expect(onToggleMaterial).toHaveBeenCalledWith("SM-P1")
	})

	it("a selected row's control says Remove — the way back out", () => {
		renderRail({ materials: [material({ selected: true })] })

		expect(
			screen.getByRole("button", { name: /Remove/ }),
		).toHaveAttribute("aria-pressed", "true")
	})

	it("marks owned and unavailable items instead of offering a button", () => {
		renderRail({
			materials: [
				material({ productCode: "SM-OWNED", isOwned: true }),
				material({ productCode: "SM-GONE", isAvailable: false }),
			],
		})

		expect(screen.getByText("Owned")).toBeInTheDocument()
		expect(screen.getByText("Unavailable")).toBeInTheDocument()
		expect(screen.queryByRole("button")).not.toBeInTheDocument()
	})

	it("a selectable comp shows Included with its shipping caveat", () => {
		renderRail({
			materials: [
				material({
					isComp: true,
					isCompSelectable: true,
					isShippable: true,
				}),
			],
		})

		expect(screen.getByText("Included")).toBeInTheDocument()
		expect(screen.getByText(/plus shipping/)).toBeInTheDocument()
		// Selectable, so it still carries the cart control.
		expect(screen.getByRole("button", { name: /Add/ })).toBeInTheDocument()
	})

	it("a non-selectable comp moves to Included with registration, buttonless", () => {
		renderRail({ materials: [material({ isComp: true })] })

		expect(
			screen.getByText("Included with registration"),
		).toBeInTheDocument()
		expect(screen.queryByRole("button")).not.toBeInTheDocument()
	})

	it("disabled freezes the cart control", () => {
		renderRail({ materials: [material()], disabled: true })

		expect(screen.getByRole("button", { name: /Add/ })).toBeDisabled()
	})
})

describe("RegistrationRail — the order summary", () => {
	it("before pricing, placeholder rows keep the shape of the summary to come", () => {
		renderRail()

		expect(
			screen.getByText("Choose your exam to see the total."),
		).toBeInTheDocument()
		for (const label of ["Exam registration", "Enrollment fee", "Total"]) {
			expect(screen.getByText(label)).toBeInTheDocument()
		}
	})

	it("one untaxed line earns no subtotal — the total says it once", () => {
		renderRail({ fees: feesResult(600) })

		expect(screen.getByText("Exam Fee")).toBeInTheDocument()
		expect(screen.queryByText("Subtotal")).not.toBeInTheDocument()
		expect(screen.getByText("Total")).toBeInTheDocument()
	})

	it("taxes bring the subtotal, their own rows, and the VAT label", () => {
		const fees: FeesResult = {
			...feesResult(600),
			subTotal: 600,
			njSalesTax: 39.75,
			vatAmount: 120,
			vatLabel: "UK VAT (20%)",
			total: 759.75,
		}
		renderRail({ fees })

		expect(screen.getByText("Subtotal")).toBeInTheDocument()
		expect(screen.getByText("NJ sales tax")).toBeInTheDocument()
		expect(screen.getByText("UK VAT (20%)")).toBeInTheDocument()
	})

	it("a comp line reads Included rather than printing a zero", () => {
		const fees: FeesResult = {
			lines: [
				{ productCode: "EXAM", name: "Exam Fee", amount: 600, isEnrollment: true },
				{ productCode: "MEM", name: "Individual Membership", amount: 0, isComp: true },
			],
			subTotal: 600,
			total: 600,
			currencyCode: "USD",
			hasBilling: true,
		}
		renderRail({ fees })

		expect(screen.getByText("Individual Membership")).toBeInTheDocument()
		expect(screen.getByText("Included")).toBeInTheDocument()
	})

	it("announces re-pricing over an existing summary, not over nothing", () => {
		renderRail({ fees: feesResult(600), isPricing: true })

		expect(screen.getByText("Updating…")).toBeInTheDocument()
	})

	it("stays quiet about re-pricing before any summary exists", () => {
		renderRail({ isPricing: true })

		expect(screen.queryByText("Updating…")).not.toBeInTheDocument()
	})
})
