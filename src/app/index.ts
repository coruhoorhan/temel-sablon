import { healthCheck, type HealthStatus } from '@/features/health';

export function createApp(): void {
  // Uygulama kökü — provider'lar, router, global stil burada birleşir.
  const status: HealthStatus = healthCheck();
  if (status === 'degraded') {
    console.warn('sağlık kontrolü: düşük performans');
  }
}

export { formatDate } from '@/shared/lib';
