import {
  clubSchema,
  modInfoSchema,
  nationSchema,
  playerSchema,
  slugSchema,
  type Club,
  type ModInfo,
  type Player,
  type Slug,
} from '@phoenix/contracts';
import type { SaveFs } from './persistence.js';

const CLUBS_SHARD = 'clubs-00001.json';
const PLAYERS_SHARD = 'players-00001.json';
const NATIONS_SHARD = 'nations-00001.json';

export type EditorSource = 'core' | 'mod' | 'new';

export type EditorClub = Club & { source: EditorSource };
export type EditorPlayer = Player & { source: EditorSource };

export type EditorWorld = {
  modId: string;
  clubs: EditorClub[];
  players: EditorPlayer[];
  nationIds: Slug[];
};

function parseSlug(value: string): Slug {
  const result = slugSchema.safeParse(value);
  if (!result.success) {
    throw new Error('Slug inválido');
  }
  return result.data;
}

async function assertModExists(fs: SaveFs, modRoot: string): Promise<void> {
  try {
    await fs.readFile(fs.joinPath(modRoot, 'manifest.json'));
  } catch {
    throw new Error('Mod não encontrado');
  }
}

async function readShardEntities<T>(
  fs: SaveFs,
  filePath: string,
  parseOne: (raw: unknown) => T,
): Promise<T[]> {
  try {
    const raw = JSON.parse(await fs.readFile(filePath)) as unknown;
    const entities = (raw as { entities?: unknown }).entities;
    if (!Array.isArray(entities)) return [];
    return entities.map(parseOne);
  } catch {
    return [];
  }
}

async function writeShardEntities<T extends { id: string }>(
  fs: SaveFs,
  dir: string,
  fileName: string,
  entities: T[],
): Promise<void> {
  await fs.mkdir(dir, { recursive: true });
  const path = fs.joinPath(dir, fileName);
  await fs.writeFile(path, `${JSON.stringify({ entities }, null, 2)}\n`);
}

function sortedById<T extends { id: string }>(entities: Iterable<T>): T[] {
  return [...entities].sort((left, right) => left.id.localeCompare(right.id));
}

function mergeEditorEntities<T extends { id: string }>(
  coreEntities: T[],
  modEntities: T[],
): Array<T & { source: EditorSource }> {
  const coreIds = new Set(coreEntities.map(({ id }) => id));
  const merged = new Map<string, T & { source: EditorSource }>();

  for (const entity of coreEntities) {
    merged.set(entity.id, { ...entity, source: 'core' });
  }
  for (const entity of modEntities) {
    merged.set(entity.id, {
      ...entity,
      source: coreIds.has(entity.id) ? 'mod' : 'new',
    });
  }

  return sortedById(merged.values());
}

export async function createMod(
  fs: SaveFs,
  databaseRoot: string,
  input: { id: string; name: string },
): Promise<ModInfo> {
  const id = parseSlug(input.id);
  const info = modInfoSchema.parse({ id, name: input.name });
  const modRoot = fs.joinPath(databaseRoot, 'mods', id);

  try {
    await fs.readFile(fs.joinPath(modRoot, 'manifest.json'));
    throw new Error('Mod já existe');
  } catch (error) {
    if (error instanceof Error && error.message === 'Mod já existe') {
      throw error;
    }
  }

  await fs.mkdir(modRoot, { recursive: true });
  await fs.writeFile(
    fs.joinPath(modRoot, 'manifest.json'),
    `${JSON.stringify({ ...info, version: '0.1.0' }, null, 2)}\n`,
  );
  return info;
}

export async function updateModManifest(
  fs: SaveFs,
  databaseRoot: string,
  modId: string,
  patch: { name: string; version?: string },
): Promise<ModInfo> {
  const id = parseSlug(modId);
  const modRoot = fs.joinPath(databaseRoot, 'mods', id);
  await assertModExists(fs, modRoot);

  const manifestPath = fs.joinPath(modRoot, 'manifest.json');
  const raw = JSON.parse(await fs.readFile(manifestPath)) as unknown;
  const current =
    typeof raw === 'object' && raw !== null ? raw : { id, name: patch.name, version: '0.1.0' };
  const info = modInfoSchema.parse({ id, name: patch.name });
  const manifest = {
    ...current,
    ...info,
    ...(patch.version === undefined ? {} : { version: patch.version }),
  };
  await fs.writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);
  return info;
}

export async function loadEditorWorld(
  fs: SaveFs,
  databaseRoot: string,
  modId: string,
): Promise<EditorWorld> {
  const id = parseSlug(modId);
  const coreRoot = fs.joinPath(databaseRoot, 'core');
  const modRoot = fs.joinPath(databaseRoot, 'mods', id);
  await assertModExists(fs, modRoot);

  const [coreClubs, corePlayers, coreNations, modClubs, modPlayers] = await Promise.all([
    readShardEntities(fs, fs.joinPath(coreRoot, 'clubs', CLUBS_SHARD), (raw) =>
      clubSchema.parse(raw),
    ),
    readShardEntities(fs, fs.joinPath(coreRoot, 'players', PLAYERS_SHARD), (raw) =>
      playerSchema.parse(raw),
    ),
    readShardEntities(fs, fs.joinPath(coreRoot, 'nations', NATIONS_SHARD), (raw) =>
      nationSchema.parse(raw),
    ),
    readShardEntities(fs, fs.joinPath(modRoot, 'clubs', CLUBS_SHARD), (raw) =>
      clubSchema.parse(raw),
    ),
    readShardEntities(fs, fs.joinPath(modRoot, 'players', PLAYERS_SHARD), (raw) =>
      playerSchema.parse(raw),
    ),
  ]);

  return {
    modId: id,
    clubs: mergeEditorEntities(coreClubs, modClubs),
    players: mergeEditorEntities(corePlayers, modPlayers),
    nationIds: coreNations.map(({ id: nationId }) => nationId).sort(),
  };
}

export async function upsertModClub(
  fs: SaveFs,
  databaseRoot: string,
  modId: string,
  club: Club,
): Promise<EditorWorld> {
  const parsed = clubSchema.parse(club);
  const world = await loadEditorWorld(fs, databaseRoot, modId);
  if (!world.nationIds.includes(parsed.nationId)) {
    throw new Error('Nação de referência inválida');
  }

  const modRoot = fs.joinPath(databaseRoot, 'mods', world.modId);
  const dir = fs.joinPath(modRoot, 'clubs');
  const entities = await readShardEntities(fs, fs.joinPath(dir, CLUBS_SHARD), (raw) =>
    clubSchema.parse(raw),
  );
  const byId = new Map(entities.map((entity) => [entity.id, entity]));
  byId.set(parsed.id, parsed);
  await writeShardEntities(fs, dir, CLUBS_SHARD, sortedById(byId.values()));
  return await loadEditorWorld(fs, databaseRoot, world.modId);
}

export async function upsertModPlayer(
  fs: SaveFs,
  databaseRoot: string,
  modId: string,
  player: Player,
): Promise<EditorWorld> {
  const parsed = playerSchema.parse(player);
  const world = await loadEditorWorld(fs, databaseRoot, modId);
  if (!world.nationIds.includes(parsed.nationId)) {
    throw new Error('Nação de referência inválida');
  }
  if (!world.clubs.some(({ id }) => id === parsed.clubId)) {
    throw new Error('Clube de referência inválido');
  }

  const modRoot = fs.joinPath(databaseRoot, 'mods', world.modId);
  const dir = fs.joinPath(modRoot, 'players');
  const entities = await readShardEntities(fs, fs.joinPath(dir, PLAYERS_SHARD), (raw) =>
    playerSchema.parse(raw),
  );
  const byId = new Map(entities.map((entity) => [entity.id, entity]));
  byId.set(parsed.id, parsed);
  await writeShardEntities(fs, dir, PLAYERS_SHARD, sortedById(byId.values()));
  return await loadEditorWorld(fs, databaseRoot, world.modId);
}

export async function removeModClub(
  fs: SaveFs,
  databaseRoot: string,
  modId: string,
  clubId: Slug,
): Promise<EditorWorld> {
  const id = parseSlug(clubId);
  const world = await loadEditorWorld(fs, databaseRoot, modId);
  const dir = fs.joinPath(databaseRoot, 'mods', world.modId, 'clubs');
  const entities = await readShardEntities(fs, fs.joinPath(dir, CLUBS_SHARD), (raw) =>
    clubSchema.parse(raw),
  );
  if (!entities.some((entity) => entity.id === id)) {
    throw new Error('Entidade não existe neste mod');
  }

  await writeShardEntities(
    fs,
    dir,
    CLUBS_SHARD,
    entities.filter((entity) => entity.id !== id),
  );
  return await loadEditorWorld(fs, databaseRoot, world.modId);
}

export async function removeModPlayer(
  fs: SaveFs,
  databaseRoot: string,
  modId: string,
  playerId: Slug,
): Promise<EditorWorld> {
  const id = parseSlug(playerId);
  const world = await loadEditorWorld(fs, databaseRoot, modId);
  const dir = fs.joinPath(databaseRoot, 'mods', world.modId, 'players');
  const entities = await readShardEntities(fs, fs.joinPath(dir, PLAYERS_SHARD), (raw) =>
    playerSchema.parse(raw),
  );
  if (!entities.some((entity) => entity.id === id)) {
    throw new Error('Entidade não existe neste mod');
  }

  await writeShardEntities(
    fs,
    dir,
    PLAYERS_SHARD,
    entities.filter((entity) => entity.id !== id),
  );
  return await loadEditorWorld(fs, databaseRoot, world.modId);
}
