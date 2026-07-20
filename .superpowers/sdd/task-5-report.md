# Task 5 Report — GameSession managed club, cup, snapshot, save/load

**Status:** Done  
**Date:** 2026-07-20

## Changes

- Added configurable `managedClubId` (default `london-fc-en`) and the deterministic `phoenix-cup-en` knockout state to `GameSession`.
- League matchdays now request an L1 highlight for the managed club; cup rounds run after matchdays 5, 10, and 15.
- Cup managed fixtures use L1 when decisive; drawn cup ties re-run Layer 3 until decisive. Cup L1 takes precedence over a same-day league highlight.
- Applied the existing reputation bump behavior to cup winners.
- Expanded snapshots with managed club, club labels, highlight timeline, and named cup ties plus next scheduled round.
- Save/load persists both fields; loading a legacy save without a cup regenerates a deterministic bracket.
- Added application dependencies on competition, match engine, and shared RNG.

## Tests

```text
pnpm --filter @phoenix/application test
✓ 9 tests passed

pnpm --filter @phoenix/application typecheck
✓ passed

pnpm --filter @phoenix/application build
✓ passed
```

## Commit

`feat(application): wire managed club L1 and knockout cup into session`

## Concerns

- The application package consumes built declarations from `@phoenix/simulation`; build that workspace first when its exported types change.
# Task 5 Report: Documentação Microsoft Store (STORE/BETA/índices)

**Status:** DONE  
**Branch:** `feature/microsoft-store-msix`  
**Date:** 2026-07-18

## Summary

Task 5 concluída com updates de documentação e índices para Microsoft Store (MSIX), mantendo a identidade Partner Center exacta e alinhando o estado da spec para implementado em docs/scripts, com upload manual no Partner Center ainda pendente.

## Files updated

- `docs/STORE.md` — secção completa "Microsoft Store — upload passo a passo"
- `docs/BETA.md` — secção `## Windows (desktop)` conforme brief
- `docs/README.md` — índice actualizado para incluir Microsoft Store
- `docs/plano.md` — tabela "Lojas — Microsoft Store" (scripts ✅ / publicação ⏳)
- `docs/roadmap/master-roadmap-v1.md` — itens Microsoft Store no checklist MVP
- `README.md` — comandos MSIX adicionados e próximo passo actualizado
- `apps/phoenix_manager/MOBILE.md` — ponte para secção Microsoft Store em `docs/STORE.md`
- `scripts/phase_e_status.sh` — nova secção Microsoft Store (doctor + artefactos MSIX)
- `docs/superpowers/specs/2026-07-18-microsoft-store-design.md` — estado ajustado para implementação parcial e checklist docs/scripts marcado

## Verification

| Command | Result |
|---|---|
| `./scripts/msix_doctor.sh` | PASS (OK=8, WARN=1 em macOS por build Windows-only) |
| `./scripts/msix_partner_brief.sh >/dev/null` | PASS |
| `grep -n "Microsoft Store" docs/STORE.md docs/BETA.md docs/plano.md` | PASS (secções encontradas) |

## Notes / concerns

- Upload do package no Partner Center permanece **⏳** (fora do escopo deste task).
- Não foi executado smoke de Task 6 além da verificação pedida no Step 4.

## Follow-up (2026-07-18)

- `docs/STORE.md` — linha `PublisherDisplayName` na tabela Product identity passou a incluir alias MSIX `publisher_display_name`, alinhada com as restantes linhas da tabela.
