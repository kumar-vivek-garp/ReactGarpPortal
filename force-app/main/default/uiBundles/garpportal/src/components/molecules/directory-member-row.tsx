import type { DirectoryMember } from "@/api/directory"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/atoms/avatar"
import { Badge } from "@/components/atoms/badge"
import { programBrandSurface } from "@/config/program-brand"
import { Card } from "@/components/atoms/card"
import {
	directoryCredentials,
	directoryMemberSubtitle,
	memberInitials,
} from "@/lib/directory-presentation"
import { cn } from "@/lib/utils"

type DirectoryMemberRowProps = {
	member: DirectoryMember
	onOpen: () => void
	className?: string
}

/**
 * One directory result.
 *
 * The whole card opens the member, via `onActivate` rather than `onClick`, so
 * the press spring settles before the dialog takes focus — the same idiom
 * `OrderRow` uses for navigation.
 *
 * The monogram carries the eye down a list far better than a column of plain
 * text, and it degrades gracefully: most members have no photo, and initials
 * are something every row can produce.
 */
function DirectoryMemberRow({
	member,
	onOpen,
	className,
}: DirectoryMemberRowProps) {
	const credentials = directoryCredentials(member)
	const subtitle = directoryMemberSubtitle(member)
	const name = member.name ?? "GARP member"

	return (
		<Card
			interactive
			role="button"
			tabIndex={0}
			aria-label={`View ${name}`}
			// No `shadow-none` — the interactive Card owns elevation via spring.
			className={cn("flex-row items-center gap-3 p-3", className)}
			onActivate={onOpen}
		>
			<Avatar className="size-10 shrink-0">
				{member.photoUrl ? <AvatarImage src={member.photoUrl} alt="" /> : null}
				<AvatarFallback className="bg-primary/10 text-xs font-semibold text-primary">
					{memberInitials(member)}
				</AvatarFallback>
			</Avatar>

			<div className="min-w-0 flex-1">
				<h3 className="truncate font-heading text-base leading-snug tracking-wide text-foreground">
					{name}
				</h3>
				{subtitle ? (
					<p className="truncate text-sm text-muted-foreground">{subtitle}</p>
				) : null}
			</div>

			{credentials.length > 0 ? (
				<span className="hidden shrink-0 gap-1 sm:flex">
					{/*
					 * Tinted with the programme's own brand surface, the same one
					 * the Study Materials chips use, so FRM reads as FRM wherever
					 * it appears (UI/UX request, Sep 2026). An unrecognised
					 * credential falls back to the neutral surface rather than
					 * borrowing another programme's hue.
					 */}
					{credentials.slice(0, 3).map((code) => (
						<Badge
							key={code}
							className={cn(
								"text-xs font-bold tracking-wider",
								programBrandSurface(code).chip,
							)}
						>
							{code}
						</Badge>
					))}
				</span>
			) : null}
		</Card>
	)
}

export { DirectoryMemberRow }
