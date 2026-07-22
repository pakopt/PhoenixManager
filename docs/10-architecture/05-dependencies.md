# Dependency Rules (diamond)

Quem pode depender de quem no monorepo?

Canónico com [03-monorepo.md](03-monorepo.md) e [Vol. 21](../bible/21-development-architecture.md). Complementa (não substitui) o [Module Map](19-module-map.md) e [ARCHITECTURE_RULES.md](../ARCHITECTURE_RULES.md).

## Diamond (obrigatório)

```
Apps → Application → Domain
                  ↘ Runtime
Domain → Infrastructure → Shared
Runtime → Infrastructure → Shared
Domain → Shared
Runtime → Shared
Application → Infrastructure, Shared
```

### Sempre

| De | Para | Motivo |
|----|------|--------|
| Apps | Application, UI | Shell fino |
| Application | Domain **e** Runtime | Wiring / use cases |
| Domain | Shared; Infra via ports | Regras sem I/O cru |
| Runtime | Shared; Infra via ports | Tick genérico |
| Infrastructure | Shared | Loaders, saves, FS |
| Qualquer | Shared (tipos puros) | Contratos estáveis |

### Nunca

| De | Para | Motivo |
|----|------|--------|
| **Runtime** | **Domain** | Runtime genérico; futebol injectado pela Application |
| Domain | UI / React / Electron | Domínio ≠ apresentação |
| Domain | Domain (chamada directa) | Só Event Bus + World Changes |
| Runtime | React / Electron | Sem UI no motor |
| Match / Domain | React | Idem |
| UI | Database loaders / FS | Só via Application |
| Qualquer | Ciclo A→B→A | Proibido |
| Package novo | Qualquer | Sem [Package Contract](22-package-contracts.md) |

## Quatro níveis (visão lógica)

Compatível com o Module Map:

```
Applications → Application Services → (Domain | Runtime) → Infrastructure → Shared
```

A diferença face a docs antigos: **Runtime não está “acima” de Domain** — são irmãos wired pela Application.

## Exemplos

**Correcto (Application wires):**

```ts
// packages/application — permitido
import { advanceTick } from "@phoenix/runtime";
import { TransferSystem } from "@phoenix/domain"; // futuro

advanceTick({ systems: [TransferSystem], /* ... */ });
```

**Incorrecto:**

```ts
// packages/runtime — PROIBIDO
import { TransferSystem } from "@phoenix/domain";
```

**Incorrecto:**

```ts
// packages/domain — PROIBIDO
import { Button } from "@phoenix/ui";
```

## Enforcement

1. Code review + ADR se a regra for tensionada.
2. Futuro: `no-restricted-imports` / dependency-cruiser (pós-M1).
3. Violação = bug de arquitectura; corrigir antes de merge.

## Relação com Event Buses

Domain Systems só no **Domain Event Bus**. Application / Infrastructure nos seus buses. Bridging entre buses → ADR. Ver Volume 6 / `17-events/`.

Ver também: [03-monorepo.md](03-monorepo.md) · [22-package-contracts.md](22-package-contracts.md) · [ADR-0033](../DECISIONS.md#adr-0033)
