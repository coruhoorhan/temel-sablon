import { describe, expect, it } from 'vitest';
import { healthCheck } from './status';

describe('healthCheck', () => {
  it('sağlıklı durumda ok döndürür', () => {
    expect(healthCheck()).toBe('ok');
  });
});
