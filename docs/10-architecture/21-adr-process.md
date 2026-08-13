# ADR Process

Como registamos Architecture Decision Records (ADRs)?

## Sempre

1. Registar em [`DECISIONS.md`](../DECISIONS.md) com id **`ADR-NNNN`** (quatro dígitos, sequencial).
2. Usar o template abaixo (Status, Context, Decision, Consequences — mais Motivo/Alternativas/Resultado).
3. Criar ADR quando a mudança:
   - altera dependências entre packages / diamond;
   - introduz ou funde Event Buses;
   - muda formato de save / migração;
   - adiciona categoria de topo no Module Map;
   - cria package novo ou move engines entre packages;
   - altera ordem de [Platform Milestones](../90-roadmap/00-platform-milestones.md);
   - rejeita uma alternativa que alguém voltará a propor.
4. Actualizar Status (`Proposed` → `Accepted` → `Deprecated` / `Superseded by ADR-XXXX`).
5. Linkar o ADR a partir de docs afectados (monorepo, saves, buses, …).

## Nunca

1. Decidir “só no chat / PR” sem entrada no log para mudanças estruturais.
2. Reescrever história: marcar `Superseded` em vez de apagar ADRs antigos.
3. Usar ADR para bugs triviais ou typos de código.
4. Numerar fora de sequência ou reutilizar `ADR-NNNN`.
5. Aceitar package novo sem ADR **ou** sem [Package Contract](22-package-contracts.md) (ambos quando aplicável).

## Template

```markdown
## ADR-NNNN — Título curto

- **Status:** Proposed | Accepted | Deprecated | Superseded by ADR-XXXX
- **Data:** YYYY-MM-DD

### Context

Problema ou força que obriga a uma escolha.

### Decision

A escolha concreta (uma frase + detalhe necessário).

### Motivo

Porquê esta opção.

### Alternativas

- Opção A — porquê rejeitada
- Opção B — …

### Consequences

Efeitos em código, docs, milestones, migrações.

### Resultado

O que ficou adoptado / links para docs.
```

## IDs existentes

O log histórico em `DECISIONS.md` foi renumerado para `ADR-NNNN` (ordem cronológica aproximada, mais recentes com números altos). Novas entradas = próximo número livre.

## Failure modes

| Sintoma | Acção |
|---------|-------|
| Duas decisões contraditórias “aceites” | Marcar uma `Superseded`; alinhar docs |
| PR grande sem ADR | Bloquear merge até ADR-NNNN |
| ADR sem consequências | Completar antes de `Accepted` |

Ver também: [DECISIONS.md](../DECISIONS.md) · [20-coding-standards.md](20-coding-standards.md) · [Vol. 21](../bible/21-development-architecture.md)
