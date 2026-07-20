import { app, BrowserWindow, ipcMain } from 'electron';
import { mkdir, readFile, readdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { GameSession, listMods, listSaves, type SaveFs } from '@phoenix/application';
import type { Slug } from '@phoenix/contracts';

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
    async (_evt, opts: { seed: number; modIds?: string[] }) => {
      return session.start({
        databaseRoot: databaseRoot(),
        savesRoot: savesRoot(),
        seed: opts.seed,
        modIds: opts.modIds,
      });
    },
  );

  ipcMain.handle('session:advanceDay', () => session.advanceDay());
  ipcMain.handle('session:getSnapshot', () => session.getSnapshot());
  ipcMain.handle('session:save', async (_evt, slotId: string, label?: string) => {
    return session.save(slotId as Slug, label);
  });
  ipcMain.handle('session:load', async (_evt, slotId: string) => {
    return session.loadWithRoots(slotId as Slug, databaseRoot(), savesRoot());
  });
  ipcMain.handle('session:listSaves', async () => listSaves(nodeFs, savesRoot()));
  ipcMain.handle('session:listMods', async () => listMods(nodeFs, databaseRoot()));

  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
