# Error Handling

Como tratamos falhas na Phoenix Platform (save, DB, mods, contratos)?

Uma estratégia única: **falhar cedo, tipar o erro, não corromper estado, mensagem accionável**.

## Classificação

| Classe | Quando | Comportamento |
|--------|--------|---------------|
| `ValidationError` | Zod / invariante de input | Rejeitar operação; não mutar World/save |
| `IntegrityError` | Save/DB/mod inconsistente após parse | Abortar load; oferecer repair/migrate se seguro |
| `CompatibilityError` | Versão de save/mod/app incompatível | Bloquear; apontar migração ou upgrade |
| `ContractError` | Aggregate Contract / Package Contract violado | Rejeitar World Change ou publish |
| `DomainError` | Regra de negócio (ex. transferência ilegal) | Resultado de domínio; sem crash |
| `InfrastructureError` | FS, permissões, disco cheio | Retry limitado se transitório; senão surfacer |
| `InvariantError` | World State impossível após commit | Rollback do tick; log + fail hard em debug |

## Sempre

1. Validar com **Zod** na fronteira (save load, mod load, IPC, CLI args).
2. Distinguir **erro esperado** (Domain/Validation → resultado) de **excepção** (Integrity/Infrastructure).
3. Em simulação: falha ao aplicar World Change → **Reject/Rollback** do tick ([World Changes](../16-processes/02-world-changes.md)); não deixar World a meio.
4. Em load de save/mod: **all-or-nothing** — ou fica carregado e válido, ou erro claro.
5. Mensagens: o que falhou, qual recurso (path/id/versão), o que o utilizador pode fazer.
6. Logar `code` estável (`SAVE_CORRUPT`, `MOD_INCOMPATIBLE`, …) + contexto sem PII desnecessária.
7. UI/CLI traduz o `code`; não mostra stack ao jogador em release.

## Nunca

1. `catch (e) {}` vazio.
2. Gravar save por cima de ficheiro corrupto sem backup/rotação.
3. Continuar o tick após `InvariantError`.
4. Tratar mod em falta como “ok, ignore” sem política explícita de mods.
5. Expor caminhos internos / stacks em builds Stable.
6. Usar string livre sem `code` para erros que a UI trata.

## Save corrupto

**Detecção:** falha Zod; checksum/length mismatch; referências a IDs inexistentes na DB compilada; patches que violam schema.

**Acção:**

1. Não abrir carreira em modo “best effort” silencioso.
2. Devolver `IntegrityError` / `SAVE_CORRUPT`.
3. Se existir backup autosave → oferecer restauro ([07-integrity-security.md](../60-save-system/07-integrity-security.md)).
4. Nunca “reparar” inventando entidades em silêncio.

## Database inválida

**Detecção:** schema pack falha; IDs duplicados; refs quebradas no compile/validate.

**Acção:**

1. Compiler/Validator falha o build do pack (`ValidationError` / `IntegrityError`).
2. Runtime **não** arranca carreira sobre DB que falhou validação.
3. Editor mostra lista de issues (ver Volume 14 / validation docs).

## Mod incompatível

**Detecção:** `engineVersion` / `schemaVersion` fora do range; override que parte invariantes; conflito de prioridade irresolúvel.

**Acção:**

1. `CompatibilityError` / `MOD_INCOMPATIBLE`.
2. Bloquear apply; listar mods ofensores.
3. Não aplicar “parcialmente” um pack multi-ficheiro.

## Contract inconsistente (domínio)

**Detecção:** Aggregate Contract com status ilegal; obrigação sem party; tentativa de `isActive` flag; World Change que parte invariante.

**Acção:**

1. `ContractError` ou `DomainError` conforme camada.
2. Reject da World Change; Domain Event **não** é publicado a partir de estado inválido.
3. Testes de Aggregate cobrem o caso ([00-testing-strategy.md](../80-testing/00-testing-strategy.md)).

## Package / dependency contract

**Detecção:** import Runtime→Domain; UI a chamar Domain; API pública usada fora do contrato.

**Acção:**

1. Falha de review / CI (futuro dependency-cruiser).
2. Não contornar com `any` ou deep imports.

## Exemplos

```ts
export type PlatformErrorCode =
  | "SAVE_CORRUPT"
  | "SAVE_VERSION"
  | "DB_INVALID"
  | "MOD_INCOMPATIBLE"
  | "CONTRACT_INVARIANT"
  | "INFRA_IO";

export class PlatformError extends Error {
  constructor(
    readonly code: PlatformErrorCode,
    message: string,
    readonly details?: Record<string, string | number | boolean>
  ) {
    super(message);
    this.name = "PlatformError";
  }
}
```

```ts
// Load save — fail closed
const parsed = SaveSchema.safeParse(raw);
if (!parsed.success) {
  throw new PlatformError("SAVE_CORRUPT", "Save failed schema validation", {
    slot,
  });
}
```

## Failure modes (meta)

| Sintoma | Causa | Fix |
|---------|-------|-----|
| Carreira abre com plantel vazio | Load parcial | Fail closed |
| Tick avança com finanças negativas ilegais | Commit sem validação | Validar World Changes |
| Jogador vê stack Electron | Erro não mapeado | Mapear para `code` + UI |

Ver também: [07-integrity-security.md](../60-save-system/07-integrity-security.md) · [20-coding-standards.md](20-coding-standards.md) · [05-versioning.md](../60-save-system/05-versioning.md)
