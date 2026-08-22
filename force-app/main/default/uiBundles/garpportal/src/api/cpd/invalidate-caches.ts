import type { QueryClient } from "@tanstack/react-query"

import { cpdQueryKeys } from "@/api/cpd/query-options"

/**
 * Refreshes CPD after a write.
 *
 * `cpdQueryKeys.all` prefix-matches both the page (`cpdProgram`) and the
 * dashboard card (`cpd`) — a claim changes the approved total the card draws,
 * and an attestation flips the certificate rows on the page. Activity types
 * are org configuration and no write touches them, but the prefix covers them
 * anyway, which costs one cheap refetch and cannot go stale by omission.
 */
export async function invalidateCpdCaches(
	queryClient: QueryClient,
): Promise<void> {
	await queryClient.invalidateQueries({ queryKey: cpdQueryKeys.all })
}
