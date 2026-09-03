import { useForm, useWatch } from "react-hook-form"
import { screen, waitFor } from "@testing-library/react"
import userEvent, { type UserEvent } from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import {
	EMPTY_EXAM_FORM_VALUES,
	type ExamFormValues,
} from "@/components/forms/exam-registration/exam-form-values"
import { OstaSection } from "@/components/forms/exam-registration/sections/osta-section"
import { chooseSelectOption } from "@/testing/exam-registration-ui"
import { renderWithProviders } from "@/testing/render"

/**
 * Every rule protecting this data lives in the client — Apex validates none
 * of it (see the section's own doc comment) — so the validation wiring IS the
 * behavior under test here. The format rules themselves are unit-tested in
 * `lib/registration-presentation.test.ts`.
 */
function Harness({ onValid }: { onValid: (values: ExamFormValues) => void }) {
	const form = useForm<ExamFormValues>({
		defaultValues: EMPTY_EXAM_FORM_VALUES,
		mode: "onTouched",
	})
	const idType = useWatch({ control: form.control, name: "osta.idType" })
	const workStatus = useWatch({ control: form.control, name: "osta.workStatus" })
	const studentStatus = useWatch({
		control: form.control,
		name: "osta.studentStatus",
	})
	return (
		<form noValidate onSubmit={form.handleSubmit(onValid)}>
			<OstaSection
				register={form.register}
				control={form.control}
				errors={form.formState.errors}
				getValues={form.getValues}
				idType={idType}
				workStatus={workStatus}
				studentStatus={studentStatus}
			/>
			<button type="submit">Register</button>
		</form>
	)
}

function renderSection() {
	const onValid = vi.fn()
	const rendered = renderWithProviders(<Harness onValid={onValid} />)
	return { ...rendered, onValid }
}

const submit = () => screen.getByRole("button", { name: "Register" })

/** Fills every field with values that pass, ready for one targeted break. */
async function fillValid(user: UserEvent) {
	await chooseSelectOption(user, /Where was your ID issued/, "China")
	await user.type(screen.getByLabelText(/^ID number/), "E12345678")
	await user.type(screen.getByLabelText(/Confirm ID number/), "E12345678")
	await user.type(
		screen.getByLabelText(/Name as it appears on your passport/),
		"ADA LOVELACE",
	)
	await user.type(screen.getByLabelText(/Passport expiry date/), "2030-01-01")
	await user.type(screen.getByLabelText(/Date of birth/), "1990-06-15")
	await chooseSelectOption(user, "Gender", "Female")
	await user.type(screen.getByLabelText(/Full name in Chinese/), "阿达")
	await user.type(screen.getByLabelText(/Phone number/), "13800138000")
	await user.type(screen.getByLabelText(/Current company/), "GARP")
	await user.type(screen.getByLabelText(/Last school attended/), "MIT")
	await user.type(screen.getByLabelText(/Highest degree earned/), "MSc")
	await user.click(screen.getByRole("checkbox", { name: /I agree to GARP/ }))
}

describe("submitting", () => {
	it("surfaces every missing answer at once, consent included", async () => {
		const user = userEvent.setup()
		const { onValid } = renderSection()

		await user.click(submit())

		expect(
			await screen.findByText("Please select where your ID was issued."),
		).toBeInTheDocument()
		expect(screen.getByText("Please enter your ID number.")).toBeInTheDocument()
		expect(
			screen.getByText("Please enter your full name in Chinese."),
		).toBeInTheDocument()
		expect(
			screen.getByText(
				"Please confirm you consent to these details being shared.",
			),
		).toBeInTheDocument()
		expect(onValid).not.toHaveBeenCalled()
	})

	it("passes with a fully valid China + passport answer set", async () => {
		const user = userEvent.setup()
		const { onValid } = renderSection()

		await fillValid(user)
		await user.click(submit())

		await waitFor(() => expect(onValid).toHaveBeenCalledTimes(1))
		expect(onValid.mock.calls[0][0].osta).toMatchObject({
			idLocation: "China",
			idNumber: "E12345678",
			ostaConsent: true,
		})
	})
})

describe("the ID number format, read at validation time", () => {
	it("applies the China passport rule from the CURRENT location and type", async () => {
		const user = userEvent.setup()
		const { onValid } = renderSection()

		await fillValid(user)
		// Break just the number: China passports are exactly 9 characters.
		await user.clear(screen.getByLabelText(/^ID number/))
		await user.type(screen.getByLabelText(/^ID number/), "SHORT1")
		await user.click(submit())

		expect(
			await screen.findByText("Your ID must be 9 characters long."),
		).toBeInTheDocument()
		expect(onValid).not.toHaveBeenCalled()
	})

	it("catches a confirm-number typo nothing downstream would", async () => {
		const user = userEvent.setup()
		const { onValid } = renderSection()

		await fillValid(user)
		await user.clear(screen.getByLabelText(/Confirm ID number/))
		await user.type(screen.getByLabelText(/Confirm ID number/), "E12345679")
		await user.click(submit())

		expect(
			await screen.findByText("Your ID numbers do not match."),
		).toBeInTheDocument()
		expect(onValid).not.toHaveBeenCalled()
	})

	it("rejects a phone outside 7–15 digits", async () => {
		const user = userEvent.setup()
		const { onValid } = renderSection()

		await fillValid(user)
		await user.clear(screen.getByLabelText(/Phone number/))
		await user.type(screen.getByLabelText(/Phone number/), "12345")
		await user.click(submit())

		expect(
			await screen.findByText("Please enter between 7 and 15 numbers."),
		).toBeInTheDocument()
		expect(onValid).not.toHaveBeenCalled()
	})
})
