import type { AccountProfileValues } from "@/api/account/save-profile"
import type { AccountView } from "@/api/account/types"
import {
	DESIGNATION_CODES,
	RISK_JOB_FUNCTION,
	type DesignationCode,
} from "@/config/career-information"

/** The typed fields react-hook-form owns on the survey. */
export type SurveyFormValues = {
	workingStatus: string
	industry: string
	industryWorkingYear: string
	company: string
	corporateTitle: string
	jobFunction: string
	riskSpecialty: string
	riskManagementWorkingYear: string
	designations: Record<DesignationCode, boolean>
	otherDesignation: boolean
	otherQualifications: string
	school: string
	highestDegree: string
	graduationYear: string
	graduationMonth: string
}

function noDesignations(): Record<DesignationCode, boolean> {
	return Object.fromEntries(
		DESIGNATION_CODES.map((code) => [code, false]),
	) as Record<DesignationCode, boolean>
}

export const EMPTY_SURVEY_VALUES: SurveyFormValues = {
	workingStatus: "",
	industry: "",
	industryWorkingYear: "",
	company: "",
	corporateTitle: "",
	jobFunction: "",
	riskSpecialty: "",
	riskManagementWorkingYear: "",
	designations: noDesignations(),
	otherDesignation: false,
	otherQualifications: "",
	school: "",
	highestDegree: "",
	graduationYear: "",
	graduationMonth: "",
}

/**
 * Seed the survey from what the member already has, so it confirms rather
 * than re-asks. Guests start blank — there is nothing to seed from.
 */
export function toSurveyValues(account: AccountView): SurveyFormValues {
	const { career, academic, designations, expertise } = account
	return {
		workingStatus: career.currentlyWorkingStatus ?? "",
		industry: career.areaOfConcentration ?? "",
		industryWorkingYear: career.industryWorkingYear ?? "",
		company: career.company ?? "",
		corporateTitle: career.corporateTitle ?? "",
		jobFunction: career.jobFunction ?? "",
		riskSpecialty: expertise.riskSpecialty ?? "",
		riskManagementWorkingYear: career.riskManagementWorkingYear ?? "",
		designations: Object.fromEntries(
			DESIGNATION_CODES.map((code) => [code, designations[code] === true]),
		) as Record<DesignationCode, boolean>,
		otherDesignation: designations.Other === true,
		otherQualifications: designations.otherQualifications ?? "",
		school: academic.schoolName ?? "",
		highestDegree: academic.highestDegree ?? "",
		graduationYear: academic.expectedGraduationDate ?? "",
		graduationMonth: academic.expectedGraduationMonth ?? "",
	}
}

function emptyToNull(value: string): string | null {
	const trimmed = value.trim()
	return trimmed === "" ? null : trimmed
}

/**
 * The Contact fields the survey writes — the same allow-list
 * `GARP_ExamReg_Demographics` and the member-portal profile save both accept,
 * so one builder serves the guest and the member path.
 *
 * Two dependencies are enforced here, not left to the screen: a risk specialty
 * only means anything under the Risk Management job function, and free-text
 * qualifications only under the Other designation. Blanks post as `null` —
 * Apex distinguishes "cleared" from "unchanged" by it.
 */
export function toSurveyPayload(values: SurveyFormValues): AccountProfileValues {
	const payload: AccountProfileValues = {
		Currently_Working_Status__c: emptyToNull(values.workingStatus),
		Area_of_Concentration__c: emptyToNull(values.industry),
		Industry_Working_Year__c: emptyToNull(values.industryWorkingYear),
		Company__c: emptyToNull(values.company),
		Corporate_Title__c: emptyToNull(values.corporateTitle),
		Job_Function__c: emptyToNull(values.jobFunction),
		Risk_Specialty__c:
			values.jobFunction === RISK_JOB_FUNCTION
				? emptyToNull(values.riskSpecialty)
				: null,
		Risk_Management_Working_Year__c: emptyToNull(
			values.riskManagementWorkingYear,
		),
		School_Name__c: emptyToNull(values.school),
		Highest_Degree__c: emptyToNull(values.highestDegree),
		Expected_Graduation_Date__c: emptyToNull(values.graduationYear),
		Expected_Graduation_Month__c: emptyToNull(values.graduationMonth),
		Professional_Designation_Other__c: values.otherDesignation,
		Other_Qualifications__c: values.otherDesignation
			? emptyToNull(values.otherQualifications)
			: null,
	}
	for (const code of DESIGNATION_CODES) {
		payload[`Professional_Designation_${code}__c`] =
			values.designations[code] === true
	}
	return payload
}

export type SurveyProgress = { answered: number; total: number; percent: number }

/**
 * How much of the survey has an answer — the number behind the progress ring.
 *
 * One question per control the candidate can see: the twelve fixed ones, plus
 * the risk specialty while the Risk Management job function makes it appear.
 * The designation checkboxes count as one question, answered once anything
 * is ticked (an untouched row and "none of these" look the same, so it is
 * never counted against them). Free-text "other qualifications" is part of
 * the Other tick, not a question of its own.
 */
export function surveyProgress(values: SurveyFormValues): SurveyProgress {
	const filled = (value: string) => value.trim() !== ""
	const answers = [
		filled(values.workingStatus),
		filled(values.industry),
		filled(values.industryWorkingYear),
		filled(values.company),
		filled(values.corporateTitle),
		filled(values.jobFunction),
		filled(values.riskManagementWorkingYear),
		values.otherDesignation || Object.values(values.designations).some(Boolean),
		filled(values.school),
		filled(values.highestDegree),
		filled(values.graduationYear),
		filled(values.graduationMonth),
	]
	if (values.jobFunction === RISK_JOB_FUNCTION) answers.push(filled(values.riskSpecialty))
	const answered = answers.filter(Boolean).length
	const total = answers.length
	return { answered, total, percent: total === 0 ? 0 : (answered / total) * 100 }
}
