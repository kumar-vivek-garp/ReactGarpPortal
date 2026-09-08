import { Download, ExternalLink, GraduationCap } from "lucide-react"

import { CardCta } from "@/components/molecules/card-cta"
import type { MaterialAction } from "@/lib/study-materials-presentation"
import { cn } from "@/lib/utils"

type StudyMaterialActionProps = {
	action: MaterialAction
	className?: string
}

const NOTE = "text-sm text-muted-foreground"

/**
 * The one thing a material lets the member do — rendered from the decision
 * `resolveMaterialAction` already made, so the grid card and the list row
 * cannot disagree about it.
 */
function StudyMaterialAction({ action, className }: StudyMaterialActionProps) {
	switch (action.kind) {
		case "garpLearning":
			/*
			 * A link, not a button (UI/UX request, Sep 2026). Every other card
			 * offers its destination as a primary-tinted CTA, and a filled button
			 * here made GARP Learning read as the page's main action rather than
			 * as one material among several.
			 */
			return (
				<span className={cn("inline-flex items-center gap-2", className)}>
					<GraduationCap className="size-4 text-muted-foreground" aria-hidden />
					<CardCta
						label="Access GARP Learning"
						url={action.url}
						isExternal
						newWindow
					/>
				</span>
			)
		case "external":
			return (
				<span className={cn("inline-flex items-center gap-2", className)}>
					{action.icon === "download" ? (
						<Download className="size-4 text-muted-foreground" aria-hidden />
					) : (
						<ExternalLink className="size-4 text-muted-foreground" aria-hidden />
					)}
					<CardCta label={action.label} url={action.url} isExternal newWindow />
				</span>
			)
		case "completeOrder":
			return (
				<CardCta
					label="Complete your order"
					url={action.path}
					isExternal={false}
					className={className}
				/>
			)
		case "comingSoon":
			return (
				<div className={cn("flex flex-wrap items-center gap-x-4 gap-y-1", className)}>
					<p className={NOTE}>{action.text}</p>
					{action.notifyUrl ? (
						<CardCta label="Notify me" url={action.notifyUrl} isExternal newWindow />
					) : null}
				</div>
			)
		case "purchase":
			return (
				<div className={cn("flex flex-wrap items-center gap-x-4 gap-y-1", className)}>
					{action.priceLabel ? (
						<span className="text-sm font-semibold text-foreground">
							{action.priceLabel}
						</span>
					) : null}
					<CardCta label="Purchase" url={action.path} isExternal={false} />
				</div>
			)
		case "outOfStock":
		case "contact":
			return <p className={cn(NOTE, className)}>{action.text}</p>
		case "none":
			return null
	}
}

export { StudyMaterialAction }
