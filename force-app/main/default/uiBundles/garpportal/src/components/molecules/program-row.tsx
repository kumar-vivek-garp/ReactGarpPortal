import { Badge } from "@/components/atoms/badge"
import { Card } from "@/components/atoms/card"
import { CardCta } from "@/components/molecules/card-cta"
import { MetaLines } from "@/components/molecules/meta-lines"
import { ProgramResultsChip } from "@/components/molecules/program-results-chip"
import { StatusBadge } from "@/components/molecules/status-badge"
import { programBrandSurface } from "@/config/program-brand"
import { localizeProgramLogoUrl } from "@/config/program-logos"
import {
	buildProgramListingPresentation,
	type ProgramCardVariant,
	type ProgramListingProgram,
} from "@/lib/program-listing-presentation"
import { resolvePortalAssetUrl } from "@/lib/resolve-portal-asset-url"
import { cn } from "@/lib/utils"

type ProgramRowProps = {
	variant: ProgramCardVariant
	program: ProgramListingProgram
	/** Mark above-the-fold logos as LCP candidates. */
	priority?: boolean
	/** The member has exam results for this program. */
	hasResults?: boolean
	className?: string
}

/**
 * List-view row for one program — status-forward and dense, for the buckets
 * where a member has a handful of items and cares about state, not artwork.
 *
 * Shares `buildProgramListingPresentation` with `ProgramCard` so the two views
 * can never show different facts.
 */
function ProgramRow({
	variant,
	program,
	priority = false,
	hasResults = false,
	className,
}: ProgramRowProps) {
	const presentation = buildProgramListingPresentation(variant, program)
	const brand = programBrandSurface(program.programType)
	const info = program.programInformation
	const logoUrl = localizeProgramLogoUrl(
		resolvePortalAssetUrl(info?.myProgramsLogoURL) ??
			info?.myProgramsLogoURL ??
			undefined,
	)

	const {
		codeLabel,
		displayName,
		statusLabel,
		statusTone,
		description,
		metaLines,
		detailsLink,
		registrationLink,
		learnMoreLink,
	} = presentation

	return (
		<Card
			className={cn(
				// Same flat, bordered treatment as the grid card this row shares
				// presentation with — Card's own border/bg/radius apply as-is,
				// only the row's flex layout is added on top.
				"gap-4 p-4 shadow-none sm:flex-row sm:items-center",
				className,
			)}
		>
			<div
				className={cn(
					"flex h-16 w-full shrink-0 items-center justify-center rounded-lg p-2 sm:w-24",
					brand.surface,
				)}
			>
				{logoUrl ? (
					<img
						src={logoUrl}
						alt=""
						width={96}
						height={64}
						decoding="async"
						fetchPriority={priority ? "high" : "auto"}
						loading={priority ? "eager" : "lazy"}
						className="max-h-full max-w-full object-contain"
						onError={(event) => {
							event.currentTarget.style.display = "none"
						}}
					/>
				) : null}
			</div>

			<div className="min-w-0 flex-1 space-y-2">
				<div className="flex flex-wrap items-center gap-2">
					<Badge className={cn("rounded-md font-bold tracking-wider", brand.chip)}>
						{codeLabel}
					</Badge>
					<StatusBadge label={statusLabel} tone={statusTone} />
					{hasResults ? (
						<ProgramResultsChip programType={program.programType} />
					) : null}
				</div>

				<h3 className="font-heading text-base leading-snug tracking-wide text-foreground">
					{displayName}
				</h3>

				{description ? (
					<p className="line-clamp-1 text-sm text-muted-foreground">
						{description}
					</p>
				) : null}

				<MetaLines lines={metaLines} className="space-y-1" />
			</div>

			<div className="flex shrink-0 flex-wrap items-center gap-x-5 gap-y-2 sm:flex-col sm:items-end">
				{detailsLink ? (
					<CardCta
						label={detailsLink.label}
						url={detailsLink.url}
						isExternal={detailsLink.isExternal}
					/>
				) : null}

				{registrationLink ? (
					<CardCta
						label={registrationLink.label}
						url={registrationLink.url}
						isExternal
					/>
				) : null}

				{learnMoreLink ? (
					<CardCta
						label="Learn more"
						ariaLabel={learnMoreLink.label}
						url={learnMoreLink.url}
						isExternal
						newWindow
					/>
				) : null}
			</div>
		</Card>
	)
}

export { ProgramRow }
