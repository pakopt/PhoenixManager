import type { ModInfo, SaveGame, SaveMeta, Slug } from '@phoenix/contracts';
import { modInfoSchema, saveGameSchema, saveMetaSchema } from '@phoenix/contracts';

export type SaveFs = {
  readFile: (path: string) => Promise<string>;
  writeFile: (path: string, contents: string) => Promise<void>;
  mkdir: (path: string, opts?: { recursive?: boolean }) => Promise<void>;
  readdir: (path: string) => Promise<string[]>;
  joinPath: (...parts: string[]) => string;
};

export async function writeSave(
  fs: SaveFs,
  savesRoot: string,
  save: SaveGame,
): Promise<SaveMeta> {
  const parsed = saveGameSchema.parse(save);
  const dir = fs.joinPath(savesRoot, parsed.slotId);
  await fs.mkdir(dir, { recursive: true });
  await fs.writeFile(fs.joinPath(dir, 'save.json'), `${JSON.stringify(parsed, null, 2)}\n`);
  return saveMetaSchema.parse({
    slotId: parsed.slotId,
    label: parsed.label,
    savedAt: parsed.savedAt,
    matchday: parsed.matchday,
    modIds: parsed.modIds,
  });
}

export async function readSave(
  fs: SaveFs,
  savesRoot: string,
  slotId: Slug,
): Promise<SaveGame> {
  const raw = await fs.readFile(fs.joinPath(savesRoot, slotId, 'save.json'));
  return saveGameSchema.parse(JSON.parse(raw) as unknown);
}

export async function listSaves(fs: SaveFs, savesRoot: string): Promise<SaveMeta[]> {
  let entries: string[];
  try {
    entries = await fs.readdir(savesRoot);
  } catch {
    return [];
  }

  const metas: SaveMeta[] = [];
  for (const slotId of entries.sort()) {
    try {
      const save = await readSave(fs, savesRoot, slotId as Slug);
      metas.push(
        saveMetaSchema.parse({
          slotId: save.slotId,
          label: save.label,
          savedAt: save.savedAt,
          matchday: save.matchday,
          modIds: save.modIds,
        }),
      );
    } catch {
      // skip invalid slots
    }
  }
  return metas;
}

export async function listMods(fs: SaveFs, databaseRoot: string): Promise<ModInfo[]> {
  const modsRoot = fs.joinPath(databaseRoot, 'mods');
  let entries: string[];
  try {
    entries = await fs.readdir(modsRoot);
  } catch {
    return [];
  }

  const mods: ModInfo[] = [];
  for (const id of entries.sort()) {
    try {
      const raw = await fs.readFile(fs.joinPath(modsRoot, id, 'manifest.json'));
      const json = JSON.parse(raw) as unknown;
      const info = modInfoSchema.parse(
        typeof json === 'object' && json !== null && 'id' in json
          ? json
          : { id, name: id },
      );
      mods.push(info);
    } catch {
      // skip
    }
  }
  return mods;
}
