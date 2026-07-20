import { readFile, readdir } from 'node:fs/promises';
import { join } from 'node:path';
import type { MatchResult, SeasonReport, Slug, TableRow } from '@phoenix/contracts';
import { generateLeagueFixtures, totalMatchdays } from '@phoenix/calendar';
import { loadWorld, type WorldDatabase } from '@phoenix/database';
import { simulateMatch } from '@phoenix/match-engine';
import { createRng } from '@phoenix/shared';

export type RunSeasonOptions = {
  databaseRoot: string;
  competitionId?: Slug;
  seed: number;
  modIds?: string[];
};

function clubStrength(world: WorldDatabase, clubId: Slug): number {
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

function emptyRow(clubId: Slug): TableRow {
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

function applyResult(table: Map<Slug, TableRow>, result: MatchResult): void {
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

function sortTable(rows: TableRow[]): TableRow[] {
  return [...rows].sort((a, b) => {
    if (b.points !== a.points) return b.points - a.points;
    const gdA = a.goalsFor - a.goalsAgainst;
    const gdB = b.goalsFor - b.goalsAgainst;
    if (gdB !== gdA) return gdB - gdA;
    if (b.goalsFor !== a.goalsFor) return b.goalsFor - a.goalsFor;
    return a.clubId.localeCompare(b.clubId);
  });
}

export async function runSeason(options: RunSeasonOptions): Promise<SeasonReport> {
  const started = performance.now();

  const world = await loadWorld({
    databaseRoot: options.databaseRoot,
    modIds: options.modIds,
    readFile: (p) => readFile(p, 'utf8'),
    readDir: (p) => readdir(p),
    joinPath: join,
  });

  const competitionId = options.competitionId ?? 'phoenix-premier-en';
  const competition = world.competitions.get(competitionId);
  if (!competition) {
    throw new Error(`Competition not found: ${competitionId}`);
  }

  const fixtures = generateLeagueFixtures(competitionId, competition.clubIds);
  const expectedMatchdays = totalMatchdays(competition.clubIds.length);
  const maxMatchday = Math.max(...fixtures.map((f) => f.matchday));
  if (maxMatchday !== expectedMatchdays) {
    throw new Error(`Expected ${expectedMatchdays} matchdays, got ${maxMatchday}`);
  }

  const table = new Map<Slug, TableRow>();
  for (const clubId of competition.clubIds) {
    table.set(clubId, emptyRow(clubId));
  }

  const results: MatchResult[] = [];
  const rootRng = createRng(options.seed);

  for (const fixture of fixtures) {
    const matchRng = rootRng.fork(
      fixture.matchday * 1_000_003 + hashSlug(fixture.id),
    );
    const result = simulateMatch({
      homeClubId: fixture.homeClubId,
      awayClubId: fixture.awayClubId,
      homeStrength: clubStrength(world, fixture.homeClubId),
      awayStrength: clubStrength(world, fixture.awayClubId),
      rng: matchRng,
    });
    results.push(result);
    applyResult(table, result);
  }

  const durationMs = performance.now() - started;

  return {
    competitionId,
    seed: options.seed,
    durationMs,
    matchCount: results.length,
    table: sortTable([...table.values()]),
    results,
  };
}

function hashSlug(slug: string): number {
  let h = 2166136261;
  for (let i = 0; i < slug.length; i += 1) {
    h ^= slug.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  return h >>> 0;
}
