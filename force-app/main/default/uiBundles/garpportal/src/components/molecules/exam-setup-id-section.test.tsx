import { useForm, useWatch } from "react-hook-form"
import { screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it } from "vitest"
import type { FieldErrors } from "react-hook-form"

import {
	ExamSetupIdSection,
	type ExamSetupIdFormValues,
} from "@/components/molecules/exam-setup-id-section"
import {
	EXAM_SETUP_ID_ON_FILE_HINT,
	EXAM_SETUP_PASSPORT_HINT,
} from "@/config/exam-setup"
import { chooseSelectOption } from "@/testing/exam-registration-ui"
import { renderWithProviders } from "@/testing/render"

const EMPTY_VALUES: ExamSetupIdFormValues = {
	idName: "",
	idNumber: "",
	idType: "",
	idExpireDate: "",
	mobilePhoneLocation: "",
	mobilePhoneNumber: "",
	ostaIDLocation: "",
	ostaGender: "",
	ostaFullNameInChinese: "",
	ostaDateOfBirth: "",
	ostaPhoneNumber: "",
	ostaCurrentWorkingStatus: "",
	ostaCompany: "",
	ostaCurrentSchoolStatus: "",
	ostaSchool: "",
	ostaDegreeProgramName: "",
}

type HarnessProps = {
	isIDRequired?: boolean
	idOnFile?: boolean
	isOSTA?: boolean
	defaults?: Partial<ExamSetupIdFormValues>
	errors?: FieldErrors<ExamSetupIdFormValues>
}

/** Owns the form and feeds the watched values back in, as the panel does. */
function Harness({
	isIDRequired = false,
	idOnFile = false,
	isOSTA = false,
	defaults,
	errors = {},
}: HarnessProps) {
	const form = useForm<ExamSetupIdFormValues>({
		defaultValues: { ...EMPTY_VALUES, ...defaults },
	})
	const idType = useWatch({ control: form.control, name: "idType" })
	const workingStatus = useWatch({
		control: form.control,
		name: "ostaCurrentWorkingStatus",
	})
	const schoolStatus = useWatch({
		control: form.control,
		name: "ostaCurrentSchoolStatus",
	})
	return (
		<ExamSetupIdSection
			control={form.control}
			errors={errors}
			isIDRequired={isIDRequired}
			idOnFile={idOnFile}
			isOSTA={isOSTA}
			mobilePhoneLocations={["United States", "China"]}
			idType={idType}
			workingStatus={workingStatus}
			schoolStatus={schoolStatus}
		/>
	)
}

const OSTA_LEGEND = "Additional details for your exam centre"

describe("the server-decided layers", () => {
	it("hides the whole OSTA block for a member outside mainland China", () => {
		renderWithProviders(<Harness />)
		expect(
			screen.queryByRole("group", { name: OSTA_LEGEND }),
		).not.toBeInTheDocument()
	})

	it("adds the OSTA block when the exam centre demands it", () => {
		renderWithProviders(<Harness isOSTA />)
		expect(screen.getByRole("group", { name: OSTA_LEGEND })).toBeInTheDocument()
		expect(screen.getByLabelText(/Full name in Chinese/)).toBeInTheDocument()
		expect(screen.getByRole("combobox", { name: "ID issued in" })).toBeInTheDocument()
	})

	it("marks the base ID fields required only when Apex says so", () => {
		const { rerender } = renderWithProviders(<Harness />)
		expect(
			screen.getByText("Name as it appears on your ID").textContent,
		).not.toContain("*")

		rerender(<Harness isIDRequired />)
		expect(
			screen.getByText("Name as it appears on your ID").textContent,
		).toContain("*")
	})

	it("does not demand a fresh ID number while one is already on file", () => {
		renderWithProviders(<Harness isIDRequired idOnFile />)
		expect(screen.getByText("ID number").textContent).not.toContain("*")
	})
})

describe("the ID number hint", () => {
	it("explains blank-means-keep while a number is on file", () => {
		renderWithProviders(<Harness idOnFile />)
		expect(screen.getByText(EXAM_SETUP_ID_ON_FILE_HINT)).toBeInTheDocument()
	})

	it("explains the passport format only for a passport", async () => {
		const user = userEvent.setup()
		renderWithProviders(<Harness />)
		expect(screen.queryByText(EXAM_SETUP_PASSPORT_HINT)).not.toBeInTheDocument()

		await chooseSelectOption(user, "ID type", "Passport")
		expect(screen.getByText(EXAM_SETUP_PASSPORT_HINT)).toBeInTheDocument()

		await chooseSelectOption(user, "ID type", "Driver's License")
		expect(screen.queryByText(EXAM_SETUP_PASSPORT_HINT)).not.toBeInTheDocument()
	})

	it("prefers the on-file hint over the passport one", () => {
		renderWithProviders(<Harness idOnFile defaults={{ idType: "Passport" }} />)
		expect(screen.getByText(EXAM_SETUP_ID_ON_FILE_HINT)).toBeInTheDocument()
		expect(screen.queryByText(EXAM_SETUP_PASSPORT_HINT)).not.toBeInTheDocument()
	})
})

describe("labels that listen to the answers above them", () => {
	it("asks for the current or last company and school by status", async () => {
		const user = userEvent.setup()
		renderWithProviders(<Harness isOSTA />)

		// Nothing chosen yet: the not-working / not-in-school wording.
		expect(screen.getByLabelText("Last company")).toBeInTheDocument()
		expect(screen.getByLabelText("Last school attended")).toBeInTheDocument()
		expect(screen.getByLabelText("Highest degree earned")).toBeInTheDocument()

		await chooseSelectOption(user, "Working status", "Working")
		expect(screen.getByLabelText("Current company")).toBeInTheDocument()

		await chooseSelectOption(user, "Schooling status", "In School")
		expect(screen.getByLabelText("Current school")).toBeInTheDocument()
		expect(screen.getByLabelText("Degree you are seeking")).toBeInTheDocument()
	})
})

describe("panel-owned validation surfacing", () => {
	it("renders the panel's field errors inline", () => {
		renderWithProviders(
			<Harness
				errors={{
					idName: { type: "required", message: "Please enter your name." },
					idExpireDate: {
						type: "required",
						message: "Please enter the expiry date.",
					},
				}}
			/>,
		)
		const alerts = screen.getAllByRole("alert")
		expect(alerts.map((alert) => alert.textContent)).toEqual([
			"Please enter your name.",
			"Please enter the expiry date.",
		])
	})
})

describe("the mobile phone", () => {
	it("offers the org's phone locations and records a choice", async () => {
		const user = userEvent.setup()
		renderWithProviders(<Harness />)

		await chooseSelectOption(user, "Mobile country code", "China")
		expect(
			screen.getByRole("combobox", { name: "Mobile country code" }),
		).toHaveTextContent("China")
	})
})
