import { Download, ExternalLink, GraduationCap } from "lucide-react"

import { Button } from "@/components/atoms/button"
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
			return (
				<Button asChild size="sm" className={className}>
					<a href={action.url} target="_blank" rel="noreferrer noopener">
						<GraduationCap aria-hidden />
						Access GARP Learning
					</a>
				</Button>
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
		case "owned":
		case "outOfStock":
		case "contact":
			return <p className={cn(NOTE, className)}>{action.text}</p>
		case "none":
			return null
	}
}

export { StudyMaterialAction }
