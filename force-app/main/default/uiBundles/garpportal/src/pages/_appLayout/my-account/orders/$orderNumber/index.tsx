import { createFileRoute } from "@tanstack/react-router"

import {
	OrderDetailPending,
	PAGE_PENDING_MIN_MS,
	PAGE_PENDING_MS,
} from "@/components/molecules/page-pending"
import { OrderDetailPanel } from "@/components/organisms/order-detail-panel"
import { pageTitle } from "@/lib/document-title"

export const Route = createFileRoute(
	"/_appLayout/my-account/orders/$orderNumber/",
)({
	head: () => ({
		meta: [{ title: pageTitle("Order Detail") }],
	}),
	pendingMs: PAGE_PENDING_MS,
	pendingMinMs: PAGE_PENDING_MIN_MS,
	pendingComponent: OrderDetailPending,
	component: OrderDetailPage,
})

function OrderDetailPage() {
	const { orderNumber } = Route.useParams()
	return <OrderDetailPanel orderNumber={orderNumber} />
}
