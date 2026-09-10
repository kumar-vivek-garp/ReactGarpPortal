import { Link } from "@tanstack/react-router"

import { Button } from "@/components/atoms/button"
import {
	Card,
	CardContent,
	CardFooter,
	CardHeader,
} from "@/components/atoms/card"
import { CardCta } from "@/components/molecules/card-cta"
import { StatusBadge } from "@/components/molecules/status-badge"
import { parseInternalAppHref } from "@/lib/parse-internal-app-href"
import type { ProgramChrome } from "@/config/program-chrome"
import type { ProgramDetailPresentation } from "@/lib/program-detail-presentation"
import { cn } from "@/lib/utils"

type ProgramDetailHeroProps = {
	presentation: ProgramDetailPresentation
	logoUrl?: string | null
	/**
	 * The programme's designed chrome, when it has any. Supplies the brand hue
	 * behind the logo and a seal to fall back on, so the tile is never empty for
	 * a redesigned programme. Undefined leaves the neutral tile exactly as it
	 * was — the same fallback every other chrome consumer uses.
	 */
	chrome?: ProgramChrome
	className?: string
}

function PrimaryActionButton({
	action,
}: {
	action: NonNullable<ProgramDetailPresentation["primaryAction"]>
}) {
	if (action.isExternal) {
		return (
			<Button asChild size="lg">
				<a
					href={action.url}
					{...(action.newWindow
						? { target: "_blank", rel: "noreferrer noopener" }
						: {})}
				>
					{action.label}
				</a>
			</Button>
		)
	}

	const { pathname, search } = parseInternalAppHref(action.url)
	const hasSearch = Object.keys(search).length > 0

	return (
		<Button asChild size="lg">
			{hasSearch ? (
				<Link to={pathname} search={search}>
					{action.label}
				</Link>
			) : (
				<Link to={pathname}>{action.label}</Link>
			)}
		</Button>
	)
}

function ProgramDetailHero({
	presentation,
	logoUrl,
	chrome,
	className,
}: ProgramDetailHeroProps) {
	/*
	 * The API logo when there is one, our bundled seal when there is not. The
	 * seal is the same asset the registration bar shows, so a programme reads
	 * the same from its detail page through to its form.
	 */
	const tileArt = logoUrl ?? chrome?.seal
	const {
		displayName,
		description,
		administration,
		statusLabel,
		statusTone,
		statusSummary,
		nextStepTitle,
		nextStepBody,
		nextStepTone,
		notes,
		primaryAction,
		secondaryActions,
	} = presentation

	return (
		<section className={cn("space-y-5", className)}>
			<Card className="gap-0 overflow-hidden py-0 shadow-none">
				<div className="flex flex-col gap-5 p-5 sm:flex-row sm:items-start">
					{tileArt ? (
						<div
							className={cn(
								"flex h-28 w-full shrink-0 items-center justify-center rounded-xl p-3 sm:h-32 sm:w-40",
								/* Brand hue for a redesigned programme, neutral otherwise. */
								chrome?.barWash ?? "bg-muted/40",
							)}
						>
							<img
								src={tileArt}
								alt=""
								className="max-h-full max-w-full object-contain"
								onError={(event) => {
									event.currentTarget.style.display = "none"
								}}
							/>
						</div>
					) : null}

					<div className="min-w-0 flex-1 space-y-3">
						<div className="flex flex-wrap items-center gap-2">
							<StatusBadge label={statusLabel} tone={statusTone} />
							{administration ? (
								<span className="text-sm font-medium text-primary">
									{administration}
								</span>
							) : null}
						</div>
						{/*
						 * `font-sans` ExtraBold, matching the registration and exam-setup
						 * bars — `base.css` would otherwise give this h1 Klinic Slab, and
						 * a programme would be named in two typefaces between its detail
						 * page and its own Register page.
						 */}
						<h1 className="font-sans text-3xl font-extrabold text-foreground">
							{displayName}
						</h1>
						{description ? (
							<p className="max-w-2xl text-sm text-muted-foreground">
								{description}
							</p>
						) : null}
						<p className="text-sm text-foreground">{statusSummary}</p>
					</div>
				</div>
			</Card>

			<Card
				className={cn(
					"gap-4 py-5 shadow-none",
					// Danger is a warning the member must act on (an unpaid exam
					// change); it gets the destructive tint, not a muted one.
					nextStepTone === "danger"
						? "border-destructive/40 bg-destructive/5"
						: nextStepTone === "warning"
							? "bg-muted/40"
							: "bg-accent/40",
				)}
				role={nextStepTone === "danger" ? "alert" : undefined}
			>
				<CardHeader className="gap-1 px-5">
					<p
						className={cn(
							"text-xs font-semibold uppercase tracking-wider",
							nextStepTone === "danger" ? "text-destructive" : "text-primary",
						)}
					>
						{nextStepTone === "danger" ? "Action required" : "Next step"}
					</p>
					<h2 className="font-heading text-xl tracking-wide text-heading">
						{nextStepTitle}
					</h2>
				</CardHeader>
				<CardContent className="space-y-2 px-5">
					<p className="text-sm text-muted-foreground">{nextStepBody}</p>
					{notes.map((note) => (
						<p key={note} className="text-xs text-muted-foreground">
							{note}
						</p>
					))}
				</CardContent>
				{(primaryAction || secondaryActions.length > 0) && (
					<CardFooter className="flex flex-wrap items-center gap-3 border-t border-border/60 px-5 pt-4">
						{primaryAction ? (
							<PrimaryActionButton action={primaryAction} />
						) : null}
						{secondaryActions.map((action) => (
							<CardCta
								key={`${action.kind}-${action.label}`}
								label={action.label}
								url={action.url}
								isExternal={action.isExternal}
								newWindow={action.newWindow}
							/>
						))}
					</CardFooter>
				)}
			</Card>
		</section>
	)
}

export { ProgramDetailHero }
