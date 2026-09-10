import { ExternalLink } from "lucide-react"

import { Badge } from "@/components/atoms/badge"
import { Card } from "@/components/atoms/card"
import { CardCta } from "@/components/molecules/card-cta"
import { MetaLines } from "@/components/molecules/meta-lines"
import { ProgramResultsChip } from "@/components/molecules/program-results-chip"
import { StatusBadge } from "@/components/molecules/status-badge"
import { programBrandSurface } from "@/config/program-brand"
import { useCardActivation } from "@/hooks/use-card-activation"
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
 * can never show different facts — including which of them is clickable: a row
 * whose only destination is View Details IS that link, and the CTA goes.
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

	const activation = useCardActivation(
		detailsLink,
		`View details for ${displayName}`,
	)

	return (
		<Card
			{...activation}
			className={cn(
				// Same flat, bordered treatment as the grid card this row shares
				// presentation with — Card's own border/bg/radius apply as-is,
				// only the row's flex layout is added on top.
				"gap-4 p-4 sm:flex-row sm:items-center",
				// An interactive card owns its elevation through the spring.
				!activation.interactive && "shadow-none",
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

				<h3 className="font-heading text-base leading-snug tracking-wide text-heading">
					{displayName}
				</h3>

				{description ? (
					<p className="line-clamp-1 text-sm text-muted-foreground">
						{description}
					</p>
				) : null}

				<MetaLines lines={metaLines} className="space-y-1" />
			</div>

			{/*
			 * Only rendered when it holds something: an empty box still spends the
			 * row's `gap` and pulls the text in off the right edge.
			 */}
			{registrationLink || learnMoreLink ? (
				<div className="flex shrink-0 flex-wrap items-center gap-x-5 gap-y-2 sm:flex-col sm:items-end">
					{registrationLink ? (
						<CardCta
							label={registrationLink.label}
							url={registrationLink.url}
							isExternal={registrationLink.isExternal}
						/>
					) : null}

					{/*
					 * New-tab glyph rather than the CTA's forward arrow (UI/UX
					 * request, Sep 2026) — this one leaves the portal for garp.org,
					 * and the arrow promises an in-app step.
					 */}
					{learnMoreLink ? (
						<CardCta
							label="Learn more"
							ariaLabel={learnMoreLink.label}
							url={learnMoreLink.url}
							isExternal
							newWindow
							icon={<ExternalLink className="size-4" />}
						/>
					) : null}
				</div>
			) : null}
		</Card>
	)
}

export { ProgramRow }
