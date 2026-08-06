---
description: F5 (Agent Mesh) — DID/trust mesh + Merkle audit + shadow AI discovery + dashboard
status: accepted
approved_by: coruhoorhan (insan)
plan_hash: d4c1865eddb8ea5751ee2948cfc63197dce8079979e9095878c1789c0b20932a
last_approved: 2026-08-06T14:24:58Z
last_review_date: 2026-08-06T14:24:58Z
ttl_days: 90
---

# Plan: f5-agent-mesh

## Amaç

TEMEL şablonuna multi-agent güvenlik katmanı ekler:
1. **T5.1** Manifest'i trust mesh ile genişlet (decay, attestation, min_trust)
2. **T5.2** Merkle audit chain — karar kayıtlarını SHA-256 ile zincirle (tamper-evident)
3. **T5.3** Shadow AI discovery — manifest'te kayıtlı olmayan ajan tespiti
4. **T5.4** Governance dashboard — audit + trust görselleştirmesi (R11-11)

## Kapsam (değiştirilecek dosyalar)

- `.agt/manifest.yaml.template` — trust_mesh + shadow_discovery bölümleri
- `.archcore/bin/audit-chain.py` — Merkle zinciri (add/verify/report)
- `.archcore/bin/shadow-discovery.py` — shadow ajan tespiti (strict mod)
- `.archcore/bin/gov-dashboard.py` — HTML dashboard
- `.github/workflows/agent-mesh.yml` — zincir + shadow + trust CI kapısı
- `setup.sh` — `wire_mesh()` fonksiyonu
- `.gitignore` — audit-chain.json + dashboard (üretilen)
- `AGENTS.md` — Agent Mesh (F5) bölümü

## Kapsam DIŞI

- Push/publish
- F6-F8 fazları
- Gerçek ajan-ajan ağ iletişimi (A2A wire protocol) — yalnız yerel manifest+audit

## Doğrulama (gerçekleştirildi)

1. audit-chain: kayıt ekle → verify ✓ · TAMPER TESTİ: değiştirilen kayıt yakalandı (exit 1) ✓
2. shadow-discovery: manifest varken verifier eşleşti ✓ · ghost ajan strict modda engelledi (exit 1) ✓
3. gov-dashboard: HTML üretildi (docs/governance-dashboard.html) ✓
4. wire_mesh gerçek çalıştırma: tüm kontroller yeşil, fail_count 0 ✓
5. agent-mesh.yml YAML geçerli ✓ · bash -n setup.sh ✓

## Kabul kriterleri

- [x] Merkle zinciri tamper tespit ediyor (canlı test)
- [x] Shadow ajan tespit ediliyor (strict = red)
- [x] Trust mesh şeması manifest'te (decay, min_trust, attestation)
- [x] Dashboard üretiliyor (R11-11)
- [x] CI agent-mesh.yml zincir + shadow + trust zorluyor
