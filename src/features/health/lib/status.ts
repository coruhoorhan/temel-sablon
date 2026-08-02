export type HealthStatus = 'ok' | 'degraded';

export function healthCheck(): HealthStatus {
  return 'ok';
}
