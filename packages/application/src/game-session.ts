import { readFile, readdir } from 'node:fs/promises';
import { join } from 'node:path';
import type { Fixture, Slug, TableRow } from '@phoenix/contracts';
import { generateLeagueFixtures, totalMatchdays } from '@phoenix/calendar';
import { loadWorld, type WorldDatabase } from '@phoenix/database';
import {
  createEmptyTable,
  simulateMatchday,
  sortTable,
} from '@phoenix/simulation';
import {
  toSnapshotResults,
  type SessionSnapshot,
  type SnapshotTableRow,
} from './snapshot.js';

export type StartSessionOptions = {
  databaseRoot: string;
  seed: number;
  competitionId?: Slug;
  modIds?: string[];
};

export class GameSession {
  private world!: WorldDatabase;
  private fixtures: Fixture[] = [];
  private table!: Map<Slug, TableRow>;
  private matchday = 0;
  private totalMatchdays = 0;
  private seed = 0;
  private competitionId: Slug = 'phoenix-premier-en';
  private competitionName = '';
  private lastResults: SessionSnapshot['lastResults'] = [];
  private started = false;

  async start(options: StartSessionOptions): Promise<SessionSnapshot> {
    this.world = await loadWorld({
      databaseRoot: options.databaseRoot,
      modIds: options.modIds,
      readFile: (p) => readFile(p, 'utf8'),
      readDir: (p) => readdir(p),
      joinPath: join,
    });

    this.seed = options.seed;
    this.competitionId = options.competitionId ?? 'phoenix-premier-en';
    const competition = this.world.competitions.get(this.competitionId);
    if (!competition) {
      throw new Error(`Competition not found: ${this.competitionId}`);
    }

    this.competitionName = competition.name;
    this.fixtures = generateLeagueFixtures(this.competitionId, competition.clubIds);
    this.totalMatchdays = totalMatchdays(competition.clubIds.length);
    this.table = createEmptyTable(competition.clubIds);
    this.matchday = 0;
    this.lastResults = [];
    this.started = true;

    return this.getSnapshot();
  }

  advanceDay(): SessionSnapshot {
    this.assertStarted();
    if (this.matchday >= this.totalMatchdays) {
      return this.getSnapshot();
    }

    const next = this.matchday + 1;
    const { results } = simulateMatchday({
      world: this.world,
      fixtures: this.fixtures,
      matchday: next,
      seed: this.seed,
      table: this.table,
    });

    this.matchday = next;
    this.lastResults = toSnapshotResults(results, (id) => this.clubName(id));
    return this.getSnapshot();
  }

  getSnapshot(): SessionSnapshot {
    this.assertStarted();
    return {
      seed: this.seed,
      competitionId: this.competitionId,
      competitionName: this.competitionName,
      matchday: this.matchday,
      totalMatchdays: this.totalMatchdays,
      finished: this.matchday >= this.totalMatchdays,
      table: this.decorateTable(sortTable([...this.table.values()])),
      lastResults: this.lastResults,
    };
  }

  private decorateTable(rows: TableRow[]): SnapshotTableRow[] {
    return rows.map((row) => ({
      ...row,
      clubName: this.clubName(row.clubId),
    }));
  }

  private clubName(id: Slug): string {
    return this.world.clubs.get(id)?.name ?? id;
  }

  private assertStarted(): void {
    if (!this.started) {
      throw new Error('GameSession not started');
    }
  }
}
