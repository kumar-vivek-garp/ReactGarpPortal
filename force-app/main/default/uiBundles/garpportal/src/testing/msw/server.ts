import { setupServer } from "msw/node"

import { coreHandlers } from "@/testing/msw/handlers/core"

/**
 * The MSW server, started/reset/closed by `vitest.setup.ts`. Default handlers
 * model the happy-path org; individual tests override per-request with
 * `server.use(...)` (reset automatically after each test).
 */
export const server = setupServer(...coreHandlers)
