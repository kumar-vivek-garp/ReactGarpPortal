import { useState } from "react"
import { Download } from "lucide-react"

import type { CpdCycleInfo } from "@/api/cpd"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import { CpdAttestationDialog } from "@/components/molecules/cpd-attestation-dialog"
import { CpdCreditBars } from "@/components/molecules/cpd-credit-bars"
import { CPD_NO_REQUIREMENT_MESSAGE } from "@/config/cpd"
import { cycleCertificates, cycleCreditRows } from "@/lib/cpd-presentation"
import { resolveExperienceHref } from "@/lib/program-card-links"
import { cn } from "@/lib/utils"

const CERT_ROW_STYLES =
	"flex items-center gap-2 rounded-lg px-2 py-2 text-sm font-semibold"

type CpdCreditSummaryCardProps = {
	cycle: CpdCycleInfo
	className?: string
}

/**
 * "{cycle} Credit Summary" — the bars, then a download row per earned
 * certificate.
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
	const certificates = cycleCertificates(cycle)
	const isAttested = cycle.isAttested === true
	const [pendingHref, setPendingHref] = useState<string | null>(null)

	const openCertificate = (href: string) => {
		window.open(href, "_blank", "noopener,noreferrer")
	}

	return (
		<Card className={cn("gap-0 py-0 shadow-none", className)}>
			<CardHeader className="px-5 pt-5 pb-3">
				<CardTitle className="font-heading text-lg tracking-wide text-foreground">
					{cycle.cycleName ? `${cycle.cycleName} Credit Summary` : "Credit Summary"}
				</CardTitle>
			</CardHeader>

			<CardContent className="space-y-4 px-5 pb-5">
				{rows.length > 0 ? (
					<CpdCreditBars rows={rows} />
				) : (
					<p className="text-sm text-muted-foreground">
						{CPD_NO_REQUIREMENT_MESSAGE}
					</p>
				)}

				{certificates.length > 0 ? (
					<div className="space-y-1 border-t border-border/60 pt-4">
						{certificates.map((certificate) => {
							const href = resolveExperienceHref(certificate.url)
							if (!href) return null
							return isAttested ? (
								<a
									key={certificate.designation}
									href={href}
									target="_blank"
									rel="noreferrer noopener"
									className={cn(
										CERT_ROW_STYLES,
										"text-primary hover:bg-accent hover:text-accent-foreground",
									)}
								>
									<Download className="size-4 shrink-0" aria-hidden />
									{certificate.label}
								</a>
							) : (
								<button
									key={certificate.designation}
									type="button"
									onClick={() => setPendingHref(href)}
									className={cn(
										CERT_ROW_STYLES,
										"w-full text-primary hover:bg-accent hover:text-accent-foreground",
									)}
								>
									<Download className="size-4 shrink-0" aria-hidden />
									{certificate.label}
								</button>
							)
						})}
						{!isAttested ? (
							<p className="px-2 pt-1 text-xs text-muted-foreground">
								You will be asked to attest this cycle before downloading.
							</p>
						) : null}
					</div>
				) : null}
			</CardContent>

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
