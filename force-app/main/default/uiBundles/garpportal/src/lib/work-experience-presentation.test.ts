import { describe, expect, it } from "vitest"

import type { CvView, WorkExperience } from "@/api/work-experience"
import {
	CV_MAX_UPLOAD_BYTES,
	CV_MAX_UPLOAD_LABEL,
} from "@/config/work-experience"
import {
	buildCvRowPresentation,
	canEditCv,
	canSubmitCv,
	cvProgramTypeFromSlug,
	cvProgress,
	cvStatusPresentation,
	cvSubmitBlocker,
	hasChineseCharacters,
	cvViewState,
	formatAddressLine,
	formatExperiencePeriod,
	formatFileSize,
	formatMonths,
	hasDeliveryAddress,
	shortMonthYear,
	toExperienceFormValues,
	toCvAddressPayload,
	toExperienceInput,
	validateCvUpload,
	type CvExperienceFormValues,
} from "./work-experience-presentation"

function experience(overrides: Partial<WorkExperience> = {}): WorkExperience {
	return {
		id: "a1g1",
		programRequirement: "a0R1",
		startDate: "01/01/2020",
		endDate: "11/04/2025",
		isCurrentPosition: false,
		company: "Abrdn plc",
		title: "Risk Analyst",
		type: null,
		description: "A long description.",
		manager: "A Manager",
		jobFunction: "Risk Management",
		riskSpecialty: "Market Risk",
		jobType: "Full Time",
		educationalRole: null,
		timeAllotted: 71,
		validationMessage: "Valid work experience.",
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

function view(overrides: Partial<CvView> = {}): CvView {
	return {
		statusMessage: "CV Info Returned",
		statusCode: 200,
		status: "In Progress",
		workExperiences: [],
		totalTimeAllotted: 0,
		timeRequired: 24,
		isValidExperienceSubmission: false,
		submissionMessage: null,
		isOSTA: false,
		address: null,
		ostaAddress: null,
		ostaDistrict: null,
		ostaTown: null,
		ostaPhone: null,
		ostaRecipient: null,
		...overrides,
	}
}

const FORM: CvExperienceFormValues = {
	company: "Abrdn plc",
	title: "Risk Analyst",
	manager: "A Manager",
	startDateMonth: "1",
	startDateYear: "2020",
	endDateMonth: "11",
	endDateYear: "2025",
	isCurrentPosition: false,
	jobFunction: "Risk Management",
	riskSpecialty: "Market Risk",
	jobType: "Full Time",
	educationalRole: "",
	description: "A description.",
}

describe("toExperienceInput", () => {
	/**
	 * The whole reason this function exists. Apex deserializes `experience`
	 * with a typed `JSON.deserialize`, so one undeclared key throws and the
	 * request dies as an opaque 500 with no message.
	 */
	it("emits only keys ExperienceInput declares", () => {
		const allowed = new Set([
			"id", "startDate", "endDate",
			"startDateMonth", "startDateYear", "endDateMonth", "endDateYear",
			"isCurrentPosition", "company", "title", "type", "description",
			"manager", "jobFunction", "riskSpecialty", "jobType", "educationalRole",
		])
		for (const key of Object.keys(toExperienceInput(FORM, "a1g1"))) {
			expect(allowed.has(key)).toBe(true)
		}
	})

	it("never carries read-only fields back from a loaded row", () => {
		const input = toExperienceInput(FORM, "a1g1") as Record<string, unknown>
		for (const forbidden of [
			"programRequirement",
			"timeAllotted",
			"attachmentCount",
			"hasAttachments",
			"isValidExperience",
			"validationMessage",
			"overlapWarning",
			"requiredDocuments",
		]) {
			expect(input).not.toHaveProperty(forbidden)
		}
	})

	it("sends month/year integers and never the date strings", () => {
		const input = toExperienceInput(FORM)
		expect(input.startDateMonth).toBe(1)
		expect(input.startDateYear).toBe(2020)
		expect(input).not.toHaveProperty("startDate")
		expect(input).not.toHaveProperty("endDate")
	})

	/** The legacy persisted a stale end date alongside isCurrentPosition. */
	it("drops the end date for a current position", () => {
		const input = toExperienceInput({ ...FORM, isCurrentPosition: true })
		expect(input.isCurrentPosition).toBe(true)
		expect(input.endDateMonth).toBeNull()
		expect(input.endDateYear).toBeNull()
	})

	it("omits id when creating and includes it when editing", () => {
		expect(toExperienceInput(FORM)).not.toHaveProperty("id")
		expect(toExperienceInput(FORM, "  a1g1  ").id).toBe("a1g1")
		expect(toExperienceInput(FORM, "   ")).not.toHaveProperty("id")
	})

	it("blanks empty text rather than sending empty strings", () => {
		const input = toExperienceInput({ ...FORM, educationalRole: "  " })
		expect(input.educationalRole).toBeNull()
	})
})

describe("cvViewState", () => {
	/** There is no "Approved" literal — a certified member reports null. */
	it("treats a null status as complete, not as an error", () => {
		expect(cvViewState(view({ status: null }))).toBe("closed")
		expect(canEditCv(view({ status: null }))).toBe(false)
		expect(cvStatusPresentation(null).label).toBe("Complete")
	})

	it("maps the four in-flight states", () => {
		expect(cvViewState(view({ status: "New" }))).toBe("empty")
		expect(cvViewState(view({ status: "In Progress" }))).toBe("editing")
		expect(cvViewState(view({ status: "Failed Review" }))).toBe("editing")
		expect(cvViewState(view({ status: "Submitted" }))).toBe("submitted")
	})

	it("reopens editing after a failed review", () => {
		expect(canEditCv(view({ status: "Failed Review" }))).toBe(true)
	})

	it("locks a submitted CV", () => {
		expect(canEditCv(view({ status: "Submitted" }))).toBe(false)
	})
})

describe("canSubmitCv", () => {
	it("follows the server's own gate", () => {
		expect(canSubmitCv(view({ isValidExperienceSubmission: true }))).toBe(true)
		expect(canSubmitCv(view({ isValidExperienceSubmission: false }))).toBe(false)
	})

	it("is false once submitted, whatever the gate says", () => {
		expect(
			canSubmitCv(view({ status: "Submitted", isValidExperienceSubmission: true })),
		).toBe(false)
	})
})

describe("cvProgress", () => {
	it("describes the bar", () => {
		expect(cvProgress(view({ totalTimeAllotted: 18 }))).toMatchObject({
			logged: 18, required: 24, remaining: 6, percent: 75,
			label: "18 of 24 months logged",
		})
	})

	it("clamps past the requirement and drops the 'of 24' from the label", () => {
		expect(cvProgress(view({ totalTimeAllotted: 71 }))).toMatchObject({
			remaining: 0,
			percent: 100,
			// "71 of 24 months logged" is nonsense once the bar is cleared.
			label: "71 months logged",
		})
	})
})

describe("buildCvRowPresentation", () => {
	/** Apex zeroes part-time but keeps it valid — zero must not read as an error. */
	it("shows a part-time row as zero months without marking it invalid", () => {
		const row = buildCvRowPresentation(
			experience({
				jobType: "Part Time",
				timeAllotted: 0,
				isValidExperience: true,
				validationMessage:
					"Job type is part-time or part-time intern, which is not eligible for time calculation.",
			}),
		)
		expect(row.monthsLabel).toBe("0 months")
		expect(row.tone).not.toBe("invalid")
		expect(row.note).toContain("not eligible")
	})

	it("surfaces the overlap warning separately, in a warning tone", () => {
		const row = buildCvRowPresentation(
			experience({
				overlapWarning: {
					message: "Experience overlaps with another experience at Abrdn plc.",
					company: "Abrdn plc",
				},
			}),
		)
		expect(row.overlapNote).toContain("overlaps")
		expect(row.tone).toBe("warning")
	})

	it("marks an invalid row", () => {
		expect(
			buildCvRowPresentation(experience({ isValidExperience: false })).tone,
		).toBe("invalid")
	})

	it("flags a row that still needs documents", () => {
		expect(
			buildCvRowPresentation(
				experience({ isExperienceAttachmentRequired: true, hasAttachments: false }),
			).needsDocuments,
		).toBe(true)
	})

	it("treats an empty validationMessage as nothing to say", () => {
		expect(buildCvRowPresentation(experience({ validationMessage: "" })).note).toBeNull()
	})
})

describe("dates", () => {
	it("parses Apex's MM/dd/yyyy without a timezone shift", () => {
		expect(shortMonthYear("01/01/2020")).toBe("Jan 2020")
		expect(shortMonthYear("11/04/2025")).toBe("Nov 2025")
		expect(shortMonthYear(null)).toBeNull()
		expect(shortMonthYear("nonsense")).toBeNull()
	})

	it("formats a closed and a current period", () => {
		expect(formatExperiencePeriod(experience())).toBe("Jan 2020 – Nov 2025")
		expect(
			formatExperiencePeriod(experience({ isCurrentPosition: true })),
		).toBe("Jan 2020 – Present")
	})

	it("round-trips a row into form values", () => {
		const values = toExperienceFormValues(experience())
		expect(values.startDateMonth).toBe("1")
		expect(values.startDateYear).toBe("2020")
		expect(values.endDateMonth).toBe("11")
		expect(values.endDateYear).toBe("2025")
	})

	it("seeds an empty form from nothing", () => {
		expect(toExperienceFormValues(null).company).toBe("")
	})
})

describe("formatMonths", () => {
	it("pluralises", () => {
		expect(formatMonths(1)).toBe("1 month")
		expect(formatMonths(0)).toBe("0 months")
		expect(formatMonths(null)).toBe("0 months")
	})
})

describe("address", () => {
	it("needs a street and a city to count as given", () => {
		expect(hasDeliveryAddress(view())).toBe(false)
		expect(
			hasDeliveryAddress(
				view({
					address: {
						street: "12 Example Road", city: "London", state: null,
						postalCode: "EC1A 1BB", country: "United Kingdom", isEmpty: false,
					},
				}),
			),
		).toBe(true)
	})

	it("respects the server's isEmpty flag", () => {
		expect(
			hasDeliveryAddress(
				view({
					address: {
						street: "x", city: "y", state: null, postalCode: null,
						country: null, isEmpty: true,
					},
				}),
			),
		).toBe(false)
	})

	it("joins only the parts that exist", () => {
		expect(
			formatAddressLine({
				street: "12 Example Road", city: "London", state: null,
				postalCode: "EC1A 1BB", country: "United Kingdom", isEmpty: false,
			}),
		).toBe("12 Example Road, London, EC1A 1BB, United Kingdom")
		expect(formatAddressLine(null)).toBeNull()
	})
})

describe("cvProgramTypeFromSlug", () => {
	it("accepts only the two programmes with a CV requirement", () => {
		expect(cvProgramTypeFromSlug("frm")).toBe("FRM")
		expect(cvProgramTypeFromSlug("ERP")).toBe("ERP")
		expect(cvProgramTypeFromSlug("scr")).toBeNull()
		expect(cvProgramTypeFromSlug(null)).toBeNull()
	})
})

describe("validateCvUpload", () => {
	const file = (over: Partial<{ name: string; size: number; type: string }> = {}) => ({
		name: "evidence.pdf",
		size: 1024,
		type: "application/pdf",
		...over,
	})

	it("accepts a normal PDF", () => {
		expect(validateCvUpload(file())).toBeNull()
	})

	/**
	 * Apex validates nothing. The platform caps an Attachment body at 5 MB and
	 * base64 inflates by about a third, so an oversized file comes back as an
	 * opaque 500 reading "Error uploading file".
	 */
	it("refuses a file over the client cap", () => {
		expect(validateCvUpload(file({ size: CV_MAX_UPLOAD_BYTES + 1 }))).toContain(
			CV_MAX_UPLOAD_LABEL,
		)
	})

	it("refuses an empty file", () => {
		expect(validateCvUpload(file({ size: 0 }))).toBe("This file is empty.")
	})

	it("refuses a type GARP does not accept", () => {
		expect(
			validateCvUpload(file({ name: "sheet.xlsx", type: "application/vnd.ms-excel" })),
		).not.toBeNull()
	})

	/**
	 * Browsers report an empty `type` for several accepted formats — .doc most
	 * reliably — so the extension has to be enough on its own.
	 */
	it("accepts an allowed extension when the browser reports no MIME type", () => {
		expect(validateCvUpload(file({ name: "letter.doc", type: "" }))).toBeNull()
	})

	it("accepts an allowed MIME type when the name has no extension", () => {
		expect(validateCvUpload(file({ name: "scan", type: "image/png" }))).toBeNull()
	})
})

describe("formatFileSize", () => {
	/** Null on every upload response — the service returns the record it just inserted. */
	it("returns null rather than 0 bytes when the size is absent", () => {
		expect(formatFileSize(null)).toBeNull()
		expect(formatFileSize(undefined)).toBeNull()
	})

	it("formats bytes, kilobytes and megabytes", () => {
		expect(formatFileSize(1)).toBe("1 byte")
		expect(formatFileSize(900)).toBe("900 bytes")
		expect(formatFileSize(2048)).toBe("2 KB")
		expect(formatFileSize(1_572_864)).toBe("1.5 MB")
	})
})

describe("toCvAddressPayload", () => {
	const values = {
		company: " Northgate ",
		address1: "12 Example Road",
		address2: "Floor 3",
		address3: "",
		country: "United Kingdom",
		city: "London",
		state: "Greater London",
		postalCode: "EC1A 1BB",
		phone: "+44 20 7946 0000",
	}

	it("joins the three street lines into one field", () => {
		expect(toCvAddressPayload(values).mailingAddress.street).toBe(
			"12 Example Road\nFloor 3",
		)
	})

	/**
	 * Apex assigns all seven Contact columns unconditionally, so a key left out
	 * is written as null. `company` and `phone` are absent from `GET cv`, which
	 * is exactly how a CV-seeded form would silently blank them.
	 */
	it("names every field, so nothing is nulled by omission", () => {
		expect(Object.keys(toCvAddressPayload(values).mailingAddress).sort()).toEqual(
			["city", "company", "country", "phone", "postalCode", "state", "street"],
		)
	})

	it("sends null rather than an empty string for a blank field", () => {
		const payload = toCvAddressPayload({ ...values, company: "   ", phone: "" })
		expect(payload.mailingAddress.company).toBeNull()
		expect(payload.mailingAddress.phone).toBeNull()
	})
})

describe("cvSubmitBlocker", () => {
	const submittable = (over: Partial<CvView> = {}): CvView =>
		view({
			status: "In Progress",
			isValidExperienceSubmission: true,
			totalTimeAllotted: 30,
			timeRequired: 24,
			address: {
				street: "12 Example Road",
				city: "London",
				state: null,
				postalCode: "EC1A 1BB",
				country: "United Kingdom",
				isEmpty: false,
			},
			...over,
		})

	it("allows submission when the months and the address are both there", () => {
		expect(cvSubmitBlocker(submittable())).toBeNull()
	})

	/**
	 * Ours alone — `cvSubmit` never looks at the address, so without this a
	 * member can raise a review with nowhere to post the certificate.
	 */
	it("blocks on a missing address even though Apex would accept it", () => {
		expect(cvSubmitBlocker(submittable({ address: null }))).toContain("address")
	})

	it("blocks when the server says the experience is not yet valid", () => {
		expect(
			cvSubmitBlocker(
				submittable({
					isValidExperienceSubmission: false,
					totalTimeAllotted: 10,
					submissionMessage: null,
				}),
			),
		).toContain("14 months")
	})

	it("prefers the server's own sentence when it gives one", () => {
		expect(
			cvSubmitBlocker(
				submittable({
					isValidExperienceSubmission: false,
					submissionMessage: "Add a role in risk management.",
				}),
			),
		).toBe("Add a role in risk management.")
	})

	/** `null` is the approved case — there is nothing left to send. */
	it("blocks once the CV is already with GARP, and when it is approved", () => {
		expect(cvSubmitBlocker(submittable({ status: "Submitted" }))).toContain(
			"already been sent",
		)
		expect(cvSubmitBlocker(submittable({ status: null }))).toContain(
			"already been sent",
		)
	})
})

describe("OSTA delivery address", () => {
	const mailing = {
		company: "",
		address1: "12 Example Road",
		address2: "",
		address3: "",
		country: "China",
		city: "Shanghai",
		state: "",
		postalCode: "200000",
		phone: "",
	}
	const osta = {
		recipient: "张伟",
		province: "上海市",
		city: "上海",
		district: "浦东新区",
		town: "世纪大道 100 号",
		street: "陆家嘴环路 1000 号 5 楼",
		phone: "+86 21 1234 5678",
	}

	/**
	 * Apex writes the six OSTA columns inside `if (input.ostaAddress != null)`,
	 * so sending an empty block for a non-OSTA member would erase a real one.
	 */
	it("omits the block entirely for a non-OSTA member", () => {
		const payload = toCvAddressPayload(mailing, null)
		expect(payload.ostaAddress).toBeUndefined()
		expect(payload.ostaRecipient).toBeUndefined()
	})

	it("maps the Chinese fields onto the wire names Apex reads", () => {
		const payload = toCvAddressPayload(mailing, osta)
		expect(payload.ostaAddress).toMatchObject({
			street: osta.street,
			city: osta.city,
			state: osta.province,
			district: osta.district,
			town: osta.town,
			phone: osta.phone,
		})
		expect(payload.ostaRecipient).toBe("张伟")
	})

	/** `saveAddress` reads neither for the OSTA block, and `GET cv` hard-codes China. */
	it("sends no postal code or country in the OSTA block", () => {
		const payload = toCvAddressPayload(mailing, osta)
		expect(payload.ostaAddress?.postalCode).toBeNull()
		expect(payload.ostaAddress?.country).toBeNull()
	})
})

describe("hasChineseCharacters", () => {
	it("accepts Chinese text", () => {
		expect(hasChineseCharacters("上海市浦东新区")).toBe(true)
	})

	/**
	 * The rule is "contains Chinese", not "contains only Chinese" — building
	 * and unit numbers are normal in a real address. The legacy rejected any
	 * non-Chinese character, which a street number trips.
	 */
	it("accepts Chinese text carrying digits and punctuation", () => {
		expect(hasChineseCharacters("陆家嘴环路 1000 号 5 楼")).toBe(true)
	})

	it("rejects Latin-only text and blanks", () => {
		expect(hasChineseCharacters("Lujiazui Ring Road")).toBe(false)
		expect(hasChineseCharacters("")).toBe(false)
	})
})
