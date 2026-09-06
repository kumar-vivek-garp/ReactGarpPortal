import { defineConfig, devices } from '@playwright/test';

const PREVIEW_PORT = 4173;
const GATEWAY_PORT = 8787;

/**
 * LIVE smoke — REAL Salesforce APIs, STRICTLY READ-ONLY. Explicit-run-only
 * (`npm run e2e:live`); never part of the default `npm run e2e`.
 *
 * Stack: vite preview (:4173) proxies BOTH /services and /__local_sf to the
 * local CLI gateway (:8787), which signs requests with the developer's own
 * `sf` CLI session. The org is PINNED via SF_TARGET_ORG — without the pin
 * the gateway silently resolves the project-local default (currently
 * preprod). Specs must run through the org-safety guard fixture in
 * e2e/support/live-guard.ts, which makes mutation requests physically
 * impossible (aborted in the browser). See e2e/live/_gate.setup.ts for the
 * health/org gate.
 */
export default defineConfig({
  testDir: './e2e/live',
  fullyParallel: false,
  workers: 1,
  retries: 0,
  reporter: [['html', { outputFolder: 'playwright-report-live' }], ['line']],
  use: {
    baseURL: `http://localhost:${PREVIEW_PORT}`,
    trace: 'retain-on-failure',
  },
  projects: [{ name: 'live', use: { ...devices['Desktop Chrome'] } }],
  webServer: [
    {
      command: 'node ../../../../../tools/local-dev/server.mjs',
      url: `http://127.0.0.1:${GATEWAY_PORT}/health`,
      reuseExistingServer: true,
      timeout: 60_000,
      env: {
        ...process.env,
        SF_TARGET_ORG: process.env.SF_TARGET_ORG ?? 'devjuly25a',
        LOCAL_SF_PORT: String(GATEWAY_PORT),
      },
    },
    {
      command: `npx vite preview --port ${PREVIEW_PORT}`,
      url: `http://localhost:${PREVIEW_PORT}`,
      reuseExistingServer: true,
      timeout: 60_000,
    },
  ],
});
