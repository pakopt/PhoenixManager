import type { MatchResult, Slug, TableRow } from '@phoenix/contracts';

export type SnapshotTableRow = TableRow & { clubName: string; reputation: number };

export type SnapshotResult = {
  homeClubId: Slug;
  awayClubId: Slug;
  homeName: string;
  awayName: string;
  homeGoals: number;
  awayGoals: number;
};

export type SessionSnapshot = {
  seed: number;
  competitionId: Slug;
  competitionName: string;
  matchday: number;
  totalMatchdays: number;
  finished: boolean;
  table: SnapshotTableRow[];
  lastResults: SnapshotResult[];
  modIds: string[];
};

export function toSnapshotResults(
  results: readonly MatchResult[],
  clubName: (id: Slug) => string,
): SnapshotResult[] {
  return results.map((r) => ({
    homeClubId: r.homeClubId,
    awayClubId: r.awayClubId,
    homeName: clubName(r.homeClubId),
    awayName: clubName(r.awayClubId),
    homeGoals: r.homeGoals,
    awayGoals: r.awayGoals,
  }));
}
