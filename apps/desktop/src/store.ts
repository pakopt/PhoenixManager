import type { SessionSnapshot } from '@phoenix/application';
import { create } from 'zustand';

type SessionStore = {
  snapshot: SessionSnapshot | null;
  busy: boolean;
  error: string | null;
  start: (seed?: number) => Promise<void>;
  advanceDay: () => Promise<void>;
  reset: () => Promise<void>;
};

export const useSessionStore = create<SessionStore>((set, get) => ({
  snapshot: null,
  busy: false,
  error: null,

  start: async (seed = 42) => {
    set({ busy: true, error: null });
    try {
      const snapshot = await window.phoenix.session.start(seed);
      set({ snapshot, busy: false });
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

  reset: async () => {
    const seed = get().snapshot?.seed ?? 42;
    await get().start(seed);
  },
}));
