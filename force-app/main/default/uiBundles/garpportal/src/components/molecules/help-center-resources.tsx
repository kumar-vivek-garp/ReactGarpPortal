import {
	Card,
	CardContent,
	CardDescription,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { CardCta } from "@/components/molecules/card-cta"
import {
	HELP_RESOURCE_GROUPS,
	HELP_RESOURCE_LINKS,
} from "@/config/help-center"
import { cn } from "@/lib/utils"

function HelpCenterResources({ className }: { className?: string }) {
	return (
		<Card className={cn("h-full gap-4 bg-muted/40 py-5 shadow-none", className)}>
			<CardHeader className="gap-1.5">
				<CardTitle className="font-heading text-lg tracking-wide">
					Other ways to get help
				</CardTitle>
				<CardDescription>
					Email Member Services or browse public FAQs.
				</CardDescription>
			</CardHeader>
			<CardContent className="flex flex-col gap-6">
				{HELP_RESOURCE_GROUPS.map((group) => {
					const links = HELP_RESOURCE_LINKS.filter(
						(link) => link.group === group.key,
					)
					if (links.length === 0) return null
					return (
						<div key={group.key} className="space-y-3">
							<h3 className="text-xs font-bold tracking-wider text-muted-foreground uppercase">
								{group.heading}
							</h3>
							<div className="flex flex-col gap-3">
								{links.map((link) => {
									const Icon = link.icon
									return (
										<div key={link.url} className="flex items-center gap-2">
											<Icon
												className="size-4 shrink-0 text-primary"
												aria-hidden
											/>
											<CardCta
												label={link.title}
												url={link.url}
												isExternal
												newWindow
											/>
										</div>
									)
								})}
							</div>
						</div>
					)
				})}
			</CardContent>
		</Card>
	)
}

export { HelpCenterResources }
