import { Link } from "@tanstack/react-router"

import type { DashboardEnrolledPreview } from "@/api/dashboard"
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
		<ul className={cn("space-y-4", className)}>
			{programs.map((program) => (
				<li key={program.programType} className="space-y-1">
					<Link
						to="/programs"
						search={{ tab: "in-progress" }}
						className="font-semibold text-foreground hover:text-primary"
					>
						{program.name}
					</Link>
					{program.adminPartIName ? (
						<p className="text-sm text-muted-foreground">
							{program.adminPartIName}
						</p>
					) : null}
					{program.adminPartIIName ? (
						<p className="text-sm text-muted-foreground">
							{program.adminPartIIName}
						</p>
					) : null}
				</li>
			))}
		</ul>
	)
}

export { DashboardEnrolledList }
