# Data Architecture

## Pergunta

Como os dados vivem, são persistidos e consultados?

## Fronteiras

Este pilar **não** é:

- ciclo de Tick / Scheduler → [Simulation Runtime](simulation-runtime.md)
- regras de futebol / Aggregates de domínio → [Domain Architecture](domain-architecture.md)
- layouts de UI → Vol. 13

## Conceitos canónicos

| Conceito | Onde |
|----------|------|
| IDs `{type}:{ulid}` | [12-ids.md](../../20-database/12-ids.md) |
| Compiled Database | Vol. 9 · Platform Overview |
| Schemas / packs | [Vol. 9](../09-database.md) · `docs/20-database/` |
| Saves (deltas, não DB completa) | [Vol. 16](../16-save-system.md) · `docs/60-save-system/` |
| Mods / data packs | Vol. 15 · `20-database` / modding docs |
| Referências só por ID (nunca objectos) | `ARCHITECTURE_RULES.md` · Vol. 9 |

## Documentos oficiais

- [Volume 9 — Database](../09-database.md)
- [Volume 16 — Save System](../16-save-system.md)
- `docs/20-database/`
- `docs/60-save-system/` (se existir)

## Regra para satélites

Docs de schema de Club/Player, save format, compiler, etc. **ligam a este pilar**; não redefinem o formato de ID nem a filosofia Compiled DB vs save.
