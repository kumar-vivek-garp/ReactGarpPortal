import { useForm } from "react-hook-form"
import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import type { EventCountry } from "@/api/registration/event-types"
import {
	toEventFormValues,
	type EventFormValues,
} from "@/components/forms/event-registration/event-form-values"
import { AddressSection } from "@/components/forms/event-registration/sections/address-section"
import { chooseSelectOption } from "@/testing/exam-registration-ui"
import { eventCountry } from "@/testing/factories/event"
import { renderWithProviders } from "@/testing/render"

const COUNTRIES: EventCountry[] = [
	eventCountry({
		id: "cty-us",
		name: "United States",
		countryCode: "US",
		provinceRequired: true,
		postalCodeRequired: true,
	}),
	eventCountry({ id: "cty-fr", name: "France", countryCode: "FR" }),
]

/** Owns the react-hook-form instance the way the webcast form does. */
function Harness({ onValid }: { onValid: (values: EventFormValues) => void }) {
	const form = useForm<EventFormValues>({
		defaultValues: toEventFormValues(null),
		mode: "onTouched",
	})
	const findCountry = (value: string) =>
		COUNTRIES.find((country) => country.countryCode === value) ?? null
	return (
		<form noValidate onSubmit={form.handleSubmit(onValid)}>
			<AddressSection
				register={form.register}
				control={form.control}
				errors={form.formState.errors}
				countries={COUNTRIES}
				findCountry={findCountry}
			/>
			<button type="submit">Save</button>
		</form>
	)
}

function renderSection() {
	const onValid = vi.fn()
	const rendered = renderWithProviders(<Harness onValid={onValid} />)
	return { ...rendered, onValid }
}

const save = () => screen.getByRole("button", { name: "Save" })

describe("the country requirement", () => {
	it("refuses to submit without a country", async () => {
		const user = userEvent.setup()
		const { onValid } = renderSection()

		await user.click(save())
		expect(
			await screen.findByText("Please select your country."),
		).toBeInTheDocument()
		expect(onValid).not.toHaveBeenCalled()
	})
})

describe("what the selected country demands", () => {
	it("requires province and postal code when the country's flags say so", async () => {
		const user = userEvent.setup()
		const { onValid } = renderSection()

		await chooseSelectOption(user, "Country", "United States")
		await user.click(save())

		expect(
			await screen.findByText(
				"A state or province is required for this country.",
			),
		).toBeInTheDocument()
		expect(
			screen.getByText("A postal code is required for this country."),
		).toBeInTheDocument()
		expect(onValid).not.toHaveBeenCalled()

		await user.type(screen.getByLabelText(/State \/ Province/), "NJ")
		await user.type(screen.getByLabelText(/Postal code/), "08108")
		await user.click(save())

		await waitFor(() => expect(onValid).toHaveBeenCalledTimes(1))
		expect(onValid.mock.calls[0][0]).toMatchObject({
			country: "US",
			province: "NJ",
			postalCode: "08108",
		})
	})

	it("lets both stay empty for a country without the flags", async () => {
		const user = userEvent.setup()
		const { onValid } = renderSection()

		await chooseSelectOption(user, "Country", "France")
		await user.click(save())

		await waitFor(() => expect(onValid).toHaveBeenCalledTimes(1))
	})

	it("rejects a lettered postal code even where none is required", async () => {
		const user = userEvent.setup()
		const { onValid } = renderSection()

		await chooseSelectOption(user, "Country", "France")
		await user.type(screen.getByLabelText(/Postal code/), "SW1A 1AA")
		await user.click(save())

		expect(
			await screen.findByText("Postal code must be digits only."),
		).toBeInTheDocument()
		expect(onValid).not.toHaveBeenCalled()
	})
})
