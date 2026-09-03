import { http, HttpResponse } from "msw"
import { describe, expect, it } from "vitest"

import {
	fetchDirectory,
	searchDirectory,
	sendDirectoryMessage,
} from "@/api/directory/directory"
import type { DirectoryMessageInput } from "@/api/directory/types"
import { directoryView } from "@/testing/factories/directory"
import {
	memberPortalEnvelope,
	memberPortalError,
} from "@/testing/factories/envelope"
import { server } from "@/testing/msw/server"

const DIRECTORY_PATH = "/services/apexrest/memberportal/directory"
const SEARCH_PATH = "/services/apexrest/memberportal/directorySearch"
const MESSAGE_PATH = "/services/apexrest/memberportal/directoryMessage"

const messageInput: DirectoryMessageInput = {
	recipientContactId: " 003xx9 ",
	messageType: "Directory_Connect",
	message: "  Hello from the directory  ",
}

describe("fetchDirectory", () => {
	it("throws the inner refusal even on an HTTP 200", async () => {
		server.use(
			http.get(DIRECTORY_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						directoryView({ statusCode: 401, statusMessage: " No access " }),
					),
				),
			),
		)

		await expect(fetchDirectory()).rejects.toMatchObject({
			messages: ["No access"],
			status: 401,
		})
	})

	it("falls back to its own wording for a silent refusal", async () => {
		server.use(
			http.get(DIRECTORY_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope(
						directoryView({ statusCode: 500, statusMessage: null }),
					),
				),
			),
		)

		await expect(fetchDirectory()).rejects.toMatchObject({
			messages: ["Unable to load the member directory."],
		})
	})
})

describe("searchDirectory", () => {
	it("defaults members, pages and total when the payload omits them", async () => {
		server.use(
			http.post(SEARCH_PATH, () =>
				HttpResponse.json(
					memberPortalEnvelope({
						statusMessage: null,
						statusCode: 200,
						pageCurrent: 1,
						pageSize: 10,
					}),
				),
			),
		)

		await expect(searchDirectory({ searchText: "" })).resolves.toMatchObject({
			members: [],
			pages: 0,
			total: 0,
		})
	})
})

describe("sendDirectoryMessage", () => {
	it("refuses a missing recipient or empty message before the network", async () => {
		await expect(
			sendDirectoryMessage({ ...messageInput, recipientContactId: "  " }),
		).rejects.toMatchObject({ messages: ["A recipient is required."], status: 400 })

		await expect(
			sendDirectoryMessage({ ...messageInput, message: "   " }),
		).rejects.toMatchObject({
			messages: ["Please write a message before sending."],
			status: 400,
		})
	})

	it("posts the trimmed recipient, type and text", async () => {
		let body: unknown
		server.use(
			http.post(MESSAGE_PATH, async ({ request }) => {
				body = await request.json()
				return HttpResponse.json(
					memberPortalEnvelope({ statusMessage: "Sent", statusCode: 200 }),
				)
			}),
		)

		await expect(sendDirectoryMessage(messageInput)).resolves.toEqual({
			statusMessage: "Sent",
			statusCode: 200,
		})
		expect(body).toEqual({
			recipientContactId: "003xx9",
			messageType: "Directory_Connect",
			message: "Hello from the directory",
		})
	})

	it("surfaces the server's error message on a transport failure", async () => {
		server.use(
			http.post(MESSAGE_PATH, () =>
				HttpResponse.json(memberPortalError(500, "Messaging down"), {
					status: 500,
				}),
			),
		)

		await expect(sendDirectoryMessage(messageInput)).rejects.toMatchObject({
			messages: ["Messaging down"],
		})
	})
})
