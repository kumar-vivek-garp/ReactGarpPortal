import { createFileRoute } from "@tanstack/react-router"

import {
	PAGE_PENDING_MIN_MS,
	PAGE_PENDING_MS,
	StudyMaterialPurchasePending,
} from "@/components/molecules/page-pending"
import { StudyMaterialPurchasePanel } from "@/components/forms/study-material-purchase/study-material-purchase-panel"
import {
	STUDY_MATERIAL_PURCHASE,
	materialPurchaseSearchSchema,
} from "@/config/study-materials"
import { pageTitle } from "@/lib/document-title"
import { isCheckoutCancelled } from "@/lib/registration-paths"

/**
 * Buying one study material. Members only — `_appLayout`'s guard covers
 * guests, and this path has no public twin for the guard to fall back to.
 */
export const Route = createFileRoute(
	"/_appLayout/study-materials/purchase/$productCode/",
)({
	validateSearch: materialPurchaseSearchSchema,
	head: () => ({
		meta: [{ title: pageTitle(STUDY_MATERIAL_PURCHASE.title) }],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: StudyMaterialPurchasePending,
	component: StudyMaterialPurchasePage,
})

function StudyMaterialPurchasePage() {
	const { productCode } = Route.useParams()
	const search = Route.useSearch()
	return (
		<StudyMaterialPurchasePanel
			productCode={productCode}
			checkoutCancelled={isCheckoutCancelled(search)}
		/>
	)
}
