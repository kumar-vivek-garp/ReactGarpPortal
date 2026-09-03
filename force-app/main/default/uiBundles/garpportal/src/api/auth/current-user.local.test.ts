/**
 * `fetchCurrentUser`'s LOCAL branch — jsdom's origin is localhost, so with the
 * real `@/auth/sfdc-env` in place the identity probe routes to the CLI
 * gateway. `currentUserWireHandlers` serves that wire; everything above it
 * runs for real. The Data SDK branch lives in `current-user.test.ts`.
 */
import { beforeEach, describe, expect, it } from "vitest"

import { fetchCurrentUser } from "@/api/auth/current-user"
import { currentUserWireHandlers } from "@/testing/msw/handlers/auth"
import { server } from "@/testing/msw/server"

const member = {
	id: "005xx1",
	name: "Ada Lovelace",
	garpId: "G-1",
	contactId: "003xx1",
	photoUrl: "/photo.png",
}

beforeEach(() => {
	sessionStorage.clear()
})

describe("fetchCurrentUser (local CLI branch)", () => {
	it("resolves the member through the local gateway wire", async () => {
		server.use(...currentUserWireHandlers(member))
		await expect(fetchCurrentUser()).resolves.toEqual(member)
	})

	it("resolves null for a guest — GraphQL empty, me-probe refused", async () => {
		server.use(...currentUserWireHandlers(null))
		await expect(fetchCurrentUser()).resolves.toBeNull()
	})
})
