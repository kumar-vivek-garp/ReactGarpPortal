import { useCallback, useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"

import {
	authorizeExamSetup,
	examSetupQueryKeys,
	examSetupQueryOptions,
	saveExamSetupId,
	type ExamSetupAuthorizeResult,
	type ExamSetupIdInput,
	type ExamSetupProgramType,
	type ExamSetupSelectionInput,
} from "@/api/exam-setup"
import {
	EXAM_SETUP_AUTHORIZE_ENABLED,
	EXAM_SETUP_AUTHORIZE_MAX_RETRIES,
} from "@/config/exam-setup"

/** The wizard's form for one programme (`GET /memberportal/examSetup`). */
export function useExamSetup(
	programType: ExamSetupProgramType | null,
	enabled = true,
) {
	return useQuery({
		...examSetupQueryOptions(programType ?? "frm"),
		enabled: enabled && programType !== null,
	})
}

/**
 * Saves the sitting and the ID together (`POST /memberportal/examSetupId`).
 *
 * Invalidates the form afterwards rather than patching it: a successful save
 * can change which administrations remain open to this member, and a stale
 * list would offer a sitting they have just moved away from.
 */
export function useSaveExamSetup(programType: ExamSetupProgramType) {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: (args: {
			id: ExamSetupIdInput
			selection: ExamSetupSelectionInput
		}) => saveExamSetupId({ programType, ...args }),
		meta: { errorTitle: "Unable to save your exam setup" },
		onSuccess: () =>
			queryClient.invalidateQueries({
				queryKey: examSetupQueryKeys.form(programType),
			}),
	})
}

export type ExamSetupAuthorizeState = {
	result: ExamSetupAuthorizeResult | null
	/** True while the provider is being asked, first attempt or retry. */
	isPending: boolean
	/** True once the provider answered "unprocessed" as many times as we ask. */
	isExhausted: boolean
	/** False when `EXAM_SETUP_AUTHORIZE_ENABLED` is off — nothing will be called. */
	isEnabled: boolean
	attempts: number
	authorize: () => void
	retry: () => void
}

/**
 * The provider push (`POST /memberportal/examSetupAuthorize`).
 *
 * Two things make this unlike the other mutations here.
 *
 * It is an OUTBOUND INTEGRATION — `ExamRegistrationsStatusCls.updateRegistration`
 * reaches Pearson / PSI / ATA for real from whichever org runs it. Every call
 * site is gated on `EXAM_SETUP_AUTHORIZE_ENABLED`, which is off until the
 * backend team confirms the sandbox path is safe. With it off `authorize()` is
 * a no-op and the outcome screen shows the MyGarp handoff instead.
 *
 * And the provider can answer "not yet". `isRetry` exists for that, so this
 * counts attempts and stops at `EXAM_SETUP_AUTHORIZE_MAX_RETRIES` rather than
 * polling a third-party integration forever.
 */
export function useAuthorizeExamSetup(
	programType: ExamSetupProgramType,
): ExamSetupAuthorizeState {
	const [attempts, setAttempts] = useState(0)

	const mutation = useMutation({
		mutationFn: (isRetry: boolean) =>
			authorizeExamSetup({ programType, isRetry }),
		meta: { errorTitle: "Unable to authorize your exam scheduling" },
	})

	const { mutate } = mutation

	const run = useCallback(
		(isRetry: boolean) => {
			if (!EXAM_SETUP_AUTHORIZE_ENABLED) return
			setAttempts((count) => count + 1)
			mutate(isRetry)
		},
		[mutate],
	)

	const authorize = useCallback(() => run(false), [run])
	const retry = useCallback(() => run(true), [run])

	const result = mutation.data ?? null
	const unprocessed = result != null && result.isAuthorized !== true

	return {
		result,
		isPending: mutation.isPending,
		isExhausted: unprocessed && attempts >= EXAM_SETUP_AUTHORIZE_MAX_RETRIES,
		isEnabled: EXAM_SETUP_AUTHORIZE_ENABLED,
		attempts,
		authorize,
		retry,
	}
}
