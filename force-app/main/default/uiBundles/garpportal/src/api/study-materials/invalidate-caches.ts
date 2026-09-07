import type { QueryClient } from "@tanstack/react-query"

import { ordersQueryKeys } from "@/api/orders/query-options"
import { studyMaterialsQueryKeys } from "@/api/study-materials/query-options"

/**
 * After a purchase leg lands — the success return on the listing, or the
 * cancel leg on the purchase page — both of these can be stale: the
 * catalogue's owned / unpaid flags, and Order History, where an unpaid
 * order now sits under the immediate flow.
 */
export async function invalidatePurchaseCaches(
	queryClient: QueryClient,
): Promise<void> {
	await Promise.all([
		queryClient.invalidateQueries({ queryKey: studyMaterialsQueryKeys.all }),
		queryClient.invalidateQueries({ queryKey: ordersQueryKeys.all }),
	])
}
