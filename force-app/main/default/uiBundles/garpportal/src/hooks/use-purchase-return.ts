import { useEffect, useRef } from "react"
import { useQueryClient } from "@tanstack/react-query"
import { useNavigate } from "@tanstack/react-router"

import { notifySuccess } from "@/api/client"
import { invalidatePurchaseCaches } from "@/api/study-materials/invalidate-caches"
import { PURCHASE_SUCCESS_NOTICE } from "@/config/study-materials"

/**
 * The payment provider's success return to the listing
 * (`/study-materials?purchased=1`): say so once, refresh what the purchase
 * changed, and drop the flag from the address so a reload or a shared link
 * does not announce it again.
 *
 * Ref-guarded because StrictMode runs effects twice and a second toast for
 * one purchase reads as two purchases.
 *
 * The toast waits for the navigation to commit: this effect runs during the
 * page's first mount, BEFORE the root's `Toaster` has subscribed (children's
 * effects run first), and a toast raised then is simply lost. Once the
 * address has been rewritten the whole tree — Toaster included — is up.
 */
export function usePurchaseReturn(purchased: string | undefined): void {
	const navigate = useNavigate({ from: "/study-materials/" })
	const queryClient = useQueryClient()
	const handled = useRef(false)

	useEffect(() => {
		if (purchased !== "1" || handled.current) return
		handled.current = true

		const announce = () =>
			notifySuccess(
				PURCHASE_SUCCESS_NOTICE.title,
				PURCHASE_SUCCESS_NOTICE.description,
			)

		void invalidatePurchaseCaches(queryClient)
		void navigate({
			search: (prev) => ({ ...prev, purchased: undefined }),
			replace: true,
		}).then(announce, announce)
	}, [purchased, navigate, queryClient])
}
