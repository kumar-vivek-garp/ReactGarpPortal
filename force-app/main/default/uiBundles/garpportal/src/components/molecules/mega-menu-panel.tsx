import { MegaMenuColumnView } from "@/components/molecules/mega-menu-column"
import { MegaMenuHeadingText } from "@/components/molecules/mega-menu-heading"
import type { TopNavItem } from "@/config/navigation/types"
import { cn } from "@/lib/utils"

type MegaMenuPanelProps = {
	item: TopNavItem
	variant?: "desktop" | "mobile"
	className?: string
}

function MegaMenuPanel({ item, variant = "desktop", className }: MegaMenuPanelProps) {
	const isDesktop = variant === "desktop"
	const columnCount = item.column3 ? 3 : 2

	return (
		<div className={cn(isDesktop ? "text-dark-blue-gray" : "", className)}>
			{item.heading ? (
				<h3
					className={cn(
						"font-sans font-extrabold text-foreground",
						isDesktop ? "mb-0 px-5 pt-5 text-xl" : "mb-5 text-lg font-bold"
					)}
				>
					<MegaMenuHeadingText heading={item.heading} />
				</h3>
			) : null}
			<div
				className={cn(
					isDesktop
						? cn(
								"grid w-max gap-5 p-5 text-dark-blue-gray",
								columnCount === 3 ? "grid-cols-3" : "grid-cols-2"
							)
						: "flex flex-col gap-6"
				)}
			>
				<MegaMenuColumnView
					column={item.column1}
					variant={variant}
					className={isDesktop ? "mr-10 pl-2.5" : undefined}
				/>
				<MegaMenuColumnView
					column={item.column2}
					variant={variant}
					className={isDesktop ? "pr-2.5" : undefined}
				/>
				{item.column3 ? (
					<MegaMenuColumnView
						column={item.column3}
						variant={variant}
						className={isDesktop ? "pr-2.5" : undefined}
					/>
				) : null}
			</div>
		</div>
	)
}

export { MegaMenuPanel }
