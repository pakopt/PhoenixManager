import { describe, expect, it } from 'vitest';
import { createRng } from './rng.js';

describe('createRng', () => {
  it('is reproducible for the same seed', () => {
    const a = createRng(42);
    const b = createRng(42);
    const seqA = Array.from({ length: 20 }, () => a.next());
    const seqB = Array.from({ length: 20 }, () => b.next());
    expect(seqA).toEqual(seqB);
  });

  it('differs across seeds', () => {
    const a = createRng(1);
    const b = createRng(2);
    expect(a.next()).not.toBe(b.next());
  });

  it('int stays in range', () => {
    const rng = createRng(7);
    for (let i = 0; i < 100; i += 1) {
      const n = rng.int(0, 5);
      expect(n).toBeGreaterThanOrEqual(0);
      expect(n).toBeLessThanOrEqual(5);
    }
  });
});
