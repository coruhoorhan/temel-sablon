import { describe, expect, it } from 'vitest';
import { formatDate } from './date';

describe('formatDate', () => {
  it('ISO formatında tarih döndürür', () => {
    const date = new Date('2026-08-02T10:00:00.000Z');

    expect(formatDate(date)).toBe('2026-08-02T10:00:00.000Z');
  });
});
