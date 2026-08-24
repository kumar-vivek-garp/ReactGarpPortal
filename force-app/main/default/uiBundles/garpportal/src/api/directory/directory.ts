import { createDataSDK } from "@salesforce/platform-sdk"

import {
	AppError,
	normalizeHttpResponse,
	unwrapApiResult,
	unwrapMemberPortalEnvelope,
} from "@/api/client"
import type {
	DirectoryMessageInput,
	DirectoryMessageResult,
	DirectorySearchParams,
	DirectorySearchResults,
	DirectoryView,
	MemberPortalEnvelope,
} from "@/api/directory/types"

const DIRECTORY_PATH = "/services/apexrest/memberportal/directory"
const DIRECTORY_SEARCH_PATH = "/services/apexrest/memberportal/directorySearch"
const DIRECTORY_MESSAGE_PATH = "/services/apexrest/memberportal/directoryMessage"

async function directoryRequest<T extends { statusCode: number; statusMessage: string | null }>(
	path: string,
	init: RequestInit,
	fallback: string,
): Promise<T> {
	const sdk = await createDataSDK()
	const response = await sdk.fetch?.(path, init)

	const result = await normalizeHttpResponse<MemberPortalEnvelope<T>>(response, {
		unreachableMessage: "Unable to reach the member directory.",
		fallbackErrorMessage: fallback,
	})

	const data = unwrapMemberPortalEnvelope(unwrapApiResult(result), {
		fallbackErrorMessage: fallback,
		missingDataMessage: "No directory data was returned.",
		status: result.status,
	})

	if (data.statusCode !== 200) {
		throw new AppError({
			messages: [data.statusMessage?.trim() || fallback],
			status: data.statusCode,
		})
	}

	return data
}

/** What the viewer may do in the directory (`GET directory`). */
export async function fetchDirectory(): Promise<DirectoryView> {
	return directoryRequest<DirectoryView>(
		DIRECTORY_PATH,
		{ method: "GET", headers: { Accept: "application/json" } },
		"Unable to load the member directory.",
	)
}

/**
 * Runs a directory search (`POST directorySearch`).
 *
 * The whole `SearchParams` shape is the body. Every value is bound
 * server-side, `sortField` is whitelisted and `pageSize` is clamped to 50, so
 * there is nothing to sanitise here — but equally nothing to gain from sending
 * a larger page.
 *
 * An empty `searchText` is a valid search, not a no-op: it becomes `%%` and
 * lists everyone the viewer is entitled to see, which is how the filter-only
 * case works.
 */
export async function searchDirectory(
	params: DirectorySearchParams,
): Promise<DirectorySearchResults> {
	const data = await directoryRequest<DirectorySearchResults>(
		DIRECTORY_SEARCH_PATH,
		{
			method: "POST",
			headers: {
				"Content-Type": "application/json",
				Accept: "application/json",
			},
			body: JSON.stringify(params),
		},
		"The directory search could not be run.",
	)

	return {
		...data,
		members: Array.isArray(data.members) ? data.members : [],
		pages: data.pages ?? 0,
		total: data.total ?? 0,
	}
}

/**
 * Sends a directory message or connection invite (`POST directoryMessage`).
 *
 * `messageType` must be one of the two literals Apex accepts. The legacy sent
 * the wrong type for Send Message and dropped the text the member had typed;
 * both are supplied properly here, and the recipient's own `canSendMessage` /
 * `canInvite` decide whether the action is offered at all.
 */
export async function sendDirectoryMessage(
	input: DirectoryMessageInput,
): Promise<DirectoryMessageResult> {
	if (!input.recipientContactId?.trim()) {
		throw new AppError({
			messages: ["A recipient is required."],
			status: 400,
		})
	}
	if (!input.message?.trim()) {
		throw new AppError({
			messages: ["Please write a message before sending."],
			status: 400,
		})
	}

	return directoryRequest<DirectoryMessageResult>(
		DIRECTORY_MESSAGE_PATH,
		{
			method: "POST",
			headers: {
				"Content-Type": "application/json",
				Accept: "application/json",
			},
			body: JSON.stringify({
				recipientContactId: input.recipientContactId.trim(),
				messageType: input.messageType,
				message: input.message.trim(),
			}),
		},
		"Your message could not be sent.",
	)
}
