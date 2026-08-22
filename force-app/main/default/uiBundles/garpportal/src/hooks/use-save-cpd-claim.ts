import { useMutation, useQueryClient } from "@tanstack/react-query"

import {
	attestCpdCycle,
	deleteCpdClaim,
	invalidateCpdCaches,
	saveCpdClaim,
	type CpdClaimInput,
} from "@/api/cpd"

/** Create or update a CPD activity (`POST /memberportal/cpdClaim`). */
export function useSaveCpdClaim(isEdit: boolean) {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: (input: CpdClaimInput) => saveCpdClaim(input),
		meta: {
			successMessage: isEdit ? "Activity updated" : "Activity submitted",
			errorTitle: isEdit
				? "Unable to update activity"
				: "Unable to submit activity",
		},
		onSuccess: async () => {
			await invalidateCpdCaches(queryClient)
		},
	})
}

/** Remove a pending CPD activity (`POST /memberportal/cpdClaimDelete`). */
export function useDeleteCpdClaim() {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: (claimId: string) => deleteCpdClaim(claimId),
		meta: {
			successMessage: "Activity deleted",
			errorTitle: "Unable to delete activity",
		},
		onSuccess: async () => {
			await invalidateCpdCaches(queryClient)
		},
	})
}

/**
 * Attest the cycle (`POST /memberportal/cpdAttest`).
 *
 * Invalidation matters more here than elsewhere: `isAttested` is what gates the
 * certificate links, and the legacy never refreshed it — a member who attested
 * was re-prompted on their next certificate in the same session.
 */
export function useAttestCpdCycle() {
	const queryClient = useQueryClient()
	return useMutation({
		mutationFn: (attestationId: string) => attestCpdCycle(attestationId),
		meta: { errorTitle: "Unable to record your attestation" },
		onSuccess: async () => {
			await invalidateCpdCaches(queryClient)
		},
	})
}
