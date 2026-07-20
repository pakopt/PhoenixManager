import { mkdir, readFile, readdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import type {
  Club,
  CupState,
  Fixture,
  MatchResult,
  SaveMeta,
  Slug,
  TableRow,
} from '@phoenix/contracts';
import { generateLeagueFixtures, totalMatchdays } from '@phoenix/calendar';
import {
  advanceKnockout,
  createKnockoutCup,
  cupRoundAfterMatchday,
  pickEntrants,
} from '@phoenix/competition';
import { loadWorld, type WorldDatabase } from '@phoenix/database';
import {
  simulateMatch,
  simulateMatchDetailed,
  type DetailedMatch,
} from '@phoenix/match-engine';
import { createRng, type Rng } from '@phoenix/shared';
import {
  clubStrength,
  createEmptyTable,
  simulateMatchday,
  sortTable,
} from '@phoenix/simulation';
import {
  applyClubPatches,
  bumpClubReputation,
  cloneClubs,
  diffClubs,
} from './entity-patches.js';
import { listMods, listSaves, readSave, writeSave, type SaveFs } from './persistence.js';
import {
  toSnapshotResults,
  type SessionSnapshot,
  type SnapshotCup,
  type SnapshotHighlight,
  type SnapshotTableRow,
} from './snapshot.js';

export type StartSessionOptions = {
  databaseRoot: string;
  seed: number;
  competitionId?: Slug;
  modIds?: string[];
  savesRoot?: string;
  managedClubId?: Slug;
};

const DEFAULT_MANAGED_CLUB_ID: Slug = 'london-fc-en';
const CUP_ID: Slug = 'phoenix-cup-en';
const CUP_MATCHDAYS = [5, 10, 15] as const;

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
  private baselineClubs!: Map<Slug, Club>;
  private fixtures: Fixture[] = [];
  private table!: Map<Slug, TableRow>;
  private matchday = 0;
  private totalMatchdays = 0;
  private seed = 0;
  private competitionId: Slug = 'phoenix-premier-en';
  private competitionName = '';
  private lastMatchResults: MatchResult[] = [];
  private managedClubId: Slug = DEFAULT_MANAGED_CLUB_ID;
  private cup!: CupState;
  private lastHighlight: SnapshotHighlight | undefined;
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
    this.baselineClubs = cloneClubs(this.world.clubs);

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
    this.managedClubId = options.managedClubId ?? DEFAULT_MANAGED_CLUB_ID;
    this.cup = createKnockoutCup({
      competitionId: CUP_ID,
      clubIds: competition.clubIds,
      seed: this.seed,
    });
    this.lastHighlight = undefined;
    this.started = true;

    return this.getSnapshot();
  }

  advanceDay(): SessionSnapshot {
    this.assertStarted();
    if (this.matchday >= this.totalMatchdays) {
      return this.getSnapshot();
    }

    const next = this.matchday + 1;
    const { results, highlight: leagueHighlight } = simulateMatchday({
      world: this.world,
      fixtures: this.fixtures,
      matchday: next,
      seed: this.seed,
      table: this.table,
      highlightClubId: this.managedClubId,
    });

    this.bumpWinningReputations(results);

    this.matchday = next;
    this.lastMatchResults = results;
    this.lastHighlight = leagueHighlight
      ? this.toSnapshotHighlight(leagueHighlight)
      : undefined;

    if (
      cupRoundAfterMatchday(next) === this.cup.round &&
      !this.cup.completed
    ) {
      const cupHighlight = this.simulateCupRound(next);
      if (cupHighlight) {
        this.lastHighlight = this.toSnapshotHighlight(cupHighlight);
      }
    }

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
      managedClubId: this.managedClubId,
      clubs: [...this.world.clubs.values()].map((club) => ({
        id: club.id,
        name: club.name,
      })),
      highlight: this.lastHighlight,
      cup: this.toSnapshotCup(),
    };
  }

  async save(slotId: Slug, label?: string): Promise<SaveMeta> {
    this.assertStarted();
    if (!this.savesRoot) {
      throw new Error('savesRoot not configured');
    }
    return writeSave(this.fs, this.savesRoot, {
      version: 2,
      savedAt: Date.now(),
      slotId,
      label: label ?? slotId,
      seed: this.seed,
      modIds: this.modIds,
      competitionId: this.competitionId,
      matchday: this.matchday,
      table: [...this.table.values()],
      lastResults: this.lastMatchResults,
      patches: {
        clubs: diffClubs(this.baselineClubs, this.world.clubs),
        players: [],
      },
      managedClubId: this.managedClubId,
      cup: this.cup,
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

    applyClubPatches(this.world.clubs, save.patches?.clubs ?? []);

    this.matchday = save.matchday;
    this.table = new Map(save.table.map((row) => [row.clubId, { ...row }]));
    this.lastMatchResults = save.lastResults.map((r) => ({ ...r }));
    this.managedClubId = save.managedClubId ?? DEFAULT_MANAGED_CLUB_ID;
    const competition = this.world.competitions.get(this.competitionId);
    if (!competition) {
      throw new Error(`Competition not found: ${this.competitionId}`);
    }
    this.cup =
      save.cup ??
      this.regenerateCupForMatchday(competition.clubIds);
    this.lastHighlight = undefined;
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
      reputation: this.world.clubs.get(row.clubId)?.reputation ?? 50,
    }));
  }

  private clubName(id: Slug): string {
    return this.world.clubs.get(id)?.name ?? id;
  }

  private bumpWinningReputations(results: readonly MatchResult[]): void {
    for (const result of results) {
      if (result.homeGoals > result.awayGoals) {
        bumpClubReputation(this.world.clubs, result.homeClubId, 1);
      } else if (result.awayGoals > result.homeGoals) {
        bumpClubReputation(this.world.clubs, result.awayClubId, 1);
      }
    }
  }

  private simulateCupRound(matchday: number): DetailedMatch | undefined {
    const rootRng = createRng(this.seed).fork(matchday * 1_000_003);
    const results: MatchResult[] = [];
    let highlight: DetailedMatch | undefined;

    for (const [index, tie] of this.cup.ties.entries()) {
      const simulated = this.simulateDecisiveCupTie(
        tie.homeClubId,
        tie.awayClubId,
        rootRng.fork(index),
      );
      results.push(simulated.result);
      if (simulated.detailed) {
        highlight = simulated.detailed;
      }
    }

    this.bumpWinningReputations(results);
    this.cup = advanceKnockout(this.cup, results);
    return highlight;
  }

  private simulateDecisiveCupTie(
    homeClubId: Slug,
    awayClubId: Slug,
    rng: Rng,
  ): { result: MatchResult; detailed?: DetailedMatch } {
    const matchInput = {
      homeClubId,
      awayClubId,
      homeStrength: clubStrength(this.world, homeClubId),
      awayStrength: clubStrength(this.world, awayClubId),
    };
    const managesTie =
      homeClubId === this.managedClubId || awayClubId === this.managedClubId;

    if (managesTie) {
      let retry = 0;
      while (true) {
        const detailed = simulateMatchDetailed({
          ...matchInput,
          rng: rng.fork(retry),
        });
        if (detailed.result.homeGoals !== detailed.result.awayGoals) {
          return { result: detailed.result, detailed };
        }
        retry += 1;
      }
    }

    let retry = 0;
    while (true) {
      const result = simulateMatch({ ...matchInput, rng: rng.fork(retry) });
      if (result.homeGoals !== result.awayGoals) {
        return { result };
      }
      retry += 1;
    }
  }

  private regenerateCupForMatchday(clubIds: readonly Slug[]): CupState {
    const cup = createKnockoutCup({
      competitionId: CUP_ID,
      clubIds,
      seed: this.seed,
    });
    if (this.matchday < 5) return cup;

    // Legacy saves lack prior cup outcomes, so deterministically select the
    // remaining entrants for the round scheduled after the saved matchday.
    const entrants = cup.ties.flatMap((tie) => [tie.homeClubId, tie.awayClubId]);
    const remaining = pickEntrants(
      entrants,
      this.seed + this.matchday,
      this.matchday < 10 ? 4 : 2,
    );
    const ties =
      this.matchday < 10
        ? [
            { homeClubId: remaining[0]!, awayClubId: remaining[1]! },
            { homeClubId: remaining[2]!, awayClubId: remaining[3]! },
          ]
        : [{ homeClubId: remaining[0]!, awayClubId: remaining[1]! }];

    if (this.matchday < 10) {
      return { competitionId: CUP_ID, round: 'sf', ties, completed: false };
    }
    if (this.matchday < 15) {
      return { competitionId: CUP_ID, round: 'final', ties, completed: false };
    }

    const finalTie = ties[0]!;
    const result: MatchResult = {
      homeClubId: finalTie.homeClubId,
      awayClubId: finalTie.awayClubId,
      homeGoals: 1,
      awayGoals: 0,
    };
    return {
      competitionId: CUP_ID,
      round: 'final',
      ties: [{ ...finalTie, result }],
      completed: true,
    };
  }

  private toSnapshotHighlight(detailed: DetailedMatch): SnapshotHighlight {
    return {
      ...toSnapshotResults([detailed.result], (id) => this.clubName(id))[0]!,
      events: detailed.events,
    };
  }

  private toSnapshotCup(): SnapshotCup {
    return {
      competitionId: this.cup.competitionId,
      round: this.cup.round,
      ties: this.cup.ties.map((tie) => ({
        homeClubId: tie.homeClubId,
        awayClubId: tie.awayClubId,
        homeName: this.clubName(tie.homeClubId),
        awayName: this.clubName(tie.awayClubId),
        result: tie.result
          ? toSnapshotResults([tie.result], (id) => this.clubName(id))[0]
          : undefined,
      })),
      completed: this.cup.completed,
      nextRoundAfterMatchday: this.nextCupRoundAfterMatchday(),
    };
  }

  private nextCupRoundAfterMatchday(): number | undefined {
    if (this.cup.completed) return undefined;
    return CUP_MATCHDAYS.find((matchday) => matchday > this.matchday);
  }

  private assertStarted(): void {
    if (!this.started) {
      throw new Error('GameSession not started');
    }
  }
}
