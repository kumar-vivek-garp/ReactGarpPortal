import { useForm, useWatch } from "react-hook-form"
import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"

import {
	EMPTY_EXAM_FORM_VALUES,
	type ExamFormValues,
} from "@/components/forms/exam-registration/exam-form-values"
import { OstaSection } from "@/components/forms/exam-registration/sections/osta-section"
import { chooseSelectOption } from "@/testing/exam-registration-ui"
import { renderWithProviders } from "@/testing/render"

/**
 * Owns the react-hook-form instance and feeds the section the same watched
 * values the exam form does, so choosing in the UI re-labels live.
 */
function Harness({
	companies,
	schools,
	disabled,
}: {
	companies?: string[]
	schools?: string[]
	disabled?: boolean
}) {
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
		<OstaSection
			register={form.register}
			control={form.control}
			errors={form.formState.errors}
			getValues={form.getValues}
			idType={idType}
			workStatus={workStatus}
			studentStatus={studentStatus}
			companies={companies}
			schools={schools}
			disabled={disabled}
		/>
	)
}

describe("labels that track the person's own answers", () => {
	it("speaks of a passport while Passport is the ID type, and of an ID otherwise", async () => {
		const user = userEvent.setup()
		renderWithProviders(<Harness />)

		// The seed default is Passport.
		expect(
			screen.getByLabelText(/Name as it appears on your passport/),
		).toBeInTheDocument()
		expect(screen.getByLabelText(/Passport expiry date/)).toBeInTheDocument()

		await chooseSelectOption(user, "ID type", "Driver's License")

		expect(
			screen.getByLabelText(/Name as it appears on your ID/),
		).toBeInTheDocument()
		expect(screen.getByLabelText(/^ID expiry date/)).toBeInTheDocument()
	})

	it("asks for the current or last company depending on work status", async () => {
		const user = userEvent.setup()
		renderWithProviders(<Harness />)

		// The seed default is Working.
		expect(screen.getByLabelText(/Current company/)).toBeInTheDocument()

		await chooseSelectOption(user, "Work status", "Not Working")
		expect(screen.getByLabelText(/Last company/)).toBeInTheDocument()
	})

	it("asks for the current or last school depending on education status", async () => {
		const user = userEvent.setup()
		renderWithProviders(<Harness />)

		// The seed default is Not In School.
		expect(screen.getByLabelText(/Last school attended/)).toBeInTheDocument()
		expect(screen.getByLabelText(/Highest degree earned/)).toBeInTheDocument()

		await chooseSelectOption(user, "Education", "In School")
		expect(screen.getByLabelText(/Current school/)).toBeInTheDocument()
		expect(screen.getByLabelText(/Degree you are seeking/)).toBeInTheDocument()
	})
})

describe("the legacy typeahead", () => {
	it("offers company and school suggestions only when the load supplies them", () => {
		const { rerender } = renderWithProviders(
			<Harness companies={["GARP"]} schools={["MIT"]} />,
		)
		expect(screen.getByLabelText(/Current company/)).toHaveAttribute(
			"list",
			"osta-company-options",
		)
		expect(screen.getByLabelText(/Last school attended/)).toHaveAttribute(
			"list",
			"osta-school-options",
		)

		rerender(<Harness />)
		expect(screen.getByLabelText(/Current company/)).not.toHaveAttribute("list")
		expect(screen.getByLabelText(/Last school attended/)).not.toHaveAttribute(
			"list",
		)
	})
})

describe("disabled while a submit is in flight", () => {
	it("locks every control", () => {
		renderWithProviders(<Harness disabled />)
		expect(screen.getByLabelText(/^ID number/)).toBeDisabled()
		expect(screen.getByRole("combobox", { name: "ID type" })).toBeDisabled()
		expect(
			screen.getByRole("checkbox", { name: /I agree to GARP sharing/ }),
		).toBeDisabled()
	})
})
