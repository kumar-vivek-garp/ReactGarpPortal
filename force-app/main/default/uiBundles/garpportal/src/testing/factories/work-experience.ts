import type {
	CvAttachmentInfo,
	CvAttachmentResult,
	CvView,
	ExperienceFormView,
	WorkExperience,
} from "@/api/work-experience"

/**
 * `GARP_Portal_CvService` fixtures. Defaults model an in-progress FRM CV whose
 * single role already satisfies the 24 months and whose delivery address is on
 * file — the state in which Submit is offered. Tests override the one aspect
 * under test.
 */

export function workExperience(
	overrides: Partial<WorkExperience> = {},
): WorkExperience {
	return {
		id: "a1Q-exp-1",
		programRequirement: "a1R-req-1",
		startDate: "01/15/2020",
		endDate: "01/15/2022",
		isCurrentPosition: false,
		company: "Abrdn plc",
		title: "Risk Analyst",
		type: null,
		description: "Quantitative risk work.",
		manager: "Grace Hopper",
		jobFunction: "Risk Management",
		riskSpecialty: null,
		jobType: "Full Time",
		educationalRole: null,
		timeAllotted: 24,
		validationMessage: null,
		isValidExperience: true,
		attachmentCount: 0,
		hasAttachments: false,
		isExperienceAttachmentRequired: false,
		documentMessage: null,
		requiredDocuments: null,
		overlapWarning: null,
		...overrides,
	}
}

export function cvView(overrides: Partial<CvView> = {}): CvView {
	return {
		statusMessage: null,
		statusCode: 200,
		status: "In Progress",
		workExperiences: [workExperience()],
		totalTimeAllotted: 24,
		timeRequired: 24,
		isValidExperienceSubmission: true,
		submissionMessage: null,
		isOSTA: false,
		address: {
			street: "12 Example Road",
			city: "London",
			state: null,
			postalCode: "EC1A 1BB",
			country: "United Kingdom",
			isEmpty: false,
		},
		ostaAddress: null,
		ostaDistrict: null,
		ostaTown: null,
		ostaPhone: null,
		ostaRecipient: null,
		...overrides,
	}
}

/** `GET cvExperience` — a blank row (the Add form) plus populated picklists. */
export function experienceFormView(
	overrides: Partial<ExperienceFormView> = {},
): ExperienceFormView {
	return {
		statusMessage: null,
		statusCode: 200,
		workExperience: null,
		jobFunctions: ["Risk Management", "Education/Training"],
		riskSpecialties: ["Credit Risk", "Market Risk"],
		jobTypes: ["Full Time", "Part Time"],
		educationalRoles: ["Professor"],
		...overrides,
	}
}

export function cvAttachment(
	overrides: Partial<CvAttachmentInfo> = {},
): CvAttachmentInfo {
	return {
		id: "00P-att-1",
		name: "employment-letter.pdf",
		url: "/servlet/servlet.FileDownload?file=00P-att-1",
		size: 2048,
		...overrides,
	}
}

export function cvAttachmentResult(
	overrides: Partial<CvAttachmentResult> = {},
): CvAttachmentResult {
	return {
		status: "success",
		message: null,
		statusCode: 200,
		attachments: [cvAttachment()],
		...overrides,
	}
}
