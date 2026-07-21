import { z } from 'zod';

/** Lowercase slug IDs: letters, digits, hyphens. Never numeric-only IDs. */
export const slugSchema = z
  .string()
  .min(2)
  .max(80)
  .regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/, 'Invalid slug');

export type Slug = z.infer<typeof slugSchema>;

export const nationSchema = z.object({
  id: slugSchema,
  name: z.string().min(1),
  code: z.string().min(2).max(3),
});

export type Nation = z.infer<typeof nationSchema>;

export const clubSchema = z.object({
  id: slugSchema,
  name: z.string().min(1),
  nationId: slugSchema,
  reputation: z.number().min(1).max(100).default(50),
});

export type Club = z.infer<typeof clubSchema>;

export const playerSchema = z.object({
  id: slugSchema,
  name: z.string().min(1),
  clubId: slugSchema,
  nationId: slugSchema,
  position: z.enum(['GK', 'DF', 'MF', 'FW']),
  rating: z.number().min(1).max(100),
  age: z.number().int().min(15).max(45),
});

export type Player = z.infer<typeof playerSchema>;

export const competitionSchema = z.object({
  id: slugSchema,
  name: z.string().min(1),
  nationId: slugSchema,
  type: z.literal('league'),
  clubIds: z.array(slugSchema).min(2),
});

export type Competition = z.infer<typeof competitionSchema>;

export const matchResultSchema = z.object({
  homeClubId: slugSchema,
  awayClubId: slugSchema,
  homeGoals: z.number().int().min(0),
  awayGoals: z.number().int().min(0),
});

export type MatchResult = z.infer<typeof matchResultSchema>;

export const cupRoundSchema = z.enum(['qf', 'sf', 'final']);
export const cupTieSchema = z.object({
  homeClubId: slugSchema,
  awayClubId: slugSchema,
  result: matchResultSchema.optional(),
});
export const cupStateSchema = z.object({
  competitionId: slugSchema,
  round: cupRoundSchema,
  ties: z.array(cupTieSchema),
  completed: z.boolean(),
});
export type CupRound = z.infer<typeof cupRoundSchema>;
export type CupTie = z.infer<typeof cupTieSchema>;
export type CupState = z.infer<typeof cupStateSchema>;

export const fixtureSchema = z.object({
  id: slugSchema,
  competitionId: slugSchema,
  matchday: z.number().int().min(1),
  homeClubId: slugSchema,
  awayClubId: slugSchema,
});

export type Fixture = z.infer<typeof fixtureSchema>;

export const tableRowSchema = z.object({
  clubId: slugSchema,
  played: z.number().int().min(0),
  won: z.number().int().min(0),
  drawn: z.number().int().min(0),
  lost: z.number().int().min(0),
  goalsFor: z.number().int().min(0),
  goalsAgainst: z.number().int().min(0),
  points: z.number().int().min(0),
});

export type TableRow = z.infer<typeof tableRowSchema>;

export const seasonReportSchema = z.object({
  competitionId: slugSchema,
  seed: z.number().int(),
  durationMs: z.number().min(0),
  matchCount: z.number().int().min(0),
  table: z.array(tableRowSchema),
  results: z.array(matchResultSchema),
});

export type SeasonReport = z.infer<typeof seasonReportSchema>;

/** Entity-level patch: only changed fields vs baseline (core+mods). */
export const entityPatchSchema = z.object({
  id: slugSchema,
  changes: z.record(z.unknown()),
});

export type EntityPatch = z.infer<typeof entityPatchSchema>;

export const savePatchesSchema = z.object({
  clubs: z.array(entityPatchSchema).default([]),
  players: z.array(entityPatchSchema).default([]),
});

export type SavePatches = z.infer<typeof savePatchesSchema>;

export const ledgerTypeSchema = z.union([
  z.literal('wages'),
  z.literal('gate'),
  z.literal('transfer_in'),
  z.literal('transfer_out'),
]);

export type LedgerType = z.infer<typeof ledgerTypeSchema>;

export const ledgerEntrySchema = z.object({
  id: z.string().min(1),
  matchday: z.number().int().min(0),
  type: ledgerTypeSchema,
  amount: z.number().finite(),
  balanceAfter: z.number().finite(),
  note: z.string().optional(),
});

export type LedgerEntry = z.infer<typeof ledgerEntrySchema>;

export const offerKindSchema = z.union([
  z.literal('player_buy'),
  z.literal('player_sell'),
  z.literal('npc_bid'),
]);
export type OfferKind = z.infer<typeof offerKindSchema>;

export const offerStatusSchema = z.union([
  z.literal('pending'),
  z.literal('countered'),
]);
export type OfferStatus = z.infer<typeof offerStatusSchema>;

export const pendingOfferSchema = z.object({
  id: z.string().min(1),
  kind: offerKindSchema,
  playerId: slugSchema,
  fromClubId: slugSchema,
  toClubId: slugSchema,
  amount: z.number().finite(),
  status: offerStatusSchema,
  counterAmount: z.number().finite().optional(),
  createdMatchday: z.number().int().min(0),
});
export type PendingOffer = z.infer<typeof pendingOfferSchema>;

/** Career save: runtime deltas + optional entity patches (v2). */
export const saveGameSchema = z.object({
  version: z.union([z.literal(1), z.literal(2)]),
  savedAt: z.number().int().nonnegative(),
  slotId: slugSchema,
  label: z.string().min(1),
  seed: z.number().int(),
  modIds: z.array(z.string()),
  competitionId: slugSchema,
  matchday: z.number().int().min(0),
  table: z.array(tableRowSchema),
  lastResults: z.array(matchResultSchema),
  patches: savePatchesSchema.optional(),
  balance: z.number().finite().optional(),
  managedClubId: slugSchema.optional(),
  cup: cupStateSchema.optional(),
  ledger: z.array(ledgerEntrySchema).optional(),
  pendingOffers: z.array(pendingOfferSchema).optional(),
});

export type SaveGame = z.infer<typeof saveGameSchema>;

export const saveMetaSchema = z.object({
  slotId: slugSchema,
  label: z.string(),
  savedAt: z.number().int().nonnegative(),
  matchday: z.number().int().min(0),
  modIds: z.array(z.string()),
});

export type SaveMeta = z.infer<typeof saveMetaSchema>;

export const modInfoSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(1),
});

export type ModInfo = z.infer<typeof modInfoSchema>;
