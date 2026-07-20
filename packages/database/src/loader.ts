import { z } from 'zod';
import {
  clubSchema,
  competitionSchema,
  nationSchema,
  playerSchema,
  type Club,
  type Competition,
  type Nation,
  type Player,
  type Slug,
} from '@phoenix/contracts';

export const manifestSchema = z.object({
  version: z.string(),
  name: z.string(),
  packs: z.array(
    z.object({
      id: z.string(),
      path: z.string(),
    }),
  ),
});

export type Manifest = z.infer<typeof manifestSchema>;

export type WorldDatabase = {
  nations: Map<Slug, Nation>;
  clubs: Map<Slug, Club>;
  players: Map<Slug, Player>;
  competitions: Map<Slug, Competition>;
  indexes: {
    playersByClub: Map<Slug, Slug[]>;
    clubsByNation: Map<Slug, Slug[]>;
  };
};

type EntityMaps = {
  nations: Map<Slug, Nation>;
  clubs: Map<Slug, Club>;
  players: Map<Slug, Player>;
  competitions: Map<Slug, Competition>;
};

const shardFileSchema = z.object({
  entities: z.array(z.unknown()),
});

function buildIndexes(maps: EntityMaps): WorldDatabase['indexes'] {
  const playersByClub = new Map<Slug, Slug[]>();
  for (const player of maps.players.values()) {
    const list = playersByClub.get(player.clubId) ?? [];
    list.push(player.id);
    playersByClub.set(player.clubId, list);
  }

  const clubsByNation = new Map<Slug, Slug[]>();
  for (const club of maps.clubs.values()) {
    const list = clubsByNation.get(club.nationId) ?? [];
    list.push(club.id);
    clubsByNation.set(club.nationId, list);
  }

  return { playersByClub, clubsByNation };
}

function emptyMaps(): EntityMaps {
  return {
    nations: new Map(),
    clubs: new Map(),
    players: new Map(),
    competitions: new Map(),
  };
}

export type LoadWorldOptions = {
  /** Absolute or relative path to database root (contains core/ and mods/). */
  databaseRoot: string;
  /** Ordered mod folder names under database/mods/. Later mods win on slug conflicts. */
  modIds?: string[];
  readFile: (absolutePath: string) => Promise<string>;
  readDir: (absolutePath: string) => Promise<string[]>;
  joinPath: (...parts: string[]) => string;
};

async function loadShardFiles(
  dir: string,
  options: LoadWorldOptions,
): Promise<unknown[]> {
  let names: string[];
  try {
    names = await options.readDir(dir);
  } catch {
    return [];
  }

  const jsonFiles = names.filter((n) => n.endsWith('.json')).sort();
  const entities: unknown[] = [];
  for (const file of jsonFiles) {
    const raw = await options.readFile(options.joinPath(dir, file));
    const parsed = shardFileSchema.parse(JSON.parse(raw) as unknown);
    entities.push(...parsed.entities);
  }
  return entities;
}

function mergeEntities(maps: EntityMaps, kind: keyof EntityMaps, entities: unknown[]): void {
  switch (kind) {
    case 'nations':
      for (const e of entities) {
        const nation = nationSchema.parse(e);
        maps.nations.set(nation.id, nation);
      }
      break;
    case 'clubs':
      for (const e of entities) {
        const club = clubSchema.parse(e);
        maps.clubs.set(club.id, club);
      }
      break;
    case 'players':
      for (const e of entities) {
        const player = playerSchema.parse(e);
        maps.players.set(player.id, player);
      }
      break;
    case 'competitions':
      for (const e of entities) {
        const competition = competitionSchema.parse(e);
        maps.competitions.set(competition.id, competition);
      }
      break;
    default: {
      const _exhaustive: never = kind;
      throw new Error(`Unknown entity kind: ${_exhaustive}`);
    }
  }
}

async function loadPackInto(
  maps: EntityMaps,
  packRoot: string,
  options: LoadWorldOptions,
): Promise<void> {
  const kinds: (keyof EntityMaps)[] = ['nations', 'clubs', 'players', 'competitions'];
  for (const kind of kinds) {
    const entities = await loadShardFiles(options.joinPath(packRoot, kind), options);
    mergeEntities(maps, kind, entities);
  }
}

export async function loadWorld(options: LoadWorldOptions): Promise<WorldDatabase> {
  const coreManifestPath = options.joinPath(options.databaseRoot, 'core', 'manifest.json');
  const manifestRaw = await options.readFile(coreManifestPath);
  const manifest = manifestSchema.parse(JSON.parse(manifestRaw) as unknown);

  const maps = emptyMaps();

  for (const pack of manifest.packs) {
    const packRoot = options.joinPath(options.databaseRoot, pack.path);
    await loadPackInto(maps, packRoot, options);
  }

  for (const modId of options.modIds ?? []) {
    const modRoot = options.joinPath(options.databaseRoot, 'mods', modId);
    await loadPackInto(maps, modRoot, options);
  }

  return {
    ...maps,
    indexes: buildIndexes(maps),
  };
}
