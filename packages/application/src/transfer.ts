import type { Club, Slug } from '@phoenix/contracts';

export const INITIAL_BALANCE = 5_000_000;

export function transferFee(rating: number): number {
  return rating * 100_000;
}

export function pickSellDestinationClub(
  clubs: ReadonlyMap<Slug, Club>,
  managedClubId: Slug,
): Slug {
  const candidates = [...clubs.values()].filter((c) => c.id !== managedClubId);
  if (candidates.length === 0) {
    throw new Error('Nenhum clube de destino disponível');
  }
  candidates.sort((a, b) => {
    if (a.reputation !== b.reputation) return a.reputation - b.reputation;
    return a.id.localeCompare(b.id);
  });
  return candidates[0]!.id;
}
