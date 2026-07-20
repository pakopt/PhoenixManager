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
        rng: createRng(candidate).fork(5 * 1_000_003).fork(0),
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
    expect(snapshot.lastResults).not.toContainEqual(
      expect.objectContaining({
        homeClubId: snapshot.highlight?.homeClubId,
        awayClubId: snapshot.highlight?.awayClubId,
      }),
    );
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
});
