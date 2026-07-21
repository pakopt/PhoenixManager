import { contextBridge, ipcRenderer } from 'electron';
import type { EditorWorld, ProposeResult, SessionSnapshot } from '@phoenix/application';
import type { Club, ModInfo, Player, SaveMeta } from '@phoenix/contracts';

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
    proposeBuy: (playerId: string, amount?: number): Promise<ProposeResult> =>
      ipcRenderer.invoke('session:proposeBuy', playerId, amount),
    proposeSell: (playerId: string, amount?: number): Promise<ProposeResult> =>
      ipcRenderer.invoke('session:proposeSell', playerId, amount),
    respondOffer: (
      offerId: string,
      action: 'accept' | 'reject' | 'counter',
      counterAmount?: number,
    ): Promise<ProposeResult> =>
      ipcRenderer.invoke('session:respondOffer', offerId, action, counterAmount),
    acceptCounter: (offerId: string): Promise<ProposeResult> =>
      ipcRenderer.invoke('session:acceptCounter', offerId),
    declineOffer: (offerId: string): Promise<ProposeResult> =>
      ipcRenderer.invoke('session:declineOffer', offerId),
    getSnapshot: (): Promise<SessionSnapshot> => ipcRenderer.invoke('session:getSnapshot'),
    save: (slotId: string, label?: string): Promise<SaveMeta> =>
      ipcRenderer.invoke('session:save', slotId, label),
    load: (slotId: string): Promise<SessionSnapshot> =>
      ipcRenderer.invoke('session:load', slotId),
    listSaves: (): Promise<SaveMeta[]> => ipcRenderer.invoke('session:listSaves'),
    listMods: (): Promise<ModInfo[]> => ipcRenderer.invoke('session:listMods'),
  },
  modEditor: {
    create: (input: { id: string; name: string }): Promise<ModInfo> =>
      ipcRenderer.invoke('modEditor:create', input),
    loadWorld: (modId: string): Promise<EditorWorld> =>
      ipcRenderer.invoke('modEditor:loadWorld', modId),
    upsertClub: (modId: string, club: Club): Promise<EditorWorld> =>
      ipcRenderer.invoke('modEditor:upsertClub', modId, club),
    upsertPlayer: (modId: string, player: Player): Promise<EditorWorld> =>
      ipcRenderer.invoke('modEditor:upsertPlayer', modId, player),
    removeClub: (modId: string, clubId: string): Promise<EditorWorld> =>
      ipcRenderer.invoke('modEditor:removeClub', modId, clubId),
    removePlayer: (modId: string, playerId: string): Promise<EditorWorld> =>
      ipcRenderer.invoke('modEditor:removePlayer', modId, playerId),
    updateManifest: (
      modId: string,
      patch: { name: string; version?: string },
    ): Promise<ModInfo> => ipcRenderer.invoke('modEditor:updateManifest', modId, patch),
  },
};

contextBridge.exposeInMainWorld('phoenix', phoenix);

export type PhoenixApi = typeof phoenix;
