/**
 * Mulberry32 — small deterministic PRNG.
 * Same seed always yields the same sequence.
 */
export type Rng = {
  next: () => number;
  int: (minInclusive: number, maxInclusive: number) => number;
  fork: (salt: number) => Rng;
};

export function createRng(seed: number): Rng {
  let state = seed >>> 0;

  const next = (): number => {
    state = (state + 0x6d2b79f5) >>> 0;
    let t = state;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };

  const int = (minInclusive: number, maxInclusive: number): number => {
    if (maxInclusive < minInclusive) {
      throw new Error('maxInclusive must be >= minInclusive');
    }
    const span = maxInclusive - minInclusive + 1;
    return minInclusive + Math.floor(next() * span);
  };

  const fork = (salt: number): Rng => createRng((seed ^ (salt >>> 0)) >>> 0);

  return { next, int, fork };
}
