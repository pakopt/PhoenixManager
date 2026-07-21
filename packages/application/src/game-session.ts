import { mkdir, readFile, readdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import type {
  Club,
  CupState,
  Fixture,
  LedgerEntry,
  MatchResult,
  PendingOffer,
  Player,
  SaveMeta,
  Slug,
  TableRow,
} from '@phoenix/contracts';
import {
  fixturesForMatchday,
  generateLeagueFixtures,
  totalMatchdays,
} from '@phoenix/calendar';
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
  applyPlayerPatches,
  bumpClubReputation,
  cloneClubs,
  clonePlayers,
  diffClubs,
  diffPlayers,
} from './entity-patches.js';
import { listMods, listSaves, readSave, writeSave, type SaveFs } from './persistence.js';
import { buildMarket, buildSquad } from './player-lists.js';
import {
  toSnapshotResults,
  type SessionSnapshot,
  type SnapshotCup,
  type SnapshotHighlight,
  type SnapshotTableRow,
} from './snapshot.js';
import {
  gateReceipt,
  makeGateEntry,
  makeTransferEntry,
  makeWagesEntry,
  squadWages,
} from './finance.js';
import {
  INITIAL_BALANCE,
  pickSellDestinationClub,
  transferFee,
} from './transfer.js';
import {
  aiBidCount,
  counterAmountFor,
  decideNpcReplyToPlayerCounter,
  decideNpcResponse,
  pickNpcBids,
  pickNpcNpcTransfers,
} from './club-ai.js';

export type StartSessionOptions = {
  databaseRoot: string;
  seed: number;
  competitionId?: Slug;
  modIds?: string[];
  savesRoot?: string;
  managedClubId?: Slug;
};

export type ProposeResult = {
  outcome: 'accepted' | 'rejected' | 'countered';
  snapshot: SessionSnapshot;
  offerId?: string;
  counterAmount?: number;
  message?: string;
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
  private baselinePlayers!: Map<Slug, Player>;
  private fixtures: Fixture[] = [];
  private table!: Map<Slug, TableRow>;
  private matchday = 0;
  private totalMatchdays = 0;
  private seed = 0;
  private competitionId: Slug = 'phoenix-premier-en';
  private competitionName = '';
  private lastMatchResults: MatchResult[] = [];
  private managedClubId: Slug = DEFAULT_MANAGED_CLUB_ID;
  private balance = INITIAL_BALANCE;
  private ledger: LedgerEntry[] = [];
  private transferSeq = 0;
  private pendingOffers: PendingOffer[] = [];
  private offerSeq = 0;
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
    this.baselinePlayers = clonePlayers(this.world.players);

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
    this.balance = INITIAL_BALANCE;
    this.ledger = [];
    this.transferSeq = 0;
    this.pendingOffers = [];
    this.offerSeq = 0;
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
    this.pendingOffers = [];
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

    const cupPlayedThisDay =
      cupRoundAfterMatchday(next) === this.cup.round &&
      !this.cup.completed;
    let cupHome = false;
    if (cupPlayedThisDay) {
      cupHome = this.cup.ties.some(
        (tie) => tie.homeClubId === this.managedClubId,
      );
      const cupHighlight = this.simulateCupRound(next);
      if (cupHighlight) {
        this.lastHighlight = this.toSnapshotHighlight(cupHighlight);
      }
    }

    const managedPlayers = [...this.world.players.values()].filter(
      (player) => player.clubId === this.managedClubId,
    );
    const wageAmount = -squadWages(managedPlayers);
    this.balance += wageAmount;
    this.ledger = [
      ...this.ledger,
      makeWagesEntry(next, wageAmount, this.balance),
    ];

    const leagueHome = fixturesForMatchday(this.fixtures, next).some(
      (fixture) => fixture.homeClubId === this.managedClubId,
    );
    if (leagueHome || cupHome) {
      const club = this.world.clubs.get(this.managedClubId);
      const gateAmount = gateReceipt(club?.reputation ?? 50);
      this.balance += gateAmount;
      this.ledger = [
        ...this.ledger,
        makeGateEntry(next, gateAmount, this.balance),
      ];
    }

    const aiRng = createRng(this.seed).fork(0x0c1b_a100 ^ next);
    const npcMoves = pickNpcNpcTransfers(
      this.world.clubs,
      this.world.players,
      this.managedClubId,
      aiRng,
      3,
    );
    for (const move of npcMoves) {
      const player = this.world.players.get(move.playerId);
      if (!player) continue;
      this.world.players.set(move.playerId, { ...player, clubId: move.toClubId });
    }

    const bids = pickNpcBids(
      this.world.clubs,
      this.world.players,
      this.managedClubId,
      aiRng,
      aiBidCount(aiRng),
    );
    for (const bid of bids) {
      this.offerSeq += 1;
      this.pendingOffers.push({
        id: `offer-${this.offerSeq}`,
        kind: 'npc_bid',
        playerId: bid.playerId,
        fromClubId: bid.fromClubId,
        toClubId: this.managedClubId,
        amount: bid.amount,
        status: 'pending',
        createdMatchday: next,
      });
    }

    return this.getSnapshot();
  }

  buyPlayer(playerId: Slug): SessionSnapshot {
    const result = this.proposeBuy(playerId);
    if (result.outcome !== 'accepted') {
      throw new Error('Transferência recusada');
    }
    return result.snapshot;
  }

  sellPlayer(playerId: Slug): SessionSnapshot {
    const result = this.proposeSell(playerId);
    if (result.outcome !== 'accepted') {
      throw new Error('Transferência recusada');
    }
    return result.snapshot;
  }

  proposeBuy(playerId: Slug, amount?: number): ProposeResult {
    this.assertStarted();
    const player = this.world.players.get(playerId);
    if (!player || player.clubId === this.managedClubId) {
      throw new Error('Jogador indisponível para compra');
    }

    const fair = transferFee(player.rating);
    const offerAmount = amount ?? fair;
    this.assertValidOfferAmount(offerAmount);
    if (this.balance < offerAmount) {
      throw new Error('Saldo insuficiente');
    }

    const sellerSquadSize = [...this.world.players.values()].filter(
      (candidate) => candidate.clubId === player.clubId,
    ).length;
    const decision = decideNpcResponse({
      kind: 'player_buy',
      amount: offerAmount,
      fair,
      sellerSquadSize,
    });
    if (decision === 'accept') {
      this.executeBuy(player, offerAmount);
      return { outcome: 'accepted', snapshot: this.getSnapshot() };
    }
    if (decision === 'reject') {
      return { outcome: 'rejected', snapshot: this.getSnapshot() };
    }

    const counterAmount = counterAmountFor(
      'player_buy',
      fair,
      this.world.clubs.get(player.clubId)?.reputation ?? 50,
    );
    const offer = this.createOffer({
      kind: 'player_buy',
      playerId,
      fromClubId: this.managedClubId,
      toClubId: player.clubId,
      amount: offerAmount,
      status: 'countered',
      counterAmount,
      createdMatchday: this.matchday,
    });
    return {
      outcome: 'countered',
      snapshot: this.getSnapshot(),
      offerId: offer.id,
      counterAmount,
    };
  }

  proposeSell(playerId: Slug, amount?: number): ProposeResult {
    this.assertStarted();
    const player = this.world.players.get(playerId);
    if (!player || player.clubId !== this.managedClubId) {
      throw new Error('Jogador não pertence ao plantel gerido');
    }
    if (this.managedSquadSize() <= 11) {
      throw new Error('Plantel mínimo de 11 jogadores');
    }

    const fair = transferFee(player.rating);
    const offerAmount = amount ?? fair;
    this.assertValidOfferAmount(offerAmount);
    const decision = decideNpcResponse({
      kind: 'player_sell',
      amount: offerAmount,
      fair,
      sellerSquadSize: this.managedSquadSize(),
    });
    if (decision === 'reject') {
      return { outcome: 'rejected', snapshot: this.getSnapshot() };
    }

    const destinationClubId = pickSellDestinationClub(
      this.world.clubs,
      this.managedClubId,
    );
    if (decision === 'accept') {
      this.executeSell(player, destinationClubId, offerAmount);
      return { outcome: 'accepted', snapshot: this.getSnapshot() };
    }

    const counterAmount = counterAmountFor(
      'player_sell',
      fair,
      this.world.clubs.get(destinationClubId)?.reputation ?? 50,
    );
    const offer = this.createOffer({
      kind: 'player_sell',
      playerId,
      fromClubId: this.managedClubId,
      toClubId: destinationClubId,
      amount: offerAmount,
      status: 'countered',
      counterAmount,
      createdMatchday: this.matchday,
    });
    return {
      outcome: 'countered',
      snapshot: this.getSnapshot(),
      offerId: offer.id,
      counterAmount,
    };
  }

  respondOffer(
    offerId: string,
    action: 'accept' | 'reject' | 'counter',
    counterAmount?: number,
  ): ProposeResult {
    this.assertStarted();
    const offer = this.pendingOffers.find((candidate) => candidate.id === offerId);
    if (!offer) {
      throw new Error('Oferta não encontrada');
    }
    if (offer.kind !== 'npc_bid') {
      if (action === 'accept') return this.acceptCounter(offerId);
      if (action === 'reject') return this.declineOffer(offerId);
      throw new Error('Oferta não permite nova contraproposta');
    }

    if (action === 'reject') {
      this.removeOffer(offerId);
      return { outcome: 'rejected', snapshot: this.getSnapshot() };
    }

    const player = this.world.players.get(offer.playerId);
    if (!player || player.clubId !== this.managedClubId) {
      this.removeOffer(offerId);
      throw new Error('Jogador não pertence ao plantel gerido');
    }
    if (this.managedSquadSize() <= 11) {
      throw new Error('Plantel mínimo de 11 jogadores');
    }

    if (action === 'counter') {
      if (counterAmount === undefined) {
        throw new Error('Valor da contraproposta obrigatório');
      }
      this.assertValidOfferAmount(counterAmount);
      const reply = decideNpcReplyToPlayerCounter({
        amount: counterAmount,
        fair: transferFee(player.rating),
      });
      if (reply === 'reject') {
        this.removeOffer(offerId);
        return { outcome: 'rejected', snapshot: this.getSnapshot() };
      }
      this.executeSell(player, offer.fromClubId, counterAmount);
      this.removeOffer(offerId);
      return { outcome: 'accepted', snapshot: this.getSnapshot() };
    }

    this.executeSell(player, offer.fromClubId, offer.amount);
    this.removeOffer(offerId);
    return { outcome: 'accepted', snapshot: this.getSnapshot() };
  }

  acceptCounter(offerId: string): ProposeResult {
    this.assertStarted();
    const offer = this.pendingOffers.find((candidate) => candidate.id === offerId);
    if (!offer || offer.status !== 'countered' || offer.counterAmount === undefined) {
      throw new Error('Contraproposta não encontrada');
    }

    const player = this.world.players.get(offer.playerId);
    if (!player) {
      this.removeOffer(offerId);
      throw new Error('Jogador não encontrado');
    }
    if (offer.kind === 'player_buy') {
      if (player.clubId !== offer.toClubId) {
        this.removeOffer(offerId);
        throw new Error('Jogador indisponível para compra');
      }
      if (this.balance < offer.counterAmount) {
        throw new Error('Saldo insuficiente');
      }
      this.executeBuy(player, offer.counterAmount);
    } else if (offer.kind === 'player_sell') {
      if (player.clubId !== this.managedClubId) {
        this.removeOffer(offerId);
        throw new Error('Jogador não pertence ao plantel gerido');
      }
      if (this.managedSquadSize() <= 11) {
        throw new Error('Plantel mínimo de 11 jogadores');
      }
      this.executeSell(player, offer.toClubId, offer.counterAmount);
    } else {
      throw new Error('Oferta não é uma contraproposta');
    }

    this.removeOffer(offerId);
    return { outcome: 'accepted', snapshot: this.getSnapshot() };
  }

  declineOffer(offerId: string): ProposeResult {
    this.assertStarted();
    const offer = this.pendingOffers.find((candidate) => candidate.id === offerId);
    if (!offer || offer.status !== 'countered') {
      throw new Error('Contraproposta não encontrada');
    }
    this.removeOffer(offerId);
    return { outcome: 'rejected', snapshot: this.getSnapshot() };
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
      balance: this.balance,
      ledger: [...this.ledger],
      clubs: [...this.world.clubs.values()].map((club) => ({
        id: club.id,
        name: club.name,
      })),
      highlight: this.lastHighlight,
      cup: this.toSnapshotCup(),
      squad: buildSquad(this.world.players.values(), this.managedClubId),
      market: buildMarket(
        this.world.players.values(),
        this.world.clubs,
        this.managedClubId,
      ),
      pendingOffers: this.pendingOffers.map((offer) => {
        const player = this.world.players.get(offer.playerId);
        return {
          ...offer,
          playerName: player?.name ?? offer.playerId,
          fromClubName: this.clubName(offer.fromClubId),
          toClubName: this.clubName(offer.toClubId),
          fairFee: transferFee(player?.rating ?? 0),
        };
      }),
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
        players: diffPlayers(this.baselinePlayers, this.world.players),
      },
      balance: this.balance,
      managedClubId: this.managedClubId,
      cup: this.cup,
      ledger: this.ledger,
      pendingOffers: this.pendingOffers,
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
    applyPlayerPatches(this.world.players, save.patches?.players ?? []);

    this.matchday = save.matchday;
    this.table = new Map(save.table.map((row) => [row.clubId, { ...row }]));
    this.lastMatchResults = save.lastResults.map((r) => ({ ...r }));
    this.managedClubId = save.managedClubId ?? DEFAULT_MANAGED_CLUB_ID;
    this.balance = save.balance ?? INITIAL_BALANCE;
    this.ledger = save.ledger ?? [];
    this.transferSeq = this.nextTransferSequence(this.ledger);
    this.pendingOffers = save.pendingOffers ?? [];
    this.offerSeq = this.nextOfferSequence(this.pendingOffers);
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

  private managedSquadSize(): number {
    return [...this.world.players.values()].filter(
      (player) => player.clubId === this.managedClubId,
    ).length;
  }

  private assertValidOfferAmount(amount: number): void {
    if (!Number.isFinite(amount) || amount <= 0) {
      throw new Error('Valor de oferta inválido');
    }
  }

  private createOffer(offer: Omit<PendingOffer, 'id'>): PendingOffer {
    this.offerSeq += 1;
    const created = { ...offer, id: `offer-${this.offerSeq}` };
    this.pendingOffers = [...this.pendingOffers, created];
    return created;
  }

  private removeOffer(offerId: string): void {
    this.pendingOffers = this.pendingOffers.filter((offer) => offer.id !== offerId);
  }

  private executeBuy(player: Player, amount: number): void {
    this.world.players.set(player.id, {
      ...player,
      clubId: this.managedClubId,
    });
    this.balance -= amount;
    this.transferSeq += 1;
    this.ledger = [
      ...this.ledger,
      makeTransferEntry(
        'transfer_out',
        player.id,
        this.transferSeq,
        this.matchday,
        -amount,
        this.balance,
        player.name,
      ),
    ];
  }

  private executeSell(player: Player, destinationClubId: Slug, amount: number): void {
    this.world.players.set(player.id, {
      ...player,
      clubId: destinationClubId,
    });
    this.balance += amount;
    this.transferSeq += 1;
    this.ledger = [
      ...this.ledger,
      makeTransferEntry(
        'transfer_in',
        player.id,
        this.transferSeq,
        this.matchday,
        amount,
        this.balance,
        player.name,
      ),
    ];
  }

  private nextTransferSequence(ledger: readonly LedgerEntry[]): number {
    const transferSequences = ledger.flatMap((entry) => {
      const match = /^xfer-.+-(\d+)$/.exec(entry.id);
      return match ? [Number(match[1])] : [];
    });
    return transferSequences.length > 0
      ? Math.max(...transferSequences)
      : ledger.length;
  }

  private nextOfferSequence(offers: readonly PendingOffer[]): number {
    const sequences = offers.flatMap((offer) => {
      const match = /^offer-(\d+)$/.exec(offer.id);
      return match ? [Number(match[1])] : [];
    });
    return sequences.length > 0 ? Math.max(...sequences) : offers.length;
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
