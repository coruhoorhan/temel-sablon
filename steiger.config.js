// Steiger config (v0.5.0+ format — Bölüm 2.13-B/3.3: FSD kapısı)
// Referans: github.com/feature-sliced/steiger (configs: defineConfig + fsd.configs.recommended)
import { defineConfig } from 'steiger'
import fsd from '@feature-sliced/steiger-plugin'

export default defineConfig([
  ...fsd.configs.recommended,
  {
    ignores: ['**/__mocks__/**', '**/fixtures/**'],
  },
  // Örnek: shared/ui public-api muafiyeti gerekirse açılır
  // {
  //   files: ['./src/shared/ui/**'],
  //   rules: { 'fsd/public-api': 'off' },
  // },
])
