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

export default defineConfig(({ mode }) => {
  const isProd = mode === 'production'

  return {
    base: './',
    // Local CLI gateway (tools/local-dev) — development only; never used in production build.
    ...(isProd
      ? {}
      : {
          server: {
            port: 5173,
            strictPort: true,
            proxy: {
              '/__local_sf': {
                target: `http://127.0.0.1:${process.env.LOCAL_SF_PORT || 8787}`,
                changeOrigin: true,
                rewrite: (p: string) => p.replace(/^\/__local_sf/, ''),
              },
            },
          },
        }),
    plugins: [
      tailwindcss(),
      tanstackRouter({
        target: 'react',
        autoCodeSplitting: true,
        routesDirectory: './src/pages',
        generatedRouteTree: './src/routeTree.gen.ts',
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
           * Keep the entry chunk small: split heavy node_modules into cacheable
           * vendor groups (avoids a single >500kB JS warning and improves caching).
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

            if (
              id.includes('@react-spring/') ||
              id.includes('radix-ui') ||
              id.includes('lucide-react') ||
              id.includes('class-variance-authority') ||
              id.includes('clsx') ||
              id.includes('tailwind-merge')
            ) {
              return 'ui-vendor'
            }

            if (id.includes('node_modules/zod')) {
              return 'zod'
            }
          },
        },
      },
    },

    // Resolve aliases (shared between build and test)
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

    // Vitest configuration
    test: {
      // Override root for tests (build uses src/pages as root)
      root: resolve(__dirname),

      // Use jsdom environment for React component testing
      environment: 'jsdom',

      // Setup files to run before each test
      setupFiles: ['./src/test/setup.ts'],

      // Global test patterns
      include: [
        'src/**/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}',
        'src/**/__tests__/**/*.{js,mjs,cjs,ts,mts,cts,jsx,tsx}',
      ],

      // Coverage configuration
      coverage: {
        provider: 'v8',
        reporter: ['text', 'html', 'clover', 'json'],
        exclude: [
          'node_modules/',
          'src/test/',
          'src/**/*.d.ts',
          'src/main.tsx',
          'src/vite-env.d.ts',
          'src/components/**/index.ts',
          '**/*.config.ts',
          'build/',
          'dist/',
          'coverage/',
          'eslint.config.js',
        ],
        thresholds: {
          global: {
            branches: 85,
            functions: 85,
            lines: 85,
            statements: 85,
          },
        },
      },

      // Test timeout
      testTimeout: 10000,

      // Globals for easier testing
      globals: true,
    },
  };
});
