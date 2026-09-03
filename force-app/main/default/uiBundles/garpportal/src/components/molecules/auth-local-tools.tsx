import { useEffect, useMemo, useState } from "react"
import { useNavigate } from "@tanstack/react-router"
import { Users } from "lucide-react"

import { Button } from "@/components/atoms/button"
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogHeader,
	DialogTitle,
	DialogTrigger,
} from "@/components/atoms/dialog"
import { Input } from "@/components/atoms/input"
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from "@/components/atoms/select"
import { authQueryKeys } from "@/api/auth/query-options"
import type { CurrentUser } from "@/api/auth/current-user"
import { DEFAULT_POST_LOGIN_PATH } from "@/auth/constants"
import {
	checkLocalSfHealth,
	fetchCurrentUserViaLocalCli,
} from "@/auth/local-cli-auth"
import {
	clearLocalDevContactId,
	DEFAULT_LIST_VIEW,
	fetchContactListViewsViaLocalCli,
	fetchContactsFromListViewViaLocalCli,
	getLocalDevContactId,
	getLocalDevListViewApiName,
	searchContactsViaLocalCli,
	setLocalDevContact,
	setLocalDevListViewApiName,
	type LocalDevContact,
	type LocalDevContactListView,
} from "@/auth/local-dev-contacts"
import { clearLocalLogoutFlag } from "@/auth/local-session"
import { ThemeToggle } from "@/components/molecules/theme-toggle"
import { queryClient } from "@/api/client"

/**
 * Contact list + Continue-with-CLI actions for the local-dev dialog body.
 * List views come from Salesforce UI API via local-sf (no Apex).
 */
function LocalDevContactPanel({ onEntered }: { onEntered?: () => void }) {
	const navigate = useNavigate()
	const [pending, setPending] = useState(false)
	const [errors, setErrors] = useState<string[]>([])
	const [query, setQuery] = useState("")
	const [listViewQuery, setListViewQuery] = useState("")
	const [listViews, setListViews] = useState<LocalDevContactListView[]>([])
	const [listViewApiName, setListViewApiName] = useState(() =>
		getLocalDevListViewApiName(),
	)
	const [contacts, setContacts] = useState<LocalDevContact[]>([])
	const [listPending, setListPending] = useState(false)
	const [viewsPending, setViewsPending] = useState(true)
	const [listError, setListError] = useState<string | null>(null)
	const [selectedId, setSelectedId] = useState<string | null>(() =>
		getLocalDevContactId(),
	)

	const filteredListViews = useMemo(() => {
		const q = listViewQuery.trim().toLowerCase()
		if (!q) return listViews
		return listViews.filter(
			(view) =>
				view.label.toLowerCase().includes(q) ||
				view.apiName.toLowerCase().includes(q),
		)
	}, [listViewQuery, listViews])

	useEffect(() => {
		let cancelled = false
		void (async () => {
			setViewsPending(true)
			try {
				const health = await checkLocalSfHealth()
				if (!health.ok) {
					if (!cancelled) {
						setListViews([])
						setListError(
							[
								health.error ?? "Local Salesforce gateway is not ready.",
								health.hint ?? "From the repo root run: npm run local-sf",
							]
								.filter(Boolean)
								.join(" "),
						)
					}
					return
				}
				const views = await fetchContactListViewsViaLocalCli()
				if (cancelled) return
				setListViews(views)
				const saved = getLocalDevListViewApiName()
				const exists = views.some((view) => view.apiName === saved)
				const next = exists ? saved : DEFAULT_LIST_VIEW
				setListViewApiName(next)
				setLocalDevListViewApiName(next)
			} catch (error) {
				if (!cancelled) {
					setListViews([])
					setListError(
						error instanceof Error
							? error.message
							: "Unable to load Contact list views.",
					)
				}
			} finally {
				if (!cancelled) setViewsPending(false)
			}
		})()
		return () => {
			cancelled = true
		}
	}, [])

	useEffect(() => {
		if (viewsPending) return
		let cancelled = false
		const handle = window.setTimeout(() => {
			void (async () => {
				setListPending(true)
				setListError(null)
				try {
					const health = await checkLocalSfHealth()
					if (!health.ok) {
						if (!cancelled) {
							setContacts([])
							setListError(
								[
									health.error ?? "Local Salesforce gateway is not ready.",
									health.hint ?? "From the repo root run: npm run local-sf",
								]
									.filter(Boolean)
									.join(" "),
							)
						}
						return
					}
					// A typed query searches every Contact via SOQL, not just the
					// selected view. List views here are org metadata and are
					// often filtered to a working subset — the stock "All
					// Contacts" in this org is scoped to uncertified FRM
					// candidates — so a view-bounded search silently hides
					// anyone outside it. The view still drives the idle list.
					const rows = query.trim()
						? await searchContactsViaLocalCli({ q: query, limit: 40 })
						: await fetchContactsFromListViewViaLocalCli({
								listViewApiName,
								limit: 40,
							})
					if (!cancelled) setContacts(rows)
				} catch (error) {
					if (!cancelled) {
						setContacts([])
						setListError(
							error instanceof Error
								? error.message
								: "Unable to load Contacts.",
						)
					}
				} finally {
					if (!cancelled) setListPending(false)
				}
			})()
		}, 300)

		return () => {
			cancelled = true
			window.clearTimeout(handle)
		}
	}, [listViewApiName, query, viewsPending])

	async function enterAsUser(user: CurrentUser) {
		clearLocalLogoutFlag()
		queryClient.setQueryData(authQueryKeys.currentUser, user)
		onEntered?.()
		await navigate({ to: DEFAULT_POST_LOGIN_PATH })
	}

	async function onContinueDefault() {
		setPending(true)
		setErrors([])
		try {
			const health = await checkLocalSfHealth()
			if (!health.ok) {
				setErrors(
					[
						health.error ?? "Local Salesforce gateway is not ready.",
						health.hint ?? "From the repo root run: npm run local-sf",
					].filter(Boolean),
				)
				return
			}

			clearLocalDevContactId()
			setSelectedId(null)

			const user = await fetchCurrentUserViaLocalCli()
			if (!user) {
				setErrors([
					"CLI session is up, but identity checks failed.",
					`Gateway user: ${health.username ?? "unknown"}`,
					`Try: sf org login web --alias ${health.targetOrg ?? "<alias>"}`,
				])
				return
			}

			await enterAsUser(user)
		} catch (error) {
			setErrors([
				error instanceof Error ? error.message : "Local CLI continue failed.",
			])
		} finally {
			setPending(false)
		}
	}

	async function onSelectContact(contact: LocalDevContact) {
		setPending(true)
		setErrors([])
		setSelectedId(contact.id)
		try {
			const health = await checkLocalSfHealth()
			if (!health.ok) {
				setErrors(
					[
						health.error ?? "Local Salesforce gateway is not ready.",
						health.hint ?? "From the repo root run: npm run local-sf",
					].filter(Boolean),
				)
				return
			}

			setLocalDevContact(contact)
			await enterAsUser({
				id: contact.id,
				name: contact.name,
				garpId: contact.garpId,
				contactId: contact.id,
				photoUrl: null,
			})
		} catch (error) {
			setErrors([
				error instanceof Error
					? error.message
					: "Unable to continue as selected Contact.",
			])
		} finally {
			setPending(false)
		}
	}

	function onListViewChange(apiName: string) {
		setListViewApiName(apiName)
		setLocalDevListViewApiName(apiName)
	}

	return (
		<div className="flex flex-col gap-3">
			<p className="text-center text-sm text-muted-foreground">
				Local development: pick an org Contact list view, then a Contact (admin
				CLI token).
			</p>

			<div className="flex flex-col gap-2 rounded-xl border border-border bg-background p-3">
				<label
					htmlFor="local-dev-list-view-search"
					className="text-caption font-bold"
				>
					Search lists
				</label>
				<Input
					id="local-dev-list-view-search"
					type="search"
					placeholder="Search lists…"
					value={listViewQuery}
					disabled={pending || viewsPending}
					onChange={(event) => setListViewQuery(event.target.value)}
					className="h-9 rounded-lg"
					autoComplete="off"
				/>

				<label htmlFor="local-dev-list-view" className="text-caption font-bold">
					List view
				</label>
				<Select
					value={listViewApiName}
					onValueChange={onListViewChange}
					disabled={pending || viewsPending || filteredListViews.length === 0}
				>
					<SelectTrigger id="local-dev-list-view" className="w-full">
						<SelectValue
							placeholder={viewsPending ? "Loading lists…" : "Select list view"}
						/>
					</SelectTrigger>
					<SelectContent className="max-h-60">
						{filteredListViews.map((view) => (
							<SelectItem key={view.apiName} value={view.apiName}>
								{view.label}
							</SelectItem>
						))}
					</SelectContent>
				</Select>

				<label
					htmlFor="local-dev-contact-search"
					className="text-caption font-bold"
				>
					Search Contacts
				</label>
				<Input
					id="local-dev-contact-search"
					type="search"
					placeholder="Name, email, or GARP Id — searches all Contacts…"
					value={query}
					disabled={pending || viewsPending}
					onChange={(event) => setQuery(event.target.value)}
					className="h-9 rounded-lg"
					autoComplete="off"
				/>

				{listError ? (
					<p className="text-caption text-destructive" role="alert">
						{listError}
					</p>
				) : null}

				<div
					className="max-h-56 overflow-y-auto rounded-lg border border-border"
					role="listbox"
					aria-label="Contacts"
				>
					{viewsPending || listPending ? (
						<p className="p-3 text-caption text-muted-foreground">Loading…</p>
					) : contacts.length === 0 ? (
						<p className="p-3 text-caption text-muted-foreground">
							{query.trim()
								? "No Contacts match that search."
								: "No Contacts found in this list view."}
						</p>
					) : (
						<ul className="divide-y divide-border">
							{contacts.map((contact) => {
								const selected = contact.id === selectedId
								return (
									<li key={contact.id}>
										<button
											type="button"
											role="option"
											aria-selected={selected}
											disabled={pending}
											onClick={() => void onSelectContact(contact)}
											className={
												selected
													? "flex w-full flex-col gap-0.5 bg-primary/10 px-3 py-2 text-left hover:bg-primary/15"
													: "flex w-full flex-col gap-0.5 px-3 py-2 text-left hover:bg-muted/60"
											}
										>
											<span className="text-body font-semibold text-foreground">
												{contact.name}
											</span>
											<span className="text-caption text-muted-foreground">
												{[
													contact.email,
													contact.garpId ? `GARP ${contact.garpId}` : null,
												]
													.filter(Boolean)
													.join(" · ") || contact.id}
											</span>
										</button>
									</li>
								)
							})}
						</ul>
					)}
				</div>

				<p className="text-caption text-muted-foreground">
					List views are org metadata via UI API. Click a Contact to enter;
					requests send{" "}
					<code className="text-[0.7rem]">X-GARP-Dev-Contact</code>.
				</p>
			</div>

			{errors.length > 0 ? (
				<ul
					className="list-disc space-y-1 pl-5 text-body text-destructive"
					role="alert"
				>
					{errors.map((message) => (
						<li key={message}>{message}</li>
					))}
				</ul>
			) : null}

			<Button
				type="button"
				variant="outline"
				className="h-[60px]"
				disabled={pending}
				onClick={() => void onContinueDefault()}
			>
				{pending ? "Connecting…" : "Continue with Salesforce CLI (default)"}
			</Button>
		</div>
	)
}

/**
 * Login-page chrome (localhost only): theme toggle + Contact picker dialog.
 * Fixed top-left so Sign In stays clean.
 */
function AuthLocalTools() {
	const [open, setOpen] = useState(false)

	return (
		<div className="fixed top-4 left-4 z-50 flex items-center gap-1">
			<ThemeToggle
				variant="toolbar"
				className="text-white hover:bg-white/10 hover:text-white"
			/>
			<Dialog open={open} onOpenChange={setOpen}>
				<DialogTrigger asChild>
					<Button
						type="button"
						variant="ghost"
						size="icon"
						aria-label="Local Salesforce CLI contacts"
						title="Local CLI contacts"
						className="size-9 shrink-0 text-white hover:bg-white/10 hover:text-white"
					>
						<Users className="size-5" strokeWidth={2.25} aria-hidden />
					</Button>
				</DialogTrigger>
				<DialogContent className="gap-4 sm:max-w-md">
					<DialogHeader className="pr-8 text-left">
						<DialogTitle>Local CLI contacts</DialogTitle>
						<DialogDescription>
							Choose a Salesforce Contact list view, then pick a member — or
							continue with the org default fallback.
						</DialogDescription>
					</DialogHeader>
					<LocalDevContactPanel onEntered={() => setOpen(false)} />
				</DialogContent>
			</Dialog>
		</div>
	)
}

export { AuthLocalTools, LocalDevContactPanel }
