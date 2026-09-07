import { useCallback, useEffect, useRef, useState } from "react"
import { useMutation, useQuery } from "@tanstack/react-query"

import {
	authorizeExamSetup,
	examSetupQueryOptions,
	fetchExamSetupFees,
	saveExamSetupId,
	type ExamSetupAuthorizeResult,
	type ExamSetupFeesView,
	type ExamSetupIdInput,
	type ExamSetupProgramType,
	type ExamSetupSelectionInput,
} from "@/api/exam-setup"
import {
	EXAM_SETUP_AUTH_RETRY_MS,
	EXAM_SETUP_AUTHORIZE_ENABLED,
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
 * `meta.silent` because a refusal is not an exception here: Apex answers the
 * deferral rules through `statusCode` / `statusMessage` on a resolved result,
 * and the panel prints that against the step the member can fix it on. Only a
 * genuine transport failure reaches the toast layer, and that still throws.
 *
 * Deliberately does **not** invalidate the form query. The wizard moves to its
 * outcome step on success and offers no way back, so a refetch would only race
 * an unmount — and this write is not idempotent, so nothing should encourage a
 * second trip through it.
 */
export function useSaveExamSetup(programType: ExamSetupProgramType) {
	return useMutation({
		mutationFn: (args: {
			id: ExamSetupIdInput
			selection: ExamSetupSelectionInput
		}) => saveExamSetupId({ programType, ...args }),
		meta: { silent: true },
	})
}

/**
 * Prices a raised modification for the Pay Fees outcome.
 *
 * Silent by design: the member has already been charged nothing and the
 * checkout link works without the breakdown, so a failure here degrades to
 * "no table" rather than an error toast on a screen that is otherwise good news.
 */
export function useExamSetupFees() {
	return useMutation<ExamSetupFeesView, Error, string>({
		mutationFn: (modificationId: string) => fetchExamSetupFees(modificationId),
		meta: { silent: true },
	})
}

export type ExamSetupAuthorizeState = {
	result: ExamSetupAuthorizeResult | null
	/** True while the provider is being asked, first attempt or retry. */
	isAuthorising: boolean
	/** False when `EXAM_SETUP_AUTHORIZE_ENABLED` is off — nothing will be called. */
	isEnabled: boolean
	/** True once a run has finished, whatever it answered. */
	hasRun: boolean
	run: () => void
}

/**
 * The provider push (`POST /memberportal/examSetupAuthorize`).
 *
 * Two things make this unlike the other mutations here.
 *
 * It is an OUTBOUND INTEGRATION — `ExamRegistrationsStatusCls.updateRegistration`
 * reaches Pearson / PSI / ATA for real from whichever org runs it. Every call
 * site is gated on `EXAM_SETUP_AUTHORIZE_ENABLED`, which is off until the
 * backend team confirms the sandbox path is safe. With it off `run()` is a
 * no-op and the outcome screen shows the MyGarp hand-off instead.
 *
 * And the provider can answer "not yet". Authorisation is not instant, so this
 * asks once, waits, and asks once more with `isRetry` before giving up — a
 * single retry, not a poll. Polling a third-party integration from a member's
 * browser is how you turn one slow vendor into a stampede.
 */
export function useAuthorizeExamSetup(
	programType: ExamSetupProgramType,
): ExamSetupAuthorizeState {
	const [result, setResult] = useState<ExamSetupAuthorizeResult | null>(null)
	const [isAuthorising, setAuthorising] = useState(false)
	const [hasRun, setHasRun] = useState(false)

	// A pending retry must not outlive the screen that asked for it.
	const timer = useRef<ReturnType<typeof setTimeout> | null>(null)
	const cancelled = useRef(false)

	useEffect(() => {
		cancelled.current = false
		return () => {
			cancelled.current = true
			if (timer.current) clearTimeout(timer.current)
		}
	}, [])

	const run = useCallback(() => {
		if (!EXAM_SETUP_AUTHORIZE_ENABLED) return

		const wait = () =>
			new Promise<void>((resolve) => {
				timer.current = setTimeout(resolve, EXAM_SETUP_AUTH_RETRY_MS)
			})

		const attempt = async () => {
			setAuthorising(true)
			try {
				let answer = await authorizeExamSetup({ programType, isRetry: false })
				if (!answer.isAuthorized) {
					await wait()
					if (cancelled.current) return
					answer = await authorizeExamSetup({ programType, isRetry: true })
				}
				if (!cancelled.current) setResult(answer)
			} catch {
				// The outcome screen reads a null result as "not completed", which is
				// the honest answer: we do not know whether the provider took it.
				if (!cancelled.current) setResult(null)
			} finally {
				if (!cancelled.current) {
					setAuthorising(false)
					setHasRun(true)
				}
			}
		}

		void attempt()
	}, [programType])

	return {
		result,
		isAuthorising,
		isEnabled: EXAM_SETUP_AUTHORIZE_ENABLED,
		hasRun,
		run,
	}
}
