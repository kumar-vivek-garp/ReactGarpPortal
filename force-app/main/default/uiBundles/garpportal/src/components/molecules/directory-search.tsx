import { useState } from "react"
import { Loader2, Search } from "lucide-react"

import { searchDirectory } from "@/api/directory/directory"
import type { DirectoryMember } from "@/api/directory/types"
import { AppError, notifyError } from "@/api/client"
import { Button } from "@/components/atoms/button"
import { Input } from "@/components/atoms/input"
import { cn } from "@/lib/utils"

type DirectorySearchProps = {
	placeholder?: string
	className?: string
}

function memberSubtitle(member: DirectoryMember): string {
	return [member.corporateTitle, member.company, member.country]
		.filter(Boolean)
		.join(" · ")
}

/**
 * Submit-driven directory search. Layout is pagination-ready: sticky toolbar,
 * scrollable result region, count row — page controls can slot into the footer later.
 */
function DirectorySearch({
	placeholder = "Search by name, location, or company",
	className,
}: DirectorySearchProps) {
	const [term, setTerm] = useState("")
	const [submittedTerm, setSubmittedTerm] = useState<string | null>(null)
	const [results, setResults] = useState<DirectoryMember[] | null>(null)
	const [searching, setSearching] = useState(false)
	const [error, setError] = useState<string | null>(null)

	async function runSearch(event: React.FormEvent) {
		event.preventDefault()
		const trimmed = term.trim()
		if (!trimmed) return

		setSearching(true)
		setError(null)
		setSubmittedTerm(trimmed)
		try {
			setResults(await searchDirectory(trimmed))
		} catch (err) {
			const message =
				err instanceof AppError
					? err.messages[0]
					: err instanceof Error
						? err.message
						: "Search failed"
			setError(message)
			setResults(null)
			notifyError(err, "Directory search failed")
		} finally {
			setSearching(false)
		}
	}

	const canSubmit = Boolean(term.trim()) && !searching
	const hasResults = results !== null && !error

	return (
		<div className={cn("flex min-h-0 flex-1 flex-col gap-3", className)}>
			{/* Sticky search toolbar — stays put while results scroll. */}
			<form
				onSubmit={runSearch}
				className="relative shrink-0"
			>
				<Input
					value={term}
					onChange={(event) => setTerm(event.target.value)}
					placeholder={placeholder}
					aria-label="Search the Member Directory"
					className="h-10 rounded-xl pr-11 shadow-none focus-visible:border-ring focus-visible:ring-0 focus-visible:ring-offset-0"
				/>
				<Button
					type="submit"
					variant="ghost"
					size="icon"
					aria-label="Search"
					disabled={!canSubmit}
					className="absolute top-1/2 right-0.5 size-9 -translate-y-1/2 rounded-md text-foreground hover:text-primary"
				>
					{searching ? (
						<Loader2 className="size-4 animate-spin" />
					) : (
						<Search className="size-4" />
					)}
				</Button>
			</form>

			{error ? <p className="shrink-0 text-xs text-destructive">{error}</p> : null}

			{/* Scrollable results region — fills remaining height. */}
			<div className="min-h-0 flex-1 overflow-y-auto overscroll-contain [scrollbar-width:thin]">
				{!hasResults && !searching ? (
					<p className="py-6 text-sm text-muted-foreground">
						Search by name, company, or country to find members who opted into the
						directory.
					</p>
				) : null}

				{hasResults ? (
					<div className="space-y-2">
						<div className="flex items-baseline justify-between gap-3">
							<p className="text-xs text-muted-foreground">
								{results.length === 0
									? `No members matched “${submittedTerm}”`
									: `${results.length} member${results.length === 1 ? "" : "s"}`}
								{results.length > 0 ? (
									<span className="text-muted-foreground/80">
										{" "}
										· opted-in directory
									</span>
								) : null}
							</p>
							{/* Pagination controls slot here when list API lands. */}
						</div>

						{results.length === 0 ? (
							<p className="text-xs text-muted-foreground">
								Only members who opted into the directory are listed.
							</p>
						) : (
							<ul className="divide-y divide-border rounded-md border border-border bg-card">
								<li className="hidden grid-cols-[minmax(0,1.2fr)_minmax(0,1fr)_minmax(0,1fr)_minmax(0,0.7fr)] gap-3 px-3 py-1.5 text-[11px] font-semibold tracking-wide text-muted-foreground uppercase sm:grid">
									<span>Name</span>
									<span>Title</span>
									<span>Company</span>
									<span>Country</span>
								</li>
								{results.map((member) => (
									<li
										key={member.id}
										className="grid gap-0.5 px-3 py-2.5 sm:grid-cols-[minmax(0,1.2fr)_minmax(0,1fr)_minmax(0,1fr)_minmax(0,0.7fr)] sm:items-center sm:gap-3"
									>
										<p className="truncate text-sm font-medium text-foreground">
											{member.name ?? "—"}
										</p>
										<p className="hidden truncate text-sm text-muted-foreground sm:block">
											{member.corporateTitle ?? "—"}
										</p>
										<p className="hidden truncate text-sm text-muted-foreground sm:block">
											{member.company ?? "—"}
										</p>
										<p className="hidden truncate text-sm text-muted-foreground sm:block">
											{member.country ?? "—"}
										</p>
										{/* Mobile: compact subtitle under name */}
										<p className="truncate text-xs text-muted-foreground sm:hidden">
											{memberSubtitle(member) || "—"}
										</p>
									</li>
								))}
							</ul>
						)}
					</div>
				) : null}
			</div>
		</div>
	)
}

export { DirectorySearch }
