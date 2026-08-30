import { animated, useTransition } from "@react-spring/web"
import { useNavigate } from "@tanstack/react-router"

import type { CaseSummary } from "@/api/help-center"
import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { Tabs } from "@/components/atoms/tabs"
import { SupportCaseForm } from "@/components/forms/support-case/support-case-form"
import { EmptyState } from "@/components/molecules/empty-state"
import {
	HelpCenterRequests,
	HelpCenterRequestsSkeleton,
} from "@/components/molecules/help-center-requests"
import { HelpCenterResources } from "@/components/molecules/help-center-resources"
import {
	GET_HELP_GRID,
	HELP_CENTER_SCROLL,
	HELP_CENTER_SHELL,
	HelpCenterHeader,
} from "@/components/organisms/help-center-chrome"
import {
	HELP_CENTER_BUCKET_META,
	HELP_REQUESTS_ERROR,
	type HelpCenterTab,
} from "@/config/help-center"
import { useCases } from "@/hooks/use-cases"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"
import { cn } from "@/lib/utils"

type HelpCenterPanelProps = {
	tab: HelpCenterTab
	className?: string
}

function GetHelpTabBody({ onSubmitted }: { onSubmitted: () => void }) {
	const { icon: Icon, heading } = HELP_CENTER_BUCKET_META["get-help"]

	return (
		<div className={GET_HELP_GRID}>
			{/* Same card grammar as AccountSectionCard so the form surface reads
			    like the rest of the portal's section cards. */}
			<Card className="min-w-0 gap-4 bg-card py-5">
				<CardHeader className="gap-1.5">
					<CardTitle className="flex min-w-0 items-center gap-2 font-heading text-lg tracking-wide">
						<span className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
							<Icon className="size-4.5" aria-hidden />
						</span>
						<span className="min-w-0 truncate">{heading}</span>
					</CardTitle>
					<CardDescription>
						Tell us what you need help with. A representative from Member
						Services will follow up.
					</CardDescription>
				</CardHeader>

				<CardContent>
					<SupportCaseForm onSubmitted={onSubmitted} />
				</CardContent>
			</Card>

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

export { HelpCenterPanel }
