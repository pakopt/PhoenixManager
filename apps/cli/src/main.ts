import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { runSeason } from '@phoenix/simulation';

function parseSeed(argv: string[]): number {
  const idx = argv.indexOf('--seed');
  if (idx >= 0 && argv[idx + 1]) {
    const n = Number(argv[idx + 1]);
    if (!Number.isFinite(n)) {
      throw new Error(`Invalid --seed: ${argv[idx + 1]}`);
    }
    return Math.trunc(n);
  }
  return 42;
}

async function main(): Promise<void> {
  const seed = parseSeed(process.argv.slice(2));
  const here = dirname(fileURLToPath(import.meta.url));
  // apps/cli/dist (or src via tsc rootDir) -> repo root database/
  const databaseRoot = join(here, '../../../database');

  const report = await runSeason({ databaseRoot, seed });

  console.log(`Phoenix Premier — seed ${report.seed}`);
  console.log(`Matches: ${report.matchCount}  Duration: ${report.durationMs.toFixed(1)} ms`);
  console.log('');
  console.log(
    'Pos  Club                          P   W   D   L   GF  GA  GD  Pts',
  );
  report.table.forEach((row, i) => {
    const club = row.clubId.padEnd(28);
    const gd = row.goalsFor - row.goalsAgainst;
    console.log(
      `${String(i + 1).padStart(2)}   ${club} ${String(row.played).padStart(2)}  ${String(row.won).padStart(2)}  ${String(row.drawn).padStart(2)}  ${String(row.lost).padStart(2)}  ${String(row.goalsFor).padStart(3)} ${String(row.goalsAgainst).padStart(3)} ${String(gd).padStart(3)}  ${String(row.points).padStart(3)}`,
    );
  });
}

main().catch((err: unknown) => {
  console.error(err);
  process.exitCode = 1;
});
