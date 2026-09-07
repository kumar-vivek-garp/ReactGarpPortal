import { describe, expect, it } from "vitest"

import {
	EMPTY_SURVEY_VALUES,
	surveyProgress,
	toSurveyPayload,
	toSurveyValues,
} from "@/components/forms/registration-survey/registration-survey-values"
import { accountView } from "@/testing/factories/account"

describe("toSurveyPayload", () => {
	it("posts every blank as null, never as an empty string", () => {
		const payload = toSurveyPayload(EMPTY_SURVEY_VALUES)
		expect(payload.Currently_Working_Status__c).toBeNull()
		expect(payload.Company__c).toBeNull()
		expect(payload.Expected_Graduation_Month__c).toBeNull()
		expect(payload.Professional_Designation_Other__c).toBe(false)
		expect(payload.Other_Qualifications__c).toBeNull()
	})

	it("sends the risk specialty only under the Risk Management job function", () => {
		const withRisk = toSurveyPayload({
			...EMPTY_SURVEY_VALUES,
			jobFunction: "Risk Management",
			riskSpecialty: "Credit Risk",
		})
		expect(withRisk.Risk_Specialty__c).toBe("Credit Risk")

		const trading = toSurveyPayload({
			...EMPTY_SURVEY_VALUES,
			jobFunction: "Trading",
			riskSpecialty: "Credit Risk",
		})
		expect(trading.Risk_Specialty__c).toBeNull()
	})

	it("sends other qualifications only when Other is ticked", () => {
		expect(
			toSurveyPayload({
				...EMPTY_SURVEY_VALUES,
				otherDesignation: false,
				otherQualifications: "FRM",
			}).Other_Qualifications__c,
		).toBeNull()
		expect(
			toSurveyPayload({
				...EMPTY_SURVEY_VALUES,
				otherDesignation: true,
				otherQualifications: " FRM ",
			}),
		).toMatchObject({
			Professional_Designation_Other__c: true,
			Other_Qualifications__c: "FRM",
		})
	})

	it("writes one boolean per designation code", () => {
		const payload = toSurveyPayload({
			...EMPTY_SURVEY_VALUES,
			designations: { ...EMPTY_SURVEY_VALUES.designations, CFA: true, PMP: true },
		})
		expect(payload.Professional_Designation_CFA__c).toBe(true)
		expect(payload.Professional_Designation_PMP__c).toBe(true)
		expect(payload.Professional_Designation_CA__c).toBe(false)
	})

	it("trims text answers", () => {
		expect(
			toSurveyPayload({ ...EMPTY_SURVEY_VALUES, company: "  Acme  " }).Company__c,
		).toBe("Acme")
	})
})

describe("toSurveyValues", () => {
	it("seeds from the member's record, reading the specialty from expertise", () => {
		const account = accountView()
		account.career.jobFunction = "Risk Management"
		account.expertise.riskSpecialty = "Market Risk"
		account.designations.CFA = true
		account.designations.Other = true
		account.designations.otherQualifications = "FRM"
		account.academic.schoolName = "MIT"

		const values = toSurveyValues(account)

		expect(values.jobFunction).toBe("Risk Management")
		expect(values.riskSpecialty).toBe("Market Risk")
		expect(values.designations.CFA).toBe(true)
		expect(values.designations.CA).toBe(false)
		expect(values.otherDesignation).toBe(true)
		expect(values.otherQualifications).toBe("FRM")
		expect(values.school).toBe("MIT")
	})

	it("turns nulls into empty strings so every control is controlled", () => {
		const account = accountView()
		account.career.company = null
		account.academic.expectedGraduationMonth = null
		const values = toSurveyValues(account)
		expect(values.company).toBe("")
		expect(values.graduationMonth).toBe("")
	})
})

describe("surveyProgress", () => {
	it("starts at nothing answered out of twelve", () => {
		expect(surveyProgress(EMPTY_SURVEY_VALUES)).toEqual({ answered: 0, total: 12, percent: 0 })
	})

	it("counts each answered control once, and the designations row as one question", () => {
		const progress = surveyProgress({
			...EMPTY_SURVEY_VALUES,
			workingStatus: "Working",
			company: "  Acme  ",
			designations: { ...EMPTY_SURVEY_VALUES.designations, CFA: true, PMP: true },
		})
		expect(progress.answered).toBe(3)
		expect(progress.total).toBe(12)
		expect(progress.percent).toBe(25)
	})

	it("only asks about the risk specialty under the Risk Management job function", () => {
		const risk = surveyProgress({ ...EMPTY_SURVEY_VALUES, jobFunction: "Risk Management" })
		expect(risk).toMatchObject({ answered: 1, total: 13 })
		const trading = surveyProgress({ ...EMPTY_SURVEY_VALUES, jobFunction: "Trading" })
		expect(trading).toMatchObject({ answered: 1, total: 12 })
	})

	it("treats the Other tick as an answer to the designations question", () => {
		expect(
			surveyProgress({ ...EMPTY_SURVEY_VALUES, otherDesignation: true }).answered,
		).toBe(1)
	})
})
