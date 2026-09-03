import { useForm, useWatch } from "react-hook-form"
import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import type { RegistrationCountry } from "@/api/registration/exam-types"
import {
	EMPTY_EXAM_FORM_VALUES,
	type ExamFormValues,
} from "@/components/forms/exam-registration/exam-form-values"
import { PaymentSection } from "@/components/forms/exam-registration/sections/payment-section"
import { renderWithProviders } from "@/testing/render"

function country(
	overrides: Partial<RegistrationCountry> = {},
): RegistrationCountry {
	return {
		id: "cc-us",
		name: "United States",
		countryCode: "United States",
		phoneCode: "1",
		creditCardAllowed: true,
		wireAllowed: true,
		achAllowed: true,
		...overrides,
	}
}

/** Owns the react-hook-form instance the way the exam form does. */
function Harness({
	country: billingCountry = country(),
	useStripe = true,
	showAutorenew = false,
	disabled,
}: {
	country?: RegistrationCountry | null
	useStripe?: boolean
	showAutorenew?: boolean
	disabled?: boolean
}) {
	const form = useForm<ExamFormValues>({
		defaultValues: EMPTY_EXAM_FORM_VALUES,
	})
	const paymentType = useWatch({
		control: form.control,
		name: "paymentType",
	})
	const autoRenew = useWatch({ control: form.control, name: "autoRenew" })

	return (
		<>
			<PaymentSection
				control={form.control}
				errors={form.formState.errors}
				country={billingCountry}
				useStripe={useStripe}
				paymentType={paymentType}
				showAutorenew={showAutorenew}
				disabled={disabled}
			/>
			<output aria-label="observed">{`${paymentType}|${autoRenew}`}</output>
		</>
	)
}

const tile = (name: RegExp | string) => screen.getByRole("radio", { name })
const observed = () => screen.getByLabelText("observed").textContent

describe("PaymentSection — what the country permits", () => {
	it("offers every method a permissive country allows", () => {
		renderWithProviders(<Harness />)

		expect(tile(/^Card$/)).toBeEnabled()
		expect(tile(/Wire transfer/)).toBeEnabled()
		expect(tile(/^ACH$/)).toBeEnabled()
		expect(screen.queryByText("Not available here")).not.toBeInTheDocument()
	})

	it("shows a forbidden method disabled and explained, not hidden", () => {
		renderWithProviders(
			<Harness
				country={country({ wireAllowed: false, achAllowed: false })}
			/>,
		)

		expect(tile(/^Card$/)).toBeEnabled()
		expect(tile(/Wire transfer.*Not available here/)).toBeDisabled()
		expect(tile(/ACH.*Not available here/)).toBeDisabled()
	})

	it("the org's Stripe switch turns the card tile off even where cards are legal", () => {
		renderWithProviders(<Harness useStripe={false} />)

		expect(tile(/Card.*Not available here/)).toBeDisabled()
		expect(tile(/Wire transfer/)).toBeEnabled()
	})

	it("with no billing country yet, offline methods stay open", () => {
		renderWithProviders(<Harness country={null} />)

		expect(tile(/^Card$/)).toBeEnabled()
		expect(tile(/Wire transfer/)).toBeEnabled()
		expect(tile(/^ACH$/)).toBeEnabled()
	})

	it("disabled locks every tile regardless of the country", () => {
		renderWithProviders(<Harness disabled />)

		expect(tile(/^Card$/)).toBeDisabled()
		expect(tile(/Wire transfer/)).toBeDisabled()
	})
})

describe("PaymentSection — choosing and its consequences", () => {
	it("selecting a tile writes the form value and checks it", async () => {
		const user = userEvent.setup()
		renderWithProviders(<Harness />)

		await user.click(tile(/^Card$/))

		expect(tile(/^Card$/)).toHaveAttribute("aria-checked", "true")
		expect(observed()).toContain("Stripe|")
	})

	it("an offline method surfaces the wire/ACH instructions and fee notice", async () => {
		const user = userEvent.setup()
		renderWithProviders(<Harness />)

		expect(screen.queryByRole("note")).not.toBeInTheDocument()
		await user.click(tile(/Wire transfer/))

		const note = screen.getByRole("note")
		expect(note).toHaveTextContent(/USD 50 fee/)
		expect(note).toHaveTextContent(/paying by wire or ACH/)
	})

	it("card shows the checkout hand-off notice instead", async () => {
		const user = userEvent.setup()
		renderWithProviders(<Harness />)

		await user.click(tile(/^Card$/))

		expect(
			screen.getByText(/taken to our payment provider/),
		).toBeInTheDocument()
		expect(screen.queryByRole("note")).not.toBeInTheDocument()
	})
})

describe("PaymentSection — the auto-renew opt-in", () => {
	it("appears only when offered, and writes the form value when ticked", async () => {
		const user = userEvent.setup()
		renderWithProviders(<Harness showAutorenew />)

		const consent = screen.getByRole("checkbox", {
			name: /Membership Automatic Renewal/,
		})
		expect(consent).not.toBeChecked()

		await user.click(consent)
		expect(consent).toBeChecked()
		expect(observed()).toContain("|true")

		await user.click(consent)
		expect(observed()).toContain("|false")
	})

	it("is absent when the order carries no complimentary membership", () => {
		renderWithProviders(<Harness />)

		expect(screen.queryByRole("checkbox")).not.toBeInTheDocument()
	})
})
