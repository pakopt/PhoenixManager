import type { Club, EntityPatch, Slug } from '@phoenix/contracts';

function clampReputation(value: number): number {
  return Math.min(100, Math.max(1, value));
}

export function cloneClubs(clubs: Map<Slug, Club>): Map<Slug, Club> {
  return new Map([...clubs.entries()].map(([id, club]) => [id, { ...club }]));
}

export function diffClubs(
  baseline: Map<Slug, Club>,
  current: Map<Slug, Club>,
): EntityPatch[] {
  const patches: EntityPatch[] = [];
  for (const [id, club] of current) {
    const base = baseline.get(id);
    if (!base) continue;
    const changes: Record<string, unknown> = {};
    if (club.reputation !== base.reputation) {
      changes.reputation = club.reputation;
    }
    if (club.name !== base.name) {
      changes.name = club.name;
    }
    if (Object.keys(changes).length > 0) {
      patches.push({ id, changes });
    }
  }
  return patches;
}

export function applyClubPatches(
  clubs: Map<Slug, Club>,
  patches: readonly EntityPatch[],
): void {
  for (const patch of patches) {
    const club = clubs.get(patch.id);
    if (!club) continue;
    const next = { ...club };
    const { reputation, name } = patch.changes;
    if (typeof reputation === 'number') {
      next.reputation = clampReputation(reputation);
    }
    if (typeof name === 'string' && name.length > 0) {
      next.name = name;
    }
    clubs.set(patch.id, next);
  }
}

export function bumpClubReputation(clubs: Map<Slug, Club>, clubId: Slug, delta = 1): void {
  const club = clubs.get(clubId);
  if (!club) return;
  clubs.set(clubId, {
    ...club,
    reputation: clampReputation(club.reputation + delta),
  });
}
