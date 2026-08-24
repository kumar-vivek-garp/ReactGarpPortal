import { AlertBarBanner } from "@/components/molecules/alert-bar-banner"
import { useAlertBar } from "@/hooks/use-alert-bar"

/**
 * The one exam alert this member must act on, above every portal page.
 *
 * Mounted once in the app layout rather than per page: the query is shared, so
 * navigating does not refetch, and the collapsed state rides along with it.
 *
 * Renders nothing at all when there is no alert — which is the common case —
 * and nothing when the service is unreachable. It is chrome relative to the
 * page the member actually asked for, so it fails by being absent rather than
 * by toasting on every route.
 */
function AlertBar({ className }: { className?: string }) {
	const { model, isCollapsed, collapse, expand } = useAlertBar()

	if (!model) return null

	return (
		<AlertBarBanner
			model={model}
			isCollapsed={isCollapsed}
			onCollapse={collapse}
			onExpand={expand}
			className={className}
		/>
	)
}

export { AlertBar }
