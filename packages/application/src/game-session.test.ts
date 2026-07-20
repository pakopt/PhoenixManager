import { mkdir, mkdtemp, readFile, readdir, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
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
});
