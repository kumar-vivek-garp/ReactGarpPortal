import { useEffect } from "react"
import { animated, useTransition } from "@react-spring/web"
import { useNavigate } from "@tanstack/react-router"
import {
	BookOpen,
	Download,
	ExternalLink,
	Lock,
	ShoppingCart,
} from "lucide-react"

import type { CatalogueItem, StudyMaterial } from "@/api/study-materials/types"
import { Button } from "@/components/atoms/button"
import {
	Card,
	CardContent,
	CardFooter,
	CardHeader,
	CardTitle,
} from "@/components/atoms/card"
import { Skeleton } from "@/components/atoms/skeleton"
import { Tabs, TabsList, TabsTrigger } from "@/components/atoms/tabs"
import { StaggerReveal } from "@/components/molecules/stagger-reveal"
import { DEFAULT_STUDY_MATERIALS_TAB } from "@/config/study-materials"
import { useStudyMaterials } from "@/hooks/use-study-materials"
import { formatDateTime, formatLongDate } from "@/lib/account-format"
import { TAB_PANEL_TRANSITION } from "@/lib/tab-panel-spring"
import { cn } from "@/lib/utils"

const pillTriggerClassName = cn(
	"h-auto flex-none shrink-0 cursor-pointer rounded-xl border-0 px-5 py-2 text-sm font-semibold shadow-none",
	"bg-muted text-foreground hover:bg-muted/80 hover:text-foreground",
	"data-[state=active]:bg-deep-purple data-[state=active]:text-deep-purple-foreground",
	"data-[state=active]:hover:bg-deep-purple data-[state=active]:hover:text-deep-purple-foreground",
	"after:hidden",
)

type StudyMaterialsPanelProps = {
	tab: string
}

function CatalogueCard({ item }: { item: CatalogueItem }) {
	return (
		<Card className="h-full gap-4 overflow-hidden border-border py-0 shadow-none">
			{item.imageUrl ? (
				<div className="flex h-44 items-center justify-center bg-muted/40 p-4">
					<img
						src={item.imageUrl}
						alt=""
						className="max-h-full max-w-full object-contain"
						onError={(event) => {
							event.currentTarget.style.display = "none"
						}}
					/>
				</div>
			) : null}

			<CardHeader className="px-5 pt-5">
				<CardTitle className="font-heading text-lg leading-snug tracking-wide text-foreground">
					{item.title ?? "Study material"}
				</CardTitle>
				{item.costNote ? (
					<p className="mt-1 text-sm font-semibold text-foreground">{item.costNote}</p>
				) : null}
			</CardHeader>

			<CardContent className="flex-1 space-y-2 px-5">
				{item.paragraphs.map((paragraph) => (
					<p key={paragraph} className="text-sm text-muted-foreground">
						{paragraph}
					</p>
				))}
			</CardContent>

			<CardFooter className="mt-auto justify-end px-5 pb-5">
				{item.isDownload && item.downloadUrl ? (
					<a
						href={item.downloadUrl}
						target="_blank"
						rel="noreferrer noopener"
						className="inline-flex items-center gap-2 text-sm font-semibold text-foreground hover:text-garp-cyan"
					>
						<Download className="size-4" />
						Download Now
					</a>
				) : item.purchaseUrl ? (
					<a
						href={item.purchaseUrl}
						target="_blank"
						rel="noreferrer noopener"
						className="inline-flex items-center gap-2 text-sm font-semibold text-foreground hover:text-garp-cyan"
					>
						<ShoppingCart className="size-4" />
						Purchase
					</a>
				) : (
					<span className="text-sm text-muted-foreground">{item.materialType ?? ""}</span>
				)}
			</CardFooter>
		</Card>
	)
}

function EntitlementCard({ material }: { material: StudyMaterial }) {
	const accessUntil = formatLongDate(material.expirationDate)
	const lastOpened = formatDateTime(material.lastAccessed)

	return (
		<Card className="h-full gap-4 border-border py-5 shadow-none">
			<CardHeader className="px-5">
				<CardTitle className="flex items-start gap-2 font-heading text-base tracking-wide text-foreground">
					{material.isAvailable ? (
						<BookOpen className="mt-0.5 size-5 shrink-0" />
					) : (
						<Lock className="mt-0.5 size-5 shrink-0 text-muted-foreground" />
					)}
					<span className="flex-1">{material.name ?? "Study material"}</span>
				</CardTitle>
			</CardHeader>

			<CardContent className="flex-1 space-y-1.5 px-5 text-sm">
				{material.status ? (
					<p className="text-foreground">
						<span className="text-muted-foreground">Status: </span>
						{material.status}
					</p>
				) : null}
				{accessUntil ? (
					<p className="text-foreground">
						<span className="text-muted-foreground">Access until: </span>
						{accessUntil}
					</p>
				) : null}
				{lastOpened ? (
					<p className="text-xs text-muted-foreground">Last opened {lastOpened}</p>
				) : null}
				{!material.isAvailable && material.unavailableReason ? (
					<p className="text-sm text-amber-700 dark:text-amber-400">
						{material.unavailableReason}
					</p>
				) : null}
			</CardContent>

			<CardFooter className="mt-auto px-5">
				{material.isAvailable && material.accessUrl ? (
					<Button asChild variant="outline">
						<a href={material.accessUrl} target="_blank" rel="noreferrer noopener">
							Open eBook
							<ExternalLink className="size-4" />
						</a>
					</Button>
				) : (
					<a
						className="text-sm text-garp-cyan underline underline-offset-2"
						href="mailto:memberservices@garp.com?Subject=Study%20material%20access"
					>
						Ask member services about access
					</a>
				)}
			</CardFooter>
		</Card>
	)
}

function CatalogueCardSkeleton() {
	return (
		<Skeleton className="flex h-full flex-col gap-4 overflow-hidden rounded-xl border border-border py-0">
			{/* Image band — matches CatalogueCard h-44 muted frame */}
			<div className="flex h-44 items-center justify-center bg-muted/40 p-4">
				<Skeleton className="h-full w-full max-w-[12rem] rounded-md" />
			</div>
			<div className="space-y-2 px-5 pt-1">
				<Skeleton className="h-5 w-4/5" />
				<Skeleton className="h-4 w-28" />
			</div>
			<div className="flex-1 space-y-2 px-5">
				<Skeleton className="h-3.5 w-full" />
				<Skeleton className="h-3.5 w-full" />
				<Skeleton className="h-3.5 w-3/4" />
			</div>
			<div className="mt-auto flex justify-end px-5 pb-5">
				<Skeleton className="h-4 w-28" />
			</div>
		</Skeleton>
	)
}

function StudyMaterialsContentSkeleton() {
	return (
		<div
			className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
			aria-busy
			aria-label="Loading study materials"
		>
			{[0, 1, 2, 3, 4, 5, 6, 7].map((key) => (
				<CatalogueCardSkeleton key={key} />
			))}
		</div>
	)
}

function CatalogueGrid({
	tab,
	programs,
	entitlements,
}: {
	tab: string
	programs: Array<{ key: string; label: string; materials: CatalogueItem[] }>
	entitlements: StudyMaterial[]
}) {
	const visiblePrograms =
		tab === DEFAULT_STUDY_MATERIALS_TAB
			? programs
			: programs.filter((entry) => entry.key === tab)
	const items = visiblePrograms.flatMap((entry) =>
		entry.materials.map((item) => ({ programKey: entry.key, item })),
	)
	const isEmpty = programs.length === 0 && entitlements.length === 0

	if (isEmpty) {
		return (
			<p className="text-sm text-muted-foreground">
				No study materials published yet. Study materials appear here once they are
				published for a program.
			</p>
		)
	}

	return (
		<div className="space-y-8">
			{entitlements.length > 0 ? (
				<section className="space-y-4">
					<h2 className="font-heading text-xl font-semibold tracking-wide text-foreground">
						My Materials
						<span className="ml-2 text-base font-normal text-muted-foreground">
							({entitlements.length})
						</span>
					</h2>
					<StaggerReveal
						className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
						itemClassName="h-full"
					>
						{entitlements.map((material) => (
							<EntitlementCard key={material.id} material={material} />
						))}
					</StaggerReveal>
				</section>
			) : null}

			{items.length === 0 ? (
				<p className="text-sm text-muted-foreground">
					Nothing published for that program yet.
				</p>
			) : (
				<StaggerReveal
					className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3"
					itemClassName="h-full"
				>
					{items.map(({ programKey, item }) => (
						<CatalogueCard key={`${programKey}-${item.id}`} item={item} />
					))}
				</StaggerReveal>
			)}
		</div>
	)
}

function StudyMaterialsPanel({ tab }: StudyMaterialsPanelProps) {
	const navigate = useNavigate({ from: "/study-materials/" })
	const { data, isLoading, isError } = useStudyMaterials()
	const programs = data?.programs ?? []
	const entitlements = data?.myEntitlements ?? []
	const showProgramTabs = programs.length > 1

	useEffect(() => {
		if (!data || tab === DEFAULT_STUDY_MATERIALS_TAB) return
		if (data.programs.some((entry) => entry.key === tab)) return
		void navigate({
			search: { tab: DEFAULT_STUDY_MATERIALS_TAB },
			replace: true,
		})
	}, [data, tab, navigate])

	const tabTransitions = useTransition(tab, TAB_PANEL_TRANSITION)

	return (
		<Tabs
			value={tab}
			onValueChange={(value) => {
				void navigate({
					search: { tab: value },
					replace: true,
				})
			}}
			className="-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
		>
			{/* Fixed chrome: heading + program tabs — does not scroll. */}
			<header className="shrink-0 space-y-4">
				<h1 className="font-heading text-3xl font-semibold tracking-wide text-foreground">
					Study Materials for Risk Professionals
				</h1>

				{isLoading ? (
					<div className="flex flex-wrap gap-2">
						{[0, 1, 2, 3].map((key) => (
							<Skeleton key={key} className="h-9 w-24 rounded-xl" />
						))}
					</div>
				) : null}

				{!isLoading && showProgramTabs ? (
					<div className="overflow-x-auto overscroll-x-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
						<TabsList className="h-auto w-max gap-3 bg-transparent p-0">
							<TabsTrigger
								value={DEFAULT_STUDY_MATERIALS_TAB}
								className={pillTriggerClassName}
							>
								All
							</TabsTrigger>
							{programs.map((entry) => (
								<TabsTrigger
									key={entry.key}
									value={entry.key}
									className={pillTriggerClassName}
								>
									{entry.label}
								</TabsTrigger>
							))}
						</TabsList>
					</div>
				) : null}
			</header>

			{/* Only this region scrolls; cards stagger in via StaggerReveal inside grids. */}
			<div className="mt-6 min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
				{isLoading ? <StudyMaterialsContentSkeleton /> : null}

				{isError ? (
					<p className="text-sm text-muted-foreground">
						We couldn&apos;t load your study materials. Please try again later.
					</p>
				) : null}

				{!isLoading && !isError
					? tabTransitions((style, currentTab) => (
							<animated.div
								key={currentTab}
								role="tabpanel"
								style={style}
								className="pb-2"
							>
								<CatalogueGrid
									tab={currentTab}
									programs={programs}
									entitlements={entitlements}
								/>
							</animated.div>
						))
					: null}
			</div>
		</Tabs>
	)
}

export { StudyMaterialsPanel }
