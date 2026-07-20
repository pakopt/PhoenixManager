# Task 2 — Marco 5a.2: Buy/Sell, Balance, Save/Load

Status: complete.

Implemented `GameSession.buyPlayer` and `sellPlayer`, including the specified Portuguese errors for insufficient balance and the 11-player squad minimum. Snapshots now expose the cash balance; saves persist it alongside player `clubId` patches and restore both while retaining the default balance for legacy saves.

Tests: added buy, insufficient-funds, sell, minimum-squad, and save/load coverage. Verified with `pnpm test`, `pnpm typecheck`, and `pnpm --filter @phoenix/application lint`.

Concern: none.
