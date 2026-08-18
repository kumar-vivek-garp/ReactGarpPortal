import { Link } from "@tanstack/react-router"
import { CircleArrowRight } from "lucide-react"

import type { DashboardEnrolledPreview } from "@/api/dashboard"
import {
	programTypeSlug,
	supportsInAppProgramDetail,
} from "@/lib/program-card-links"
import { cn } from "@/lib/utils"

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
			{programs.map((program) => {
				const inApp = supportsInAppProgramDetail(program.programType)
				const slug = programTypeSlug(program.programType)
				const routeSlug = inApp
					? slug === "rai"
						? "riskai"
						: slug
					: null

				const linkClass =
					"inline-flex items-center gap-1.5 text-sm font-semibold text-primary hover:text-primary/80"

				return (
					<li
						key={program.programType}
						className="rounded-xl border border-border/60 bg-background/50 p-3"
					>
						{routeSlug ? (
							<Link
								to="/programs/$programType"
								params={{ programType: routeSlug }}
								className={linkClass}
							>
								{program.name}
								<CircleArrowRight className="size-4 shrink-0" aria-hidden />
							</Link>
						) : (
							<Link
								to="/programs"
								search={{ tab: "in-progress" }}
								className={linkClass}
							>
								{program.name}
								<CircleArrowRight className="size-4 shrink-0" aria-hidden />
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
			})}
		</ul>
	)
}

export { DashboardEnrolledList }
