import { app, BrowserWindow, ipcMain } from 'electron';
import { join } from 'node:path';
import { GameSession } from '@phoenix/application';

let mainWindow: BrowserWindow | null = null;
const session = new GameSession();

function databaseRoot(): string {
  // electron-vite: __dirname = apps/desktop/out/main → repo root database/
  return join(__dirname, '../../../../database');
}

function createWindow(): void {
  mainWindow = new BrowserWindow({
    width: 1100,
    height: 800,
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
  ipcMain.handle('session:start', async (_evt, seed: number) => {
    return session.start({ databaseRoot: databaseRoot(), seed });
  });

  ipcMain.handle('session:advanceDay', () => session.advanceDay());
  ipcMain.handle('session:getSnapshot', () => session.getSnapshot());

  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
