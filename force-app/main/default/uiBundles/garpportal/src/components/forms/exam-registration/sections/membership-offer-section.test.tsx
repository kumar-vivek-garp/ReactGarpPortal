import { useEffect } from "react"
import { useForm, useWatch } from "react-hook-form"
import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import {
	EMPTY_EXAM_FORM_VALUES,
	type ExamFormValues,
} from "@/components/forms/exam-registration/exam-form-values"
import { MembershipOfferSection } from "@/components/forms/exam-registration/sections/membership-offer-section"
import { renderWithProviders } from "@/testing/render"

/** Owns the react-hook-form instance the way the exam form does. */
function Harness({
	amount,
	disabled,
	onChange,
}: {
	amount?: number
	disabled?: boolean
	onChange?: (selected: boolean) => void
}) {
	const form = useForm<ExamFormValues>({
		defaultValues: EMPTY_EXAM_FORM_VALUES,
	})
	// Surfaces the form value so assertions read state, not implementation.
	const selected = useWatch({
		control: form.control,
		name: "membershipSelected",
	})
	useEffect(() => {
		onChange?.(selected === true)
	}, [selected, onChange])
	return (
		<MembershipOfferSection
			control={form.control}
			amount={amount}
			disabled={disabled}
		/>
	)
}

const cartButton = () =>
	screen.getByRole("button", { name: /Add|Remove/ })

describe("the cart control", () => {
	it("toggles Add ⇄ Remove and writes the form value", async () => {
		const user = userEvent.setup()
		const onChange = vi.fn()
		renderWithProviders(<Harness amount={100} onChange={onChange} />)

		const button = cartButton()
		expect(button).toHaveTextContent("Add")
		expect(button).toHaveAttribute("aria-pressed", "false")

		await user.click(button)
		expect(button).toHaveTextContent("Remove")
		expect(button).toHaveAttribute("aria-pressed", "true")
		expect(onChange).toHaveBeenLastCalledWith(true)

		await user.click(button)
		expect(button).toHaveTextContent("Add")
		expect(button).toHaveAttribute("aria-pressed", "false")
		expect(onChange).toHaveBeenLastCalledWith(false)
	})

	it("stays inert while disabled", async () => {
		const user = userEvent.setup()
		const onChange = vi.fn()
		renderWithProviders(<Harness amount={100} disabled onChange={onChange} />)

		expect(cartButton()).toBeDisabled()
		await user.click(cartButton())
		expect(onChange).not.toHaveBeenCalledWith(true)
	})
})

describe("the price line", () => {
	it("shows the server-priced amount", () => {
		renderWithProviders(<Harness amount={100} />)
		expect(
			screen.getByText((text) => text.includes("$100.00")),
		).toBeInTheDocument()
	})

	it("shows a placeholder while the offer is unpriced", () => {
		renderWithProviders(<Harness />)
		expect(screen.getByText((text) => text.includes("—"))).toBeInTheDocument()
	})
})
