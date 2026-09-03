import { StrictMode, type ReactElement, type ReactNode } from "react"
import type { QueryClient } from "@tanstack/react-query"
import { QueryClientProvider } from "@tanstack/react-query"
import { render, renderHook, type RenderOptions } from "@testing-library/react"

import type { CurrentUser } from "@/api/auth/current-user"
import { createTestQueryClient } from "@/testing/query-client"

type ProviderOptions = {
	/** Session seeded into the query cache; `null` = guest, omit = not fetched. */
	user?: CurrentUser | null
	/** Bring a prepared client instead (e.g. with extra seeded queries). */
	queryClient?: QueryClient
	/**
	 * StrictMode is ON by default so every test sees production's double-invoke
	 * semantics (app.tsx wraps the tree in it). Turn off only to diagnose.
	 */
	strict?: boolean
}

function buildWrapper({ user, queryClient, strict = true }: ProviderOptions) {
	const client = queryClient ?? createTestQueryClient(user)

	function Wrapper({ children }: { children: ReactNode }) {
		const tree = (
			<QueryClientProvider client={client}>{children}</QueryClientProvider>
		)
		return strict ? <StrictMode>{tree}</StrictMode> : tree
	}

	return { client, Wrapper }
}

/**
 * Render a component under the app's providers. Returns everything
 * `@testing-library/react`'s `render` returns (including `container`, which
 * the theming/geometry contract tests rely on) plus the `queryClient`.
 */
export function renderWithProviders(
	ui: ReactElement,
	options: ProviderOptions & Omit<RenderOptions, "wrapper"> = {},
) {
	const { user, queryClient, strict, ...renderOptions } = options
	const { client, Wrapper } = buildWrapper({ user, queryClient, strict })

	return {
		queryClient: client,
		...render(ui, { wrapper: Wrapper, ...renderOptions }),
	}
}

/** `renderHook` under the same providers as `renderWithProviders`. */
export function renderHookWithProviders<Result, Props>(
	callback: (props: Props) => Result,
	options: ProviderOptions & { initialProps?: Props } = {},
) {
	const { user, queryClient, strict, initialProps } = options
	const { client, Wrapper } = buildWrapper({ user, queryClient, strict })

	return {
		queryClient: client,
		...renderHook(callback, { wrapper: Wrapper, initialProps }),
	}
}
