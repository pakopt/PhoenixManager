import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { runSeason } from './run-season.js';

const databaseRoot = fileURLToPath(new URL('../../../database', import.meta.url));

describe('runSeason', () => {
  it('simulates a full 20-club season under 2s', async () => {
    const report = await runSeason({ databaseRoot, seed: 42 });
    expect(report.matchCount).toBe(380);
    expect(report.table).toHaveLength(20);
    expect(report.durationMs).toBeLessThan(2000);

    for (const row of report.table) {
      expect(row.played).toBe(38);
      expect(row.won + row.drawn + row.lost).toBe(38);
      expect(row.points).toBe(row.won * 3 + row.drawn);
    }

    const again = await runSeason({ databaseRoot, seed: 42 });
    expect(again.table).toEqual(report.table);
    expect(again.results).toEqual(report.results);
  });
});
