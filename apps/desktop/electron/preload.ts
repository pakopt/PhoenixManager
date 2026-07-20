import { contextBridge, ipcRenderer } from 'electron';
import type { SessionSnapshot } from '@phoenix/application';

const phoenix = {
  session: {
    start: (seed: number): Promise<SessionSnapshot> =>
      ipcRenderer.invoke('session:start', seed),
    advanceDay: (): Promise<SessionSnapshot> => ipcRenderer.invoke('session:advanceDay'),
    getSnapshot: (): Promise<SessionSnapshot> => ipcRenderer.invoke('session:getSnapshot'),
  },
};

contextBridge.exposeInMainWorld('phoenix', phoenix);

export type PhoenixApi = typeof phoenix;
