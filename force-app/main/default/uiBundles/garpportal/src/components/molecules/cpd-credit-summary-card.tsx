import { useState } from "react"
import { Download } from "lucide-react"

import type { CpdCycleInfo } from "@/api/cpd"
import { Button } from "@/components/atoms/button"
import { Card } from "@/components/atoms/card"
import { CpdAttestationDialog } from "@/components/molecules/cpd-attestation-dialog"
import { CpdCreditBars } from "@/components/molecules/cpd-credit-bars"
import { CPD_NO_REQUIREMENT_MESSAGE } from "@/config/cpd"
import {
	cycleCertificates,
	cycleCreditRows,
	cycleCreditTotals,
} from "@/lib/cpd-presentation"
import { resolveExperienceHref } from "@/lib/program-card-links"
import { cn } from "@/lib/utils"

type CpdCreditSummaryCardProps = {
	cycle: CpdCycleInfo
	className?: string
}

/** One figure and what it counts, on a single baseline. */
function CreditStat({
	label,
	value,
	emphasis = false,
}: {
	label: string
	value: number
	/** Approved is the number the page exists to report; the others are context. */
	emphasis?: boolean
}) {
	return (
		<div className="flex items-baseline gap-1.5">
			<span
				className={cn(
					"text-base font-semibold tabular-nums",
					emphasis ? "text-primary" : "text-foreground",
				)}
			>
				{value}
			</span>
			<span className="text-caption text-muted-foreground">{label}</span>
		</div>
	)
}

/**
 * The cycle's standing, as one strip: the figures, the per-certification bars,
 * and any certificate it has earned.
 *
 * It is deliberately one line tall on a wide screen. This started as a card
 * with stat tiles over stacked bars and a bordered certificate footer, which
 * cost roughly 200px above the activity list — a permanent tax on the thing
 * members actually came to read. Every value it held is still here; only the
 * padding went.
 *
 * Certificates are gated on attestation, which is where the legacy gate lives:
 * clicking a certificate before attesting opens a two-checkbox dialog and only
 * then the PDF. `CPDCertificateCtrl` performs no server-side check, so linking
 * straight to it would let an unattested member print a certificate the legacy
 * refuses to issue.
 *
 * An unattested click therefore opens the dialog and, on success, continues to
 * the certificate — the legacy's own sequence. Unlike the legacy, the refreshed
 * `isAttested` is picked up by the cache invalidation, so a second certificate
 * in the same session does not re-prompt.
 */
function CpdCreditSummaryCard({ cycle, className }: CpdCreditSummaryCardProps) {
	const rows = cycleCreditRows(cycle)
	const totals = cycleCreditTotals(cycle)
	const certificates = cycleCertificates(cycle)
	const isAttested = cycle.isAttested === true
	const [pendingHref, setPendingHref] = useState<string | null>(null)

	const openCertificate = (href: string) => {
		window.open(href, "_blank", "noopener,noreferrer")
	}

	return (
		<Card
			className={cn(
				// `gap-4` as one value, not `gap-x`/`gap-y`: the Card base sets
				// `gap-6`, and a single-axis utility does not reliably override it.
				"flex-row flex-wrap items-center gap-4 px-4 py-3 shadow-none",
				className,
			)}
		>
			{/*
			 * Still an `h2` — it names the region for a screen reader and for the
			 * document outline — but sized as a label rather than a card title.
			 */}
			<h2 className="font-heading text-sm tracking-wide text-foreground">
				{cycle.cycleName
					? `${cycle.cycleName} Credit Summary`
					: "Credit Summary"}
			</h2>

			<div className="flex flex-wrap items-baseline gap-x-4 gap-y-1">
				<CreditStat label="Approved" value={totals.approved} emphasis />
				<CreditStat label="Pending" value={totals.pending} />
				<CreditStat label="Required" value={totals.required} />
			</div>

			{/*
			 * `lg:ml-auto` only: on a wide screen the bars and the certificates
			 * sit together at the far end, but once the row wraps an auto margin
			 * would strand the bars against the right edge of their own line.
			 */}
			{rows.length > 0 ? (
				<CpdCreditBars rows={rows} inline className="lg:ml-auto" />
			) : (
				<p className="text-caption text-muted-foreground lg:ml-auto">
					{CPD_NO_REQUIREMENT_MESSAGE}
				</p>
			)}

			{certificates.length > 0 ? (
				<div className="flex flex-wrap items-center gap-2">
					{certificates.map((certificate) => {
						const href = resolveExperienceHref(certificate.url)
						if (!href) return null
						return isAttested ? (
							<Button
								key={certificate.designation}
								asChild
								variant="outline"
								size="sm"
							>
								<a href={href} target="_blank" rel="noreferrer noopener">
									<Download className="size-4 shrink-0" aria-hidden />
									{certificate.label}
								</a>
							</Button>
						) : (
							<Button
								key={certificate.designation}
								type="button"
								variant="outline"
								size="sm"
								// The gate is not obvious from a Download button, and
								// there is no room on this strip to spell it out.
								title="You will be asked to attest this cycle before downloading."
								onClick={() => setPendingHref(href)}
							>
								<Download className="size-4 shrink-0" aria-hidden />
								{certificate.label}
							</Button>
						)
					})}
				</div>
			) : null}

			<CpdAttestationDialog
				open={pendingHref !== null}
				onOpenChange={(next) => {
					if (!next) setPendingHref(null)
				}}
				attestationId={cycle.attestationID}
				creditsRequired={cycle.creditsRequired}
				onAttested={() => {
					if (pendingHref) openCertificate(pendingHref)
					setPendingHref(null)
				}}
			/>
		</Card>
	)
}

export { CpdCreditSummaryCard }
