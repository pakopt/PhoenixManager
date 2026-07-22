# Versionamento de saves

Como versionamos saves e o que acontece quando a versão não bate certo?

## Canónico

- Campo obrigatório: **`schemaVersion`** (inteiro monotónico) no save.
- Opcional: `engineVersion` / build id para suporte.
- Regras de compatibilidade, corrupção e mods: **[07-integrity-security.md](07-integrity-security.md)**.
- Migrações passo-a-passo: **[04-migration.md](04-migration.md)**.
- Erros: `SAVE_VERSION` / `SAVE_CORRUPT` em [23-error-handling.md](../10-architecture/23-error-handling.md).

## Sempre

1. Incrementar `schemaVersion` quando o shape do save muda.
2. Fornecer migração `N → N+1` testada antes de release que escreve N+1.
3. Documentar breaking changes no release notes ([07-release-strategy.md](../85-deployment/07-release-strategy.md)).

## Nunca

1. Mudiar o schema sem bump de versão.
2. Carregar save com versão desconhecida sem caminho explícito (migrate ou erro).

Ver também: [Versioning (modding)](../70-modding/03-versioning.md) · [Database versioning](../20-database/17-database-versioning.md) · [Save files](01-save-files.md) · [Volume 16 — Save System](../bible/16-save-system.md)
