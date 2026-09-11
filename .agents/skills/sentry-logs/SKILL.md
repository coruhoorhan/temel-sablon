---
name: sentry-logs
description: Periodic diagnostic scan of Sentry events/logs for anomaly spikes, unhandled warnings, and performance degradations.
argument-hint: "(run periodically, e.g. `/loop 1h /sentry-logs`)"
---

Scan production Sentry logs and telemetry events for anomalies, error bursts, or degradation patterns.

IMPORTANT: Check raw logs and events, not resolved issues. Do NOT modify code in this skill; report findings clearly.

## 1. Fetch Telemetry & Logs
Fetch the latest event stream:
```bash
bash .archcore/bin/sentry-fetch.sh logs 25
```

## 2. Analyze Patterns
Look for:
- Sudden spikes in 4xx / 5xx HTTP responses.
- Client-side unhandled promise rejections.
- Slow transaction spans exceeding performance thresholds (>2000ms).
- Recurring warnings indicating deprecated APIs or impending deprecations.

## 3. Report
- If anomalies are detected: summarize what is failing, affected routes, first/last seen timestamps, and user impact.
- If everything is quiet and normal: report a concise "All systems nominal" status.
