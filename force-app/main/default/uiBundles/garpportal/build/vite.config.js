var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
import { existsSync } from 'node:fs';
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import { resolve } from 'path';
import tailwindcss from '@tailwindcss/vite';
import salesforce from '@salesforce/vite-plugin-ui-bundle';
import codegen from 'vite-plugin-graphql-codegen';
import { tanstackRouter } from '@tanstack/router-plugin/vite';
var schemaPath = resolve(__dirname, '../../../../../schema.graphql');
var schemaExists = existsSync(schemaPath);
export default defineConfig(function (_a) {
    var mode = _a.mode;
    var isProd = mode === 'production';
    return __assign(__assign({ base: './' }, (isProd
        ? {}
        : {
            server: {
                port: 5173,
                strictPort: true,
                proxy: {
                    '/__local_sf': {
                        target: "http://127.0.0.1:".concat(process.env.LOCAL_SF_PORT || 8787),
                        changeOrigin: true,
                        rewrite: function (p) { return p.replace(/^\/__local_sf/, ''); },
                    },
                },
            },
        })), { plugins: __spreadArray([
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
            salesforce()
        ], (schemaExists
            ? [
                codegen({
                    configFilePathOverride: resolve(__dirname, 'codegen.yml'),
                    runOnStart: true,
                    runOnBuild: true,
                    enableWatcher: true,
                    throwOnBuild: true,
                }),
            ]
            : []), true), 
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
                    manualChunks: function (id) {
                        if (!id.includes('node_modules'))
                            return;
                        if (id.includes('node_modules/react-dom') ||
                            id.includes('node_modules/react/') ||
                            id.includes('node_modules/scheduler')) {
                            return 'react-vendor';
                        }
                        if (id.includes('@tanstack/')) {
                            return 'tanstack';
                        }
                        if (id.includes('@salesforce/')) {
                            return 'salesforce';
                        }
                        if (id.includes('@react-spring/') ||
                            id.includes('radix-ui') ||
                            id.includes('lucide-react') ||
                            id.includes('class-variance-authority') ||
                            id.includes('clsx') ||
                            id.includes('tailwind-merge')) {
                            return 'ui-vendor';
                        }
                        if (id.includes('node_modules/zod')) {
                            return 'zod';
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
        } });
});
