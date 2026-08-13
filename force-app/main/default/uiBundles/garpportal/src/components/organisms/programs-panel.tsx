import type { ReactNode } from "react"
import { animated, useTransition } from "@react-spring/web"
import { useNavigate } from "@tanstack/react-router"
import { Award, Compass, GraduationCap, Hourglass } from "lucide-react"
import type { LucideIcon } from "lucide-react"

import type {
	CompletedProgram,
	EnrolledProgram,
	OtherProgram,
} from "@/api/programs"
import { Skeleton } from "@/components/atoms/skeleton"
import { Tabs, TabsList, TabsTrigger } from "@/components/atoms/tabs"
import { ProgramCard } from "@/components/molecules/program-card"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import type { ProgramsTab } from "@/config/programs"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"
import { cn } from "@/lib/utils"
import { usePrograms } from "@/hooks/use-programs"

const pillTriggerClassName = cn(
	"h-auto flex-none shrink-0 cursor-pointer rounded-xl border-0 px-5 py-2 text-sm font-semibold shadow-none",
	"bg-muted text-foreground hover:bg-muted/80 hover:text-foreground",
	"data-[state=active]:bg-deep-purple data-[state=active]:text-deep-purple-foreground",
	"data-[state=active]:hover:bg-deep-purple data-[state=active]:hover:text-deep-purple-foreground",
	"after:hidden",
)

const TAB_ITEMS: Array<{ value: ProgramsTab; label: string }> = [
	{ value: "all", label: "All" },
	{ value: "in-progress", label: "In Progress" },
	{ value: "completed", label: "Completed" },
	{ value: "explore", label: "Explore Other" },
]

type ProgramsPanelProps = {
	tab: ProgramsTab
}

function ProgramsEmptyState({
	icon: Icon,
	title,
	message,
}: {
	icon: LucideIcon
	title: string
	message: string
}) {
	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-16 text-center">
			<Icon
				className="size-10 text-muted-foreground"
				aria-hidden
			/>
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{title}
			</p>
			<p className="mt-2 max-w-md text-sm text-muted-foreground">{message}</p>
		</div>
	)
}

function ProgramCardSkeleton() {
	return (
		<Skeleton className="flex h-full flex-col gap-4 overflow-hidden rounded-xl border border-border py-0">
			<div className="flex h-44 items-center justify-center bg-muted/40 p-4">
				<Skeleton className="h-full w-full max-w-[12rem] rounded-xl" />
			</div>
			<div className="space-y-2 px-5 pt-1">
				<Skeleton className="h-5 w-4/5" />
			</div>
			<div className="flex-1 space-y-2 px-5">
				<Skeleton className="h-3.5 w-full" />
				<Skeleton className="h-3.5 w-full" />
				<Skeleton className="h-3.5 w-3/4" />
			</div>
			<div className="mt-auto px-5 pb-5">
				<Skeleton className="h-4 w-28" />
			</div>
		</Skeleton>
	)
}

function ProgramsContentSkeleton() {
	return (
		<div
			className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
			aria-busy
			aria-label="Loading programs"
		>
			{[0, 1, 2, 3, 4, 5, 6, 7].map((key) => (
				<ProgramCardSkeleton key={key} />
			))}
		</div>
	)
}

function ProgramGrid({ children }: { children: ReactNode }) {
	return (
		<StaggerReveal
			className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
			itemClassName="h-full"
		>
			{children}
		</StaggerReveal>
	)
}

function emptyForTab(tab: Exclude<ProgramsTab, "all">) {
	if (tab === "in-progress") {
		return {
			icon: Hourglass,
			title: "No programs in progress",
			message:
				"When you enroll in a program, it will show up here.",
		}
	}
	if (tab === "completed") {
		return {
			icon: Award,
			title: "No completed programs",
			message: "Programs you finish will appear here.",
		}
	}
	return {
		icon: Compass,
		title: "Nothing else to explore",
		message:
			"You're already enrolled in or have completed every program we offer right now.",
	}
}

function ProgramsTabBody({
	tab,
	enrolled,
	completed,
	other,
}: {
	tab: ProgramsTab
	enrolled: EnrolledProgram[]
	completed: CompletedProgram[]
	other: OtherProgram[]
}) {
	if (tab === "in-progress") {
		if (enrolled.length === 0) {
			return <ProgramsEmptyState {...emptyForTab(tab)} />
		}
		return (
			<ProgramGrid>
				{enrolled.map((program) => (
					<ProgramCard
						key={program.programType}
						variant="inProgress"
						program={program}
					/>
				))}
			</ProgramGrid>
		)
	}

	if (tab === "completed") {
		if (completed.length === 0) {
			return <ProgramsEmptyState {...emptyForTab(tab)} />
		}
		return (
			<ProgramGrid>
				{completed.map((program) => (
					<ProgramCard
						key={program.programType}
						variant="completed"
						program={program}
					/>
				))}
			</ProgramGrid>
		)
	}

	if (tab === "explore") {
		if (other.length === 0) {
			return <ProgramsEmptyState {...emptyForTab(tab)} />
		}
		return (
			<ProgramGrid>
				{other.map((program) => (
					<ProgramCard
						key={program.programType}
						variant="other"
						program={program}
					/>
				))}
			</ProgramGrid>
		)
	}

	const isEmpty =
		enrolled.length === 0 && completed.length === 0 && other.length === 0

	if (isEmpty) {
		return (
			<ProgramsEmptyState
				icon={GraduationCap}
				title="No programs to show"
				message="Your programs will appear here once they are available."
			/>
		)
	}

	return (
		<div className="space-y-8">
			{enrolled.length > 0 ? (
				<section className="space-y-4">
					<h2 className="font-heading text-xl font-semibold tracking-wide text-foreground">
						In Progress
						<span className="ml-2 text-base font-normal text-muted-foreground">
							({enrolled.length})
						</span>
					</h2>
					<ProgramGrid>
						{enrolled.map((program) => (
							<ProgramCard
								key={program.programType}
								variant="inProgress"
								program={program}
							/>
						))}
					</ProgramGrid>
				</section>
			) : null}

			{completed.length > 0 ? (
				<section className="space-y-4">
					<h2 className="font-heading text-xl font-semibold tracking-wide text-foreground">
						Completed
						<span className="ml-2 text-base font-normal text-muted-foreground">
							({completed.length})
						</span>
					</h2>
					<ProgramGrid>
						{completed.map((program) => (
							<ProgramCard
								key={program.programType}
								variant="completed"
								program={program}
							/>
						))}
					</ProgramGrid>
				</section>
			) : null}

			{other.length > 0 ? (
				<section className="space-y-4">
					<h2 className="font-heading text-xl font-semibold tracking-wide text-foreground">
						Explore Other Programs
						<span className="ml-2 text-base font-normal text-muted-foreground">
							({other.length})
						</span>
					</h2>
					<ProgramGrid>
						{other.map((program) => (
							<ProgramCard
								key={program.programType}
								variant="other"
								program={program}
							/>
						))}
					</ProgramGrid>
				</section>
			) : null}
		</div>
	)
}

function tabCount(
	tab: ProgramsTab,
	enrolled: number,
	completed: number,
	other: number,
): number {
	if (tab === "in-progress") return enrolled
	if (tab === "completed") return completed
	if (tab === "explore") return other
	return enrolled + completed + other
}

function ProgramsPanel({ tab }: ProgramsPanelProps) {
	const navigate = useNavigate({ from: "/programs/" })
	const { data, isLoading, isError } = usePrograms()
	const enrolled = data?.enrolledPrograms ?? []
	const completed = data?.completedPrograms ?? []
	const other = data?.otherPrograms ?? []
	const tabTransitions = useTransition(tab, TAB_PANEL_TRANSITION)

	return (
		<Tabs
			value={tab}
			onValueChange={(value) => {
				void navigate({
					search: { tab: value as ProgramsTab },
					replace: true,
				})
			}}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			<header className="shrink-0 space-y-4">
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					My Programs
				</h1>

				<div className="overflow-x-auto overscroll-x-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
					<TabsList className="h-auto w-max gap-3 bg-transparent p-0">
						{TAB_ITEMS.map((item) => {
							const count = tabCount(
								item.value,
								enrolled.length,
								completed.length,
								other.length,
							)
							return (
								<TabsTrigger
									key={item.value}
									value={item.value}
									className={pillTriggerClassName}
								>
									{item.label}
									{!isLoading ? (
										<span className="ml-1.5 font-normal opacity-70">
											({count})
										</span>
									) : null}
								</TabsTrigger>
							)
						})}
					</TabsList>
				</div>
			</header>

			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				{isLoading ? <ProgramsContentSkeleton /> : null}

				{isError ? (
					<p className="text-sm text-muted-foreground">
						We couldn&apos;t load your programs. Please try again later.
					</p>
				) : null}

				{!isLoading && !isError
					? tabTransitions((style, currentTab) => (
							<animated.div
								key={currentTab}
								role="tabpanel"
								style={style}
								className="pb-2"
							>
								<ProgramsTabBody
									tab={currentTab}
									enrolled={enrolled}
									completed={completed}
									other={other}
								/>
							</animated.div>
						))
					: null}
			</div>
		</Tabs>
	)
}

export { ProgramsPanel }
