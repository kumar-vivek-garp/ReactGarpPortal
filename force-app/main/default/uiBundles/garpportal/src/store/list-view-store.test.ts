import { beforeEach, describe, expect, it } from "vitest"

import { useListViewStore } from "@/store/list-view-store"

beforeEach(() => {
	window.localStorage.clear()
	useListViewStore.setState({ preferred: {} })
})

describe("list view store", () => {
	it("remembers one choice per scope without clobbering the others", () => {
		useListViewStore.getState().setPreferred("programs", "list")
		useListViewStore.getState().setPreferred("study-materials", "grid")

		expect(useListViewStore.getState().preferred).toEqual({
			programs: "list",
			"study-materials": "grid",
		})
	})

	it("overwrites a scope's earlier choice, leaving siblings intact", () => {
		useListViewStore.getState().setPreferred("programs", "list")
		useListViewStore.getState().setPreferred("membership", "list")

		useListViewStore.getState().setPreferred("programs", "grid")

		expect(useListViewStore.getState().preferred).toEqual({
			programs: "grid",
			membership: "list",
		})
	})
})
