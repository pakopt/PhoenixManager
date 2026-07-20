import { describe, expect, it } from 'vitest';
import {
  clubSchema,
  cupStateSchema,
  playerSchema,
  saveGameSchema,
  slugSchema,
} from './schemas.js';

describe('slugSchema', () => {
  it('accepts valid slugs', () => {
    expect(slugSchema.parse('london-fc-en')).toBe('london-fc-en');
    expect(slugSchema.parse('hulk-br')).toBe('hulk-br');
  });

  it('rejects uppercase and spaces', () => {
    expect(() => slugSchema.parse('London FC')).toThrow();
    expect(() => slugSchema.parse('A')).toThrow();
  });
});

describe('entity schemas', () => {
  it('parses a minimal club and player', () => {
    const club = clubSchema.parse({
      id: 'london-fc-en',
      name: 'London FC',
      nationId: 'england',
    });
    expect(club.reputation).toBe(50);

    const player = playerSchema.parse({
      id: 'striker-01-london-fc-en',
      name: 'Alex Striker',
      clubId: 'london-fc-en',
      nationId: 'england',
      position: 'FW',
      rating: 72,
      age: 24,
    });
    expect(player.clubId).toBe('london-fc-en');
  });
});

describe('cupStateSchema', () => {
  it('parses cup state with optional tie results', () => {
    const cup = cupStateSchema.parse({
      competitionId: 'fa-cup-en',
      round: 'qf',
      ties: [
        {
          homeClubId: 'london-fc-en',
          awayClubId: 'manchester-fc-en',
          result: {
            homeClubId: 'london-fc-en',
            awayClubId: 'manchester-fc-en',
            homeGoals: 2,
            awayGoals: 1,
          },
        },
        { homeClubId: 'liverpool-fc-en', awayClubId: 'chelsea-fc-en' },
      ],
      completed: false,
    });
    expect(cup.round).toBe('qf');
    expect(cup.ties).toHaveLength(2);
  });
});

describe('saveGameSchema', () => {
  it('accepts v2 save with optional managedClubId and cup', () => {
    const save = saveGameSchema.parse({
      version: 2,
      savedAt: 1,
      slotId: 'slot-1',
      label: 'Career',
      seed: 42,
      modIds: [],
      competitionId: 'premier-league-en',
      matchday: 5,
      table: [],
      lastResults: [],
      managedClubId: 'london-fc-en',
      cup: {
        competitionId: 'fa-cup-en',
        round: 'sf',
        ties: [{ homeClubId: 'london-fc-en', awayClubId: 'manchester-fc-en' }],
        completed: false,
      },
    });
    expect(save.managedClubId).toBe('london-fc-en');
    expect(save.cup?.round).toBe('sf');
  });

  it('accepts v2 save without managedClubId or cup', () => {
    const save = saveGameSchema.parse({
      version: 2,
      savedAt: 1,
      slotId: 'slot-1',
      label: 'Career',
      seed: 42,
      modIds: [],
      competitionId: 'premier-league-en',
      matchday: 5,
      table: [],
      lastResults: [],
    });
    expect(save.managedClubId).toBeUndefined();
    expect(save.cup).toBeUndefined();
  });
});
