import type { MatchResult, Slug, TableRow } from '@phoenix/contracts';
import type { WorldDatabase } from '@phoenix/database';

export function clubStrength(world: WorldDatabase, clubId: Slug): number {
  const playerIds = world.indexes.playersByClub.get(clubId) ?? [];
  if (playerIds.length === 0) {
    return world.clubs.get(clubId)?.reputation ?? 50;
  }
  let sum = 0;
  for (const id of playerIds) {
    sum += world.players.get(id)?.rating ?? 50;
  }
  return sum / playerIds.length;
}

export function emptyRow(clubId: Slug): TableRow {
  return {
    clubId,
    played: 0,
    won: 0,
    drawn: 0,
    lost: 0,
    goalsFor: 0,
    goalsAgainst: 0,
    points: 0,
  };
}

export function applyResult(table: Map<Slug, TableRow>, result: MatchResult): void {
  const home = table.get(result.homeClubId) ?? emptyRow(result.homeClubId);
  const away = table.get(result.awayClubId) ?? emptyRow(result.awayClubId);

  home.played += 1;
  away.played += 1;
  home.goalsFor += result.homeGoals;
  home.goalsAgainst += result.awayGoals;
  away.goalsFor += result.awayGoals;
  away.goalsAgainst += result.homeGoals;

  if (result.homeGoals > result.awayGoals) {
    home.won += 1;
    home.points += 3;
    away.lost += 1;
  } else if (result.homeGoals < result.awayGoals) {
    away.won += 1;
    away.points += 3;
    home.lost += 1;
  } else {
    home.drawn += 1;
    away.drawn += 1;
    home.points += 1;
    away.points += 1;
  }

  table.set(result.homeClubId, home);
  table.set(result.awayClubId, away);
}

export function sortTable(rows: TableRow[]): TableRow[] {
  return [...rows].sort((a, b) => {
    if (b.points !== a.points) return b.points - a.points;
    const gdA = a.goalsFor - a.goalsAgainst;
    const gdB = b.goalsFor - b.goalsAgainst;
    if (gdB !== gdA) return gdB - gdA;
    if (b.goalsFor !== a.goalsFor) return b.goalsFor - a.goalsFor;
    return a.clubId.localeCompare(b.clubId);
  });
}

export function hashSlug(slug: string): number {
  let h = 2166136261;
  for (let i = 0; i < slug.length; i += 1) {
    h ^= slug.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  return h >>> 0;
}

export function createEmptyTable(clubIds: readonly Slug[]): Map<Slug, TableRow> {
  const table = new Map<Slug, TableRow>();
  for (const clubId of clubIds) {
    table.set(clubId, emptyRow(clubId));
  }
  return table;
}
