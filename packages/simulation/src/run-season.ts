import { readFile, readdir } from 'node:fs/promises';
import { join } from 'node:path';
import type { MatchResult, SeasonReport, Slug } from '@phoenix/contracts';
import { generateLeagueFixtures, totalMatchdays } from '@phoenix/calendar';
import { loadWorld } from '@phoenix/database';
import { createEmptyTable, sortTable } from './league-table.js';
import { simulateMatchday } from './simulate-matchday.js';

export type RunSeasonOptions = {
  databaseRoot: string;
  competitionId?: Slug;
  seed: number;
  modIds?: string[];
};

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

  const table = createEmptyTable(competition.clubIds);
  const results: MatchResult[] = [];

  for (let matchday = 1; matchday <= expectedMatchdays; matchday += 1) {
    const day = simulateMatchday({
      world,
      fixtures,
      matchday,
      seed: options.seed,
      table,
    });
    results.push(...day.results);
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
