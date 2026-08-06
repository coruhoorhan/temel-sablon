#!/usr/bin/env python3
"""Governance Dashboard — audit + shadow + trust durumunu HTML üretir (F5 · T5.4).

CI'da çalışır: .archcore/audit-chain.json + .agt/manifest.yaml okuyup
tek sayfalık statik HTML rapor üretir (docs/governance-dashboard.html).
Denetim izi (R11-11) — gerçek zamanlı fleet görünürlüğü.

Kullanım:
  python3 .archcore/bin/gov-dashboard.py              # HTML üret
  python3 .archcore/bin/gov-dashboard.py --stdout     # konsola yazdır
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent.parent
CHAIN_FILE = ROOT / ".archcore" / "audit-chain.json"
MANIFEST = ROOT / ".agt" / "manifest.yaml"
OUTPUT = ROOT / "docs" / "governance-dashboard.html"


def load_chain() -> list[dict]:
    if not CHAIN_FILE.exists():
        return []
    return json.load(open(CHAIN_FILE, encoding="utf-8"))


def load_manifest() -> dict:
    if not MANIFEST.exists():
        return {}
    return yaml.safe_load(open(MANIFEST, encoding="utf-8"))


def chain_status(chain: list[dict]) -> tuple[bool, str]:
    """Zincir bütünlüğünü basitçe doğrula (audit-chain ile aynı mantık)."""
    prev = hashlib.sha256(b"TEMEL-Merkle-Audit-Genesis-v1").hexdigest()
    for i, e in enumerate(chain):
        expected = hashlib.sha256(f"{e['data']}|{prev}".encode()).hexdigest()
        if e["hash"] != expected:
            return False, f"kayıt {i} bozuk"
        prev = e["hash"]
    return True, "tamper yok"


def render() -> str:
    chain = load_chain()
    manifest = load_manifest()
    ok, status = chain_status(chain)

    agents = manifest.get("agents", [])
    trust_rows = "".join(
        f"<tr><td>{a.get('id','?')}</td><td>{a.get('role','?')}</td>"
        f"<td>{a.get('trust_score','?')}</td><td>{','.join(a.get('capabilities',[]))}</td></tr>"
        for a in agents
    )

    chain_rows = "".join(
        f"<tr><td>{e['index']}</td><td>{e['timestamp'][:19]}</td>"
        f"<td>{e['data'][:60]}</td><td><code>{e['hash'][:12]}…</code></td></tr>"
        for e in chain[-10:]
    )

    color = "#2e7d32" if ok else "#c62828"
    return f"""<!DOCTYPE html>
<html lang="tr"><head><meta charset="utf-8">
<title>TEMEL Governance Dashboard</title>
<style>
  body {{ font-family: system-ui, sans-serif; margin: 2rem; background: #0f172a; color: #e2e8f0; }}
  h1 {{ color: #38bdf8; }} h2 {{ color: #94a3b8; margin-top: 2rem; }}
  table {{ border-collapse: collapse; width: 100%; margin-top: .5rem; }}
  th, td {{ text-align: left; padding: .5rem; border-bottom: 1px solid #334155; }}
  th {{ color: #7dd3fc; }}
  code {{ background: #1e293b; padding: .15rem .4rem; border-radius: 4px; }}
  .badge {{ display: inline-block; padding: .3rem .8rem; border-radius: 999px;
           font-weight: 700; color: white; }}
</style></head><body>
<h1>🛡 TEMEL Governance Dashboard</h1>
<p>Merkle Audit: <span class="badge" style="background:{color}">{status}</span>
&nbsp; Kayıt: {len(chain)} &nbsp; Ajan: {len(agents)}</p>

<h2>Agent Trust Mesh</h2>
<table><tr><th>ID</th><th>Rol</th><th>Trust</th><th>Yetkiler</th></tr>{trust_rows}</table>

<h2>Son Merkle Kayıtları (son 10)</h2>
<table><tr><th>#</th><th>Zaman</th><th>Karar</th><th>Hash</th></tr>{chain_rows}</table>

<p style="margin-top:2rem;color:#64748b;font-size:.85rem">
Otomatik üretildi: .archcore/bin/gov-dashboard.py · CI agent-mesh.yml</p>
</body></html>"""


def main() -> int:
    parser = argparse.ArgumentParser(description="TEMEL Governance Dashboard")
    parser.add_argument("--stdout", action="store_true", help="dosya yerine konsola yaz")
    args = parser.parse_args()

    html = render()
    if args.stdout:
        print(html)
        return 0

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(html, encoding="utf-8")
    print(f"✓ Dashboard üretildi: {OUTPUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
