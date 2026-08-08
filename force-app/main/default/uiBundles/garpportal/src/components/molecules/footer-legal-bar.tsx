import type { ExternalNavLink } from "@/config/navigation/types"

type FooterLegalBarProps = {
	links: ExternalNavLink[]
	copyright: string
}

function FooterLegalBar({ links, copyright }: FooterLegalBarProps) {
	return (
		<div className="flex flex-col gap-4 border-t border-background pt-6 text-caption text-foreground sm:flex-row sm:items-center sm:justify-between">
			<ul className="flex flex-wrap gap-x-4 gap-y-2">
				{links.map((link) => (
					<li key={link.title}>
						<a href={link.url} className="hover:underline">
							{link.title}
						</a>
					</li>
				))}
			</ul>
			<p>{copyright}</p>
		</div>
	)
}

export { FooterLegalBar }
