import type { MemberPortalEnvelope } from "@/api/account/types"

/** Marketing catalogue entry from `GARP_Portal_ProgramsService.ProgramInformation`. */
export type ProgramInformation = {
	programCode: string | null
	abbrevName: string | null
	formalName: string | null
	informalName: string | null
	policyURL: string | null
	regLogoURL: string | null
	myProgramsLogoURL: string | null
	description: string | null
	registrationPath: string | null
}

/** In-progress program. Listing does not use exam attempt rows. */
export type EnrolledProgram = {
	programType: string
	adminPartIName: string | null
	adminPartIIName: string | null
	programInformation: ProgramInformation | null
}

export type CompletedProgram = {
	programType: string
	programInformation: ProgramInformation | null
}

export type OtherProgram = {
	programType: string
	isRegistrationOpen: boolean
	/** ISO date (`yyyy-MM-dd`) when closed. */
	nextRegistrationOpenDate: string | null
	nextRegistrationOpenAdminName: string | null
	isMicroCourse: boolean
	programInformation: ProgramInformation | null
}

/** Typed for the payload; listing cards do not render this map. */
export type MicroCourseConfig = {
	name: string | null
	courseCode: string | null
	description: string | null
	abbrevName: string | null
	formalName: string | null
	policyURL: string | null
	registrationLogoURL: string | null
	myProgramsLogoURL: string | null
	programType: string | null
	programRecordTypeAPIName: string | null
}

/** `GET /memberportal/programs` view (`GARP_Portal_ProgramsService.ProgramsView`). */
export type ProgramsView = {
	statusMessage: string | null
	statusCode: number
	enrolledPrograms: EnrolledProgram[]
	completedPrograms: CompletedProgram[]
	otherPrograms: OtherProgram[]
	hasCPDProgram: boolean
	hasExamResults: boolean
	microCourseConfig: Record<string, MicroCourseConfig> | null
}

export type { MemberPortalEnvelope }
