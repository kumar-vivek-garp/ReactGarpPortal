import { cn } from "@/lib/utils"
import type { FooterNavSection } from "@/lib/navigation/types"

function FooterNavSectionView({ section, className }: { section: FooterNavSection; className?: string }) {
	return (
		<div className={cn(className)}>
			<h3 className="mb-2 font-sans text-section font-bold text-foreground">{section.label}</h3>
			<ul className="flex flex-col gap-2">
				{section.links.map((link) => (
					<li key={link.title}>
						<a
							href={link.url}
							target={link.openInNewTab ? "_blank" : undefined}
							rel={link.openInNewTab ? "noopener noreferrer" : undefined}
							className="text-body text-foreground hover:underline"
						>
							{link.title}
						</a>
					</li>
				))}
			</ul>
		</div>
	)
}

export { FooterNavSectionView }
