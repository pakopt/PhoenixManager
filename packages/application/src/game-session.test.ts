import { mkdir, mkdtemp, readFile, readdir, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import type { WorldDatabase } from '@phoenix/database';
import { simulateMatchDetailed } from '@phoenix/match-engine';
import { createRng } from '@phoenix/shared';
import { clubStrength } from '@phoenix/simulation';
import { GameSession } from './game-session.js';
import type { SaveFs } from './persistence.js';
import { gateReceipt, squadWages } from './finance.js';
import { INITIAL_BALANCE, transferFee } from './transfer.js';

const databaseRoot = fileURLToPath(new URL('../../../database', import.meta.url));

const nodeFs: SaveFs = {
  readFile: (p) => readFile(p, 'utf8'),
  writeFile: (p, c) => writeFile(p, c, 'utf8'),
  mkdir: async (p, opts) => {
    await mkdir(p, opts);
  },
  readdir: (p) => readdir(p),
  joinPath: join,
};

describe('GameSession', () => {
  it('starts with empty table and advances one matchday', async () => {
    const session = new GameSession(nodeFs);
    const start = await session.start({ databaseRoot, seed: 42 });
    expect(start.matchday).toBe(0);
    expect(start.finished).toBe(false);
    expect(start.table).toHaveLength(20);
    expect(start.modIds).toEqual([]);

    const day1 = session.advanceDay();
    expect(day1.matchday).toBe(1);
    expect(day1.lastResults.length).toBe(10);
  });

  it('save and load restores matchday and table', async () => {
    const savesRoot = await mkdtemp(join(tmpdir(), 'phoenix-saves-'));
    const session = new GameSession(nodeFs);
    await session.start({ databaseRoot, savesRoot, seed: 42 });
    session.advanceDay();
    session.advanceDay();
    const before = session.getSnapshot();

    await session.save('career-01', 'Test Career');

    const loaded = new GameSession(nodeFs);
    const after = await loaded.loadWithRoots('career-01', databaseRoot, savesRoot);
    expect(after.matchday).toBe(before.matchday);
    expect(after.table.map((r) => ({ id: r.clubId, pts: r.points }))).toEqual(
      before.table.map((r) => ({ id: r.clubId, pts: r.points })),
    );
    expect(after.lastResults).toHaveLength(before.lastResults.length);
  });

  it('applies rename-pack mod club names', async () => {
    const session = new GameSession(nodeFs);
    const snap = await session.start({
      databaseRoot,
      seed: 1,
      modIds: ['rename-pack'],
    });
    const london = snap.table.find((r) => r.clubId === 'london-fc-en');
    expect(london?.clubName).toBe('Real London');
  });

  it('lists rename-pack mod', async () => {
    const session = new GameSession(nodeFs);
    await session.start({ databaseRoot, seed: 1 });
    const mods = await session.listMods();
    expect(mods.some((m) => m.id === 'rename-pack')).toBe(true);
  });

  it('persists club reputation patches across save/load', async () => {
    const savesRoot = await mkdtemp(join(tmpdir(), 'phoenix-saves-'));
    const session = new GameSession(nodeFs);
    await session.start({ databaseRoot, savesRoot, seed: 42 });
    const beforeRep = new Map(
      session.getSnapshot().table.map((r) => [r.clubId, r.reputation]),
    );
    session.advanceDay();
    session.advanceDay();
    const mid = session.getSnapshot();
    const changed = mid.table.some(
      (r) => (beforeRep.get(r.clubId) ?? 0) !== r.reputation,
    );
    expect(changed).toBe(true);

    await session.save('patch-test', 'Patch Test');
    const loaded = new GameSession(nodeFs);
    const after = await loaded.loadWithRoots('patch-test', databaseRoot, savesRoot);
    expect(
      after.table.map((r) => ({ id: r.clubId, rep: r.reputation })).sort((a, b) =>
        a.id.localeCompare(b.id),
      ),
    ).toEqual(
      mid.table
        .map((r) => ({ id: r.clubId, rep: r.reputation }))
        .sort((a, b) => a.id.localeCompare(b.id)),
    );
  });

  it('exposes managed squad and market excluding managed club', async () => {
    const session = new GameSession(nodeFs);
    const snap = await session.start({
      databaseRoot,
      seed: 42,
      managedClubId: 'london-fc-en',
    });
    const world = (session as unknown as { world: WorldDatabase }).world;
    expect(snap.squad.length).toBeGreaterThan(0);
    expect(snap.squad.length + snap.market.length).toBe(world.players.size);
    const squadIds = new Set(snap.squad.map((p) => p.id));
    const marketIds = new Set(snap.market.map((p) => p.id));
    expect(snap.squad.every((p) => !marketIds.has(p.id))).toBe(true);
    expect(snap.market.every((p) => !squadIds.has(p.id))).toBe(true);
    expect(snap.market.every((p) => p.clubId !== 'london-fc-en')).toBe(true);
    expect(snap.market[0]?.clubName).toBeTruthy();
  });

  it('exposes a highlight for the managed club league fixture', async () => {
    const session = new GameSession(nodeFs);
    await session.start({ databaseRoot, seed: 42, managedClubId: 'london-fc-en' });

    let day = session.getSnapshot();
    while (!day.highlight && day.matchday < day.totalMatchdays) {
      day = session.advanceDay();
    }

    expect(day.highlight).toBeDefined();
    expect(day.matchday).toBe(1);
    expect([day.highlight?.homeClubId, day.highlight?.awayClubId]).toContain(
      'london-fc-en',
    );
    expect(day.highlight?.events).toBeDefined();
  });

  it('runs the cup quarter-finals after matchday five', async () => {
    const session = new GameSession(nodeFs);
    await session.start({ databaseRoot, seed: 42 });

    for (let i = 0; i < 5; i += 1) {
      session.advanceDay();
    }

    const snapshot = session.getSnapshot();
    expect(snapshot.cup?.round).toBe('sf');
    expect(snapshot.cup?.ties).toHaveLength(2);
  });

  it('settles every completed cup tie decisively', async () => {
    const session = new GameSession(nodeFs);
    await session.start({ databaseRoot, seed: 42 });

    for (let i = 0; i < 15; i += 1) {
      session.advanceDay();
    }

    const finalTie = session.getSnapshot().cup?.ties[0];
    expect(finalTie?.result).toBeDefined();
    expect(finalTie?.result?.homeGoals).not.toBe(finalTie?.result?.awayGoals);
  });

  it('keeps a managed cup L1 highlight when its tie initially draws', async () => {
    let seed: number | undefined;
    for (let candidate = 1; candidate <= 100; candidate += 1) {
      const probe = new GameSession(nodeFs);
      const snapshot = await probe.start({ databaseRoot, seed: candidate });
      const tie = snapshot.cup?.ties[0];
      const world = (probe as unknown as { world: WorldDatabase }).world;
      if (!tie) continue;
      const initial = simulateMatchDetailed({
        homeClubId: tie.homeClubId,
        awayClubId: tie.awayClubId,
        homeStrength: clubStrength(world, tie.homeClubId),
        awayStrength: clubStrength(world, tie.awayClubId),
        rng: createRng(candidate).fork(5 * 1_000_003).fork(0).fork(0),
      });
      if (initial.result.homeGoals === initial.result.awayGoals) {
        seed = candidate;
        break;
      }
    }
    expect(seed).toBeDefined();

    const setup = new GameSession(nodeFs);
    const start = await setup.start({ databaseRoot, seed: seed! });
    const managedClubId = start.cup?.ties[0]?.homeClubId;
    expect(managedClubId).toBeDefined();

    const session = new GameSession(nodeFs);
    await session.start({ databaseRoot, seed: seed!, managedClubId });
    let snapshot = session.getSnapshot();
    for (let i = 0; i < 5; i += 1) {
      snapshot = session.advanceDay();
    }

    expect(snapshot.highlight?.events).toBeDefined();
    expect([snapshot.highlight?.homeClubId, snapshot.highlight?.awayClubId]).toContain(
      managedClubId,
    );
    expect(snapshot.highlight?.homeGoals).not.toBe(snapshot.highlight?.awayGoals);
  });

  it('regenerates a completed cup with a decisive final at matchday 15', async () => {
    const savesRoot = await mkdtemp(join(tmpdir(), 'phoenix-saves-'));
    const session = new GameSession(nodeFs);
    await session.start({ databaseRoot, savesRoot, seed: 42 });
    for (let i = 0; i < 15; i += 1) {
      session.advanceDay();
    }
    await session.save('legacy-cup-final');

    const savePath = join(savesRoot, 'legacy-cup-final', 'save.json');
    const saved = JSON.parse(await readFile(savePath, 'utf8')) as Record<string, unknown>;
    delete saved.cup;
    await writeFile(savePath, `${JSON.stringify(saved)}\n`);

    const loaded = new GameSession(nodeFs);
    const snapshot = await loaded.loadWithRoots(
      'legacy-cup-final',
      databaseRoot,
      savesRoot,
    );
    expect(snapshot.matchday).toBe(15);
    expect(snapshot.cup?.completed).toBe(true);
    expect(snapshot.cup?.round).toBe('final');
    const finalTie = snapshot.cup?.ties[0];
    expect(finalTie?.result).toBeDefined();
    expect(finalTie?.result?.homeGoals).not.toBe(finalTie?.result?.awayGoals);
  });

  it('reconciles a missing legacy cup with the saved matchday', async () => {
    const savesRoot = await mkdtemp(join(tmpdir(), 'phoenix-saves-'));
    const session = new GameSession(nodeFs);
    await session.start({ databaseRoot, savesRoot, seed: 42 });
    for (let i = 0; i < 6; i += 1) {
      session.advanceDay();
    }
    await session.save('legacy-cup');

    const savePath = join(savesRoot, 'legacy-cup', 'save.json');
    const saved = JSON.parse(await readFile(savePath, 'utf8')) as Record<string, unknown>;
    delete saved.cup;
    await writeFile(savePath, `${JSON.stringify(saved)}\n`);

    const loaded = new GameSession(nodeFs);
    const snapshot = await loaded.loadWithRoots('legacy-cup', databaseRoot, savesRoot);
    expect(snapshot.cup?.round).toBe('sf');

    for (let i = snapshot.matchday; i < 10; i += 1) {
      loaded.advanceDay();
    }
    expect(loaded.getSnapshot().cup?.round).toBe('final');
  });

  it('persists managed club and cup through save/load', async () => {
    const savesRoot = await mkdtemp(join(tmpdir(), 'phoenix-saves-'));
    const session = new GameSession(nodeFs);
    await session.start({
      databaseRoot,
      savesRoot,
      seed: 42,
      managedClubId: 'manchester-rovers-en',
    });
    for (let i = 0; i < 5; i += 1) {
      session.advanceDay();
    }
    const before = session.getSnapshot();
    await session.save('cup-test');

    const loaded = new GameSession(nodeFs);
    const after = await loaded.loadWithRoots('cup-test', databaseRoot, savesRoot);

    expect(after.managedClubId).toBe(before.managedClubId);
    expect(after.cup).toEqual(before.cup);
  });

  it('buys a market player when balance allows', async () => {
    const session = new GameSession(nodeFs);
    const start = await session.start({
      databaseRoot,
      seed: 42,
      managedClubId: 'london-fc-en',
    });
    const original = start.market[0]!;
    const world = (session as unknown as { world: WorldDatabase }).world;
    world.players.set(original.id, { ...world.players.get(original.id)!, rating: 40 });

    const after = session.buyPlayer(original.id);

    expect(after.balance).toBe(INITIAL_BALANCE - transferFee(40));
    expect(after.squad.some((candidate) => candidate.id === original.id)).toBe(true);
    expect(after.market.some((candidate) => candidate.id === original.id)).toBe(false);
  });

  it('proposeBuy at fair accepts and debits balance', async () => {
    const session = new GameSession(nodeFs);
    const start = await session.start({ databaseRoot, seed: 42 });
    const player = start.market[0]!;
    const world = (session as unknown as { world: WorldDatabase }).world;
    world.players.set(player.id, { ...world.players.get(player.id)!, rating: 40 });

    const result = session.proposeBuy(player.id);

    expect(result.outcome).toBe('accepted');
    expect(result.snapshot.balance).toBe(start.balance - transferFee(40));
    expect(result.snapshot.squad.some((candidate) => candidate.id === player.id)).toBe(true);
  });

  it('proposeBuy below 0.85 rejects without balance change', async () => {
    const session = new GameSession(nodeFs);
    const start = await session.start({ databaseRoot, seed: 42 });
    const player = start.market[0]!;
    const world = (session as unknown as { world: WorldDatabase }).world;
    world.players.set(player.id, { ...world.players.get(player.id)!, rating: 40 });

    const result = session.proposeBuy(player.id, transferFee(40) * 0.8);

    expect(result.outcome).toBe('rejected');
    expect(result.snapshot.balance).toBe(start.balance);
    expect(result.snapshot.market.some((candidate) => candidate.id === player.id)).toBe(true);
  });

  it('proposeBuy in counter band stores countered offer', async () => {
    const session = new GameSession(nodeFs);
    const start = await session.start({ databaseRoot, seed: 42 });
    const player = start.market[0]!;
    const world = (session as unknown as { world: WorldDatabase }).world;
    world.players.set(player.id, { ...world.players.get(player.id)!, rating: 40 });
    const fair = transferFee(40);

    const result = session.proposeBuy(player.id, fair * 0.9);

    expect(result).toMatchObject({
      outcome: 'countered',
      offerId: 'offer-1',
    });
    expect(result.snapshot.pendingOffers).toContainEqual(
      expect.objectContaining({
        id: 'offer-1',
        kind: 'player_buy',
        playerId: player.id,
        status: 'countered',
      }),
    );
  });

  it('acceptCounter completes buy at counterAmount', async () => {
    const session = new GameSession(nodeFs);
    const start = await session.start({ databaseRoot, seed: 42 });
    const player = start.market[0]!;
    const world = (session as unknown as { world: WorldDatabase }).world;
    world.players.set(player.id, { ...world.players.get(player.id)!, rating: 40 });
    const proposed = session.proposeBuy(player.id, transferFee(40) * 0.9);

    const accepted = session.acceptCounter(proposed.offerId!);

    expect(accepted.outcome).toBe('accepted');
    expect(accepted.snapshot.balance).toBe(start.balance - proposed.counterAmount!);
    expect(accepted.snapshot.pendingOffers).toEqual([]);
    expect(accepted.snapshot.squad.some((candidate) => candidate.id === player.id)).toBe(true);
  });

  it('advanceDay expires pending offers then may add npc_bid', async () => {
    const session = new GameSession(nodeFs);
    const start = await session.start({ databaseRoot, seed: 42 });
    const player = start.market[0]!;
    const world = (session as unknown as { world: WorldDatabase }).world;
    world.players.set(player.id, { ...world.players.get(player.id)!, rating: 40 });
    const proposed = session.proposeBuy(player.id, transferFee(40) * 0.9);
    expect(proposed.snapshot.pendingOffers).toHaveLength(1);

    const advanced = session.advanceDay();

    expect(advanced.pendingOffers.every((offer) => offer.kind === 'npc_bid')).toBe(true);
    expect(advanced.pendingOffers.length).toBeLessThanOrEqual(2);
  });

  it('accepts an npc_bid, credits balance, and moves the player', async () => {
    const session = new GameSession(nodeFs);
    const start = await session.start({ databaseRoot, seed: 42 });
    const player = start.squad[0]!;
    const amount = transferFee(player.rating);
    const internal = session as unknown as {
      pendingOffers: Array<{
        id: string;
        kind: 'npc_bid';
        playerId: string;
        fromClubId: string;
        toClubId: string;
        amount: number;
        status: 'pending';
        createdMatchday: number;
      }>;
    };
    internal.pendingOffers = [{
      id: 'offer-7',
      kind: 'npc_bid',
      playerId: player.id,
      fromClubId: 'manchester-rovers-en',
      toClubId: start.managedClubId,
      amount,
      status: 'pending',
      createdMatchday: 0,
    }];

    const accepted = session.respondOffer('offer-7', 'accept');

    expect(accepted.outcome).toBe('accepted');
    expect(accepted.snapshot.balance).toBe(start.balance + amount);
    expect(accepted.snapshot.squad.some((candidate) => candidate.id === player.id)).toBe(false);
    expect(accepted.snapshot.pendingOffers).toEqual([]);
  });

  it('save/load restores pendingOffers', async () => {
    const savesRoot = await mkdtemp(join(tmpdir(), 'phoenix-saves-'));
    const session = new GameSession(nodeFs);
    const start = await session.start({ databaseRoot, savesRoot, seed: 42 });
    const player = start.market[0]!;
    const world = (session as unknown as { world: WorldDatabase }).world;
    world.players.set(player.id, { ...world.players.get(player.id)!, rating: 40 });
    const proposed = session.proposeBuy(player.id, transferFee(40) * 0.9);
    await session.save('offer-test');

    const loaded = new GameSession(nodeFs);
    const snapshot = await loaded.loadWithRoots('offer-test', databaseRoot, savesRoot);

    expect(snapshot.pendingOffers).toHaveLength(1);
    expect(snapshot.pendingOffers[0]).toMatchObject({
      id: proposed.offerId,
      kind: 'player_buy',
      playerId: player.id,
      amount: transferFee(40) * 0.9,
      counterAmount: transferFee(40),
      status: 'countered',
    });
  });

  it('rejects a buy when the balance is insufficient', async () => {
    const session = new GameSession(nodeFs);
    const start = await session.start({ databaseRoot, seed: 42 });
    const player = start.market.find(
      (candidate) => transferFee(candidate.rating) > INITIAL_BALANCE,
    );
    expect(player).toBeDefined();

    expect(() => session.buyPlayer(player!.id)).toThrow('Saldo insuficiente');
  });

  it('sells when the squad is larger than 11 and credits balance', async () => {
    const session = new GameSession(nodeFs);
    const start = await session.start({ databaseRoot, seed: 42 });
    expect(start.squad.length).toBeGreaterThan(11);
    const player = start.squad[0]!;

    const after = session.sellPlayer(player.id);

    expect(after.balance).toBe(start.balance + transferFee(player.rating));
    expect(after.squad.some((candidate) => candidate.id === player.id)).toBe(false);
    expect(after.market.some((candidate) => candidate.id === player.id)).toBe(true);
  });

  it('rejects a sale when the squad has 11 players or fewer', async () => {
    const session = new GameSession(nodeFs);
    const start = await session.start({ databaseRoot, seed: 42 });
    const world = (session as unknown as { world: WorldDatabase }).world;
    const managedPlayers = [...world.players.values()].filter(
      (player) => player.clubId === start.managedClubId,
    );
    for (const player of managedPlayers.slice(11)) {
      world.players.set(player.id, { ...player, clubId: 'manchester-rovers-en' });
    }

    expect(() => session.sellPlayer(managedPlayers[0]!.id)).toThrow(
      'Plantel mínimo de 11 jogadores',
    );
  });

  it('appends wages on advanceDay', async () => {
    const session = new GameSession(nodeFs);
    const start = await session.start({
      databaseRoot,
      seed: 42,
      managedClubId: 'london-fc-en',
    });

    const after = session.advanceDay();
    const wages = after.ledger.find((entry) => entry.type === 'wages');

    expect(wages).toMatchObject({
      id: 'md-1-wages',
      matchday: 1,
      amount: -squadWages(start.squad),
      balanceAfter: INITIAL_BALANCE - squadWages(start.squad),
    });
  });

  it('appends gate when managed is league home', async () => {
    const probe = new GameSession(nodeFs);
    await probe.start({ databaseRoot, seed: 42 });
    const homeClubId = (
      probe as unknown as {
        fixtures: Array<{ matchday: number; homeClubId: string }>;
      }
    ).fixtures.find((fixture) => fixture.matchday === 1)!.homeClubId;

    const session = new GameSession(nodeFs);
    await session.start({
      databaseRoot,
      seed: 42,
      managedClubId: homeClubId,
    });

    const after = session.advanceDay();
    const reputation = after.table.find((club) => club.clubId === homeClubId)!.reputation;

    expect(after.ledger).toContainEqual(
      expect.objectContaining({
        id: 'md-1-gate',
        matchday: 1,
        type: 'gate',
        amount: gateReceipt(reputation),
      }),
    );
  });

  it('does not append gate when managed is away only', async () => {
    const probe = new GameSession(nodeFs);
    await probe.start({ databaseRoot, seed: 42 });
    const awayClubId = (
      probe as unknown as {
        fixtures: Array<{ matchday: number; awayClubId: string }>;
      }
    ).fixtures.find((fixture) => fixture.matchday === 1)!.awayClubId;

    const session = new GameSession(nodeFs);
    await session.start({
      databaseRoot,
      seed: 42,
      managedClubId: awayClubId,
    });

    const after = session.advanceDay();

    expect(after.ledger.some((entry) => entry.type === 'gate')).toBe(false);
  });

  it('appends at most one gate when home in league and cup on the same day', async () => {
    const session = new GameSession(nodeFs);
    const start = await session.start({ databaseRoot, seed: 42 });
    const cupHomeClubId = start.cup!.ties[0]!.homeClubId;
    const internals = session as unknown as {
      fixtures: Array<{ matchday: number; homeClubId: string }>;
      managedClubId: string;
    };
    internals.managedClubId = cupHomeClubId;
    const leagueFixture = internals.fixtures.find((fixture) => fixture.matchday === 5)!;
    leagueFixture.homeClubId = cupHomeClubId;

    for (let index = 0; index < 5; index += 1) {
      session.advanceDay();
    }
    const gates = session
      .getSnapshot()
      .ledger.filter((entry) => entry.matchday === 5 && entry.type === 'gate');

    expect(gates).toHaveLength(1);
  });

  it('records transfer_out on buy and transfer_in on sell', async () => {
    const session = new GameSession(nodeFs);
    const start = await session.start({ databaseRoot, seed: 42 });
    const marketPlayer = start.market[0]!;
    const world = (session as unknown as { world: WorldDatabase }).world;
    world.players.set(marketPlayer.id, {
      ...world.players.get(marketPlayer.id)!,
      rating: 40,
    });

    const bought = session.buyPlayer(marketPlayer.id);
    const boughtEntry = bought.ledger.at(-1);
    expect(boughtEntry).toMatchObject({
      id: `xfer-${marketPlayer.id}-1`,
      matchday: 0,
      type: 'transfer_out',
      amount: -transferFee(40),
      note: marketPlayer.name,
    });

    const sold = session.sellPlayer(start.squad[0]!.id);
    expect(sold.ledger.at(-1)).toMatchObject({
      id: `xfer-${start.squad[0]!.id}-2`,
      matchday: 0,
      type: 'transfer_in',
      amount: transferFee(start.squad[0]!.rating),
      note: start.squad[0]!.name,
    });
  });

  it('allows negative balance after wages', async () => {
    const session = new GameSession(nodeFs);
    await session.start({
      databaseRoot,
      seed: 42,
      managedClubId: 'london-fc-en',
    });
    (session as unknown as { balance: number }).balance = 0;

    const after = session.advanceDay();

    expect(after.balance).toBeLessThan(0);
    expect(after.ledger.find((entry) => entry.type === 'wages')?.balanceAfter).toBeLessThan(0);
  });

  it('persists ledger across save/load', async () => {
    const savesRoot = await mkdtemp(join(tmpdir(), 'phoenix-saves-'));
    const session = new GameSession(nodeFs);
    await session.start({ databaseRoot, savesRoot, seed: 42 });
    session.advanceDay();
    const before = session.getSnapshot();
    await session.save('ledger-test');

    const loaded = new GameSession(nodeFs);
    const after = await loaded.loadWithRoots('ledger-test', databaseRoot, savesRoot);

    expect(after.ledger).toEqual(before.ledger);
  });

  it('persists balance and player club patches across save/load', async () => {
    const savesRoot = await mkdtemp(join(tmpdir(), 'phoenix-saves-'));
    const session = new GameSession(nodeFs);
    const start = await session.start({ databaseRoot, savesRoot, seed: 42 });
    const player = start.market[0]!;
    const world = (session as unknown as { world: WorldDatabase }).world;
    world.players.set(player.id, { ...world.players.get(player.id)!, rating: 40 });
    const beforeSave = session.buyPlayer(player.id);

    await session.save('transfer-test');

    const loaded = new GameSession(nodeFs);
    const afterLoad = await loaded.loadWithRoots('transfer-test', databaseRoot, savesRoot);
    expect(afterLoad.balance).toBe(beforeSave.balance);
    expect(afterLoad.squad.some((candidate) => candidate.id === player.id)).toBe(true);
  });
});
