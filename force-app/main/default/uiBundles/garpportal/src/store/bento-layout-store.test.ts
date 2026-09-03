import { beforeEach, describe, expect, it } from "vitest"

import { BENTO_STORAGE_KEY, BENTO_STORAGE_VERSION } from "@/config/bento"
import { useBentoLayoutStore } from "@/store/bento-layout-store"

const SCOPE = "account-information"

beforeEach(() => {
	window.localStorage.clear()
	useBentoLayoutStore.setState({ layouts: {} })
})

describe("bento layout store", () => {
	it("stores an arrangement under its scope and column count", () => {
		useBentoLayoutStore.getState().setColumns(SCOPE, 2, [["a", "b"], ["c"]])

		expect(useBentoLayoutStore.getState().layouts[SCOPE]?.columns).toEqual({
			"2": [["a", "b"], ["c"]],
		})
	})

	it("keeps the 2-column arrangement when a 1-column one is saved", () => {
		useBentoLayoutStore.getState().setColumns(SCOPE, 2, [["a", "b"], ["c"]])

		useBentoLayoutStore.getState().setColumns(SCOPE, 1, [["c", "a", "b"]])

		const columns = useBentoLayoutStore.getState().layouts[SCOPE]?.columns
		expect(columns?.["1"]).toEqual([["c", "a", "b"]])
		expect(columns?.["2"]).toEqual([["a", "b"], ["c"]])
	})

	it("replaces the arrangement for the same column count", () => {
		useBentoLayoutStore.getState().setColumns(SCOPE, 1, [["a", "b"]])

		useBentoLayoutStore.getState().setColumns(SCOPE, 1, [["b", "a"]])

		expect(useBentoLayoutStore.getState().layouts[SCOPE]?.columns).toEqual({
			"1": [["b", "a"]],
		})
	})

	it("reset removes the scope entirely, at every column count", () => {
		useBentoLayoutStore.getState().setColumns(SCOPE, 1, [["a"]])
		useBentoLayoutStore.getState().setColumns(SCOPE, 2, [["a"], []])

		useBentoLayoutStore.getState().reset(SCOPE)

		expect(useBentoLayoutStore.getState().layouts[SCOPE]).toBeUndefined()
		expect(useBentoLayoutStore.getState().layouts).toEqual({})
	})

	it("persists to localStorage under the bento key with its version", () => {
		useBentoLayoutStore.getState().setColumns(SCOPE, 2, [["a"], ["b"]])

		const raw = window.localStorage.getItem(BENTO_STORAGE_KEY)
		expect(raw).not.toBeNull()
		const parsed = JSON.parse(raw as string) as {
			version: number
			state: { layouts: Record<string, { columns: Record<string, string[][]> }> }
		}
		expect(parsed.version).toBe(BENTO_STORAGE_VERSION)
		expect(parsed.state.layouts[SCOPE]?.columns["2"]).toEqual([["a"], ["b"]])
	})
})
