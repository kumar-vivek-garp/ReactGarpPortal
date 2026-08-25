import { AlertBarCard } from "@/components/molecules/alert-bar-card"
import { useAlertBar } from "@/hooks/use-alert-bar"

/**
 * The one exam alert this member must act on, above every portal page.
 *
 * Mounted once in the app layout rather than per page: the query is shared, so
 * navigating does not refetch, and the phase rides along with it.
 *
 * This is only half of the alert — its minimised half is `AlertBarTrigger`,
 * which lives in the toolbars. Exactly one of the two is ever visible.
 *
 * Renders nothing at all when there is no alert — which is the common case —
 * and nothing when the service is unreachable. It is chrome relative to the
 * page the member actually asked for, so it fails by being absent rather than
 * by toasting on every route.
 */
function AlertBar({ className }: { className?: string }) {
	const { model, phase, minimise, settleMinimised, settleExpanded } = useAlertBar()

	if (!model) return null

	return (
		<AlertBarCard
			model={model}
			phase={phase}
			onMinimise={minimise}
			onMinimised={settleMinimised}
			onRestored={settleExpanded}
			className={className}
		/>
	)
}

export { AlertBar }
