import type { CupRound, CupState, CupTie, MatchResult, Slug } from '@phoenix/contracts';
import { createRng } from '@phoenix/shared';

function shuffle<T>(items: readonly T[], seed: number): T[] {
  const rng = createRng(seed);
  const arr = [...items];
  for (let i = arr.length - 1; i > 0; i -= 1) {
    const j = rng.int(0, i);
    [arr[i], arr[j]] = [arr[j]!, arr[i]!];
  }
  return arr;
}

export function pickEntrants(clubIds: readonly Slug[], seed: number, n = 8): Slug[] {
  return shuffle(clubIds, seed).slice(0, n);
}

function pairIntoTies(clubIds: readonly Slug[]): CupTie[] {
  const ties: CupTie[] = [];
  for (let i = 0; i < clubIds.length; i += 2) {
    ties.push({
      homeClubId: clubIds[i]!,
      awayClubId: clubIds[i + 1]!,
    });
  }
  return ties;
}

export function createKnockoutCup({
  competitionId,
  clubIds,
  seed,
}: {
  competitionId: Slug;
  clubIds: readonly Slug[];
  seed: number;
}): CupState {
  const entrants = pickEntrants(clubIds, seed, 8);
  return {
    competitionId,
    round: 'qf',
    ties: pairIntoTies(entrants),
    completed: false,
  };
}

export function cupRoundAfterMatchday(matchday: number): CupRound | null {
  if (matchday === 5) return 'qf';
  if (matchday === 10) return 'sf';
  if (matchday === 15) return 'final';
  return null;
}

export function nextCupRound(round: CupRound): CupRound | null {
  if (round === 'qf') return 'sf';
  if (round === 'sf') return 'final';
  return null;
}

function tieWinner(result: MatchResult): Slug {
  return result.homeGoals > result.awayGoals ? result.homeClubId : result.awayClubId;
}

export function advanceKnockout(state: CupState, results: MatchResult[]): CupState {
  const tiesWithResults: CupTie[] = state.ties.map((tie, i) => ({
    ...tie,
    result: results[i],
  }));

  const winners = results.map(tieWinner);
  const nextRound = nextCupRound(state.round);

  if (nextRound === null) {
    return {
      ...state,
      ties: tiesWithResults,
      completed: true,
    };
  }

  return {
    competitionId: state.competitionId,
    round: nextRound,
    ties: pairIntoTies(winners),
    completed: false,
  };
}
