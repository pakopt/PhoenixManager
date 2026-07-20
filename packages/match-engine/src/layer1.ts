import type { MatchResult, Slug } from '@phoenix/contracts';
import type { Rng } from '@phoenix/shared';

export type Layer1Input = {
  homeClubId: Slug;
  awayClubId: Slug;
  homeStrength: number;
  awayStrength: number;
  rng: Rng;
};

export type MatchEvent = {
  minute: number;
  type: 'chance' | 'goal';
  clubId: Slug;
  text: string;
};

export type DetailedMatch = {
  result: MatchResult;
  events: MatchEvent[];
};

function lambdas(homeStrength: number, awayStrength: number): { home: number; away: number } {
  const homeAttack = homeStrength / 70;
  const awayAttack = awayStrength / 70;
  return {
    home: Math.max(0.2, 1.15 * homeAttack * (1.1 - awayAttack * 0.35) + 0.25),
    away: Math.max(0.2, 1.05 * awayAttack * (1.1 - homeAttack * 0.35)),
  };
}

function minuteP(lambda: number): number {
  return 1 - Math.exp(-lambda / 90);
}

function trimEvents(events: MatchEvent[], max = 12): MatchEvent[] {
  if (events.length <= max) return events;
  const goals = events.filter((e) => e.type === 'goal');
  const chances = events.filter((e) => e.type === 'chance');
  const room = Math.max(0, max - goals.length);
  return [...goals, ...chances.slice(0, room)].sort((a, b) => a.minute - b.minute);
}

export function simulateMatchDetailed(input: Layer1Input): DetailedMatch {
  const { home, away } = lambdas(input.homeStrength, input.awayStrength);
  const pHome = minuteP(home);
  const pAway = minuteP(away);
  const convert = 0.35;

  let homeGoals = 0;
  let awayGoals = 0;
  const raw: MatchEvent[] = [];

  for (let minute = 1; minute <= 90; minute += 1) {
    if (input.rng.next() < pHome) {
      if (input.rng.next() < convert) {
        homeGoals += 1;
        raw.push({
          minute,
          type: 'goal',
          clubId: input.homeClubId,
          text: `Golo! (${minute}')`,
        });
      } else {
        raw.push({
          minute,
          type: 'chance',
          clubId: input.homeClubId,
          text: `Oportunidade falhada (${minute}')`,
        });
      }
    }
    if (input.rng.next() < pAway) {
      if (input.rng.next() < convert) {
        awayGoals += 1;
        raw.push({
          minute,
          type: 'goal',
          clubId: input.awayClubId,
          text: `Golo! (${minute}')`,
        });
      } else {
        raw.push({
          minute,
          type: 'chance',
          clubId: input.awayClubId,
          text: `Oportunidade falhada (${minute}')`,
        });
      }
    }
  }

  return {
    result: {
      homeClubId: input.homeClubId,
      awayClubId: input.awayClubId,
      homeGoals,
      awayGoals,
    },
    events: trimEvents(raw),
  };
}
