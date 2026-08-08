import type { MegaMenuColumn } from "@/config/navigation/types"
import { cn } from "@/lib/utils"

type MegaMenuColumnViewProps = {
	column: MegaMenuColumn
	/** Desktop mega-menu uses denser line-height; mobile list is taller tap targets. */
	variant?: "desktop" | "mobile"
	className?: string
}

function MegaMenuColumnView({
	column,
	variant = "desktop",
	className,
}: MegaMenuColumnViewProps) {
	const isDesktop = variant === "desktop"

	return (
		<div className={cn(isDesktop ? "min-w-[150px] w-max" : "w-full", className)}>
			{column.headerURL ? (
				<a
					href={column.headerURL}
					className={cn(
						"font-extrabold hover:underline",
						isDesktop
							? "whitespace-nowrap text-xl text-dark-blue-gray"
							: "text-xl text-foreground"
					)}
				>
					{column.header}
				</a>
			) : (
				<p
					className={cn(
						"font-extrabold text-foreground",
						isDesktop ? "whitespace-nowrap text-xl text-dark-blue-gray" : "text-xl"
					)}
				>
					{column.header}
				</p>
			)}
			<ul className={cn("list-none p-0", isDesktop ? "mt-0" : "mt-1")}>
				{column.links.map((link) => (
					<li
						key={link.title}
						className={cn(isDesktop ? "leading-10" : "border-b border-border last:border-b-0")}
					>
						<a
							href={link.url}
							target={link.openInNewTab ? "_blank" : undefined}
							rel={link.openInNewTab ? "noopener noreferrer" : undefined}
							className={cn(
								"block font-bold text-foreground no-underline",
								isDesktop
									? "whitespace-nowrap hover:underline hover:decoration-[0.15em] hover:underline-offset-[0.2em]"
									: "px-2 py-3 text-base"
							)}
						>
							{link.title}
						</a>
					</li>
				))}
			</ul>
		</div>
	)
}

export { MegaMenuColumnView }
