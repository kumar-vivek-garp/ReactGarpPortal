/**
 * Typed fixtures for the payment leg of the exam-registration contract —
 * the return-leg status, the deferred flow's staged shapes, and the survey
 * options. Split from `exam.ts` by domain so neither file outgrows the cap.
 */

import type {
	DemographicsOptions,
	ExamRegisterResult,
	PaymentStatusResult,
	ResumeResult,
} from "@/api/registration/exam-types"

import { examRegisterRequest, examRegisterResult } from "@/testing/factories/exam"

/** An Opportunity-backed order that has been paid — the immediate flow's happy poll. */
export function paymentStatusResult(
	overrides: Partial<PaymentStatusResult> = {},
): PaymentStatusResult {
	return {
		isOrderFound: true,
		isPaymentFound: true,
		isPaymentSuccess: true,
		isOrderRolledback: false,
		paymentType: "Stripe",
		orderNumber: "ORD-1001",
		...overrides,
	}
}

/**
 * A `paymentStatus` answer for a STAGED id (deferred flow). Defaults to the
 * `Paid` state — the webhook has taken the money and is writing records.
 */
export function stagedPaymentStatus(
	overrides: Partial<PaymentStatusResult> = {},
): PaymentStatusResult {
	return {
		registrationStatus: "Paid",
		registrationRef: "REG-000123",
		isPaymentFound: true,
		isPaymentSuccess: true,
		...overrides,
	}
}

/** `register` under the deferred flow: a staged row, no order. */
export function stagedRegisterResult(
	overrides: Partial<ExamRegisterResult> = {},
): ExamRegisterResult {
	return examRegisterResult({
		orderId: null,
		orderNumber: null,
		registrationId: null,
		stagedId: "a0H-staged",
		registrationRef: "REG-000123",
		...overrides,
	})
}

/** A resumable staged registration carrying the payload it was created from. */
export function resumeResult(overrides: Partial<ResumeResult> = {}): ResumeResult {
	return {
		resumable: true,
		payload: examRegisterRequest(),
		registrationRef: "REG-000123",
		stagedId: "a0H-staged",
		expiresAt: Date.UTC(2026, 8, 7, 12, 30),
		...overrides,
	}
}

export function demographicsOptions(
	overrides: Partial<DemographicsOptions> = {},
): DemographicsOptions {
	return {
		picklists: {
			Currently_Working_Status__c: [
				{ label: "Working", value: "Working" },
				{ label: "Not working", value: "Not working" },
			],
			Area_of_Concentration__c: [{ label: "Banking", value: "Banking" }],
			Corporate_Title__c: [{ label: "Analyst", value: "Analyst" }],
			Job_Function__c: [
				{ label: "Risk Management", value: "Risk Management" },
				{ label: "Trading", value: "Trading" },
			],
			Risk_Specialty__c: [{ label: "Credit Risk", value: "Credit Risk" }],
			Highest_Degree__c: [{ label: "Bachelor's", value: "Bachelor's" }],
			Expected_Graduation_Month__c: [
				{ label: "May", value: "May" },
				{ label: "June", value: "June" },
			],
		},
		workingYears: ["2026", "2025", "2024"],
		graduationYears: ["2028", "2027", "2026"],
		...overrides,
	}
}
