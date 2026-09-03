import { act } from "@testing-library/react"
import { http, HttpResponse } from "msw"
import { beforeEach, describe, expect, it, vi } from "vitest"

import type { ExamRegistrationLoad } from "@/api/registration/exam-types"
import {
	useExamRegistrationLoad,
	useExamRegistrationState,
} from "@/hooks/use-exam-registration"
import { memberPortalEnvelope } from "@/testing/factories/envelope"
import {
	examLoad,
	feesResult,
	registrationAddress,
} from "@/testing/factories/exam"
import { EXAMREG_PATH, examregGet } from "@/testing/msw/handlers/examreg"
import { server } from "@/testing/msw/server"
import { renderHookWithProviders } from "@/testing/render"

/** Every mount opens the fees query immediately — give it a quiet answer. */
beforeEach(() => {
	server.use(
		http.post(`${EXAMREG_PATH}/fees`, () =>
			HttpResponse.json(memberPortalEnvelope(feesResult(100))),
		),
	)
})

function stateProps(load: ExamRegistrationLoad = examLoad()) {
	return {
		load,
		programType: "frm",
		billingCountry: "",
		mobilePhoneCode: "",
		paymentType: "",
		billingAddress: registrationAddress({ country: "" }),
		shippingAddress: registrationAddress(),
		billingAndShippingSame: true,
		autoRenew: false,
		membershipSelected: false,
	}
}

function renderState(load?: ExamRegistrationLoad) {
	return renderHookWithProviders(
		(props: ReturnType<typeof stateProps>) => useExamRegistrationState(props),
		{ initialProps: stateProps(load) },
	)
}

const BOTH_PARTS = "FRM Exam Part I and FRM Exam Part II"

describe("useExamRegistrationState — selection", () => {
	it("starts unselected when several part options exist", () => {
		const { result } = renderState()

		expect(result.current.selection.partSelected).toBe("")
		expect(result.current.part1Active).toBe(false)
		expect(result.current.part2Active).toBe(false)
		expect(result.current.selection.part1).toEqual({ rateId: "", siteId: "" })
		expect(result.current.selection.part2).toEqual({ rateId: "", siteId: "" })
		// No part chosen yet: only the part-agnostic material is visible.
		expect(
			result.current.visibleMaterials.map((material) => material.productCode),
		).toEqual(["SM-GEN"])
	})

	it("pre-selects a sole part option and defaults its earliest sitting", () => {
		const load = examLoad()
		load.examSelection = {
			...load.examSelection!,
			partsAvailable: ["FRM Exam Part I"],
		}
		const { result } = renderState(load)

		expect(result.current.selection.partSelected).toBe("FRM Exam Part I")
		expect(result.current.part1Active).toBe(true)
		// The earliest sitting fills itself in; two sites means no site default.
		expect(result.current.selection.part1).toEqual({
			rateId: "rate-1a",
			siteId: "",
		})
		expect(result.current.selection.part2).toEqual({ rateId: "", siteId: "" })
	})

	it("activates both parts with sitting defaults on the combined option", () => {
		const { result } = renderState()

		act(() => {
			result.current.selectPart(BOTH_PARTS)
		})

		expect(result.current.part1Active).toBe(true)
		expect(result.current.part2Active).toBe(true)
		expect(result.current.selection.part1.rateId).toBe("rate-1a")
		expect(result.current.selection.part2.rateId).toBe("rate-2a")
		expect(
			result.current.visibleMaterials.map((material) => material.productCode),
		).toEqual(["SM-P1", "SM-P2", "SM-GEN"])
	})

	it("switching parts drops the other part's choice AND its study materials", () => {
		const { result } = renderState()

		act(() => {
			result.current.selectPart(BOTH_PARTS)
		})
		act(() => {
			result.current.selectSite(1, "site-a2")
			result.current.selectSite(2, "site-c2")
			result.current.toggleMaterial("SM-P2")
			result.current.toggleMaterial("SM-GEN")
		})

		expect(result.current.selection.part2).toEqual({
			rateId: "rate-2a",
			siteId: "site-c2",
		})

		act(() => {
			result.current.selectPart("FRM Exam Part I")
		})

		expect(result.current.part2Active).toBe(false)
		expect(result.current.selection.part2).toEqual({ rateId: "", siteId: "" })
		// Part I's own choice survives the switch.
		expect(result.current.selection.part1).toEqual({
			rateId: "rate-1a",
			siteId: "site-a2",
		})
		// The dropped part's book leaves the cart; the general one stays.
		const selected = result.current.materials
			.filter((material) => material.selected)
			.map((material) => material.productCode)
		expect(selected).toEqual(["SM-GEN"])
		expect(
			result.current.visibleMaterials.map((material) => material.productCode),
		).toEqual(["SM-P1", "SM-GEN"])

		// And the mirror image: dropping Part I drops its book too.
		act(() => {
			result.current.toggleMaterial("SM-P1")
		})
		act(() => {
			result.current.selectPart("FRM Exam Part II")
		})
		expect(result.current.selection.part1).toEqual({ rateId: "", siteId: "" })
		expect(
			result.current.materials
				.filter((material) => material.selected)
				.map((material) => material.productCode),
		).toEqual(["SM-GEN"])
	})

	it("selectAdmin clears the site; a single-site sitting fills itself back in", () => {
		const { result } = renderState()

		act(() => {
			result.current.selectPart("FRM Exam Part I")
		})
		act(() => {
			result.current.selectSite(1, "site-a2")
		})
		expect(result.current.selection.part1).toEqual({
			rateId: "rate-1a",
			siteId: "site-a2",
		})

		// The new sitting has one site — dropped, then auto-filled.
		act(() => {
			result.current.selectAdmin(1, "rate-1b")
		})
		expect(result.current.selection.part1).toEqual({
			rateId: "rate-1b",
			siteId: "site-b1",
		})

		// Back to a two-site sitting: the old site does NOT come back.
		act(() => {
			result.current.selectAdmin(1, "rate-1a")
		})
		expect(result.current.selection.part1).toEqual({
			rateId: "rate-1a",
			siteId: "",
		})
	})

	it("selectAdmin on part 2 leaves part 1 untouched", () => {
		const { result } = renderState()

		act(() => {
			result.current.selectPart(BOTH_PARTS)
		})
		act(() => {
			result.current.selectSite(1, "site-a1")
			result.current.selectAdmin(2, "rate-2a")
		})

		expect(result.current.selection.part1).toEqual({
			rateId: "rate-1a",
			siteId: "site-a1",
		})
		expect(result.current.selection.part2).toEqual({
			rateId: "rate-2a",
			siteId: "",
		})
	})
})

describe("useExamRegistrationLoad", () => {
	it("resolves the /info payload for the programme", async () => {
		const info = examregGet("info", () => examLoad())
		server.use(info.handler)

		const { result } = renderHookWithProviders(() =>
			useExamRegistrationLoad("frm", "TEAM24"),
		)

		await vi.waitFor(() => {
			expect(result.current.isSuccess).toBe(true)
		})
		expect(info.spy.hits).toBe(1)
		expect(result.current.data?.program.type).toBe("frm")
		expect(result.current.data?.eligibility.isEligible).toBe(true)
	})
})
