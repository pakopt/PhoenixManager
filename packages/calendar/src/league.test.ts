import { describe, expect, it } from 'vitest';
import { generateLeagueFixtures, totalMatchdays } from './league.js';

const clubs = Array.from({ length: 20 }, (_, i) => `club-${String(i + 1).padStart(2, '0')}`);

describe('generateLeagueFixtures', () => {
  it('builds 380 fixtures for 20 clubs', () => {
    const fixtures = generateLeagueFixtures('phoenix-premier-en', clubs);
    expect(fixtures).toHaveLength(20 * 19); // n*(n-1)
    expect(totalMatchdays(20)).toBe(38);
  });

  it('gives each club 38 games and no self-matches', () => {
    const fixtures = generateLeagueFixtures('phoenix-premier-en', clubs);
    const played = new Map<string, number>();
    for (const f of fixtures) {
      expect(f.homeClubId).not.toBe(f.awayClubId);
      played.set(f.homeClubId, (played.get(f.homeClubId) ?? 0) + 1);
      played.set(f.awayClubId, (played.get(f.awayClubId) ?? 0) + 1);
    }
    for (const club of clubs) {
      expect(played.get(club)).toBe(38);
    }
  });

  it('has unique home/away pairs across the season once each way', () => {
    const fixtures = generateLeagueFixtures('phoenix-premier-en', clubs);
    const pairs = new Set<string>();
    for (const f of fixtures) {
      const key = `${f.homeClubId}>${f.awayClubId}`;
      expect(pairs.has(key)).toBe(false);
      pairs.add(key);
    }
    expect(pairs.size).toBe(380);
  });
});
