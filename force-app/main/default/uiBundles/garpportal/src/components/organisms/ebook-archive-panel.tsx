import { BookOpen, ExternalLink, Loader2 } from "lucide-react"
import { animated } from "@react-spring/web"

import { Button } from "@/components/atoms/button"
import { Card } from "@/components/atoms/card"
import { Skeleton } from "@/components/atoms/skeleton"
import { ProgramsSubpageHeader } from "@/components/molecules/programs-subpage-header"
import { EBOOK_ARCHIVE } from "@/config/study-materials"
import { useMyEBooks, useOpenEBook } from "@/hooks/use-ebook-archive"
import { useSubpageTransition } from "@/hooks/use-subpage-transition"
import {
	archiveTitleCount,
	groupEBooksByYear,
} from "@/lib/ebook-archive-presentation"
import { cn } from "@/lib/utils"

const SUBPAGE_SHELL =
	"-my-6 flex h-[calc(100vh-4rem)] flex-col gap-0 py-6 app:h-[calc(100vh-5rem)]"
const SUBPAGE_SCROLL =
	"mt-4 min-h-0 flex-1 space-y-6 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"

function ArchiveEmpty() {
	const Icon = EBOOK_ARCHIVE.icon
	return (
		<div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border bg-muted/20 px-6 py-12 text-center">
			<Icon className="size-10 text-muted-foreground" aria-hidden />
			<p className="mt-4 font-heading text-lg font-semibold tracking-wide text-foreground">
				{EBOOK_ARCHIVE.emptyTitle}
			</p>
			<p className="mt-2 max-w-md text-sm text-muted-foreground">
				{EBOOK_ARCHIVE.emptyMessage}
			</p>
		</div>
	)
}

/**
 * Purchased eBooks, newest edition first.
 *
 * Read-only by design — no filters and no commerce, matching the legacy page.
 * Unlike it, loading, empty and error are three distinct states: the legacy
 * rendered the same bare page for a member with no books and one whose request
 * had failed, with no way to tell which had happened.
 */
function EBookArchivePanel({ className }: { className?: string }) {
	const { style, exit } = useSubpageTransition()
	const { data, isLoading, isError } = useMyEBooks()
	const open = useOpenEBook()

	const groups = groupEBooksByYear(data)
	const total = archiveTitleCount(groups)

	return (
		<animated.div style={style} className={cn(SUBPAGE_SHELL, className)}>
			<ProgramsSubpageHeader
				back={{ kind: "studyMaterials" }}
				title={EBOOK_ARCHIVE.title}
				onNavigateBack={exit}
			/>

			<div className={SUBPAGE_SCROLL}>
				{isLoading ? (
					<div className="space-y-4" aria-busy>
						<Skeleton className="h-5 w-32" />
						<Skeleton className="h-28 w-full rounded-xl" />
						<Skeleton className="h-28 w-full rounded-xl" />
					</div>
				) : null}

				{!isLoading && isError ? (
					<p className="text-sm text-muted-foreground">
						We couldn&apos;t load your purchased materials. Please try again
						later.
					</p>
				) : null}

				{!isLoading && !isError ? (
					groups.length === 0 ? (
						<ArchiveEmpty />
					) : (
						<>
							<p className="text-sm text-muted-foreground">
								{total} {total === 1 ? "title" : "titles"} across{" "}
								{groups.length}{" "}
								{groups.length === 1 ? "edition" : "editions"}.
							</p>

							{groups.map((group) => (
								<section key={group.year} className="space-y-3">
									<h2 className="font-heading text-lg font-semibold tracking-wide text-foreground">
										{group.year}
									</h2>
									<Card className="gap-0 px-5 py-4 shadow-none">
										<ul className="divide-y divide-border/80">
											{group.titles.map((title) => (
												<li
													key={title.id}
													className="flex flex-wrap items-center gap-x-4 gap-y-2 py-3 first:pt-0 last:pb-0"
												>
													<BookOpen
														className="size-4 shrink-0 text-muted-foreground"
														aria-hidden
													/>
													<div className="min-w-0 flex-1">
														<p className="text-sm text-foreground">
															{title.label}
														</p>
														{title.provider ? (
															<p className="text-xs text-muted-foreground">
																{title.provider}
															</p>
														) : null}
													</div>
													{title.vendorId ? (
														<Button
															type="button"
															variant="outline"
															size="sm"
															disabled={open.isPending}
															onClick={() =>
																void open
																	.mutateAsync(title.vendorId ?? "")
																	.catch(() => undefined)
															}
														>
															{open.isPending &&
															open.variables === title.vendorId ? (
																<Loader2
																	className="size-4 animate-spin"
																	aria-hidden
																/>
															) : (
																<ExternalLink
																	className="size-4"
																	aria-hidden
																/>
															)}
															Access
														</Button>
													) : (
														/*
														 * Owned, but the key never resolved to a vendor
														 * item — there is nothing to open. Shown rather
														 * than hidden so the member can see what they
														 * paid for and ask about it.
														 */
														<span className="text-xs text-muted-foreground">
															Not available online
														</span>
													)}
												</li>
											))}
										</ul>
									</Card>
								</section>
							))}
						</>
					)
				) : null}
			</div>
		</animated.div>
	)
}

export { EBookArchivePanel }
