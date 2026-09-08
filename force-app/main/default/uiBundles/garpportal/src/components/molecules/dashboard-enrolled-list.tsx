import { Link } from "@tanstack/react-router"

import type { DashboardEnrolledPreview } from "@/api/dashboard"
import {
	programCoursePath,
	programTypeSlug,
	supportsInAppProgramDetail,
} from "@/lib/program-card-links"
import { cn } from "@/lib/utils"

/*
 * A plain tinted link, matching the event names on the card beside this one
 * (UI/UX request, Sep 2026). The nudging arrow this used to carry belongs to
 * the card's bottom CTA and nowhere else: when every name inside the card also
 * animates an arrow, the one action the card is actually steering towards
 * stops standing out. One rule now — simple hover for items in a card, the
 * expanded arrow hover for the CTA under them.
 */
const LINK_CLASS = "block text-sm font-semibold text-primary hover:text-primary/80"

function DashboardEnrolledItem({
	program,
}: {
	program: DashboardEnrolledPreview
}) {
	/*
	 * Two in-app destinations now: `programDetail` serves the two-part exam
	 * programmes and `courseDetail` serves the courses. Only something neither
	 * knows about falls back to the listing.
	 */
	const inApp = supportsInAppProgramDetail(program.programType)
	const slug = programTypeSlug(program.programType)
	const routeSlug = inApp ? (slug === "rai" ? "riskai" : slug) : null
	const coursePath = inApp ? null : programCoursePath(program.programType)

	return (
		<li className="rounded-xl border border-border/60 bg-background/50 p-3">
			{routeSlug ? (
				<Link
					to="/programs/$programType"
					params={{ programType: routeSlug }}
					className={LINK_CLASS}
				>
					{program.name}
				</Link>
			) : coursePath ? (
				<Link to={coursePath} className={LINK_CLASS}>
					{program.name}
				</Link>
			) : (
				<Link
					to="/programs"
					search={{ tab: "in-progress" }}
					className={LINK_CLASS}
				>
					{program.name}
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
