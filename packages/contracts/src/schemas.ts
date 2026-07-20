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

/** Stub shape for future entity-level patches (post Marco 3). */
export const entityPatchSchema = z.object({
  id: slugSchema,
  changes: z.record(z.unknown()),
});

export type EntityPatch = z.infer<typeof entityPatchSchema>;

/** Marco 3 career save: runtime deltas over core + mods. */
export const saveGameSchema = z.object({
  version: z.literal(1),
  savedAt: z.number().int().nonnegative(),
  slotId: slugSchema,
  label: z.string().min(1),
  seed: z.number().int(),
  modIds: z.array(z.string()),
  competitionId: slugSchema,
  matchday: z.number().int().min(0),
  table: z.array(tableRowSchema),
  lastResults: z.array(matchResultSchema),
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
