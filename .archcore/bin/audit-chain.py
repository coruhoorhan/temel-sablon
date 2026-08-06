#!/usr/bin/env python3
"""Merkle audit chain — TEMEL karar kayıtlarını hash-zincirle (F5 · T5.2).

Her karar kaydı (plan onayı, commit, deploy) SHA-256 ile zincirlenir:
  chain[i].hash = sha256(chain[i].data + chain[i-1].hash)

Böylece:
  - Geçmişteki HERHANGİ bir kayıt değiştirilirse, sonraki tüm hash'ler
    uyuşmaz → tamper-evident (kurcalama kanıtı).
  - Audit: `python3 .archcore/bin/audit-chain.py` → zinciri doğrular.

Kullanım:
  python3 .archcore/bin/audit-chain.py --add <data>   # yeni kayıt ekle
  python3 .archcore/bin/audit-chain.py --verify       # zinciri doğrula (CI)
  python3 .archcore/bin/audit-chain.py --report       # özet yazdır
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
from pathlib import Path
from typing import Any

CHAIN_FILE = Path(__file__).resolve().parent.parent / "audit-chain.json"
GENESIS_HASH = hashlib.sha256(b"TEMEL-Merkle-Audit-Genesis-v1").hexdigest()


def load_chain() -> list[dict[str, Any]]:
    """Zinciri dosyadan oku; yoksa boş zincir döndür."""
    if not CHAIN_FILE.exists():
        return []
    with open(CHAIN_FILE, encoding="utf-8") as f:
        return json.load(f)


def save_chain(chain: list[dict[str, Any]]) -> None:
    """Zinciri atomik yaz (önce temp, sonra rename)."""
    tmp = CHAIN_FILE.with_suffix(".tmp")
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(chain, f, indent=2, ensure_ascii=False)
    tmp.replace(CHAIN_FILE)


def entry_hash(data: str, prev_hash: str) -> str:
    """SHA-256(data + prev_hash) — zincirleme karma."""
    return hashlib.sha256(f"{data}|{prev_hash}".encode("utf-8")).hexdigest()


def add_entry(data: str) -> dict[str, Any]:
    """Yeni kayıt ekle; önceki hash'e zincirle."""
    chain = load_chain()
    prev_hash = chain[-1]["hash"] if chain else GENESIS_HASH
    entry = {
        "index": len(chain),
        "timestamp": __import__("datetime").datetime.now(timezone_utc()).isoformat(),
        "data": data,
        "prev_hash": prev_hash,
        "hash": entry_hash(data, prev_hash),
    }
    chain.append(entry)
    save_chain(chain)
    return entry


def timezone_utc():
    from datetime import timezone
    return timezone.utc


def verify_chain() -> tuple[bool, list[str]]:
    """Zinciri doğrula; bozulma varsa hata mesajları döndür."""
    chain = load_chain()
    errors: list[str] = []
    prev_hash = GENESIS_HASH

    for i, entry in enumerate(chain):
        if entry["prev_hash"] != prev_hash:
            errors.append(f"Kayıt {i}: prev_hash uyuşmuyor (zincir kırılmış)")
        expected = entry_hash(entry["data"], prev_hash)
        if entry["hash"] != expected:
            errors.append(f"Kayıt {i}: hash uyuşmuyor — veri değiştirilmiş (tamper!)")
        prev_hash = entry["hash"]

    return (len(errors) == 0, errors)


def report() -> str:
    """İnsan-okur özet."""
    chain = load_chain()
    ok, errors = verify_chain()
    lines = [
        f"Merkle Audit Chain: {len(chain)} kayıt",
        f"Durum: {'✅ DOĞRU' if ok else '❌ BOZUK'}",
    ]
    if errors:
        lines.extend(f"  - {e}" for e in errors)
    if chain:
        lines.append(f"Son kayıt: {chain[-1]['data'][:60]}")
        lines.append(f"Son hash : {chain[-1]['hash'][:16]}…")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="TEMEL Merkle audit zinciri")
    parser.add_argument("--add", metavar="DATA", help="yeni kayıt ekle")
    parser.add_argument("--verify", action="store_true", help="zinciri doğrula")
    parser.add_argument("--report", action="store_true", help="özet yazdır")
    args = parser.parse_args()

    if args.add:
        entry = add_entry(args.add)
        print(f"✓ Kayıt eklendi [{entry['index']}]: {args.add[:60]}")
        print(f"  hash: {entry['hash'][:16]}…")
        return 0

    if args.verify:
        ok, errors = verify_chain()
        if ok:
            print("✓ Merkle zinciri DOĞRU — tamper yok")
            return 0
        for e in errors:
            print(f"✗ {e}", file=sys.stderr)
        return 1

    if args.report:
        print(report())
        return 0

    parser.print_help()
    return 0


if __name__ == "__main__":
    sys.exit(main())
