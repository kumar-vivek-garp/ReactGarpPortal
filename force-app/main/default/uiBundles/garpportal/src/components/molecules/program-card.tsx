import {
	Card,
	CardContent,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { CardCta } from "@/components/molecules/card-cta"
import { ProgramMetaLines } from "@/components/molecules/program-meta-lines"
import { ProgramStatusBadge } from "@/components/molecules/program-status-badge"
import { programBrandSurface } from "@/config/program-brand"
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
	className?: string
}

/**
 * Grid card for one program. Content comes from
 * `buildProgramListingPresentation` so the list row renders the same facts.
 *
 * Deliberately not clickable as a whole — the CTA is the only hit target, so
 * there is no card-level hover state to imply otherwise.
 */
function ProgramCard({
	variant,
	program,
	priority = false,
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

	const showFooter = Boolean(detailsLink || registrationLink || learnMoreLink)

	return (
		<Card
			className={cn(
				"h-full gap-4 overflow-hidden border-border py-0 shadow-none",
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
					<span
						className={cn(
							"inline-flex items-center rounded-md px-2 py-0.5 text-xs font-bold tracking-wider",
							brand.chip,
						)}
					>
						{codeLabel}
					</span>
					<ProgramStatusBadge label={statusLabel} tone={statusTone} />
				</div>
				<CardTitle className="font-heading text-lg leading-snug tracking-wide text-foreground">
					{displayName}
				</CardTitle>
			</CardHeader>

			<CardContent className="flex-1 space-y-3 px-5">
				{description ? (
					<p className="line-clamp-2 text-sm text-muted-foreground">
						{description}
					</p>
				) : null}

				<ProgramMetaLines lines={metaLines} />
			</CardContent>

			{showFooter ? (
				<CardFooter className="mt-auto flex flex-wrap items-center gap-x-6 gap-y-2 px-5 pb-5">
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
				</CardFooter>
			) : (
				<div className="pb-5" />
			)}
		</Card>
	)
}

export { ProgramCard }
