# F105 — Living HoF Commit disabled on Quo — Design

**Data:** 2026-08-11  
**Specs:** [F104 Quo button](2026-08-11-f104-hof-twin-status-quo-button-design.md) · [F103 preview switch](2026-08-11-f103-hof-twin-preview-switch-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Commit em Quo é no-op mas o botão continua clicável. World **v31**.

## Decisão

Slice approach **1** — sem bump (fica v31):

1. `disabled={busy || selected === "STATUS_QUO"}` no Commit
2. Preview Quo intacto · nav F105

## Fora de scope (F106+)

- Hide Commit · title hint · LLD-028

## Critérios de done

- [x] Disable · nav · docs · v31 (impl)
