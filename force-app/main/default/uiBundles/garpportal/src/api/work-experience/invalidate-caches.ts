import type { QueryClient } from "@tanstack/react-query"

import { personalInfoQueryKeys } from "@/api/personal-info/query-options"
import { workExperienceQueryKeys } from "@/api/work-experience/query-options"

/**
 * Refreshes Work Experience after a write.
 *
 * Uses the `all` prefix rather than the specific `cv` key on purpose. Every
 * write changes more than the row it touched: Apex recomputes `timeAllotted`,
 * `totalTimeAllotted`, `isValidExperienceSubmission` and each row's overlap
 * warning on the next read, so saving one entry can change the months and the
 * warning shown on a different one. Refetching only the edited row would leave
 * the rest of the page confidently stale.
 *
 * The prefix also covers the per-experience form and attachment queries, which
 * a save or delete can invalidate too.
 */
export async function invalidateWorkExperienceCaches(
	queryClient: QueryClient,
): Promise<void> {
	await queryClient.invalidateQueries({
		queryKey: workExperienceQueryKeys.all,
	})
}

/**
 * Refreshes Work Experience **and My Account** after an address save.
 *
 * `cvAddress` does not write a CV-local address — it writes the member's own
 * Contact mailing fields, the same ones the Personal Information dialog edits,
 * and Apex clears its server-side contact cache afterwards. Leaving the
 * personal-info queries alone would show the member their old address in My
 * Account immediately after changing it here.
 */
export async function invalidateCvAddressCaches(
	queryClient: QueryClient,
): Promise<void> {
	await Promise.all([
		queryClient.invalidateQueries({ queryKey: workExperienceQueryKeys.all }),
		queryClient.invalidateQueries({ queryKey: personalInfoQueryKeys.all }),
	])
}
