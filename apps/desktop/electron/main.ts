import { app, BrowserWindow, ipcMain } from 'electron';
import { mkdir, readFile, readdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import {
  createMod,
  GameSession,
  listMods,
  listSaves,
  loadEditorWorld,
  removeModClub,
  removeModPlayer,
  updateModManifest,
  upsertModClub,
  upsertModPlayer,
  type SaveFs,
} from '@phoenix/application';
import type { Club, Player, Slug } from '@phoenix/contracts';

let mainWindow: BrowserWindow | null = null;
const session = new GameSession();

const nodeFs: SaveFs = {
  readFile: (p) => readFile(p, 'utf8'),
  writeFile: (p, c) => writeFile(p, c, 'utf8'),
  mkdir: async (p, opts) => {
    await mkdir(p, opts);
  },
  readdir: (p) => readdir(p),
  joinPath: join,
};

function repoRoot(): string {
  return join(__dirname, '../../../..');
}

function databaseRoot(): string {
  return join(repoRoot(), 'database');
}

function savesRoot(): string {
  if (!app.isPackaged) {
    return join(repoRoot(), 'saves');
  }
  return join(app.getPath('userData'), 'saves');
}

function createWindow(): void {
  mainWindow = new BrowserWindow({
    width: 1100,
    height: 860,
    title: 'Phoenix Manager',
    webPreferences: {
      preload: join(__dirname, '../preload/index.mjs'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false,
    },
  });

  if (process.env.ELECTRON_RENDERER_URL) {
    void mainWindow.loadURL(process.env.ELECTRON_RENDERER_URL);
  } else {
    void mainWindow.loadFile(join(__dirname, '../renderer/index.html'));
  }
}

app.whenReady().then(() => {
  ipcMain.handle(
    'session:start',
    async (
      _evt,
      opts: { seed: number; modIds?: string[]; managedClubId?: string },
    ) => {
      return session.start({
        databaseRoot: databaseRoot(),
        savesRoot: savesRoot(),
        seed: opts.seed,
        modIds: opts.modIds,
        managedClubId: opts.managedClubId as Slug | undefined,
      });
    },
  );

  ipcMain.handle('session:advanceDay', () => session.advanceDay());
  ipcMain.handle('session:buyPlayer', (_evt, playerId: string) => {
    return session.buyPlayer(playerId as Slug);
  });
  ipcMain.handle('session:sellPlayer', (_evt, playerId: string) => {
    return session.sellPlayer(playerId as Slug);
  });
  ipcMain.handle(
    'session:proposeBuy',
    (_evt, playerId: string, amount?: number) =>
      session.proposeBuy(playerId as Slug, amount),
  );
  ipcMain.handle(
    'session:proposeSell',
    (_evt, playerId: string, amount?: number) =>
      session.proposeSell(playerId as Slug, amount),
  );
  ipcMain.handle(
    'session:respondOffer',
    (
      _evt,
      offerId: string,
      action: 'accept' | 'reject' | 'counter',
      counterAmount?: number,
    ) => session.respondOffer(offerId, action, counterAmount),
  );
  ipcMain.handle('session:acceptCounter', (_evt, offerId: string) => {
    return session.acceptCounter(offerId);
  });
  ipcMain.handle('session:declineOffer', (_evt, offerId: string) => {
    return session.declineOffer(offerId);
  });
  ipcMain.handle('session:getSnapshot', () => session.getSnapshot());
  ipcMain.handle('session:save', async (_evt, slotId: string, label?: string) => {
    return session.save(slotId as Slug, label);
  });
  ipcMain.handle('session:load', async (_evt, slotId: string) => {
    return session.loadWithRoots(slotId as Slug, databaseRoot(), savesRoot());
  });
  ipcMain.handle('session:listSaves', async () => listSaves(nodeFs, savesRoot()));
  ipcMain.handle('session:listMods', async () => listMods(nodeFs, databaseRoot()));

  ipcMain.handle('modEditor:create', (_evt, input: { id: string; name: string }) =>
    createMod(nodeFs, databaseRoot(), input),
  );
  ipcMain.handle('modEditor:loadWorld', (_evt, modId: string) =>
    loadEditorWorld(nodeFs, databaseRoot(), modId),
  );
  ipcMain.handle('modEditor:upsertClub', (_evt, modId: string, club: Club) =>
    upsertModClub(nodeFs, databaseRoot(), modId, club),
  );
  ipcMain.handle('modEditor:upsertPlayer', (_evt, modId: string, player: Player) =>
    upsertModPlayer(nodeFs, databaseRoot(), modId, player),
  );
  ipcMain.handle('modEditor:removeClub', (_evt, modId: string, clubId: string) =>
    removeModClub(nodeFs, databaseRoot(), modId, clubId as Slug),
  );
  ipcMain.handle('modEditor:removePlayer', (_evt, modId: string, playerId: string) =>
    removeModPlayer(nodeFs, databaseRoot(), modId, playerId as Slug),
  );
  ipcMain.handle(
    'modEditor:updateManifest',
    (_evt, modId: string, patch: { name: string; version?: string }) =>
      updateModManifest(nodeFs, databaseRoot(), modId, patch),
  );

  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
