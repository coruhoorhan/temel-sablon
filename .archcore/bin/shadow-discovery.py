#!/usr/bin/env python3
"""Shadow AI Discovery — kayıtlı olmayan ajanları tespit et (F5 · T5.3).

Manifest (.agt/manifest.yaml) ile ajan tanım dosyalarını karşılaştırır:
  - Her .opencode/agents/*.md / .claude/agents/*.md dosyası manifest'teki
    bir kimlikle eşleşmek zorundadır.
  - Eşleşmeyen ajan = "shadow agent" → raporlanır (actions: report varsayılan).

Fail-closed: manifest yoksa veya boşsa uyarır (bilinmeyen ajan güvenilmez).

Kullanım:
  python3 .archcore/bin/shadow-discovery.py            # rapor
  python3 .archcore/bin/shadow-discovery.py --strict   # shadow varsa exit 1
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent.parent
MANIFEST = ROOT / ".agt" / "manifest.yaml"
AGENT_DIRS = [ROOT / ".opencode" / "agents", ROOT / ".claude" / "agents"]


def load_manifest_ids() -> set[str]:
    """Manifest'teki tüm ajan kimliklerini döndür."""
    if not MANIFEST.exists():
        print("⚠ manifest yok — kayıtlı ajan listesi boş (fail-closed)")
        return set()
    with open(MANIFEST, encoding="utf-8") as f:
        data = yaml.safe_load(f)
    ids: set[str] = set()
    for agent in data.get("agents", []):
        ids.add(agent.get("id", ""))
        # name + id ikisini de tanı (dosya adı eşleşmesi için)
        if agent.get("name"):
            ids.add(agent["name"].lower())
    return {i for i in ids if i}


def discover() -> list[Path]:
    """Tüm ajan tanım dosyalarını bul."""
    files: list[Path] = []
    for d in AGENT_DIRS:
        if d.exists():
            files.extend(sorted(d.glob("*.md")))
    return files


def main() -> int:
    parser = argparse.ArgumentParser(description="TEMEL Shadow AI Discovery")
    parser.add_argument("--strict", action="store_true", help="shadow ajan varsa exit 1")
    args = parser.parse_args()

    manifest_ids = load_manifest_ids()
    agent_files = discover()

    if not agent_files:
        print("✓ Ajan tanım dosyası bulunamadı — shadow taraması boş")
        return 0

    shadow: list[Path] = []
    for f in agent_files:
        stem = f.stem.lower()  # örn: verifier
        # Dosya adı manifest kimliğiyle eşleşiyor mu?
        if stem not in manifest_ids:
            shadow.append(f)

    if shadow:
        print(f"⚠ {len(shadow)} SHADOW AJAN bulundu (manifest'te kayıtlı değil):")
        for f in shadow:
            print(f"  - {f.relative_to(ROOT)}")
        if args.strict:
            print("✗ strict mod: shadow ajanlar build'i engelledi")
            return 1
        return 0

    print(f"✓ {len(agent_files)} ajan dosyası manifest ile eşleşti — shadow yok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
