import { useState } from "react"
import { useNavigate } from "@tanstack/react-router"
import { Search } from "lucide-react"

import { Button } from "@/components/atoms/button"
import { Input } from "@/components/atoms/input"
import { cn } from "@/lib/utils"

type DirectorySearchProps = {
	placeholder?: string
	className?: string
}

/**
 * The directory entry box on the dashboard card and the membership tab.
 *
 * Hands the term to `/member-directory` rather than searching inline. It used
 * to run its own GraphQL Contact query, which could only ever see opted-in
 * names — the real search runs in Apex, applies the viewer's entitlements and
 * redacts each row against the subject's own privacy switches, none of which a
 * client-side query can do. Two implementations of one search is also exactly
 * the drift this box was starting to create.
 */
function DirectorySearch({
	placeholder = "Search by name, location, or company",
	className,
}: DirectorySearchProps) {
	const [term, setTerm] = useState("")
	const navigate = useNavigate()

	const submit = (event: React.FormEvent) => {
		event.preventDefault()
		void navigate({
			to: "/member-directory",
			search: { q: term.trim() || undefined },
		})
	}

	return (
		<form onSubmit={submit} className={cn("flex flex-col gap-3", className)}>
			<p className="text-sm text-muted-foreground">
				Search by name, company, or country to find members who opted into the
				directory.
			</p>
			<div className="flex gap-2">
				<Input
					value={term}
					onChange={(event) => setTerm(event.target.value)}
					placeholder={placeholder}
					aria-label="Search the member directory"
				/>
				<Button type="submit" variant="outline" size="icon">
					<Search className="size-4" aria-hidden />
					<span className="sr-only">Search</span>
				</Button>
			</div>
		</form>
	)
}

export { DirectorySearch }
