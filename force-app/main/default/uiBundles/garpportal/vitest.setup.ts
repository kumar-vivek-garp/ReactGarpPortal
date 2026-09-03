import '@testing-library/jest-dom/vitest';
import { afterAll, afterEach, beforeAll, vi } from 'vitest';

import { server } from '@/testing/msw/server';

/**
 * Sonner is mocked globally: the `@/api/client` barrel (imported by every
 * domain module) pulls it in and constructs the singleton queryClient, so
 * this cuts that cost — and gives tests an assertion surface:
 * `vi.mocked(toast.success)` etc.
 */
vi.mock('sonner', () => {
  const toast = Object.assign(vi.fn(), {
    success: vi.fn(),
    warning: vi.fn(),
    error: vi.fn(),
    info: vi.fn(),
    loading: vi.fn(),
    dismiss: vi.fn(),
    promise: vi.fn(),
    custom: vi.fn(),
  });
  return { toast, Toaster: () => null };
});

/**
 * The Data SDK's CSRF manager opens a CacheStorage bucket at construction;
 * jsdom implements none, so without this every SDK call dies with a
 * ReferenceError before any request is made.
 */
const noopCache = {
  match: async () => undefined,
  put: async () => undefined,
  delete: async () => false,
  keys: async () => [],
};
Object.defineProperty(globalThis, 'caches', {
  configurable: true,
  value: {
    open: async () => noopCache,
    match: async () => undefined,
    has: async () => false,
    delete: async () => false,
    keys: async () => [],
  } as unknown as CacheStorage,
});

// jsdom gaps with verified consumers (media hooks, nav measuring, scroll).
if (typeof window.matchMedia !== 'function') {
  window.matchMedia = ((query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: () => undefined,
    removeListener: () => undefined,
    addEventListener: () => undefined,
    removeEventListener: () => undefined,
    dispatchEvent: () => false,
  })) as unknown as typeof window.matchMedia;
}

if (typeof globalThis.ResizeObserver === 'undefined') {
  class ResizeObserverStub {
    observe() {}
    unobserve() {}
    disconnect() {}
  }
  globalThis.ResizeObserver =
    ResizeObserverStub as unknown as typeof ResizeObserver;
}

// jsdom's own scrollTo logs "Not implemented" errors — silence with a noop.
window.scrollTo = (() => undefined) as typeof window.scrollTo;

// Radix Select/Dialog interaction under jsdom: scroll + pointer-capture APIs
// and PointerEvent are missing; every form section uses these atoms.
if (typeof Element.prototype.scrollIntoView !== 'function') {
  Element.prototype.scrollIntoView = () => undefined;
}
if (typeof Element.prototype.hasPointerCapture !== 'function') {
  Element.prototype.hasPointerCapture = () => false;
  Element.prototype.setPointerCapture = () => undefined;
  Element.prototype.releasePointerCapture = () => undefined;
}
if (typeof window.PointerEvent === 'undefined') {
  window.PointerEvent = MouseEvent as unknown as typeof PointerEvent;
}

// MSW: strict by default — a request no handler expected is a test bug.
beforeAll(() => {
  server.listen({ onUnhandledRequest: 'error' });

  /**
   * The Data SDK builds RELATIVE URLs in tests (SFDC_ENV is undefined →
   * base ""), which Node's URL parsing rejects before MSW can intercept —
   * the SDK constructs `new Request(path)` itself, so BOTH the Request
   * constructor and fetch need browser-style resolution against the jsdom
   * document origin. Installed AFTER listen() so MSW's patched globals stay
   * inside the wrappers.
   */
  const resolveUrl = (input: RequestInfo | URL): RequestInfo | URL => {
    if (typeof input !== 'string') return input;
    try {
      new URL(input);
      return input;
    } catch {
      return new URL(input, window.location.href).toString();
    }
  };

  const MswRequest = globalThis.Request;
  globalThis.Request = class extends MswRequest {
    constructor(input: RequestInfo | URL, init?: RequestInit) {
      super(resolveUrl(input), init);
    }
  };

  const mswFetch = globalThis.fetch;
  globalThis.fetch = ((input: RequestInfo | URL, init?: RequestInit) =>
    mswFetch(resolveUrl(input), init)) as typeof fetch;
});
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
