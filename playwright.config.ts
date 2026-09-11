import { defineConfig, devices } from '@playwright/test'

/**
 * Playwright E2E Konfigürasyonu — TEMEL QA & Görsel Kanıt Kapısı
 * Her UI değişikliğinde test çıktısı, video ve screenshot kanıtı üretir.
 */
export default defineConfig({
  testDir: './e2e',
  timeout: 30_000,
  expect: {
    timeout: 5000,
  },
  fullyParallel: true,
  forbidOnly: Boolean(process.env.CI),
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['list'],
    ['html', { outputFolder: '.scratch/qa/report', open: 'never' }],
  ],
  outputDir: '.scratch/qa/results',
  use: {
    actionTimeout: 0,
    trace: 'on-first-retry',
    screenshot: 'on',
    video: 'on',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
})
