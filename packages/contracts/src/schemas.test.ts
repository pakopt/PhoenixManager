import { describe, expect, it } from 'vitest';
import { clubSchema, playerSchema, slugSchema } from './schemas.js';

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
