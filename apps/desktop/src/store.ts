import type { ProposeResult, SessionSnapshot } from '@phoenix/application';
import type { ModInfo, SaveMeta } from '@phoenix/contracts';
import { create } from 'zustand';

type SessionStore = {
  snapshot: SessionSnapshot | null;
  busy: boolean;
  error: string | null;
  lastOfferMessage: string | null;
  lastCounterOfferId: string | null;
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
  buyPlayer: (playerId: string) => Promise<void>;
  sellPlayer: (playerId: string) => Promise<void>;
  proposeBuy: (playerId: string, amount?: number) => Promise<void>;
  proposeSell: (playerId: string, amount?: number) => Promise<void>;
  respondOffer: (
    offerId: string,
    action: 'accept' | 'reject' | 'counter',
    counterAmount?: number,
  ) => Promise<void>;
  acceptCounter: (offerId: string) => Promise<void>;
  declineOffer: (offerId: string) => Promise<void>;
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

function offerMessage(result: ProposeResult): string {
  if (result.message) return result.message;
  switch (result.outcome) {
    case 'accepted':
      return 'Oferta aceite.';
    case 'rejected':
      return 'Oferta recusada.';
    case 'countered':
      return result.counterAmount === undefined
        ? 'Foi recebida uma contraproposta.'
        : `Contraproposta recebida: €${result.counterAmount.toLocaleString('pt-PT')}.`;
    default: {
      const exhaustive: never = result.outcome;
      return exhaustive;
    }
  }
}

export const useSessionStore = create<SessionStore>((set, get) => ({
  snapshot: null,
  busy: false,
  error: null,
  lastOfferMessage: null,
  lastCounterOfferId: null,
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
        lastOfferMessage: null,
        lastCounterOfferId: null,
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
      set({
        snapshot,
        busy: false,
        lastOfferMessage: null,
        lastCounterOfferId: null,
      });
    } catch (err) {
      set({
        busy: false,
        error: err instanceof Error ? err.message : 'Failed to advance',
      });
    }
  },

  buyPlayer: async (playerId) => {
    if (get().busy) return;
    set({ busy: true, error: null });
    try {
      const snapshot = await window.phoenix.session.buyPlayer(playerId);
      set({ snapshot, busy: false });
    } catch (err) {
      set({
        busy: false,
        error: err instanceof Error ? err.message : 'Failed to buy player',
      });
    }
  },

  sellPlayer: async (playerId) => {
    if (get().busy) return;
    set({ busy: true, error: null });
    try {
      const snapshot = await window.phoenix.session.sellPlayer(playerId);
      set({ snapshot, busy: false });
    } catch (err) {
      set({
        busy: false,
        error: err instanceof Error ? err.message : 'Failed to sell player',
      });
    }
  },

  proposeBuy: async (playerId, amount) => {
    if (get().busy) return;
    set({ busy: true, error: null });
    try {
      const result = await window.phoenix.session.proposeBuy(playerId, amount);
      set({
        snapshot: result.snapshot,
        busy: false,
        lastOfferMessage: offerMessage(result),
        lastCounterOfferId: result.outcome === 'countered' ? (result.offerId ?? null) : null,
      });
    } catch (err) {
      set({
        busy: false,
        error: err instanceof Error ? err.message : 'Falha ao propor compra',
      });
    }
  },

  proposeSell: async (playerId, amount) => {
    if (get().busy) return;
    set({ busy: true, error: null });
    try {
      const result = await window.phoenix.session.proposeSell(playerId, amount);
      set({
        snapshot: result.snapshot,
        busy: false,
        lastOfferMessage: offerMessage(result),
        lastCounterOfferId: result.outcome === 'countered' ? (result.offerId ?? null) : null,
      });
    } catch (err) {
      set({
        busy: false,
        error: err instanceof Error ? err.message : 'Falha ao propor venda',
      });
    }
  },

  respondOffer: async (offerId, action, counterAmount) => {
    if (get().busy) return;
    set({ busy: true, error: null });
    try {
      const result = await window.phoenix.session.respondOffer(
        offerId,
        action,
        counterAmount,
      );
      set({
        snapshot: result.snapshot,
        busy: false,
        lastOfferMessage: offerMessage(result),
        lastCounterOfferId: null,
      });
    } catch (err) {
      set({
        busy: false,
        error: err instanceof Error ? err.message : 'Falha ao responder à oferta',
      });
    }
  },

  acceptCounter: async (offerId) => {
    if (get().busy) return;
    set({ busy: true, error: null });
    try {
      const result = await window.phoenix.session.acceptCounter(offerId);
      set({
        snapshot: result.snapshot,
        busy: false,
        lastOfferMessage: offerMessage(result),
        lastCounterOfferId: null,
      });
    } catch (err) {
      set({
        busy: false,
        error: err instanceof Error ? err.message : 'Falha ao aceitar contraproposta',
      });
    }
  },

  declineOffer: async (offerId) => {
    if (get().busy) return;
    set({ busy: true, error: null });
    try {
      const result = await window.phoenix.session.declineOffer(offerId);
      set({
        snapshot: result.snapshot,
        busy: false,
        lastOfferMessage: offerMessage(result),
        lastCounterOfferId: null,
      });
    } catch (err) {
      set({
        busy: false,
        error: err instanceof Error ? err.message : 'Falha ao recusar contraproposta',
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
        lastOfferMessage: null,
        lastCounterOfferId: null,
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
