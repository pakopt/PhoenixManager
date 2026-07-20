# Task 5 Report — GameSession managed club, cup, snapshot, save/load

**Status:** Done
**Date:** 2026-07-20

## Changes

- Added configurable `managedClubId` (default `london-fc-en`) and deterministic `phoenix-cup-en` knockout state to `GameSession`.
- League matchdays request an L1 highlight for the managed club; cup rounds run after matchdays 5, 10, and 15.
- Applied the existing reputation bump behavior to cup winners.
- Expanded snapshots with managed club, club labels, highlight timeline, and named cup ties plus next scheduled round.
- Save/load persists both fields.

## Original verification

```text
pnpm --filter @phoenix/application test
✓ 9 tests passed

pnpm --filter @phoenix/application typecheck
✓ passed

pnpm --filter @phoenix/application build
✓ passed
```

## Original commit

`feat(application): wire managed club L1 and knockout cup into session`

## Fix round

- Legacy saves without `cup` now rebuild the deterministic bracket from the saved league's `competition.clubIds` and reconcile it to the next eligible round: semi-finals from matchday 5, final from matchday 10, and completed from matchday 15.
- Managed-club cup ties retry Layer 1 until decisive, preserving the cup event timeline as the preferred highlight; other cup ties retry Layer 3 until decisive.
- Added coverage for decisive cup resolution, managed cup highlight precedence, and legacy cup regeneration.

### Verification

```text
pnpm --filter @phoenix/application test
✓ 12 tests passed

pnpm --filter @phoenix/application typecheck
✓ passed

git diff --check
✓ passed
```
