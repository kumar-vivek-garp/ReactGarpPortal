import { Check, Minus, PackagePlus, Plus, ReceiptText } from "lucide-react"

import type { FeesResult } from "@/api/registration/exam-types"
import type { SelectableMaterial } from "@/hooks/use-exam-registration"
import { Badge } from "@/components/atoms/badge"
import { Button } from "@/components/atoms/button"
import {
	Card,
	CardContent,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { AnimatedAmount } from "@/components/forms/frm/animated-amount"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { formatMoney } from "@/lib/account-format"
import {
	showSubtotal,
	sortFeeLines,
	splitStudyMaterials,
} from "@/lib/registration-presentation"
import { cn } from "@/lib/utils"

/**
 * Product art, when the catalogue has it.
 *
 * `object-contain` on a neutral tile rather than `cover`: these are book
 * covers and screenshots of wildly different aspect ratios, and cropping them
 * to a square cuts the title off the front of a textbook.
 */
function MaterialThumb({ src, alt }: { src?: string | null; alt: string }) {
	if (!src) return null
	return (
		<div className="flex size-14 shrink-0 items-center justify-center overflow-hidden rounded-lg bg-muted">
			<img
				src={src}
				alt={alt}
				loading="lazy"
				className="size-full object-contain"
			/>
		</div>
	)
}

type OfferRowProps = {
	material: SelectableMaterial
	onToggle: () => void
	disabled?: boolean
}

/**
 * One addable item.
 *
 * Its own bordered tile rather than a row separated by rules: each of these is
 * a decision with a price and a control, and a tile groups those three things
 * together. Divider lines do the opposite — they chop a list into bands and
 * leave the eye to work out which price belongs to which button.
 */
function OfferRow({ material, onToggle, disabled }: OfferRowProps) {
	const unavailable = material.isAvailable === false
	const isFree = material.isCompSelectable === true

	return (
		<div
			className={cn(
				"flex items-center gap-3 rounded-xl border p-3 transition-colors",
				material.selected
					? "border-success-green/40 bg-success-green/5"
					: "border-border",
			)}
		>
			<MaterialThumb src={material.imageUrl} alt="" />

			<div className="flex min-w-0 flex-1 flex-col gap-0.5">
				<p className="text-body font-medium">{material.title}</p>
				<p className="text-caption">
					<span
						className={cn(
							"font-semibold",
							isFree ? "text-success-green" : "text-foreground",
						)}
					>
						{isFree ? "Included" : formatMoney(material.price ?? 0, "USD")}
					</span>
					{material.isShippable ? (
						<span className="text-muted-foreground"> · plus shipping</span>
					) : null}
				</p>
			</div>

			{material.isOwned ? (
				<Badge variant="secondary" className="shrink-0">
					Owned
				</Badge>
			) : unavailable ? (
				<Badge variant="outline" className="shrink-0 text-muted-foreground">
					Unavailable
				</Badge>
			) : (
				<Button
					type="button"
					size="sm"
					variant="outline"
					onClick={onToggle}
					disabled={disabled}
					aria-pressed={material.selected}
					/*
					 * The label says what the click does, not what the row is. The
					 * row's own green tint already carries "in the cart", so tinting
					 * this to match would read as a confirmation rather than as the
					 * way back out of it.
					 */
					className="shrink-0"
				>
					{material.selected ? (
						<>
							<Minus aria-hidden /> Remove
						</>
					) : (
						<>
							<Plus aria-hidden /> Add
						</>
					)}
				</Button>
			)}
		</div>
	)
}

function SummaryRow({
	label,
	amount,
	currency,
	tone = "default",
	pending = false,
}: {
	label: string
	amount: number | null | undefined
	currency: string
	tone?: "default" | "included" | "total"
	pending?: boolean
}) {
	return (
		<div
			className={cn(
				"flex items-baseline justify-between gap-4",
				tone === "total" ? "text-lg font-semibold" : "text-body",
			)}
		>
			<span
				className={cn(
					"min-w-0",
					tone === "total" ? "text-foreground" : "text-muted-foreground",
				)}
			>
				{label}
			</span>

			{/* An included line has no figure to count — it is a fact, not a price. */}
			{tone === "included" ? (
				<span className="shrink-0 text-success-green">Included</span>
			) : (
				<AnimatedAmount
					amount={amount}
					currency={currency}
					pending={pending}
					className={cn("shrink-0", tone === "total" && "text-primary")}
				/>
			)}
		</div>
	)
}

type RegistrationRailProps = {
	materials: SelectableMaterial[]
	onToggleMaterial: (productCode: string) => void
	fees: FeesResult | null
	isPricing: boolean
	disabled?: boolean
}

/**
 * The right-hand rail: what you can add, and what it comes to.
 *
 * Pinned rather than scrolling with the form, so the running total stays
 * visible while the candidate works down the page — the cart re-prices on
 * every change, and a total you have to scroll back to find is a total nobody
 * checks. It caps its own height and scrolls internally, because a rail taller
 * than the viewport cannot be pinned and would strand the total off screen.
 */
function RegistrationRail({
	materials,
	onToggleMaterial,
	fees,
	isPricing,
	disabled,
}: RegistrationRailProps) {
	const { included, offered } = splitStudyMaterials(materials)
	const currency = fees?.currencyCode || "USD"
	const lines = sortFeeLines(fees?.lines ?? [])
	const withSubtotal = showSubtotal(lines, fees?.vatAmount, fees?.njSalesTax)

	return (
		/*
		 * The cap is measured against the viewport, but the rail's scroll parent
		 * is not the viewport — so all three of these have to be subtracted or
		 * the rail is taller than the slot it sits in and its bottom is clipped
		 * with no way to scroll to it:
		 *
		 *   5rem    fixed navbar
		 * + 3rem    the subpage shell's own `py-6`
		 * + 5.5rem  this rail's `lg:top-22` pin offset
		 * = 13.5rem
		 *
		 * It read `100vh-9rem` and overhung by the 6rem it forgot.
		 *
		 * The pin offset is load-bearing too: it must equal the sticky bar (4rem)
		 * plus the grid gap (1.5rem). `sticky` with a `top` *larger* than the
		 * element's natural offset pushes it down immediately, so at `top-28`
		 * the rail sat 24px below the form column beside it, at rest, on first
		 * paint.
		 *
		 * No `overscroll-contain`: when the rail bottoms out the wheel should
		 * carry on scrolling the page. Trapping it in a secondary column is what
		 * made a clipped rail read as "there is content but I can't scroll".
		 */
		<div className="flex max-h-[calc(100vh-13.5rem)] flex-col gap-4 overflow-y-auto scrollbar-none">
			{offered.length > 0 ? (
				<Card>
					<CardHeader>
						<CardTitle className="flex items-center gap-2 text-base">
							<PackagePlus className="size-4 text-muted-foreground" aria-hidden />
							Add to your registration
						</CardTitle>
					</CardHeader>
					<CardContent>
						{/*
						 * Trailed in on appearance. The list only exists once an exam
						 * part is chosen, so this is a genuine arrival rather than
						 * decoration on something that was always there.
						 */}
						<StaggerReveal className="flex flex-col gap-2">
							{offered.map((material) => (
								<OfferRow
									key={material.productCode}
									material={material}
									onToggle={() => onToggleMaterial(material.productCode)}
									disabled={disabled}
								/>
							))}
						</StaggerReveal>
					</CardContent>
				</Card>
			) : null}

			{included.length > 0 ? (
				<Card>
					<CardHeader>
						<CardTitle className="flex items-center gap-2 text-base">
							<Check className="size-4 text-success-green" aria-hidden />
							Included with registration
						</CardTitle>
					</CardHeader>
					<CardContent>
						<StaggerReveal className="flex flex-col gap-3">
							{included.map((material) => (
								<div
									key={material.productCode}
									className="flex items-center gap-3"
								>
									<MaterialThumb src={material.imageUrl} alt="" />
									<p className="text-body">{material.title}</p>
								</div>
							))}
						</StaggerReveal>
					</CardContent>
				</Card>
			) : null}

			<Card>
				<CardHeader>
					<CardTitle className="flex items-center justify-between gap-3 text-base">
						<span className="flex items-center gap-2">
							<ReceiptText className="size-4 text-muted-foreground" aria-hidden />
							Order summary
						</span>
						{isPricing && fees ? (
							<span className="text-caption font-normal text-muted-foreground">
								Updating…
							</span>
						) : null}
					</CardTitle>
				</CardHeader>
				<CardContent>
					{!fees || lines.length === 0 ? (
						/*
						 * Before an exam is picked this is the only card in the rail,
						 * and a single muted sentence in it reads as something that
						 * failed to load rather than as a summary waiting to fill in.
						 * The placeholder rows say what will appear here, so the empty
						 * state has the shape of the thing it becomes.
						 */
						<div className="flex flex-col gap-3">
							<div className="flex items-center gap-3 text-muted-foreground">
								<ReceiptText className="size-5 shrink-0" aria-hidden />
								<p className="text-body">Choose your exam to see the total.</p>
							</div>
							<div
								className="flex flex-col gap-2 border-t border-border pt-3"
								aria-hidden
							>
								{["Exam registration", "Enrollment fee", "Total"].map(
									(label, index) => (
										<div
											key={label}
											className={cn(
												"flex items-center justify-between gap-4 text-body text-muted-foreground/60",
												index === 2 && "font-semibold",
											)}
										>
											<span>{label}</span>
											<span aria-hidden>&mdash;</span>
										</div>
									),
								)}
							</div>
						</div>
					) : (
						<div
							className="flex flex-col gap-2"
							aria-live="polite"
							aria-busy={isPricing}
						>
							{lines.map((line, index) => (
								<SummaryRow
									key={`${line.productCode ?? "line"}-${index}`}
									label={line.name ?? line.productCode ?? ""}
									amount={line.amount}
									currency={currency}
									tone={line.isComp ? "included" : "default"}
									pending={isPricing}
								/>
							))}

							{withSubtotal ? (
								<>
									<hr className="border-border" />
									<SummaryRow
										label="Subtotal"
										amount={fees.subTotal}
										currency={currency}
										pending={isPricing}
									/>
								</>
							) : null}

							{fees.njSalesTax ? (
								<SummaryRow
									label="NJ sales tax"
									amount={fees.njSalesTax}
									currency={currency}
									pending={isPricing}
								/>
							) : null}

							{fees.vatAmount ? (
								<SummaryRow
									label={fees.vatLabel || "VAT"}
									amount={fees.vatAmount}
									currency={currency}
									pending={isPricing}
								/>
							) : null}

							<hr className="border-border" />
							<SummaryRow
								label="Total"
								amount={fees.total}
								currency={currency}
								tone="total"
								pending={isPricing}
							/>
						</div>
					)}
				</CardContent>
			</Card>
		</div>
	)
}

export { RegistrationRail }
