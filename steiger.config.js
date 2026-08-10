// Steiger config (v0.6.0 format — Bölüm 2.13-B/3.3: FSD kapısı)
// Referans: github.com/feature-sliced/steiger (configs: defineConfig + fsd.configs.recommended)
// F4: custom architecture plugin (temel/no-upward-import) — tools/architecture/src/steiger-rules
// Katman yukarı import yasak: shared → entities → features → widgets → pages → app
import { defineConfig } from 'steiger'
import fsd from '@feature-sliced/steiger-plugin'
import { createArchitecturePlugin } from './tools/architecture/src/steiger-rules/index.js'

export default defineConfig([
  ...fsd.configs.recommended,
  createArchitecturePlugin(),
  {
    ignores: ['**/__mocks__/**', '**/fixtures/**', '**/dist/**'],
    rules: {
      'no-upward-import': 'error',
    },
  },
  // Örnek: shared/ui public-api muafiyeti gerekirse açılır
  // {
  //   files: ['./src/shared/ui/**'],
  //   rules: { 'fsd/public-api': 'off' },
  // },
])
