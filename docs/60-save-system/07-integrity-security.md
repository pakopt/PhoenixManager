# Security & Save Integrity

Como validamos saves/mods, lidamos com corrupção e compatibilidade de versões?

Estratégia de erros: [23-error-handling.md](../10-architecture/23-error-handling.md). Versionamento: [05-versioning.md](05-versioning.md).

## Ameaças e objectivos

| Objectivo | Notas |
|-----------|-------|
| Integridade | Save/mod não corrompe World State |
| Compatibilidade | Versões antigas migram ou falham de forma clara |
| Confiança | Não executar código arbitrário de mods (dados, não scripts) |
| Privacidade | Telemetry/crash reports sem dados sensíveis indevidos |

Mods = **dados** (JSON/packs), não plugins nativos nesta arquitectura.

## Sempre

1. **Validar** save com Zod (+ regras de refs) antes de hidratar World.
2. **Validar** mods/packs no apply/compile; fail closed.
3. Manter `schemaVersion` / `engineVersion` no save e nos packs.
4. Migrações **explícitas** e testadas ([04-migration.md](04-migration.md)).
5. Autosave / backup rotativo antes de overwrite arriscado.
6. Paths de save/mod confinados ao sandbox da app (sem path traversal).
7. Tratar input de ficheiro como **untrusted**.

## Nunca

1. `eval` / carregar JS de mods.
2. Confiar em checksums só do cliente para “segurança forte” (integridade local ≠ anti-cheat online).
3. Abrir save parcialmente válido em silêncio.
4. Escrever save sem fsync/fallback quando a plataforma o exige para não corromper em crash.
5. Misturar cloud sync sem resolução de conflito documentada ([06-cloud-saves.md](06-cloud-saves.md)).

## Save corrupto

1. Detectar (schema, checksum se existir, refs).
2. `SAVE_CORRUPT` — não carregar.
3. Oferecer último autosave bom.
4. Opção export quarantine do ficheiro mau para suporte.

## Versão incompatível

1. Se `schemaVersion` &lt; actual → correr migrações em cadeia; se falhar → `SAVE_VERSION`.
2. Se `schemaVersion` &gt; actual → pedir upgrade da app (`CompatibilityError`).
3. Nunca migrar “para baixo” em silêncio.

## Mods

1. Manifest com versões compatíveis.
2. Overrides: prioridade documentada ([05-priority.md](../70-modding/05-priority.md)).
3. Mod que parte validação da DB → bloqueado.
4. Lista de mods activos gravada no save para reprodutibilidade.

## Security checklist (release)

- [ ] Sem execução de código de mods
- [ ] Validação Zod em todas as entradas de ficheiro
- [ ] Path traversal coberto por testes
- [ ] Mensagens de erro sem secrets
- [ ] Migrações cobertas por regression fixtures

Ver também: [01-save-files.md](01-save-files.md) · [02-patches.md](02-patches.md) · [Volume 16](../bible/16-save-system.md)
