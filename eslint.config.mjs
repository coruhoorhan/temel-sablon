import tseslint from 'typescript-eslint'
import importX from 'eslint-plugin-import-x'
import security from 'eslint-plugin-security'

// TEMEL — ESLint 10 flat config (Bölüm 3.3 / 8.1)
// strictTypeChecked + 2 manuel kural + max-lines 150 (muaf listesiyle)
// React'a özel plugin'ler (#3977/#91702 riski) FAZ 2'de ayrı doğrulamayla eklenir.

export default tseslint.config(
  { ignores: ['node_modules/**', 'dist/**', 'coverage/**', '.archcore/tmp/**', 'eslint.config.mjs', '*.config.js', '*.config.ts'] },

  {
    files: ['src/**/*.{ts,tsx}'],
    extends: [...tseslint.configs.strictTypeChecked],
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    plugins: {
      'import-x': importX,
      security,
    },
    rules: {
      // ── 1. Tipler (01-tipler.rule.md) — strict'te olmayan 2 MANUEL kural
      '@typescript-eslint/switch-exhaustiveness-check': 'error',
      '@typescript-eslint/strict-boolean-expressions': 'error',

      // ── 2. Mimari (02-mimari.rule.md) — sirküler import; FSD Steiger'da
      // (eslint-plugin-import ESLint 10'u desteklemediği için fork: import-x)
      'import-x/no-cycle': ['error', { maxDepth: 10 }],

      // ── 4. Güvenlik (04-guvenlik.rule.md) — çekirdek kurallar
      'security/detect-eval-with-expression': 'error',
      'security/detect-object-injection': 'error',
      'security/detect-unsafe-regex': 'error',
      'security/detect-non-literal-fs-filename': 'error',
      'security/detect-possible-timing-attacks': 'error',
      'security/detect-bidi-characters': 'error',

      // ── 9. Temizlik (09-temizlik.rule.md) — 150 etkin satır kuralı
      'max-lines': ['error', { max: 150, skipBlankLines: true, skipComments: true }],
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      'no-debugger': 'error',
      'no-warning-comments': ['warn', { terms: ['TODO', 'FIXME', 'HACK'], location: 'start' }],
    },
  },

  // ── 150 satır muaf listesi (R9-01): test/stories/fixtures/mocks + machine/reducer
  {
    files: ['**/*.test.{ts,tsx}', '**/*.spec.{ts,tsx}', '**/__tests__/**', '**/*.stories.{ts,tsx}', '**/fixtures/**', '**/mocks/**'],
    rules: { 'max-lines': ['error', { max: 400, skipBlankLines: true, skipComments: true }] },
  },
  {
    files: ['**/*.machine.ts', '**/reducer.ts', '**/reducers/**'],
    rules: { 'max-lines': ['error', { max: 400, skipBlankLines: true, skipComments: true }] },
  },

  // ── test dosyaları: strict kural gevşetmeleri (test bağlamı doğal)
  {
    files: ['**/*.test.{ts,tsx}', '**/*.spec.{ts,tsx}'],
    rules: {
      '@typescript-eslint/no-non-null-assertion': 'off',
      '@typescript-eslint/no-explicit-any': 'off',
      '@typescript-eslint/no-unsafe-assignment': 'off',
    },
  },
)
