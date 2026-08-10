import { CircleUser, Users, X } from "lucide-react"

import {
	asDashboardCardMeta,
	type PortalCard,
} from "@/api/dashboard"
import { Button } from "@/components/atoms/button"
import {
	Card,
	CardContent,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { CardCta } from "@/components/molecules/card-cta"
import { DirectorySearch } from "@/components/molecules/directory-search"
import { ProfileCompletenessMeter } from "@/components/molecules/profile-completeness-meter"
import { resolvePortalAssetUrl } from "@/lib/resolve-portal-asset-url"
import { cn } from "@/lib/utils"

type DashboardCardProps = {
	card: PortalCard
	onDismiss?: (key: string) => void
	className?: string
}

/**
 * One dashboard card from Apex composition. Provider only chooses widgets
 * (meter, directory search); copy/CTA/order come from the server.
 */
function DashboardCard({ card, onDismiss, className }: DashboardCardProps) {
	const isProfile = card.provider === "ProfileCompleteness"
	const isExam = card.provider === "ExamRegistration"
	const isDirectory = card.provider === "MemberDirectory"
	const meta = asDashboardCardMeta(card.meta)
	const imageUrl = resolvePortalAssetUrl(card.imageUrl) ?? card.imageUrl
	const percent =
		typeof meta.percentComplete === "number"
			? meta.percentComplete
			: undefined

	return (
		<Card
			className={cn(
				"gap-0 overflow-hidden border-border bg-muted/40 py-0 shadow-none",
				className,
			)}
		>
			{imageUrl ? (
				<img
					src={imageUrl}
					alt=""
					className="h-40 w-full object-cover"
					onError={(event) => {
						event.currentTarget.style.display = "none"
					}}
				/>
			) : null}

			<CardHeader className="px-5 pt-5 pb-2">
				<CardTitle className="flex items-start gap-2 font-heading text-lg tracking-wide text-foreground">
					{isProfile ? (
						<CircleUser className="mt-0.5 size-5 shrink-0" aria-hidden />
					) : null}
					{isDirectory ? (
						<Users className="mt-0.5 size-5 shrink-0" aria-hidden />
					) : null}
					<span className="min-w-0 flex-1">
						{card.eyebrow ? (
							<span className="mb-1 block font-sans text-sm font-normal text-garp-cyan">
								{card.eyebrow}
							</span>
						) : null}
						{card.title}
					</span>
					{card.dismissible && onDismiss ? (
						<Button
							type="button"
							variant="ghost"
							size="icon-sm"
							aria-label="Dismiss this card"
							onClick={() => onDismiss(card.key)}
							className="-mr-1 -mt-1 rounded-full text-muted-foreground hover:text-foreground"
						>
							<X className="size-4" />
						</Button>
					) : null}
				</CardTitle>
			</CardHeader>

			<CardContent className="flex-1 space-y-3 px-5 pb-4">
				{isProfile && percent != null ? (
					<ProfileCompletenessMeter percent={percent} missing={meta.missing} />
				) : null}

				{card.body ? (
					<p className="text-sm text-muted-foreground">{card.body}</p>
				) : null}

				{card.bullets && card.bullets.length > 0 ? (
					<ul className="list-disc space-y-1 pl-5 text-sm text-muted-foreground">
						{card.bullets.map((bullet) => (
							<li key={bullet}>{bullet}</li>
						))}
					</ul>
				) : null}

				{isDirectory && meta.searchEnabled ? (
					<DirectorySearch className="min-h-40" />
				) : null}
			</CardContent>

			<CardFooter className="mt-auto border-t border-border/60 bg-transparent px-5 py-4">
				<CardCta
					label={card.ctaLabel}
					url={card.ctaUrl}
					isExternal={card.ctaIsExternal}
					locked={card.locked}
					disabled={isExam}
				/>
			</CardFooter>
		</Card>
	)
}

export { DashboardCard }
