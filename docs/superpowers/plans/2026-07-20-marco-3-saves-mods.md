# Marco 3 Saves & Mods — Implementation Plan

> **For agentic workers:** Implement task-by-task; TDD where noted.

**Goal:** Persist GameSession as runtime deltas; load with mods; wire desktop Guardar/Carregar/mods.

**Architecture:** Zod save schema in contracts/application; fs under injectable savesRoot; example `database/mods/rename-pack`.

**Tech Stack:** Existing TS monorepo + Electron IPC.

---

### Task 1: Save schema + persistence helpers
### Task 2: GameSession save/load/list + listMods + tests
### Task 3: rename-pack mod example
### Task 4: Desktop IPC + UI
### Task 5: Docs (plano.md, plan mirror)
