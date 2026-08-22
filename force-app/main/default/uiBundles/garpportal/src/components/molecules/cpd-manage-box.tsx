import { Link } from "@tanstack/react-router"
import { BookOpen, Compass, Plus } from "lucide-react"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/atoms/card"
import { CPD_HANDBOOK_URL } from "@/config/cpd"
import { cn } from "@/lib/utils"

const ROW_STYLES =
	"flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-left text-sm font-semibold"

/**
 * The legacy "Manage CPD Credits" box, shown only on the current cycle.
 *
 * All three rows are live: Add Credits opens the claim form, Download Handbook
 * opens the PDF, and Browse Credit Opportunities goes to the catalogue.
 */
function CpdManageBox({
	onAddCredits,
	handbookUrl = CPD_HANDBOOK_URL,
	className,
}: {
	onAddCredits: () => void
	/** Server value when Apex starts sending one; the constant otherwise. */
	handbookUrl?: string
	className?: string
}) {
	return (
		<Card className={cn("gap-0 py-0 shadow-none", className)}>
			<CardHeader className="px-5 pt-5 pb-2">
				<CardTitle className="font-heading text-lg tracking-wide text-foreground">
					Manage CPD Credits
				</CardTitle>
			</CardHeader>
			<CardContent className="px-3 pb-4">
				<ul className="space-y-0.5">
					<li>
						<button
							type="button"
							onClick={onAddCredits}
							className={cn(
								ROW_STYLES,
								"text-primary hover:bg-accent hover:text-accent-foreground",
							)}
						>
							<Plus className="size-4 shrink-0" aria-hidden />
							Add Credits
						</button>
					</li>
					<li>
						<a
							href={handbookUrl}
							target="_blank"
							rel="noreferrer noopener"
							className={cn(
								ROW_STYLES,
								"text-primary hover:bg-accent hover:text-accent-foreground",
							)}
						>
							<BookOpen className="size-4 shrink-0" aria-hidden />
							Download Handbook
						</a>
					</li>
					<li>
						<Link
							to="/cpd/activities"
							className={cn(
								ROW_STYLES,
								"text-primary hover:bg-accent hover:text-accent-foreground",
							)}
						>
							<Compass className="size-4 shrink-0" aria-hidden />
							Browse Credit Opportunities
						</Link>
					</li>
				</ul>
			</CardContent>
		</Card>
	)
}

export { CpdManageBox }
