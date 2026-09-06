import { defineConfig, devices } from '@playwright/test';

const E2E_PORT = 5175;

/**
 * The DEFAULT Playwright config: the `mocked` project only — the built
 * dist/ served statically, every org call answered by e2e/support/mock-org.
 * No Salesforce org is ever contacted. The live (real-API, read-only)
 * suite is a deliberate, explicit-run-only sibling: playwright.live.config.ts.
 */
export default defineConfig({
  testDir: './e2e/mocked',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: `http://localhost:${E2E_PORT}`,
    trace: 'on-first-retry',
  },
  projects: [{ name: 'mocked', use: { ...devices['Desktop Chrome'] } }],
  webServer: {
    // Serve built dist/ with static server so e2e works in CI without SF org (vite preview runs plugin and can fail)
    command: `npx serve dist -l ${E2E_PORT}`,
    url: `http://localhost:${E2E_PORT}`,
    reuseExistingServer: !process.env.CI,
    timeout: process.env.CI ? 120_000 : 60_000,
  },
});
