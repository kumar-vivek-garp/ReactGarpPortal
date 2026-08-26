import { animated, useSpring, useTrail } from "@react-spring/web"
import { ChevronRight, CircleUser, Pencil } from "lucide-react"

import type { AccountView } from "@/api/account/types"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/atoms/avatar"
import { Badge } from "@/components/atoms/badge"
import { Button } from "@/components/atoms/button"
import { CompletionRing } from "@/components/molecules/completion-ring"
import { GarpIdChip } from "@/components/molecules/garp-id-chip"
import { MetaLines } from "@/components/molecules/meta-lines"
import { StatusBadge } from "@/components/molecules/status-badge"
import { useSpringPress } from "@/hooks/use-spring-press"
import {
	buildIdentityPresentation,
	buildMissingChips,
	type CareerFocusField,
	type MissingChip,
} from "@/lib/account-presentation"
import { cn } from "@/lib/utils"

/** The app's panel/detail-enter feel. */
const HERO_SPRING = { mass: 0.9, tension: 320, friction: 26 }
/** Same cascade as `StaggerReveal`, so the chips feel like the cards below. */
const CHIP_TRAIL_SPRING = { mass: 0.8, tension: 340, friction: 26 }

type AccountIdentityHeroProps = {
	account: AccountView
	/** Opens the Personal Information dialog. */
	onEditPersonal: () => void
	/** Opens the Career dialog focused on the field behind a missing chip. */
	onFixField: (field: CareerFocusField) => void
	/** Scrolls to the card that owns the missing fields, for context first. */
	onReviewMissing: () => void
	className?: string
}

function MissingChipButton({
	chip,
	onFixField,
}: {
	chip: MissingChip
	onFixField: (field: CareerFocusField) => void
}) {
	const { bind, style } = useSpringPress<HTMLButtonElement>({
		disabled: !chip.field,
	})

	const content = (
		<animated.span
			className="inline-flex items-center gap-1 will-change-transform"
			style={{ scale: style.scale }}
		>
			{chip.label}
			{chip.field ? <ChevronRight className="size-3" aria-hidden /> : null}
		</animated.span>
	)

	const shell =
		"inline-flex items-center rounded-full border border-dashed border-primary/40 bg-primary/5 px-3 py-1 text-xs font-semibold text-primary"

	// A label this build does not recognise still gets shown — it just cannot
	// be actioned, so it must not look or behave like a button.
	if (!chip.field) {
		return <span className={shell}>{content}</span>
	}

	const field = chip.field
	return (
		<button
			type="button"
			onClick={() => onFixField(field)}
			className={cn(shell, "hover:bg-primary/10")}
			{...bind}
		>
			{content}
		</button>
	)
}

function MissingStrip({
	chips,
	onFixField,
	onReviewMissing,
}: {
	chips: MissingChip[]
	onFixField: (field: CareerFocusField) => void
	onReviewMissing: () => void
}) {
	const trails = useTrail(chips.length, {
		from: { opacity: 0, transform: "translateY(6px)" },
		to: { opacity: 1, transform: "translateY(0px)" },
		config: CHIP_TRAIL_SPRING,
	})

	return (
		<div className="mt-5 border-t border-border pt-4">
			<button
				type="button"
				onClick={onReviewMissing}
				className="text-xs font-semibold tracking-wide text-muted-foreground uppercase hover:text-foreground"
			>
				Complete your profile — {chips.length}{" "}
				{chips.length === 1 ? "item" : "items"} left
			</button>
			<div className="mt-2.5 flex flex-wrap gap-2">
				{trails.map((trailStyle, index) => (
					<animated.span
						key={chips[index].label}
						style={trailStyle}
						className="inline-flex"
					>
						<MissingChipButton chip={chips[index]} onFixField={onFixField} />
					</animated.span>
				))}
			</div>
		</div>
	)
}

/**
 * Identity banner above the Account Information bento.
 *
 * Replaces the standalone progress bar that used to sit in the page header:
 * completeness now frames the avatar as a ring, and each still-missing field is
 * a chip that opens the Career dialog focused on that control.
 */
function AccountIdentityHero({
	account,
	onEditPersonal,
	onFixField,
	onReviewMissing,
	className,
}: AccountIdentityHeroProps) {
	const presentation = buildIdentityPresentation(account)
	const chips = presentation.isComplete ? [] : buildMissingChips(account.completeness)

	const enter = useSpring({
		from: { opacity: 0, transform: "translateY(10px)" },
		to: { opacity: 1, transform: "translateY(0px)" },
		config: HERO_SPRING,
	})

	const avatar = (
		<Avatar className="size-full">
			<AvatarImage
				src={presentation.photoUrl}
				alt=""
				className="object-cover"
			/>
			<AvatarFallback className="bg-transparent p-0 text-muted-foreground">
				<CircleUser
					className="size-full"
					strokeWidth={1.25}
					absoluteStrokeWidth
					aria-hidden
				/>
			</AvatarFallback>
		</Avatar>
	)

	return (
		<animated.section
			style={enter}
			className={cn(
				"rounded-xl border border-border bg-linear-to-br from-surface-gradient-start to-surface-gradient-end p-5 sm:p-6",
				className,
			)}
			aria-label="Your profile"
		>
			<div className="flex flex-col gap-5 app:flex-row app:items-center app:gap-6">
				{presentation.isComplete ? (
					<Avatar className="size-22 shrink-0 app:size-28">
						<AvatarImage
							src={presentation.photoUrl}
							alt=""
							className="object-cover"
						/>
						<AvatarFallback className="bg-transparent p-0 text-muted-foreground">
							<CircleUser
								className="size-full"
								strokeWidth={1.25}
								absoluteStrokeWidth
								aria-hidden
							/>
						</AvatarFallback>
					</Avatar>
				) : (
					<CompletionRing percent={presentation.percentComplete}>
						{avatar}
					</CompletionRing>
				)}

				<div className="min-w-0 flex-1 space-y-2.5">
					<h2 className="font-heading text-2xl font-semibold tracking-wide break-words text-foreground sm:text-3xl">
						{presentation.displayName}
					</h2>

					<div className="flex flex-wrap items-center gap-2">
						{presentation.garpId ? (
							<GarpIdChip garpId={presentation.garpId} />
						) : null}
						{presentation.memberType ? (
							<Badge className="bg-accent px-3 py-1 font-semibold tracking-wide text-accent-foreground">
								{presentation.memberType}
							</Badge>
						) : null}
						{presentation.statusLabel ? (
							<StatusBadge
								label={presentation.statusLabel}
								tone={presentation.statusTone}
							/>
						) : null}
						{presentation.autoRenewOn ? (
							<Badge className="bg-success-green/15 px-3 py-1 font-semibold tracking-wide text-success-green">
								Auto-renew on
							</Badge>
						) : null}
					</div>

					{/* Wrapping row rather than the default stack — four facts stacked
					    would make the hero taller than the cards beneath it. */}
					<MetaLines
						lines={presentation.metaLines}
						className="flex flex-wrap gap-x-5 gap-y-1 space-y-0"
					/>
				</div>

				<Button
					type="button"
					onClick={onEditPersonal}
					className="w-full shrink-0 gap-1.5 app:w-fit"
				>
					<Pencil className="size-4" aria-hidden />
					Edit Profile
				</Button>
			</div>

			{chips.length > 0 ? (
				<MissingStrip
					chips={chips}
					onFixField={onFixField}
					onReviewMissing={onReviewMissing}
				/>
			) : null}
		</animated.section>
	)
}

export { AccountIdentityHero }
