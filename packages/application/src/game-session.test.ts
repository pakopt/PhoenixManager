import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { GameSession } from './game-session.js';

const databaseRoot = fileURLToPath(new URL('../../../database', import.meta.url));

describe('GameSession', () => {
  it('starts with empty table and advances one matchday', async () => {
    const session = new GameSession();
    const start = await session.start({ databaseRoot, seed: 42 });
    expect(start.matchday).toBe(0);
    expect(start.finished).toBe(false);
    expect(start.table).toHaveLength(20);
    expect(start.table.every((r) => r.played === 0)).toBe(true);
    expect(start.lastResults).toHaveLength(0);

    const day1 = session.advanceDay();
    expect(day1.matchday).toBe(1);
    expect(day1.lastResults.length).toBe(10);
    expect(day1.table.some((r) => r.played > 0)).toBe(true);
  });

  it('finishes after all matchdays', async () => {
    const session = new GameSession();
    await session.start({ databaseRoot, seed: 7 });
    let snap = session.getSnapshot();
    while (!snap.finished) {
      snap = session.advanceDay();
    }
    expect(snap.matchday).toBe(38);
    expect(snap.table.every((r) => r.played === 38)).toBe(true);
    const again = session.advanceDay();
    expect(again.matchday).toBe(38);
  });
});
