import { useEffect, useState } from "react"

import { AppError } from "@/api/client"
import { fetchExamPaymentStatus } from "@/api/registration/exam-registration"
import type { PaymentStatusResult } from "@/api/registration/exam-types"
import {
	isNothingFound,
	isSettledStatus,
	isTransientNetworkError,
	PAYMENT_RETURN_DELAYS_MS,
} from "@/lib/payment-return-presentation"

export type PaymentReturnPoll = {
	status: PaymentStatusResult | null
	pollError: string | null
	settled: boolean
}

type PollOptions = {
	fetchStatus?: (id: string) => Promise<PaymentStatusResult>
	delays?: readonly number[]
	sleep?: (ms: number) => Promise<void>
	/** Stops the loop between steps once the screen has gone away. */
	isCancelled?: () => boolean
	/** Called with every answer so the screen can show the reference early. */
	onStatus?: (status: PaymentStatusResult) => void
}

function defaultSleep(ms: number): Promise<void> {
	return new Promise((resolve) => {
		window.setTimeout(resolve, ms)
	})
}

/**
 * Where Stripe sends a candidate who paid.
 *
 * Under the deferred flow the order does not exist yet when the browser lands
 * here — the webhook is still writing it — so this polls until the payment is
 * confirmed rather than declaring success on arrival. That gap is short but
 * real, and telling someone they are registered before the registration
 * exists is how support tickets start.
 *
 * It settles on one of three things and never spins forever: a settled status
 * (paid, declined, rolled back, or the records failed), a deterministic
 * refusal from the endpoint (a wrong or dead id), or the delays running dry.
 * Only a network hiccup earns a retry.
 */
export async function pollPaymentReturn(
	statusId: string,
	{
		fetchStatus = fetchExamPaymentStatus,
		delays = PAYMENT_RETURN_DELAYS_MS,
		sleep = defaultSleep,
		isCancelled = () => false,
		onStatus,
	}: PollOptions = {},
): Promise<PaymentReturnPoll> {
	let status: PaymentStatusResult | null = null
	for (const wait of delays) {
		if (isCancelled()) return { status, pollError: null, settled: false }
		try {
			status = await fetchStatus(statusId)
			if (isCancelled()) return { status, pollError: null, settled: false }
			onStatus?.(status)
			if (isSettledStatus(status)) return { status, pollError: null, settled: true }
			if (isNothingFound(status)) {
				return {
					status,
					pollError: "We could not find this registration.",
					settled: true,
				}
			}
		} catch (error) {
			if (isCancelled()) return { status, pollError: null, settled: false }
			if (!isTransientNetworkError(error)) {
				return {
					status,
					pollError:
						AppError.fromUnknown(error).messages[0] ??
						"The payment status could not be read.",
					settled: true,
				}
			}
		}
		await sleep(wait)
	}
	// Ran dry without a settled answer. The payment is safe either way and the
	// confirmation email follows; the screen says so rather than spinning.
	return { status, pollError: null, settled: true }
}

/**
 * The return leg's poll as React state. `settled` starts true when there is
 * no id — nothing to poll for, so that case begins finished rather than
 * setting state from inside the effect.
 */
export function usePaymentReturnStatus(
	statusId: string | null | undefined,
): PaymentReturnPoll {
	const [status, setStatus] = useState<PaymentStatusResult | null>(null)
	const [pollError, setPollError] = useState<string | null>(null)
	const [settled, setSettled] = useState(!statusId)

	useEffect(() => {
		if (!statusId) return
		let cancelled = false
		void pollPaymentReturn(statusId, {
			isCancelled: () => cancelled,
			onStatus: (next) => {
				if (!cancelled) setStatus(next)
			},
		}).then((result) => {
			if (cancelled || !result.settled) return
			setStatus(result.status)
			setPollError(result.pollError)
			setSettled(true)
		})
		return () => {
			cancelled = true
		}
	}, [statusId])

	return { status, pollError, settled }
}
