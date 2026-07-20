import type { MatchResult, Slug } from '@phoenix/contracts';
import type { Rng } from '@phoenix/shared';

export type Layer3Input = {
  homeClubId: Slug;
  awayClubId: Slug;
  /** Aggregate attack/defence strength ~1–100 */
  homeStrength: number;
  awayStrength: number;
  rng: Rng;
};

/** Sample Poisson(lambda) via Knuth for small lambdas typical of football. */
function samplePoisson(lambda: number, rng: Rng): number {
  const L = Math.exp(-lambda);
  let k = 0;
  let p = 1;
  do {
    k += 1;
    p *= rng.next();
  } while (p > L);
  return k - 1;
}

/**
 * Layer-3 statistical match: expected goals from relative squad strength.
 * Home advantage ≈ +0.25 xG.
 */
export function simulateMatch(input: Layer3Input): MatchResult {
  const homeAttack = input.homeStrength / 70;
  const awayAttack = input.awayStrength / 70;
  const homeLambda = Math.max(0.2, 1.15 * homeAttack * (1.1 - awayAttack * 0.35) + 0.25);
  const awayLambda = Math.max(0.2, 1.05 * awayAttack * (1.1 - homeAttack * 0.35));

  return {
    homeClubId: input.homeClubId,
    awayClubId: input.awayClubId,
    homeGoals: samplePoisson(homeLambda, input.rng),
    awayGoals: samplePoisson(awayLambda, input.rng),
  };
}
