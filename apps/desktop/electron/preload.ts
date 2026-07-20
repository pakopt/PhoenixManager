import { contextBridge, ipcRenderer } from 'electron';
import type { SessionSnapshot } from '@phoenix/application';
import type { ModInfo, SaveMeta } from '@phoenix/contracts';

export type StartOpts = {
  seed: number;
  modIds?: string[];
  managedClubId?: string;
};

const phoenix = {
  session: {
    start: (opts: StartOpts): Promise<SessionSnapshot> =>
      ipcRenderer.invoke('session:start', opts),
    advanceDay: (): Promise<SessionSnapshot> => ipcRenderer.invoke('session:advanceDay'),
    buyPlayer: (playerId: string): Promise<SessionSnapshot> =>
      ipcRenderer.invoke('session:buyPlayer', playerId),
    sellPlayer: (playerId: string): Promise<SessionSnapshot> =>
      ipcRenderer.invoke('session:sellPlayer', playerId),
    getSnapshot: (): Promise<SessionSnapshot> => ipcRenderer.invoke('session:getSnapshot'),
    save: (slotId: string, label?: string): Promise<SaveMeta> =>
      ipcRenderer.invoke('session:save', slotId, label),
    load: (slotId: string): Promise<SessionSnapshot> =>
      ipcRenderer.invoke('session:load', slotId),
    listSaves: (): Promise<SaveMeta[]> => ipcRenderer.invoke('session:listSaves'),
    listMods: (): Promise<ModInfo[]> => ipcRenderer.invoke('session:listMods'),
  },
};

contextBridge.exposeInMainWorld('phoenix', phoenix);

export type PhoenixApi = typeof phoenix;
