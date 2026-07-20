import { mkdir, mkdtemp, readFile, readdir, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { loadWorld } from './loader.js';

const repoDatabaseRoot = fileURLToPath(new URL('../../../database', import.meta.url));

const fsOpts = {
  readFile: (p: string) => readFile(p, 'utf8'),
  readDir: (p: string) => readdir(p),
  joinPath: join,
};

describe('loadWorld', () => {
  it('loads core seed into maps and indexes', async () => {
    const world = await loadWorld({
      databaseRoot: repoDatabaseRoot,
      ...fsOpts,
    });

    expect(world.nations.get('england')?.name).toBe('England');
    expect(world.clubs.size).toBe(20);
    expect(world.players.size).toBe(400);
    expect(world.competitions.get('phoenix-premier-en')?.clubIds).toHaveLength(20);

    const londonPlayers = world.indexes.playersByClub.get('london-fc-en');
    expect(londonPlayers).toHaveLength(20);
    expect(world.players.get(londonPlayers![0]!)?.clubId).toBe('london-fc-en');
  });

  it('applies mod overrides by slug', async () => {
    const root = await mkdtemp(join(tmpdir(), 'phoenix-db-'));
    const core = join(root, 'core');
    await mkdir(join(core, 'nations'), { recursive: true });
    await mkdir(join(core, 'clubs'), { recursive: true });
    await mkdir(join(core, 'players'), { recursive: true });
    await mkdir(join(core, 'competitions'), { recursive: true });
    await mkdir(join(root, 'mods', 'rename-pack', 'clubs'), { recursive: true });

    await writeFile(
      join(core, 'manifest.json'),
      JSON.stringify({
        version: '0.1.0',
        name: 'test',
        packs: [{ id: 'core', path: 'core' }],
      }),
    );
    await writeFile(
      join(core, 'nations', 'nations-00001.json'),
      JSON.stringify({ entities: [{ id: 'england', name: 'England', code: 'EN' }] }),
    );
    await writeFile(
      join(core, 'clubs', 'clubs-00001.json'),
      JSON.stringify({
        entities: [{ id: 'london-fc-en', name: 'London FC', nationId: 'england', reputation: 50 }],
      }),
    );
    await writeFile(
      join(core, 'players', 'players-00001.json'),
      JSON.stringify({ entities: [] }),
    );
    await writeFile(
      join(core, 'competitions', 'competitions-00001.json'),
      JSON.stringify({ entities: [] }),
    );
    await writeFile(
      join(root, 'mods', 'rename-pack', 'clubs', 'clubs-00001.json'),
      JSON.stringify({
        entities: [
          { id: 'london-fc-en', name: 'Real London', nationId: 'england', reputation: 90 },
        ],
      }),
    );

    const world = await loadWorld({
      databaseRoot: root,
      modIds: ['rename-pack'],
      ...fsOpts,
    });

    expect(world.clubs.get('london-fc-en')?.name).toBe('Real London');
    expect(world.clubs.get('london-fc-en')?.reputation).toBe(90);
  });
});
