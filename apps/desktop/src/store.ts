import type { SessionSnapshot } from '@phoenix/application';
import type { ModInfo, SaveMeta } from '@phoenix/contracts';
import { create } from 'zustand';

type SessionStore = {
  snapshot: SessionSnapshot | null;
  busy: boolean;
  error: string | null;
  saves: SaveMeta[];
  mods: ModInfo[];
  selectedMods: string[];
  selectedManagedClubId: string | undefined;
  start: (
    seed?: number,
    modIds?: string[],
    managedClubId?: string,
  ) => Promise<void>;
  advanceDay: () => Promise<void>;
  save: (label?: string) => Promise<void>;
  load: (slotId: string) => Promise<void>;
  refreshLists: () => Promise<void>;
  toggleMod: (id: string) => void;
};

function slugifyLabel(label: string): string {
  return label
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 40) || 'career';
}

export const useSessionStore = create<SessionStore>((set, get) => ({
  snapshot: null,
  busy: false,
  error: null,
  saves: [],
  mods: [],
  selectedMods: [],
  selectedManagedClubId: undefined,

  refreshLists: async () => {
    try {
      const [saves, mods] = await Promise.all([
        window.phoenix.session.listSaves(),
        window.phoenix.session.listMods(),
      ]);
      set({ saves, mods });
    } catch {
      // lists optional at boot
    }
  },

  toggleMod: (id) => {
    const selected = get().selectedMods;
    set({
      selectedMods: selected.includes(id)
        ? selected.filter((m) => m !== id)
        : [...selected, id],
    });
  },

  start: async (seed = 42, modIds, managedClubId) => {
    set({ busy: true, error: null });
    try {
      const mods = modIds ?? get().selectedMods;
      const selectedClubId = managedClubId ?? get().selectedManagedClubId;
      const snapshot = await window.phoenix.session.start({
        seed,
        modIds: mods,
        managedClubId: selectedClubId,
      });
      set({
        snapshot,
        busy: false,
        selectedManagedClubId: snapshot.managedClubId,
      });
      await get().refreshLists();
    } catch (err) {
      set({
        busy: false,
        error: err instanceof Error ? err.message : 'Failed to start session',
      });
    }
  },

  advanceDay: async () => {
    if (get().busy) return;
    set({ busy: true, error: null });
    try {
      const snapshot = await window.phoenix.session.advanceDay();
      set({ snapshot, busy: false });
    } catch (err) {
      set({
        busy: false,
        error: err instanceof Error ? err.message : 'Failed to advance',
      });
    }
  },

  save: async (label) => {
    const snap = get().snapshot;
    if (!snap || get().busy) return;
    set({ busy: true, error: null });
    try {
      const name = label ?? `Jornada ${snap.matchday}`;
      const slotId = slugifyLabel(`${name}-${snap.seed}`);
      await window.phoenix.session.save(slotId, name);
      set({ busy: false });
      await get().refreshLists();
    } catch (err) {
      set({
        busy: false,
        error: err instanceof Error ? err.message : 'Failed to save',
      });
    }
  },

  load: async (slotId) => {
    set({ busy: true, error: null });
    try {
      const snapshot = await window.phoenix.session.load(slotId);
      set({
        snapshot,
        busy: false,
        selectedMods: snapshot.modIds,
        selectedManagedClubId: snapshot.managedClubId,
      });
      await get().refreshLists();
    } catch (err) {
      set({
        busy: false,
        error: err instanceof Error ? err.message : 'Failed to load',
      });
    }
  },
}));
