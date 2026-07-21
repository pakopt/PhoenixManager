import type { Club, Player, Slug } from '@phoenix/contracts';
import type { Rng } from '@phoenix/shared';
import { transferFee } from './transfer.js';

export type AiDecision = 'accept' | 'reject' | 'counter';

export function decideNpcResponse(args: {
  kind: 'player_buy' | 'player_sell';
  amount: number;
  fair: number;
  sellerSquadSize: number;
}): AiDecision {
  if (args.kind === 'player_buy' && args.sellerSquadSize <= 11) return 'reject';
  const ratio = args.amount / args.fair;

  if (args.kind === 'player_sell') {
    if (ratio <= 1) return 'accept';
    if (ratio <= 1.15) return 'counter';
    return 'reject';
  }

  if (ratio >= 1) return 'accept';
  if (ratio >= 0.85) return 'counter';
  return 'reject';
}

export function counterAmountFor(
  kind: 'player_buy' | 'player_sell',
  fair: number,
  sellerReputation: number,
): number {
  if (kind === 'player_buy' && sellerReputation >= 70) return fair * 1.05;
  return fair;
}

/** When player counters an npc_bid: NPC never re-counters. */
export function decideNpcReplyToPlayerCounter(args: {
  amount: number;
  fair: number;
}): 'accept' | 'reject' {
  const d = decideNpcResponse({
    kind: 'player_sell',
    amount: args.amount,
    fair: args.fair,
    sellerSquadSize: 99,
  });
  return d === 'reject' ? 'reject' : 'accept';
}

export function aiBidCount(rng: Rng): 0 | 1 | 2 {
  return rng.int(0, 2) as 0 | 1 | 2;
}

function countSquads(players: ReadonlyMap<Slug, Player>): Map<Slug, number> {
  const sizes = new Map<Slug, number>();
  for (const p of players.values()) {
    sizes.set(p.clubId, (sizes.get(p.clubId) ?? 0) + 1);
  }
  return sizes;
}

function midLowPlayersFromSeller(
  players: ReadonlyMap<Slug, Player>,
  effectiveClubByPlayer: ReadonlyMap<Slug, Slug>,
  sellerId: Slug,
  excludedPlayerIds: ReadonlySet<Slug>,
): Player[] {
  const sellerPlayers = [...players.values()]
    .filter(
      (p) =>
        effectiveClubByPlayer.get(p.id) === sellerId &&
        !excludedPlayerIds.has(p.id),
    )
    .sort((a, b) => a.rating - b.rating);
  const lowerThirdCount = Math.max(1, Math.ceil(sellerPlayers.length / 3));
  return sellerPlayers.slice(0, lowerThirdCount);
}

export function pickNpcNpcTransfers(
  clubs: ReadonlyMap<Slug, Club>,
  players: ReadonlyMap<Slug, Player>,
  managedClubId: Slug,
  rng: Rng,
  maxTransfers: number,
): Array<{ playerId: Slug; fromClubId: Slug; toClubId: Slug }> {
  if (maxTransfers <= 0) return [];

  const squadSizes = countSquads(players);
  const effectiveClubByPlayer = new Map<Slug, Slug>();
  for (const p of players.values()) {
    effectiveClubByPlayer.set(p.id, p.clubId);
  }
  const selectedPlayerIds = new Set<Slug>();
  const results: Array<{ playerId: Slug; fromClubId: Slug; toClubId: Slug }> = [];

  for (let i = 0; i < maxTransfers; i++) {
    type Candidate = {
      playerId: Slug;
      fromClubId: Slug;
      toClubId: Slug;
      preferScore: number;
    };

    const candidates: Candidate[] = [];

    for (const seller of clubs.values()) {
      if (seller.id === managedClubId) continue;
      const sellerSize = squadSizes.get(seller.id) ?? 0;
      if (sellerSize <= 11) continue;

      const transferable = midLowPlayersFromSeller(
        players,
        effectiveClubByPlayer,
        seller.id,
        selectedPlayerIds,
      );

      for (const buyer of clubs.values()) {
        if (buyer.id === managedClubId || buyer.id === seller.id) continue;
        const buyerSize = squadSizes.get(buyer.id) ?? 0;
        if (buyerSize + 1 >= 25) continue;

        const preferScore = buyer.reputation >= seller.reputation ? 1 : 0;

        for (const p of transferable) {
          candidates.push({
            playerId: p.id,
            fromClubId: seller.id,
            toClubId: buyer.id,
            preferScore,
          });
        }
      }
    }

    if (candidates.length === 0) break;

    const maxPrefer = Math.max(...candidates.map((c) => c.preferScore));
    const tier = candidates.filter((c) => c.preferScore === maxPrefer);
    const chosen = tier[rng.int(0, tier.length - 1)]!;

    results.push({
      playerId: chosen.playerId,
      fromClubId: chosen.fromClubId,
      toClubId: chosen.toClubId,
    });

    selectedPlayerIds.add(chosen.playerId);
    effectiveClubByPlayer.set(chosen.playerId, chosen.toClubId);
    squadSizes.set(
      chosen.fromClubId,
      (squadSizes.get(chosen.fromClubId) ?? 0) - 1,
    );
    squadSizes.set(
      chosen.toClubId,
      (squadSizes.get(chosen.toClubId) ?? 0) + 1,
    );
  }

  return results;
}

function lowerThirdManagedTargets(
  players: ReadonlyMap<Slug, Player>,
  managedClubId: Slug,
): Player[] {
  const managedPlayers = [...players.values()]
    .filter((p) => p.clubId === managedClubId)
    .sort((a, b) => a.rating - b.rating);

  if (managedPlayers.length < 3) return managedPlayers;

  const lowerThirdCount = Math.max(1, Math.ceil(managedPlayers.length / 3));
  return managedPlayers.slice(0, lowerThirdCount);
}

function pickBidBuyer(
  clubs: ReadonlyMap<Slug, Club>,
  managedClubId: Slug,
  managedReputation: number,
  rng: Rng,
): Club | undefined {
  const npcClubs = [...clubs.values()].filter((c) => c.id !== managedClubId);
  if (npcClubs.length === 0) return undefined;

  const withinBand = npcClubs.filter(
    (c) => Math.abs(c.reputation - managedReputation) <= 15,
  );
  if (withinBand.length > 0) {
    return withinBand[rng.int(0, withinBand.length - 1)];
  }

  npcClubs.sort((a, b) => {
    if (b.reputation !== a.reputation) return b.reputation - a.reputation;
    return a.id.localeCompare(b.id);
  });
  return npcClubs[0];
}

export function pickNpcBids(
  clubs: ReadonlyMap<Slug, Club>,
  players: ReadonlyMap<Slug, Player>,
  managedClubId: Slug,
  rng: Rng,
  count: number,
): Array<{ playerId: Slug; fromClubId: Slug; amount: number }> {
  if (count <= 0) return [];

  const managedClub = clubs.get(managedClubId);
  if (!managedClub) return [];

  const targets = lowerThirdManagedTargets(players, managedClubId);
  if (targets.length === 0) return [];

  const results: Array<{ playerId: Slug; fromClubId: Slug; amount: number }> = [];
  const usedPlayers = new Set<Slug>();

  for (let i = 0; i < count; i++) {
    const available = targets.filter((p) => !usedPlayers.has(p.id));
    if (available.length === 0) break;

    const player = available[rng.int(0, available.length - 1)]!;
    const buyer = pickBidBuyer(clubs, managedClubId, managedClub.reputation, rng);
    if (!buyer) break;

    usedPlayers.add(player.id);
    results.push({
      playerId: player.id,
      fromClubId: buyer.id,
      amount: transferFee(player.rating),
    });
  }

  return results;
}
