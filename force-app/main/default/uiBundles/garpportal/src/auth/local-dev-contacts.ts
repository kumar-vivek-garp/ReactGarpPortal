/**
 * Localhost-only Contact search + selected Contact Id persistence.
 * Used by the login Contact picker (`local-sf` + admin CLI token).
 *
 * List views use Salesforce UI API (no Apex):
 * - GET /ui-api/list-ui/Contact
 * - GET /ui-api/list-records/Contact/{listViewApiName}
 */

import { isLocalCliAuthEnabled, localSfFetch } from "@/auth/local-cli-auth"

const STORAGE_KEY = "garp.localDev.contactId"
const STORAGE_META_KEY = "garp.localDev.contactMeta"
const LIST_VIEW_STORAGE_KEY = "garp.localDev.listViewApiName"
const DEFAULT_API_VERSION = "67.0"
const DEFAULT_LIMIT = 40
const DEFAULT_LIST_VIEW = "AllContacts"

/** Header forwarded by local-sf → Apex `currentContact()` (Phase 2). */
export const LOCAL_DEV_CONTACT_HEADER = "X-GARP-Dev-Contact" as const

export type LocalDevContact = {
	id: string
	name: string
	email: string | null
	garpId: string | null
}

export type LocalDevContactListView = {
	apiName: string
	label: string
	id: string | null
}

type SoqlQueryResult = {
	totalSize?: number
	done?: boolean
	records?: Array<{
		Id?: string
		Name?: string | null
		Email?: string | null
		GARP_Member_ID__c?: string | null
	}>
}

type ListUiResponse = {
	lists?: Array<{
		apiName?: string
		label?: string
		id?: string | null
	}>
	nextPageToken?: string | null
	nextPageUrl?: string | null
}

type UiApiFieldValue = {
	displayValue?: string | null
	value?: string | null
}

type ListRecordsResponse = {
	records?: Array<{
		id?: string
		fields?: {
			Id?: UiApiFieldValue
			Name?: UiApiFieldValue
			Email?: UiApiFieldValue
			GARP_Member_ID__c?: UiApiFieldValue
		}
	}>
}

function escapeSoqlLike(raw: string): string {
	return raw.replace(/\\/g, "\\\\").replace(/'/g, "\\'").replace(/%/g, "\\%")
}

function fieldText(field: UiApiFieldValue | undefined): string | null {
	const value = field?.value?.trim() || field?.displayValue?.trim()
	return value || null
}

export function getLocalDevContactId(): string | null {
	if (!isLocalCliAuthEnabled()) return null
	try {
		const value = localStorage.getItem(STORAGE_KEY)?.trim()
		return value || null
	} catch {
		return null
	}
}

export function getLocalDevContactMeta(): LocalDevContact | null {
	if (!isLocalCliAuthEnabled()) return null
	try {
		const raw = localStorage.getItem(STORAGE_META_KEY)
		if (!raw) return null
		const parsed = JSON.parse(raw) as LocalDevContact
		if (!parsed?.id) return null
		return parsed
	} catch {
		return null
	}
}

export function setLocalDevContact(contact: LocalDevContact): void {
	if (!isLocalCliAuthEnabled()) return
	try {
		localStorage.setItem(STORAGE_KEY, contact.id)
		localStorage.setItem(STORAGE_META_KEY, JSON.stringify(contact))
	} catch {
		/* ignore quota / private mode */
	}
}

export function clearLocalDevContactId(): void {
	try {
		localStorage.removeItem(STORAGE_KEY)
		localStorage.removeItem(STORAGE_META_KEY)
	} catch {
		/* ignore */
	}
}

export function getLocalDevListViewApiName(): string {
	if (!isLocalCliAuthEnabled()) return DEFAULT_LIST_VIEW
	try {
		return localStorage.getItem(LIST_VIEW_STORAGE_KEY)?.trim() || DEFAULT_LIST_VIEW
	} catch {
		return DEFAULT_LIST_VIEW
	}
}

export function setLocalDevListViewApiName(apiName: string): void {
	if (!isLocalCliAuthEnabled()) return
	try {
		localStorage.setItem(LIST_VIEW_STORAGE_KEY, apiName)
	} catch {
		/* ignore */
	}
}

/** Headers to attach on localhost org calls when a Contact is selected. */
export function localDevContactHeaders(): Record<string, string> {
	const contactId = getLocalDevContactId()
	if (!contactId) return {}
	return { [LOCAL_DEV_CONTACT_HEADER]: contactId }
}

/**
 * Patch `fetch` so Data SDK `/services/*` calls also send the selected Contact.
 * Safe: no-op when not localhost or no Contact selected. Call once from `app.tsx`.
 */
export function installLocalDevContactFetchPatch(): void {
	if (!isLocalCliAuthEnabled()) return
	if (typeof window === "undefined") return

	const flag = "__garpLocalDevContactFetchPatched" as const
	const w = window as Window & { [flag]?: boolean }
	if (w[flag]) return
	w[flag] = true

	const originalFetch = window.fetch.bind(window)

	window.fetch = (input: RequestInfo | URL, init?: RequestInit) => {
		const url =
			typeof input === "string"
				? input
				: input instanceof URL
					? input.href
					: input.url

		const isOrgPath =
			url.includes("/services/") || url.includes("/__local_sf/")
		if (!isOrgPath) {
			return originalFetch(input, init)
		}

		const extra = localDevContactHeaders()
		if (!Object.keys(extra).length) {
			return originalFetch(input, init)
		}

		const headers = new Headers(
			init?.headers ??
				(input instanceof Request ? input.headers : undefined),
		)
		for (const [key, value] of Object.entries(extra)) {
			headers.set(key, value)
		}

		if (input instanceof Request) {
			return originalFetch(new Request(input, { ...init, headers }))
		}
		return originalFetch(input, { ...init, headers })
	}
}

async function readJsonOrThrow(response: Response, label: string): Promise<unknown> {
	if (!response.ok) {
		const body = await response.text().catch(() => "")
		throw new Error(
			`${label} failed (HTTP ${response.status})${body ? `: ${body.slice(0, 200)}` : ""}`,
		)
	}
	return response.json()
}

/**
 * All Contact list views visible to the CLI admin (UI API).
 */
export async function fetchContactListViewsViaLocalCli(): Promise<
	LocalDevContactListView[]
> {
	if (!isLocalCliAuthEnabled()) {
		throw new Error("List views are only available on localhost Vite.")
	}

	const views: LocalDevContactListView[] = []
	let path:
		| string
		| null = `/services/data/v${DEFAULT_API_VERSION}/ui-api/list-ui/Contact?pageSize=200`

	while (path) {
		const response = await localSfFetch(path, {
			method: "GET",
			headers: { Accept: "application/json" },
		})
		const payload = (await readJsonOrThrow(
			response,
			"Contact list views",
		)) as ListUiResponse

		for (const row of payload.lists ?? []) {
			const apiName = row.apiName?.trim()
			const label = row.label?.trim()
			if (!apiName || !label) continue
			views.push({
				apiName,
				label,
				id: row.id?.trim() || null,
			})
		}

		if (payload.nextPageUrl?.startsWith("/services/")) {
			path = payload.nextPageUrl
		} else if (payload.nextPageToken) {
			path = `/services/data/v${DEFAULT_API_VERSION}/ui-api/list-ui/Contact?pageSize=200&pageToken=${encodeURIComponent(payload.nextPageToken)}`
		} else {
			path = null
		}
	}

	return views.sort((a, b) => a.label.localeCompare(b.label))
}

/**
 * Contacts in a Salesforce list view (UI API), optional searchTerm within the view.
 */
export async function fetchContactsFromListViewViaLocalCli(options: {
	listViewApiName: string
	searchTerm?: string
	limit?: number
}): Promise<LocalDevContact[]> {
	if (!isLocalCliAuthEnabled()) {
		throw new Error("Contact list views are only available on localhost Vite.")
	}

	const apiName = options.listViewApiName.trim() || DEFAULT_LIST_VIEW
	const limit = Math.min(Math.max(options.limit ?? DEFAULT_LIMIT, 1), 100)
	const searchTerm = options.searchTerm?.trim() ?? ""

	const params = new URLSearchParams({
		pageSize: String(limit),
		fields: "Id,Name,Email,GARP_Member_ID__c",
	})
	if (searchTerm) params.set("searchTerm", searchTerm)

	const path =
		`/services/data/v${DEFAULT_API_VERSION}/ui-api/list-records/Contact/` +
		`${encodeURIComponent(apiName)}?${params.toString()}`

	const response = await localSfFetch(path, {
		method: "GET",
		headers: { Accept: "application/json" },
	})
	const payload = await readJsonOrThrow(response, "Contact list view records")

	if (Array.isArray(payload)) {
		const message =
			(payload[0] as { message?: string } | undefined)?.message ??
			"List view query failed."
		throw new Error(message)
	}

	const records = (payload as ListRecordsResponse).records ?? []

	return records
		.map((row) => {
			const id =
				row.id?.trim() || fieldText(row.fields?.Id)?.trim() || null
			if (!id) return null
			return {
				id,
				name: fieldText(row.fields?.Name) || id,
				email: fieldText(row.fields?.Email),
				garpId: fieldText(row.fields?.GARP_Member_ID__c),
			} satisfies LocalDevContact
		})
		.filter((row): row is LocalDevContact => row !== null)
}

/**
 * Fallback SOQL search (no list view) — Name / Email / GARP_Member_ID__c.
 */
export async function searchContactsViaLocalCli(options?: {
	q?: string
	limit?: number
}): Promise<LocalDevContact[]> {
	if (!isLocalCliAuthEnabled()) {
		throw new Error("Contact search is only available on localhost Vite.")
	}

	const limit = Math.min(Math.max(options?.limit ?? DEFAULT_LIMIT, 1), 100)
	const q = options?.q?.trim() ?? ""

	let soql =
		"SELECT Id, Name, Email, GARP_Member_ID__c FROM Contact"

	if (q) {
		const like = `%${escapeSoqlLike(q)}%`
		soql +=
			` WHERE (Name LIKE '${like}'` +
			` OR Email LIKE '${like}'` +
			` OR GARP_Member_ID__c LIKE '${like}')`
	}

	soql += ` ORDER BY Name NULLS LAST LIMIT ${limit}`

	const path =
		`/services/data/v${DEFAULT_API_VERSION}/query?q=` +
		encodeURIComponent(soql)

	const response = await localSfFetch(path, {
		method: "GET",
		headers: { Accept: "application/json" },
	})

	const payload = (await readJsonOrThrow(
		response,
		"Contact search",
	)) as SoqlQueryResult
	const records = payload.records ?? []

	return records
		.map((row) => {
			const id = row.Id?.trim()
			if (!id) return null
			return {
				id,
				name: row.Name?.trim() || id,
				email: row.Email?.trim() || null,
				garpId: row.GARP_Member_ID__c?.trim() || null,
			} satisfies LocalDevContact
		})
		.filter((row): row is LocalDevContact => row !== null)
}

export { DEFAULT_LIST_VIEW }
