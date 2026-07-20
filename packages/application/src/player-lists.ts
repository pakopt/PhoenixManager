import type { Club, Player, Slug } from '@phoenix/contracts';
import type { SnapshotMarketPlayer, SnapshotPlayer } from './snapshot.js';
import { transferFee } from './transfer.js';

const POSITION_ORDER: Record<SnapshotPlayer['position'], number> = {
  GK: 0,
  DF: 1,
  MF: 2,
  FW: 3,
};

function comparePlayers(a: SnapshotPlayer, b: SnapshotPlayer): number {
  const pos = POSITION_ORDER[a.position] - POSITION_ORDER[b.position];
  if (pos !== 0) return pos;
  return b.rating - a.rating;
}

function toSnapshotPlayer(p: Player): SnapshotPlayer {
  return {
    id: p.id,
    name: p.name,
    position: p.position,
    rating: p.rating,
    age: p.age,
    fee: transferFee(p.rating),
  };
}

export function buildSquad(
  players: Iterable<Player>,
  managedClubId: Slug,
): SnapshotPlayer[] {
  return [...players]
    .filter((p) => p.clubId === managedClubId)
    .map(toSnapshotPlayer)
    .sort(comparePlayers);
}

export function buildMarket(
  players: Iterable<Player>,
  clubs: ReadonlyMap<Slug, Club>,
  managedClubId: Slug,
): SnapshotMarketPlayer[] {
  return [...players]
    .filter((p) => p.clubId !== managedClubId)
    .map((p) => ({
      ...toSnapshotPlayer(p),
      clubId: p.clubId,
      clubName: clubs.get(p.clubId)?.name ?? p.clubId,
    }))
    .sort(comparePlayers);
}
