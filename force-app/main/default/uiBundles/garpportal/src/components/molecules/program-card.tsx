import { ExternalLink } from "lucide-react"

import {
	Card,
	CardContent,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { Badge } from "@/components/atoms/badge"
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

type ProgramCardProps = {
	variant: ProgramCardVariant
	program: ProgramListingProgram
	/** Mark above-the-fold logos as LCP candidates. */
	priority?: boolean
	/** The member has exam results for this program. */
	hasResults?: boolean
	className?: string
}

/**
 * Grid card for one program. Content comes from
 * `buildProgramListingPresentation` so the list row renders the same facts.
 *
 * A card whose only destination is View Details IS that link — the whole
 * surface activates and the CTA is dropped, because a lone CTA beside a fully
 * clickable card is a second target for one job. An Explore card offers two
 * different destinations (Register Now, Learn more), so it stays a flat
 * surface with real buttons and no hover lift to imply otherwise.
 */
function ProgramCard({
	variant,
	program,
	priority = false,
	hasResults = false,
	className,
}: ProgramCardProps) {
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
	const cardIsDetails = activation.interactive

	const showFooter = Boolean(registrationLink || learnMoreLink)

	return (
		<Card
			{...activation}
			className={cn(
				"h-full gap-4 overflow-hidden py-0",
				// An interactive card owns its elevation through the spring.
				!cardIsDetails && "shadow-none",
				className,
			)}
		>
			<div
				className={cn(
					"flex h-36 items-center justify-center p-4",
					brand.surface,
				)}
			>
				{logoUrl ? (
					<img
						src={logoUrl}
						alt=""
						width={280}
						height={160}
						decoding="async"
						fetchPriority={priority ? "high" : "auto"}
						loading={priority ? "eager" : "lazy"}
						className="max-h-full max-w-full rounded-xl object-contain"
						onError={(event) => {
							event.currentTarget.style.display = "none"
						}}
					/>
				) : null}
			</div>

			<CardHeader className="gap-2 px-5 pt-1">
				<div className="flex flex-wrap items-center gap-2">
					<Badge className={cn("rounded-md font-bold tracking-wider", brand.chip)}>
						{codeLabel}
					</Badge>
					<StatusBadge label={statusLabel} tone={statusTone} />
					{hasResults ? (
						<ProgramResultsChip programType={program.programType} />
					) : null}
				</div>
				<CardTitle className="font-heading text-lg leading-snug tracking-wide text-heading">
					{displayName}
				</CardTitle>
			</CardHeader>

			<CardContent className="flex-1 space-y-3 px-5">
				{description ? (
					<p className="line-clamp-2 text-sm text-muted-foreground">
						{description}
					</p>
				) : null}

				<MetaLines lines={metaLines} />
			</CardContent>

			{showFooter ? (
				<CardFooter className="mt-auto flex flex-wrap items-center gap-x-6 gap-y-2 px-5 pb-5">
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
				</CardFooter>
			) : (
				<div className="pb-5" />
			)}
		</Card>
	)
}

export { ProgramCard }
