// tools/architecture/src/steiger-rules/index.js
// TEMEL Custom Steiger Plugin (F4 · T4.1) — FSD katman sızıntısı zorlaması
// JSDoc'lu ESM: Node 20+ CI matrix'inde .ts import çalışmadığı için düz JS.
// Tip kontrolü tools/tsconfig.json (allowJs+checkJs) ile aynen sürer.

/**
 * @typedef {{ type: 'file', path: string, content?: string }} SteigerFile
 * @typedef {{ type: 'folder', path: string, children: Array<SteigerFile|SteigerFolder> }} SteigerFolder
 * @typedef {SteigerFile | SteigerFolder} SteigerNode
 * @typedef {{ message: string, location: { path: string, line?: number, column?: number }, fixes?: unknown[] }} SteigerDiagnostic
 * @typedef {{ name: string, check: (root: SteigerFolder, options: Record<string, unknown>) => { diagnostics: SteigerDiagnostic[] } | Promise<{ diagnostics: SteigerDiagnostic[] }> }} SteigerRule
 * @typedef {{ meta: { name: string, version: string }, ruleDefinitions: SteigerRule[] }} SteigerPlugin
 */

/** FSD katman sırası — index = seviye (düşük = daha temel) */
const LAYER_ORDER = ['shared', 'entities', 'features', 'widgets', 'pages', 'app']

/**
 * Bir yolun hangi FSD katmanında olduğunu bul (src/<layer>/...).
 * @param {string} path
 * @returns {string | null}
 */
function layerOf(path) {
  const match = /(?:^|\/)src\/([^/]+)\//.exec(path)
  if (!match) return null
  const layer = match[1]
  return LAYER_ORDER.includes(layer) ? layer : null
}

/**
 * Dosyadaki import ve export kaynaklarını topla (relative + alias + dynamic).
 * @param {SteigerFile} file
 * @returns {string[]}
 */
function importsOf(file) {
  const content = file.content ?? ''
  const sources = []
  const re = /(?:from\s+|import\s*\(?\s*|export\s+(?:\*|\{[^}]*\})\s+from\s+)['"]([^'"]+)['"]/g
  let m
  while ((m = re.exec(content)) !== null) sources.push(m[1])
  return sources
}

/**
 * Import kaynağını dosya yoluna çöz (relative + @/ + ~/ alias).
 * @param {string} fromFile
 * @param {string} importSrc
 * @returns {string}
 */
function resolveTarget(fromFile, importSrc) {
  const srcIdx = fromFile.indexOf('/src/')
  const prefix = srcIdx !== -1 ? fromFile.slice(0, srcIdx) : ''

  if (importSrc.startsWith('@/')) {
    return `${prefix}/src/${importSrc.slice(2)}`
  }
  if (importSrc.startsWith('~/')) {
    return `${prefix}/src/${importSrc.slice(2)}`
  }
  if (importSrc.startsWith('src/')) {
    return `${prefix}/${importSrc}`
  }

  const dir = fromFile.split('/').slice(0, -1)
  const parts = importSrc.split('/')
  const stack = [...dir]
  for (const p of parts) {
    if (p === '..') stack.pop()
    else if (p !== '.' && p !== '') stack.push(p)
  }
  return stack.join('/')
}

/**
 * TEMEL custom architecture plugin — no-upward-import kuralı.
 * @returns {SteigerPlugin}
 */
export function createArchitecturePlugin() {
  return {
    meta: {
      name: 'temel/architecture',
      version: '1.0.0',
    },
    ruleDefinitions: [
      {
        name: 'no-upward-import',
        check(root) {
          /** @type {SteigerDiagnostic[]} */
          const diagnostics = []

          /**
           * @param {SteigerNode} node
           */
          const walk = (node) => {
            if (node.type === 'file') {
              const fromLayer = layerOf(node.path)
              if (!fromLayer) return

              for (const src of importsOf(node)) {
                if (
                  !src.startsWith('./') &&
                  !src.startsWith('../') &&
                  !src.startsWith('src/') &&
                  !src.startsWith('@/') &&
                  !src.startsWith('~/')
                ) {
                  continue
                }
                const targetPath = resolveTarget(node.path, src)
                const toLayer = layerOf(targetPath)
                if (!toLayer) continue

                const fromIdx = LAYER_ORDER.indexOf(fromLayer)
                const toIdx = LAYER_ORDER.indexOf(toLayer)
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
      {
        name: 'fsd-layers-only',
        check(root) {
          /** @type {SteigerDiagnostic[]} */
          const diagnostics = []
          const allowedLayers = new Set(LAYER_ORDER)

          if (root.type === 'folder') {
            for (const child of root.children) {
              if (child.type === 'folder') {
                const folderName = child.path.split('/').filter(Boolean).pop()
                if (folderName && !allowedLayers.has(folderName)) {
                  diagnostics.push({
                    message:
                      `FSD ihlali (temel/fsd-layers-only): 'src/${folderName}' geçerli bir FSD katmanı değildir. ` +
                      `Yalnızca standart FSD katmanları izinlidir: ${LAYER_ORDER.join(', ')}. ` +
                      `Bileşenler ve mantık 'src/components/' gibi düz klasörlere değil; 'shared/', 'entities/', 'features/', 'widgets/' veya 'pages/' altında dilimlenmelidir.`,
                    location: { path: child.path },
                  })
                }
              }
            }
          }

          return { diagnostics }
        },
      },
    ],
  }
}

export default createArchitecturePlugin
