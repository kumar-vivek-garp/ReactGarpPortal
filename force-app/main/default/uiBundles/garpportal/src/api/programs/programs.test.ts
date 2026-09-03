import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import { AppError } from "@/api/client"
import { fetchPrograms } from "@/api/programs/programs"
import type { OtherProgram, ProgramsView } from "@/api/programs/types"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const PROGRAMS_PATH = "/services/apexrest/memberportal/programs"

const scr: OtherProgram = {
	programType: "SCR",
	isRegistrationOpen: true,
	nextRegistrationOpenDate: null,
	nextRegistrationOpenAdminName: null,
	isMicroCourse: false,
	programInformation: null,
}

function programsView(overrides: Partial<ProgramsView> = {}): ProgramsView {
	return {
		statusMessage: null,
		statusCode: 200,
		enrolledPrograms: [
			{
				programType: "FRM",
				adminPartIName: "May 2026",
				adminPartIIName: null,
				programInformation: null,
			},
		],
		completedPrograms: [],
		otherPrograms: [scr],
		hasCPDProgram: false,
		hasExamResults: true,
		microCourseConfig: null,
		...overrides,
	}
}

describe("fetchPrograms", () => {
	it("returns the program buckets", async () => {
		const view = programsView()
		server.use(
			http.get(PROGRAMS_PATH, () =>
				HttpResponse.json(memberPortalEnvelope(view)),
			),
		)

		await expect(fetchPrograms()).resolves.toEqual(view)
	})

	it("substitutes empty arrays for missing buckets", async () => {
		server.use(
			http.get(PROGRAMS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						hasCPDProgram: false,
						hasExamResults: false,
						microCourseConfig: null,
					}),
				),
			),
		)

		await expect(fetchPrograms()).resolves.toMatchObject({
			enrolledPrograms: [],
			completedPrograms: [],
			otherPrograms: [],
		})
	})

	it("throws the inner refusal even on an HTTP 200", async () => {
		server.use(
			http.get(PROGRAMS_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						programsView({ statusCode: 401, statusMessage: "No portal access" }),
					),
				),
			),
		)

		await expect(fetchPrograms()).rejects.toMatchObject({
			messages: ["No portal access"],
			status: 401,
		})
	})

	it("surfaces the server's error message as AppError", async () => {
		server.use(
			http.get(PROGRAMS_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Programs backend down"), {
					status: 500,
				}),
			),
		)

		const failure = fetchPrograms()
		await expect(failure).rejects.toBeInstanceOf(AppError)
		await expect(failure).rejects.toMatchObject({
			messages: ["Programs backend down"],
		})
	})
})
