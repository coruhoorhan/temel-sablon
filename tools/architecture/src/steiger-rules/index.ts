// tools/architecture/src/steiger-rules/index.ts
// TEMEL Custom Steiger Plugin (F4 · T4.1) — FSD katman sızıntısı + proje kuralları
//
// Steiger Plugin API (v0.6.0 — node_modules/steiger/dist/app.d.ts):
//   Plugin = { meta: { name, version }, ruleDefinitions: Rule[] }
//   Rule   = { name, check(root: Folder, options) => { diagnostics } }
//   Folder = { type: 'folder', path, children: Array<File|Folder> }
//   Diagnostic = { message, location: { path, line?, column? }, fixes? }
//
// NOT: steiger paketi Plugin/Folder/File tiplerini EXPORT ETMEZ (yalnız
// defineConfig/linter/processConfiguration). Bu yüzden tipler yerel tanımlanır.
//
// Kural mantığı: FSD katman hiyerarşisinde AŞAĞI import serbest, YUKARI yasak.
// Katman sırası (alttan üste): shared → entities → features → widgets →
// pages → app. Bir katman yalnız kendisi + altındakileri import edebilir.

/** Steiger'ın yerel tip tanımları (paket export etmez) */
interface SteigerFile {
  type: 'file'
  path: string
  content?: string
}

interface SteigerFolder {
  type: 'folder'
  path: string
  children: Array<SteigerFile | SteigerFolder>
}

type SteigerNode = SteigerFile | SteigerFolder

interface SteigerDiagnostic {
  message: string
  location: { path: string; line?: number; column?: number }
  fixes?: unknown[]
}

interface SteigerRule {
  name: string
  check: (root: SteigerFolder, options: Record<string, unknown>) => { diagnostics: SteigerDiagnostic[] } | Promise<{ diagnostics: SteigerDiagnostic[] }>
}

interface SteigerPlugin {
  meta: { name: string; version: string }
  ruleDefinitions: SteigerRule[]
}

/** FSD katman sırası — index = seviye (düşük = daha temel) */
const LAYER_ORDER = ['shared', 'entities', 'features', 'widgets', 'pages', 'app'] as const

type Layer = (typeof LAYER_ORDER)[number]

/** Bir yolun hangi FSD katmanında olduğunu bul (src/<layer>/...). */
function layerOf(path: string): Layer | null {
  const match = /\/src\/([^/]+)\//.exec(path)
  if (!match) return null
  const layer = match[1] as Layer
  return LAYER_ORDER.includes(layer) ? layer : null
}

/** Dosyadaki import kaynaklarını topla (basit regex — relative + alias). */
function importsOf(file: SteigerFile): string[] {
  const content = file.content ?? ''
  const sources: string[] = []
  const re = /from\s+['"]([^'"]+)['"]/g
  let m: RegExpExecArray | null
  while ((m = re.exec(content)) !== null) sources.push(m[1])
  return sources
}

export function createArchitecturePlugin(): SteigerPlugin {
  return {
    meta: {
      name: 'temel/architecture',
      version: '1.0.0',
    },
    ruleDefinitions: [
      {
        name: 'no-upward-import',
        check(root) {
          const diagnostics: SteigerDiagnostic[] = []

          const walk = (node: SteigerNode) => {
            if (node.type === 'file') {
              const fromLayer = layerOf(node.path)
              if (!fromLayer) return

              for (const src of importsOf(node)) {
                // Yalnız src/ içi relative importları değerlendir (node_modules dışı)
                if (!src.startsWith('./') && !src.startsWith('../') && !src.startsWith('src/')) continue
                const targetPath = resolveTarget(node.path, src)
                const toLayer = layerOf(targetPath)
                if (!toLayer) continue

                const fromIdx = LAYER_ORDER.indexOf(fromLayer)
                const toIdx = LAYER_ORDER.indexOf(toLayer)
                // YUKARI import: hedef katman, kaynak katmandan ÜSTTE ise YASAK
                if (toIdx > fromIdx) {
                  diagnostics.push({
                    message:
                      `FSD ihlali (temel/no-upward-import): '${fromLayer}' ` +
                      `katmanı '${toLayer}' import ediyor (${src}). Katman yukarı import yasak — ` +
                      `FSD: yalnız kendin + altındakiler.`,
                    location: { path: node.path },
                  })
                }
              }
            } else {
              for (const child of node.children) walk(child)
            }
          }

          walk(root)
          return { diagnostics }
        },
      },
    ],
  }
}

/** Import kaynağını dosya yoluna çöz (basit relative resolution). */
function resolveTarget(fromFile: string, importSrc: string): string {
  if (importSrc.startsWith('src/')) return importSrc
  // Dosyanın dizini üzerinden göreli çözümleme:
  // fromFile = /proj/src/features/health/lib/bad.ts → dir = /proj/src/features/health/lib
  // importSrc = ../../app/index → 2 seviye yukarı: /proj/src/features/app/index? HAYIR:
  // dir'in SON parçası 'lib' — '..' parçaları dir'in SONUNDAN itibaren pop eder.
  const dir = fromFile.split('/').slice(0, -1) // ['', 'proj', 'src', 'features', 'health', 'lib']
  const parts = importSrc.split('/')
  const stack = [...dir]
  for (const p of parts) {
    if (p === '..') stack.pop()
    else if (p !== '.' && p !== '') stack.push(p)
  }
  return stack.join('/')
}

export default createArchitecturePlugin
