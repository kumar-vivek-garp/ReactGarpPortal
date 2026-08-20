import { createFileRoute, redirect } from "@tanstack/react-router"

/**
 * Legacy top-level path — keep as a replace redirect so bookmarks and
 * older in-app links still resolve under My Account.
 */
export const Route = createFileRoute("/_appLayout/order-details/$orderNumber/")({
	beforeLoad: ({ params }) => {
		throw redirect({
			to: "/my-account/orders/$orderNumber",
			params: { orderNumber: params.orderNumber },
			replace: true,
		})
	},
})
