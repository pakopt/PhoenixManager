import { readFile, readdir } from 'node:fs/promises';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import type { Fixture, Slug } from '@phoenix/contracts';
import { generateLeagueFixtures } from '@phoenix/calendar';
import type { WorldDatabase } from '@phoenix/database';
import { loadWorld } from '@phoenix/database';
import { describe, expect, it } from 'vitest';
import { createEmptyTable } from './league-table.js';
import { simulateMatchday } from './simulate-matchday.js';

const databaseRoot = fileURLToPath(new URL('../../../database', import.meta.url));

const fsOpts = {
  readFile: (p: string) => readFile(p, 'utf8'),
  readDir: (p: string) => readdir(p),
  joinPath: join,
};

function minimalWorld(clubIds: Slug[]): WorldDatabase {
  const clubs = new Map(
    clubIds.map((id) => [
      id,
      {
        id,
        name: id,
        nationId: 'england' as Slug,
        reputation: 70,
      },
    ]),
  );
  return {
    nations: new Map(),
    clubs,
    players: new Map(),
    competitions: new Map(),
    indexes: {
      playersByClub: new Map(clubIds.map((id) => [id, [] as Slug[]])),
      clubsByNation: new Map(),
    },
  };
}

describe('simulateMatchday', () => {
  it('returns L1 highlight when highlightClubId plays', async () => {
    const world = await loadWorld({ databaseRoot, ...fsOpts });
    const competitionId = 'phoenix-premier-en';
    const competition = world.competitions.get(competitionId)!;
    const fixtures = generateLeagueFixtures(competitionId, competition.clubIds);
    const highlightClubId = 'london-fc-en';
    const table = createEmptyTable(competition.clubIds);

    const day = simulateMatchday({
      world,
      fixtures,
      matchday: 1,
      seed: 42,
      table,
      highlightClubId,
    });

    expect(day.highlight).toBeDefined();
    const highlightedResult = day.results.find(
      (r) =>
        r.homeClubId === day.highlight!.result.homeClubId &&
        r.awayClubId === day.highlight!.result.awayClubId,
    );
    expect(highlightedResult).toEqual(day.highlight!.result);
  });

  it('omits highlight when highlightClubId is not provided', async () => {
    const world = await loadWorld({ databaseRoot, ...fsOpts });
    const competitionId = 'phoenix-premier-en';
    const competition = world.competitions.get(competitionId)!;
    const fixtures = generateLeagueFixtures(competitionId, competition.clubIds);
    const table = createEmptyTable(competition.clubIds);

    const day = simulateMatchday({
      world,
      fixtures,
      matchday: 1,
      seed: 42,
      table,
    });

    expect(day.highlight).toBeUndefined();
  });

  it('highlights only the first fixture involving highlightClubId', () => {
    const clubA = 'club-a' as Slug;
    const clubB = 'club-b' as Slug;
    const clubC = 'club-c' as Slug;
    const fixtures: Fixture[] = [
      {
        id: 'fixture-1',
        competitionId: 'test-comp',
        matchday: 1,
        homeClubId: clubA,
        awayClubId: clubB,
      },
      {
        id: 'fixture-2',
        competitionId: 'test-comp',
        matchday: 1,
        homeClubId: clubA,
        awayClubId: clubC,
      },
    ];
    const world = minimalWorld([clubA, clubB, clubC]);
    const table = createEmptyTable([clubA, clubB, clubC]);

    const day = simulateMatchday({
      world,
      fixtures,
      matchday: 1,
      seed: 99,
      table,
      highlightClubId: clubA,
    });

    expect(day.highlight).toBeDefined();
    expect(day.highlight!.result).toEqual(day.results[0]);
    expect(day.results).toHaveLength(2);
  });
});
