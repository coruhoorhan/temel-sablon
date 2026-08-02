import { defineConfig } from 'vitest/config'

// Vitest 4 — coverage eşiği 80/75/80/80 + perFile (08-test R8-01)
export default defineConfig({
  test: {
    include: ['src/**/*.test.{ts,tsx}'],
    coverage: {
      provider: 'v8',
      include: ['src/**/*.{ts,tsx}'],
      exclude: ['src/**/*.test.{ts,tsx}', 'src/**/*.stories.{ts,tsx}', 'src/**/index.ts', 'src/**/*.types.ts'],
      thresholds: {
        lines: 80,
        functions: 75,
        branches: 80,
        statements: 80,
        perFile: true,
      },
    },
  },
})
