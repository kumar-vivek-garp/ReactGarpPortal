import { Link } from "@tanstack/react-router"
import { CircleArrowRight } from "lucide-react"

import type { DashboardEnrolledPreview } from "@/api/dashboard"
import { SpringNudge } from "@/components/atoms/spring-nudge"
import { useSpringNudge } from "@/hooks/use-spring-nudge"
import {
	programTypeSlug,
	supportsInAppProgramDetail,
} from "@/lib/program-card-links"
import { cn } from "@/lib/utils"

const LINK_CLASS =
	"inline-flex items-center text-sm font-semibold text-primary hover:text-primary/80"

function DashboardEnrolledItem({
	program,
}: {
	program: DashboardEnrolledPreview
}) {
	const nudge = useSpringNudge({ direction: "forward" })
	const inApp = supportsInAppProgramDetail(program.programType)
	const slug = programTypeSlug(program.programType)
	const routeSlug = inApp ? (slug === "rai" ? "riskai" : slug) : null

	const label = (
		<SpringNudge
			nudge={nudge}
			icon={<CircleArrowRight className="size-4" />}
			iconPosition="trailing"
			className="gap-1.5"
		>
			<span>{program.name}</span>
		</SpringNudge>
	)

	return (
		<li className="rounded-xl border border-border/60 bg-background/50 p-3">
			{routeSlug ? (
				<Link
					to="/programs/$programType"
					params={{ programType: routeSlug }}
					className={LINK_CLASS}
					{...nudge.bind}
				>
					{label}
				</Link>
			) : (
				<Link
					to="/programs"
					search={{ tab: "in-progress" }}
					className={LINK_CLASS}
					{...nudge.bind}
				>
					{label}
				</Link>
			)}
			{program.adminPartIName ? (
				<p className="mt-1 text-sm text-muted-foreground">
					{program.adminPartIName}
				</p>
			) : null}
			{program.adminPartIIName ? (
				<p className="text-sm text-muted-foreground">
					{program.adminPartIIName}
				</p>
			) : null}
		</li>
	)
}

type DashboardEnrolledListProps = {
	programs: DashboardEnrolledPreview[]
	className?: string
}

function DashboardEnrolledList({
	programs,
	className,
}: DashboardEnrolledListProps) {
	if (programs.length === 0) return null

	return (
		<ul className={cn("space-y-3", className)}>
			{programs.map((program) => (
				<DashboardEnrolledItem
					key={program.programType}
					program={program}
				/>
			))}
		</ul>
	)
}

export { DashboardEnrolledList }
