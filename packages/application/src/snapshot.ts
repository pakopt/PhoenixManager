import type { CupState, MatchResult, Slug, TableRow } from '@phoenix/contracts';
import type { MatchEvent } from '@phoenix/match-engine';

export type SnapshotTableRow = TableRow & { clubName: string; reputation: number };
export type SnapshotClub = { id: Slug; name: string };

export type SnapshotPlayer = {
  id: Slug;
  name: string;
  position: 'GK' | 'DF' | 'MF' | 'FW';
  rating: number;
  age: number;
};

export type SnapshotMarketPlayer = SnapshotPlayer & {
  clubId: Slug;
  clubName: string;
};

export type SnapshotResult = {
  homeClubId: Slug;
  awayClubId: Slug;
  homeName: string;
  awayName: string;
  homeGoals: number;
  awayGoals: number;
};

export type SnapshotHighlight = SnapshotResult & { events: MatchEvent[] };

export type SnapshotCupTie = {
  homeClubId: Slug;
  awayClubId: Slug;
  homeName: string;
  awayName: string;
  result?: SnapshotResult;
};

export type SnapshotCup = {
  competitionId: Slug;
  round: CupState['round'];
  ties: SnapshotCupTie[];
  completed: boolean;
  nextRoundAfterMatchday?: number;
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
  managedClubId: Slug;
  balance: number;
  clubs: SnapshotClub[];
  highlight?: SnapshotHighlight;
  cup?: SnapshotCup;
  squad: SnapshotPlayer[];
  market: SnapshotMarketPlayer[];
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
