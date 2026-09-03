import { screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { http, HttpResponse } from "msw"
import { describe, expect, it, vi } from "vitest"

import { ExamSetupPanel } from "@/components/organisms/exam-setup-panel"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import {
	examSetupAuthorizeResult,
	examSetupSaveResult,
	examSetupView,
} from "@/testing/factories/exam-setup"
import { server } from "@/testing/msw/server"
import { renderWithRouterProviders } from "@/testing/router"

/**
 * vi.mock, not MSW: `EXAM_SETUP_AUTHORIZE_ENABLED` is a build-time constant
 * with no HTTP boundary. It ships OFF (the provider push is a live outbound
 * integration), so the authorized / pending / exhausted branches are
 * unreachable without flipping it here.
 */
vi.mock(import("@/config/exam-setup"), async (importOriginal) => {
	const mod = await importOriginal()
	return {
		...mod,
		// The source narrows the flag to the literal `false`; widening through
		// unknown is the only way to hand the mock the other literal.
		EXAM_SETUP_AUTHORIZE_ENABLED:
			true as unknown as typeof mod.EXAM_SETUP_AUTHORIZE_ENABLED,
	}
})

const FORM_PATH = "/services/apexrest/memberportal/examSetup"
const SAVE_PATH = "/services/apexrest/memberportal/examSetupId"
const AUTHORIZE_PATH = "/services/apexrest/memberportal/examSetupAuthorize"

/** Save into the scheduling outcome; the provider answer is per-test. */
async function renderScheduling() {
	server.use(
		http.get(FORM_PATH, () =>
			HttpResponse.json(memberPortalEnvelope(examSetupView())),
		),
		http.post(SAVE_PATH, () =>
			HttpResponse.json(
				memberPortalEnvelope(
					examSetupSaveResult({
						nextScreen: "Check Authorization",
						schedulingRequired: true,
					}),
				),
			),
		),
	)
	const user = userEvent.setup()
	await renderWithRouterProviders(<ExamSetupPanel programType="scr" />)
	await screen.findByText("Choose your sitting")
	await user.click(screen.getByRole("button", { name: "Save and continue" }))
	await screen.findByText("Still processing")
	return user
}

describe("ExamSetupPanel — provider authorization (flag on)", () => {
	it("asks the provider once on Check again and offers the scheduling link when authorized", async () => {
		const bodies: Array<Record<string, unknown>> = []
		server.use(
			http.post(AUTHORIZE_PATH, async ({ request }) => {
				bodies.push((await request.json()) as Record<string, unknown>)
				return HttpResponse.json(
					memberPortalEnvelope(
						examSetupAuthorizeResult({
							isAuthorized: true,
							examScheduleExamURLPart1: "https://provider.example/p1",
						}),
					),
				)
			}),
		)
		const user = await renderScheduling()

		await user.click(screen.getByRole("button", { name: "Check again" }))

		expect(await screen.findByText("Now book your seat")).toBeInTheDocument()
		expect(
			screen.getByRole("link", { name: "Schedule your exam" }),
		).toHaveAttribute("href", "https://provider.example/p1")
		// The very first ask is not a retry.
		expect(bodies).toEqual([{ programType: "scr", isRetry: false }])
	})

	it("labels both links when the provider returns two parts", async () => {
		server.use(
			http.post(AUTHORIZE_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						examSetupAuthorizeResult({
							isAuthorized: true,
							examScheduleExamURLPart1: "https://provider.example/p1",
							examScheduleExamURLPart2: "https://provider.example/p2",
						}),
					),
				),
			),
		)
		const user = await renderScheduling()

		await user.click(screen.getByRole("button", { name: "Check again" }))

		expect(
			await screen.findByRole("link", { name: "Schedule Part I" }),
		).toHaveAttribute("href", "https://provider.example/p1")
		expect(
			screen.getByRole("link", { name: "Schedule Part II" }),
		).toHaveAttribute("href", "https://provider.example/p2")
	})

	it("stops asking after three unprocessed answers and hands off to MyGarp", async () => {
		const bodies: Array<Record<string, unknown>> = []
		server.use(
			http.post(AUTHORIZE_PATH, async ({ request }) => {
				bodies.push((await request.json()) as Record<string, unknown>)
				// The provider keeps saying "not yet".
				return HttpResponse.json(
					memberPortalEnvelope(examSetupAuthorizeResult()),
				)
			}),
		)
		const user = await renderScheduling()

		for (let attempt = 0; attempt < 3; attempt++) {
			await user.click(
				await screen.findByRole("button", { name: "Check again" }),
			)
			await waitFor(() => {
				expect(bodies).toHaveLength(attempt + 1)
			})
		}

		// Exhausted: no more asking a third-party integration.
		expect(
			await screen.findByText("One more step, in MyGarp"),
		).toBeInTheDocument()
		expect(
			screen.queryByRole("button", { name: "Check again" }),
		).not.toBeInTheDocument()
		// First ask plain, the rest flagged as retries.
		expect(bodies.map((body) => body.isRetry)).toEqual([false, true, true])
	})
})
