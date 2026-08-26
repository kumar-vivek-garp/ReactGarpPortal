import { animated, useTransition } from "@react-spring/web"
import { useNavigate } from "@tanstack/react-router"

import type { CaseSummary } from "@/api/help-center"
import { PillTabs } from "@/components/atoms/pill-tabs"
import { Tabs } from "@/components/atoms/tabs"
import { SupportCaseForm } from "@/components/forms/support-case/support-case-form"
import { EmptyState } from "@/components/molecules/empty-state"
import {
	HelpCenterRequests,
	HelpCenterRequestsSkeleton,
} from "@/components/molecules/help-center-requests"
import { HelpCenterResources } from "@/components/molecules/help-center-resources"
import {
	HELP_CENTER_BUCKET_META,
	HELP_CENTER_TAB_ITEMS,
	HELP_REQUESTS_ERROR,
	type HelpCenterTab,
} from "@/config/help-center"
import { useCases } from "@/hooks/use-cases"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"
import { cn } from "@/lib/utils"

/**
 * Full-height panel shell shared with the pending skeleton so the chrome
 * cannot drift — same shape as Programs / My Account / Events.
 */
const HELP_CENTER_SHELL =
	"-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
const HELP_CENTER_SCROLL =
	"mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
const GET_HELP_GRID =
	"grid items-start gap-8 lg:grid-cols-[minmax(0,7fr)_minmax(0,3fr)] lg:gap-10"

type HelpCenterPanelProps = {
	tab: HelpCenterTab
	className?: string
}

/** Fixed chrome above the scroll region — also rendered by the pending shell. */
function HelpCenterHeader({
	tab,
	requestCount,
}: {
	tab: HelpCenterTab
	requestCount?: number
}) {
	return (
		<header className="shrink-0 space-y-4">
			<div>
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					Help Center
				</h1>
				<p className="mt-1 max-w-2xl text-sm text-muted-foreground">
					Open a support case with Member Services, track requests you have
					already raised, or use the links for FAQs and other contact options.
				</p>
			</div>

			<PillTabs
				items={HELP_CENTER_TAB_ITEMS.map((item) =>
					item.value === "requests" && requestCount !== undefined
						? { ...item, count: requestCount }
						: item,
				)}
				value={tab}
			/>
		</header>
	)
}

function GetHelpTabBody({ onSubmitted }: { onSubmitted: () => void }) {
	const { icon: Icon, heading } = HELP_CENTER_BUCKET_META["get-help"]

	return (
		<div className={GET_HELP_GRID}>
			<section className="min-w-0 space-y-5">
				<div>
					<h2 className="flex items-center gap-2 font-heading text-xl font-semibold tracking-wide text-foreground">
						<Icon className="size-5 shrink-0 text-primary" aria-hidden />
						{heading}
					</h2>
					<p className="mt-1 text-sm text-muted-foreground">
						Tell us what you need help with. A representative from Member
						Services will follow up.
					</p>
				</div>

				<SupportCaseForm onSubmitted={onSubmitted} />
			</section>

			<HelpCenterResources className="lg:h-full" />
		</div>
	)
}

function RequestsTabBody({
	cases,
	isPending,
	isError,
}: {
	cases: CaseSummary[] | undefined
	isPending: boolean
	isError: boolean
}) {
	if (isPending) return <HelpCenterRequestsSkeleton />

	if (isError) {
		return <EmptyState {...HELP_REQUESTS_ERROR} tone="error" />
	}

	return <HelpCenterRequests cases={cases ?? []} />
}

function HelpCenterPanel({ tab, className }: HelpCenterPanelProps) {
	const navigate = useNavigate({ from: "/help-center/" })
	const { data, isPending, isError } = useCases()

	const selectTab = (next: HelpCenterTab) => {
		void navigate({ search: { tab: next }, replace: true })
	}

	/**
	 * Land on the requests list after submitting: the new case appearing with a
	 * status is stronger confirmation than a thank-you message, and it is where
	 * the member will look to track it. The mutation's success toast is the
	 * single explicit confirmation.
	 */
	const handleSubmitted = () => {
		selectTab("requests")
	}

	const tabTransitions = useTransition(tab, TAB_PANEL_TRANSITION)

	return (
		<Tabs
			value={tab}
			onValueChange={(value) => selectTab(value as HelpCenterTab)}
			className={cn(HELP_CENTER_SHELL, className)}
		>
			<HelpCenterHeader tab={tab} requestCount={data?.length ?? 0} />

			<div className={HELP_CENTER_SCROLL}>
				{tabTransitions((style, currentTab) => (
					<animated.div
						key={currentTab}
						role="tabpanel"
						style={style}
						className="pb-2"
					>
						{currentTab === "get-help" ? (
							<GetHelpTabBody onSubmitted={handleSubmitted} />
						) : (
							<RequestsTabBody
								cases={data}
								isPending={isPending}
								isError={isError}
							/>
						)}
					</animated.div>
				))}
			</div>
		</Tabs>
	)
}

export {
	GET_HELP_GRID,
	HELP_CENTER_SCROLL,
	HELP_CENTER_SHELL,
	HelpCenterHeader,
	HelpCenterPanel,
}
