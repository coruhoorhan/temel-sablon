import tseslint from 'typescript-eslint'
import importX from 'eslint-plugin-import-x'
import security from 'eslint-plugin-security'
import vitestPlugin from '@vitest/eslint-plugin'
import reactHooksPlugin from 'eslint-plugin-react-hooks'

// TEMEL — ESLint 10 flat config (Bölüm 3.3 / 8.1)
// strictTypeChecked + React Hooks + Vitest anti-cheat + complexity + zero-any kuralları aktif.

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
      'react-hooks': reactHooksPlugin,
    },
    rules: {
      // ── 1. Tipler (01-tipler.rule.md) — strict'te olmayan 2 MANUEL kural + sıfır-any
      '@typescript-eslint/switch-exhaustiveness-check': 'error',
      '@typescript-eslint/strict-boolean-expressions': 'error',
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-non-null-assertion': 'error',

      // ── 2. Mimari (02-mimari.rule.md) — sirküler import; FSD Steiger'da
      // (eslint-plugin-import ESLint 10'u desteklemediği için fork: import-x)
      'import-x/no-cycle': ['error', { maxDepth: 10 }],

      // ── 3. State ve React Hooks Disiplini (03-state.rule.md)
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'error',
      'react-hooks/set-state-in-effect': 'error',
      'react-hooks/set-state-in-render': 'error',
      'react-hooks/immutability': 'error',
      'react-hooks/purity': 'error',

      // ── 3. Karmaşıklık ve Spagetti Engeli — Max 10 complexity, max 3 params
      'complexity': ['error', { max: 10 }],
      'max-params': ['error', 3],
      'max-nested-callbacks': ['error', 3],

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
    files: ['**/*.machine.ts', '**/reducer.ts', '**/*reducer.ts'],
    rules: { 'max-lines': ['error', { max: 400, skipBlankLines: true, skipComments: true }] },
  },

  // ── Test dosyaları: Vitest anti-cheat + test gevşetmeleri
  {
    files: ['**/*.test.{ts,tsx}', '**/*.spec.{ts,tsx}'],
    plugins: {
      vitest: vitestPlugin,
    },
    rules: {
      '@typescript-eslint/no-non-null-assertion': 'off',
      '@typescript-eslint/no-explicit-any': 'off',
      '@typescript-eslint/no-unsafe-assignment': 'off',
      'max-params': 'off',
      'max-nested-callbacks': 'off',
      'complexity': 'off',

      // Vitest anti-cheat: Sahte, boş ve atlanan testleri engelle
      'vitest/expect-expect': 'error',
      'vitest/no-disabled-tests': 'error',
      'vitest/no-focused-tests': 'error',
      'vitest/no-identical-title': 'error',
      'vitest/no-conditional-expect': 'error',
      'vitest/valid-expect': 'error',
    },
  },
)
