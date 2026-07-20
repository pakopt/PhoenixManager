import { mkdir, readFile, readdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import type { Fixture, MatchResult, SaveMeta, Slug, TableRow } from '@phoenix/contracts';
import { generateLeagueFixtures, totalMatchdays } from '@phoenix/calendar';
import { loadWorld, type WorldDatabase } from '@phoenix/database';
import {
  createEmptyTable,
  simulateMatchday,
  sortTable,
} from '@phoenix/simulation';
import { listMods, listSaves, readSave, writeSave, type SaveFs } from './persistence.js';
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
  savesRoot?: string;
};

const defaultFs: SaveFs = {
  readFile: (p) => readFile(p, 'utf8'),
  writeFile: (p, c) => writeFile(p, c, 'utf8'),
  mkdir: async (p, opts) => {
    await mkdir(p, opts);
  },
  readdir: (p) => readdir(p),
  joinPath: join,
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
  private lastMatchResults: MatchResult[] = [];
  private modIds: string[] = [];
  private databaseRoot = '';
  private savesRoot = '';
  private started = false;
  private readonly fs: SaveFs;

  constructor(fs: SaveFs = defaultFs) {
    this.fs = fs;
  }

  async start(options: StartSessionOptions): Promise<SessionSnapshot> {
    this.databaseRoot = options.databaseRoot;
    this.savesRoot = options.savesRoot ?? join(options.databaseRoot, '..', 'saves');
    this.modIds = options.modIds ?? [];

    this.world = await loadWorld({
      databaseRoot: options.databaseRoot,
      modIds: this.modIds,
      readFile: this.fs.readFile,
      readDir: this.fs.readdir,
      joinPath: this.fs.joinPath,
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
    this.lastMatchResults = [];
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
    this.lastMatchResults = results;
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
      lastResults: toSnapshotResults(this.lastMatchResults, (id) => this.clubName(id)),
      modIds: [...this.modIds],
    };
  }

  async save(slotId: Slug, label?: string): Promise<SaveMeta> {
    this.assertStarted();
    if (!this.savesRoot) {
      throw new Error('savesRoot not configured');
    }
    return writeSave(this.fs, this.savesRoot, {
      version: 1,
      savedAt: Date.now(),
      slotId,
      label: label ?? slotId,
      seed: this.seed,
      modIds: this.modIds,
      competitionId: this.competitionId,
      matchday: this.matchday,
      table: [...this.table.values()],
      lastResults: this.lastMatchResults,
    });
  }

  async load(slotId: Slug): Promise<SessionSnapshot> {
    if (!this.databaseRoot || !this.savesRoot) {
      throw new Error('Call start() once to configure roots, or pass roots via loadWithRoots');
    }
    return this.loadWithRoots(slotId, this.databaseRoot, this.savesRoot);
  }

  async loadWithRoots(
    slotId: Slug,
    databaseRoot: string,
    savesRoot: string,
  ): Promise<SessionSnapshot> {
    const save = await readSave(this.fs, savesRoot, slotId);
    await this.start({
      databaseRoot,
      savesRoot,
      seed: save.seed,
      modIds: save.modIds,
      competitionId: save.competitionId,
    });

    this.matchday = save.matchday;
    this.table = new Map(save.table.map((row) => [row.clubId, { ...row }]));
    this.lastMatchResults = save.lastResults.map((r) => ({ ...r }));
    return this.getSnapshot();
  }

  async listSaves(): Promise<SaveMeta[]> {
    if (!this.savesRoot) return [];
    return listSaves(this.fs, this.savesRoot);
  }

  async listMods(): Promise<import('@phoenix/contracts').ModInfo[]> {
    if (!this.databaseRoot) return [];
    return listMods(this.fs, this.databaseRoot);
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
