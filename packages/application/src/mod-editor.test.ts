import { mkdir, mkdtemp, readFile, readdir, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { beforeEach, describe, expect, it } from 'vitest';
import { loadWorld } from '@phoenix/database';
import {
  createMod,
  loadEditorWorld,
  removeModClub,
  removeModPlayer,
  updateModManifest,
  upsertModClub,
  upsertModPlayer,
} from './mod-editor.js';
import type { SaveFs } from './persistence.js';

const fs: SaveFs = {
  readFile: (path) => readFile(path, 'utf8'),
  writeFile,
  mkdir,
  readdir,
  joinPath: join,
};

describe('mod editor', () => {
  let databaseRoot: string;

  beforeEach(async () => {
    databaseRoot = await mkdtemp(join(tmpdir(), 'phoenix-mod-editor-'));
    const coreRoot = join(databaseRoot, 'core');
    await mkdir(join(coreRoot, 'nations'), { recursive: true });
    await mkdir(join(coreRoot, 'clubs'), { recursive: true });
    await mkdir(join(coreRoot, 'players'), { recursive: true });
    await mkdir(join(coreRoot, 'competitions'), { recursive: true });

    await writeFile(
      join(coreRoot, 'manifest.json'),
      JSON.stringify({
        version: '0.1.0',
        name: 'Test',
        packs: [{ id: 'core', path: 'core' }],
      }),
    );
    await writeFile(
      join(coreRoot, 'nations', 'nations-00001.json'),
      JSON.stringify({ entities: [{ id: 'england', name: 'England', code: 'ENG' }] }),
    );
    await writeFile(
      join(coreRoot, 'clubs', 'clubs-00001.json'),
      JSON.stringify({
        entities: [
          { id: 'london-fc', name: 'London FC', nationId: 'england', reputation: 50 },
        ],
      }),
    );
    await writeFile(
      join(coreRoot, 'players', 'players-00001.json'),
      JSON.stringify({
        entities: [
          {
            id: 'john-smith',
            name: 'John Smith',
            clubId: 'london-fc',
            nationId: 'england',
            position: 'MF',
            rating: 70,
            age: 24,
          },
        ],
      }),
    );
    await writeFile(
      join(coreRoot, 'competitions', 'competitions-00001.json'),
      JSON.stringify({ entities: [] }),
    );
  });

  it('createMod writes manifest', async () => {
    await expect(createMod(fs, databaseRoot, { id: 'my-mod', name: 'My Mod' })).resolves.toEqual({
      id: 'my-mod',
      name: 'My Mod',
    });

    const manifest = JSON.parse(
      await readFile(join(databaseRoot, 'mods', 'my-mod', 'manifest.json'), 'utf8'),
    ) as unknown;
    expect(manifest).toEqual({ id: 'my-mod', name: 'My Mod', version: '0.1.0' });
  });

  it('createMod throws if exists', async () => {
    await createMod(fs, databaseRoot, { id: 'my-mod', name: 'My Mod' });

    await expect(createMod(fs, databaseRoot, { id: 'my-mod', name: 'Again' })).rejects.toThrow(
      'Mod já existe',
    );
  });

  it('createMod rejects invalid slug', async () => {
    await expect(createMod(fs, databaseRoot, { id: 'Bad_Slug', name: 'Bad' })).rejects.toThrow(
      'Slug inválido',
    );
    await expect(createMod(fs, databaseRoot, { id: 'INVALID', name: 'Bad' })).rejects.toThrow(
      'Slug inválido',
    );
  });

  it('upsertModClub rejects invalid modId slug', async () => {
    await expect(
      upsertModClub(fs, databaseRoot, 'Bad_Slug', {
        id: 'london-fc',
        name: 'Real London',
        nationId: 'england',
        reputation: 90,
      }),
    ).rejects.toThrow('Slug inválido');
  });

  it('loadEditorWorld rejects missing mod', async () => {
    await expect(loadEditorWorld(fs, databaseRoot, 'missing-mod')).rejects.toThrow(
      'Mod não encontrado',
    );
  });

  it('upsertModClub rejects missing mod', async () => {
    await expect(
      upsertModClub(fs, databaseRoot, 'missing-mod', {
        id: 'london-fc',
        name: 'Real London',
        nationId: 'england',
        reputation: 90,
      }),
    ).rejects.toThrow('Mod não encontrado');
  });

  it('upsertModPlayer rejects missing mod', async () => {
    await expect(
      upsertModPlayer(fs, databaseRoot, 'missing-mod', {
        id: 'new-player',
        name: 'New Player',
        clubId: 'london-fc',
        nationId: 'england',
        position: 'FW',
        rating: 65,
        age: 20,
      }),
    ).rejects.toThrow('Mod não encontrado');
  });

  it('updateModManifest rejects missing mod', async () => {
    await expect(
      updateModManifest(fs, databaseRoot, 'missing-mod', { name: 'Renamed' }),
    ).rejects.toThrow('Mod não encontrado');
  });

  it('removeModPlayer rejects missing mod', async () => {
    await expect(removeModPlayer(fs, databaseRoot, 'missing-mod', 'john-smith')).rejects.toThrow(
      'Mod não encontrado',
    );
  });

  it('upsertModClub overrides core club in editor world as source mod', async () => {
    await createMod(fs, databaseRoot, { id: 'my-mod', name: 'My Mod' });

    const world = await upsertModClub(fs, databaseRoot, 'my-mod', {
      id: 'london-fc',
      name: 'Real London',
      nationId: 'england',
      reputation: 90,
    });

    expect(world.clubs).toContainEqual({
      id: 'london-fc',
      name: 'Real London',
      nationId: 'england',
      reputation: 90,
      source: 'mod',
    });
  });

  it('upsertModClub can create new club as source new', async () => {
    await createMod(fs, databaseRoot, { id: 'my-mod', name: 'My Mod' });

    const world = await upsertModClub(fs, databaseRoot, 'my-mod', {
      id: 'manchester-fc',
      name: 'Manchester FC',
      nationId: 'england',
      reputation: 60,
    });

    expect(world.clubs.find(({ id }) => id === 'manchester-fc')?.source).toBe('new');
  });

  it('removeModClub restores core-only source', async () => {
    await createMod(fs, databaseRoot, { id: 'my-mod', name: 'My Mod' });
    await upsertModClub(fs, databaseRoot, 'my-mod', {
      id: 'london-fc',
      name: 'Real London',
      nationId: 'england',
      reputation: 90,
    });

    const world = await removeModClub(fs, databaseRoot, 'my-mod', 'london-fc');

    expect(world.clubs.find(({ id }) => id === 'london-fc')).toMatchObject({
      name: 'London FC',
      source: 'core',
    });
  });

  it('upsertModPlayer rejects unknown clubId', async () => {
    await createMod(fs, databaseRoot, { id: 'my-mod', name: 'My Mod' });

    await expect(
      upsertModPlayer(fs, databaseRoot, 'my-mod', {
        id: 'new-player',
        name: 'New Player',
        clubId: 'unknown-club',
        nationId: 'england',
        position: 'FW',
        rating: 65,
        age: 20,
      }),
    ).rejects.toThrow('Clube de referência inválido');
  });

  it('loadWorld with modIds sees upserted club name', async () => {
    await createMod(fs, databaseRoot, { id: 'my-mod', name: 'My Mod' });
    await upsertModClub(fs, databaseRoot, 'my-mod', {
      id: 'london-fc',
      name: 'Real London',
      nationId: 'england',
      reputation: 90,
    });

    const world = await loadWorld({
      databaseRoot,
      modIds: ['my-mod'],
      readFile: fs.readFile,
      readDir: fs.readdir,
      joinPath: fs.joinPath,
    });

    expect(world.clubs.get('london-fc')?.name).toBe('Real London');
  });

  it('loadEditorWorld returns sorted core entities and nations', async () => {
    await createMod(fs, databaseRoot, { id: 'my-mod', name: 'My Mod' });

    const world = await loadEditorWorld(fs, databaseRoot, 'my-mod');

    expect(world.nationIds).toEqual(['england']);
    expect(world.clubs[0]?.source).toBe('core');
    expect(world.players[0]?.source).toBe('core');
  });

  it('updateModManifest updates name on disk', async () => {
    await createMod(fs, databaseRoot, { id: 'my-mod', name: 'My Mod' });

    const info = await updateModManifest(fs, databaseRoot, 'my-mod', {
      name: 'Renamed Mod',
      version: '0.2.0',
    });

    expect(info).toEqual({ id: 'my-mod', name: 'Renamed Mod' });
    const manifest = JSON.parse(
      await readFile(join(databaseRoot, 'mods', 'my-mod', 'manifest.json'), 'utf8'),
    ) as unknown;
    expect(manifest).toMatchObject({
      id: 'my-mod',
      name: 'Renamed Mod',
      version: '0.2.0',
    });
  });

  it('createMod throws on non-ENOENT manifest read errors', async () => {
    const manifestPath = join(databaseRoot, 'mods', 'my-mod', 'manifest.json');

    const ioErrorFs: SaveFs = {
      ...fs,
      readFile: async (path) => {
        if (path === manifestPath) {
          const error = new Error('EACCES: permission denied, open') as NodeJS.ErrnoException;
          error.code = 'EACCES';
          throw error;
        }
        return fs.readFile(path);
      },
    };

    await expect(
      createMod(ioErrorFs, databaseRoot, { id: 'my-mod', name: 'My Mod' }),
    ).rejects.toMatchObject({ code: 'EACCES' });
  });

  it('loadEditorWorld rethrows non-ENOENT manifest read errors', async () => {
    await createMod(fs, databaseRoot, { id: 'my-mod', name: 'My Mod' });
    const manifestPath = join(databaseRoot, 'mods', 'my-mod', 'manifest.json');

    const ioErrorFs: SaveFs = {
      ...fs,
      readFile: async (path) => {
        if (path === manifestPath) {
          const error = new Error('EACCES: permission denied, open') as NodeJS.ErrnoException;
          error.code = 'EACCES';
          throw error;
        }
        return fs.readFile(path);
      },
    };

    await expect(loadEditorWorld(ioErrorFs, databaseRoot, 'my-mod')).rejects.toMatchObject({
      code: 'EACCES',
    });
  });

  it('loadEditorWorld throws Shard inválido on non-ENOENT read errors', async () => {
    await createMod(fs, databaseRoot, { id: 'my-mod', name: 'My Mod' });
    const clubsPath = join(databaseRoot, 'core', 'clubs', 'clubs-00001.json');

    const ioErrorFs: SaveFs = {
      ...fs,
      readFile: async (path) => {
        if (path === clubsPath) {
          const error = new Error('EACCES: permission denied, open') as NodeJS.ErrnoException;
          error.code = 'EACCES';
          throw error;
        }
        return fs.readFile(path);
      },
    };

    await expect(loadEditorWorld(ioErrorFs, databaseRoot, 'my-mod')).rejects.toThrow(
      'Shard inválido',
    );
  });

  it('upsertModClub throws on malformed shard without wiping file', async () => {
    await createMod(fs, databaseRoot, { id: 'my-mod', name: 'My Mod' });
    const shardPath = join(databaseRoot, 'mods', 'my-mod', 'clubs', 'clubs-00001.json');
    const malformed = '{ "entities": [ { "id": "broken" } ]';
    await mkdir(join(databaseRoot, 'mods', 'my-mod', 'clubs'), { recursive: true });
    await writeFile(shardPath, malformed);

    await expect(
      upsertModClub(fs, databaseRoot, 'my-mod', {
        id: 'london-fc',
        name: 'Real London',
        nationId: 'england',
        reputation: 90,
      }),
    ).rejects.toThrow('Shard inválido');

    expect(await readFile(shardPath, 'utf8')).toBe(malformed);
  });

  it('removeModPlayer removes mod player and restores core source', async () => {
    await createMod(fs, databaseRoot, { id: 'my-mod', name: 'My Mod' });
    await upsertModPlayer(fs, databaseRoot, 'my-mod', {
      id: 'john-smith',
      name: 'John Smith Jr',
      clubId: 'london-fc',
      nationId: 'england',
      position: 'MF',
      rating: 75,
      age: 24,
    });

    const world = await removeModPlayer(fs, databaseRoot, 'my-mod', 'john-smith');

    expect(world.players.find(({ id }) => id === 'john-smith')).toMatchObject({
      name: 'John Smith',
      source: 'core',
    });
  });
});
