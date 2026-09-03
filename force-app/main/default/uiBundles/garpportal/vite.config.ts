import { existsSync } from 'node:fs';
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import { resolve } from 'path';
import tailwindcss from '@tailwindcss/vite';
import salesforce from '@salesforce/vite-plugin-ui-bundle';
import codegen from 'vite-plugin-graphql-codegen';
import { tanstackRouter } from '@tanstack/router-plugin/vite';

const schemaPath = resolve(__dirname, '../../../../../schema.graphql');
const schemaExists = existsSync(schemaPath);

const localSfGatewayTarget = `http://127.0.0.1:${process.env.LOCAL_SF_PORT || 8787}`

/** Browser → `tools/local-dev` gateway (CLI Bearer token). */
const localSfPrefixProxy = {
  '/__local_sf': {
    target: localSfGatewayTarget,
    changeOrigin: true,
    rewrite: (p: string) => p.replace(/^\/__local_sf/, ''),
  },
} as const

/**
 * Preview has no Salesforce UI-bundle `/services` middleware. Dev keeps that
 * plugin path; preview routes Apex/GraphQL through the CLI gateway instead.
 */
const localSfServicesProxy = {
  '/services': {
    target: localSfGatewayTarget,
    changeOrigin: true,
  },
} as const

export default defineConfig(() => {
  return {
    base: './',
    // Local CLI gateway — `vite` + `vite preview` (UI still gates on localhost).
    server: {
      port: 5173,
      strictPort: true,
      // Leading-dot matches any subdomain (ngrok free URLs rotate).
      allowedHosts: [
        '.ngrok-free.dev',
        '.ngrok-free.app',
        '.ngrok.app',
        '.ngrok.dev',
        '.ngrok.io',
      ],
      proxy: { ...localSfPrefixProxy },
    },
    preview: {
      port: 4173,
      strictPort: true,
      proxy: { ...localSfPrefixProxy, ...localSfServicesProxy },
    },
    plugins: [
      tailwindcss(),
      tanstackRouter({
        target: 'react',
        autoCodeSplitting: true,
        routesDirectory: './src/pages',
        generatedRouteTree: './src/routeTree.gen.ts',
        // Co-located route guard tests are not routes.
        routeFileIgnorePattern: '\\.test\\.',
        codeSplittingOptions: {
          // Lazy-load route `component` only. Keep `pendingComponent` eager so a
          // shell can paint while the UI chunk downloads (and while beforeLoad runs).
          defaultBehavior: [['component']],
        },
      }),
      react(),
      salesforce(),
      // Only add codegen when schema exists (e.g. after `npm run graphql:schema`).
      // In CI or when schema is not checked in, skip codegen so build succeeds.
      ...(schemaExists
        ? [
            codegen({
              configFilePathOverride: resolve(__dirname, 'codegen.yml'),
              runOnStart: true,
              runOnBuild: true,
              enableWatcher: true,
              throwOnBuild: true,
            }),
          ]
        : []),
    ] as import('vite').PluginOption[],

    // Build configuration for MPA
    build: {
      outDir: resolve(__dirname, 'dist'),
      assetsDir: 'assets',
      sourcemap: false,
      rollupOptions: {
        output: {
          /**
           * Keep the entry chunk small: split heavy shared runtimes into
           * cacheable vendor groups. Do NOT force Radix / Lucide / Spring into
           * one `ui-vendor` chunk — that loads unused UI code on every page
           * (Lighthouse “Reduce unused JavaScript”). Let route splits own them.
           */
          manualChunks(id) {
            if (!id.includes('node_modules')) return

            if (
              id.includes('node_modules/react-dom') ||
              id.includes('node_modules/react/') ||
              id.includes('node_modules/scheduler')
            ) {
              return 'react-vendor'
            }

            if (id.includes('@tanstack/')) {
              return 'tanstack'
            }

            if (id.includes('@salesforce/')) {
              return 'salesforce'
            }

            if (id.includes('node_modules/zod')) {
              return 'zod'
            }

            /**
             * Always-eager UI runtime: the shell chrome imports all of these
             * at startup (springs/gestures for nav, Sonner's toaster, Zustand
             * stores, cn()'s tailwind-merge/clsx/cva). Grouping them adds no
             * eager bytes — it only moves them out of the entry chunk, which
             * changes every deploy, into one that stays byte-identical and
             * cached. Do NOT add Radix or Lucide here: those are only partly
             * eager, and grouping them would load route-only primitives on
             * every page.
             */
            if (
              id.includes('node_modules/@react-spring/') ||
              id.includes('node_modules/@use-gesture/') ||
              id.includes('node_modules/sonner/') ||
              id.includes('node_modules/zustand/') ||
              id.includes('node_modules/tailwind-merge/') ||
              id.includes('node_modules/clsx/') ||
              id.includes('node_modules/class-variance-authority/')
            ) {
              return 'ui-runtime'
            }
          },
        },
      },
    },

    // Resolve aliases (tests use vitest.config.ts, the config Vitest resolves)
    resolve: {
      dedupe: ['react', 'react-dom'],
      alias: {
        '@': path.resolve(__dirname, './src'),
        '@api': path.resolve(__dirname, './src/api'),
        '@components': path.resolve(__dirname, './src/components'),
        '@utils': path.resolve(__dirname, './src/utils'),
        '@styles': path.resolve(__dirname, './src/styles'),
        '@assets': path.resolve(__dirname, './src/assets'),
      },
    },
  };
});
