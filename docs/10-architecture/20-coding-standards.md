# Coding Standards

Quais são as regras obrigatórias de código na Phoenix Platform?

Contrato accionável. Resumo curto de naming: [STYLE_GUIDE.md](../STYLE_GUIDE.md). Layout: [Vol. 21](../bible/21-development-architecture.md).

## Sempre

1. **TypeScript strict** — `strict: true`; sem `@ts-ignore` sem comentário ADR-worthy.
2. **Zod na fronteira** — validar inputs de ficheiros, IPC, mods, saves e APIs públicas de package.
3. **IDs** — só `string` no formato `{type}:{ulid}` ([12-ids.md](../20-database/12-ids.md)).
4. **Funções puras** no Domain e onde o determinismo importe; I/O só em Infrastructure / Application.
5. **Uma pergunta por ficheiro de docs**; código: um módulo = uma responsabilidade clara.
6. **Await** todas as promises; sem floating promises.
7. **Testes** no package que muda (gates: [00-testing-strategy.md](../80-testing/00-testing-strategy.md)).
8. **Package Contract** antes de criar package novo ([22-package-contracts.md](22-package-contracts.md)).
9. **Referenciar pilares** em docs de Runtime / Data / Domain — não redefinir Tick, World State, IDs, Buses, Aggregates.
10. **Erros tipados** segundo [23-error-handling.md](23-error-handling.md).

## Nunca

1. **`any`** — usar `unknown` + narrow, ou tipos gerados/Zod.
2. **Lógica de futebol na UI** (React/Electron).
3. **Application com regras profundas de futebol** — só use cases → Domain / Runtime.
4. **Mutar World State fora do Commit** do Runtime.
5. **Domain System A chamar Domain System B** — só Event Bus + propostas de World Changes.
6. **Runtime importar Domain** ([05-dependencies.md](05-dependencies.md)).
7. **FS / rede fora de Infrastructure** (excepto tooling CLI explícito).
8. **Referências a objectos** entre entidades — só IDs.
9. **God-objects** (Player “faz tudo”) — BCs e Aggregates.
10. **Full-scan** de colecções grandes quando existe índice / read model ([24-performance-guidelines.md](24-performance-guidelines.md)).
11. **Decisão técnica sem ADR** quando muda deps, buses, saves ou milestones ([21-adr-process.md](21-adr-process.md)).
12. **Criar `packages/*` sem contrato** e sem milestone que o autorize.

## Naming (código)

| Elemento | Forma | Exemplo |
|----------|-------|---------|
| Funções / métodos | camelCase | `advanceTick` |
| Classes / tipos / interfaces / enums | PascalCase | `TransferSystem` |
| Constantes | UPPER_SNAKE | `MAX_SQUAD_SIZE` |
| Ficheiros / pastas | kebab-case | `transfer-system.ts` |
| JSON / campos persistidos | camelCase | `homeClubId` |
| Packages | kebab-case | `match-engine` |

## Estrutura de um módulo de Domain

```
feature/
├── schema.ts          # Zod
├── types.ts           # inferidos do schema quando possível
├── policies.ts        # regras puras
├── handlers.ts        # reagem a Domain Events → World Changes
└── index.ts           # API pública mínima
```

## Exemplos

**Bom — validação na fronteira:**

```ts
const SaveFileSchema = z.object({
  version: z.number().int().positive(),
  seed: z.string().min(1),
  // ...
});

export function loadSave(raw: unknown): SaveFile {
  return SaveFileSchema.parse(raw);
}
```

**Mau — `any` e mutação directa:**

```ts
export function applyTransfer(world: any, payload: any) {
  world.players[payload.id].clubId = payload.clubId; // proibido
}
```

**Bom — proposta de mudança:**

```ts
return {
  type: "patch",
  entity: "player",
  id: playerId,
  patch: { /* campos */ },
};
```

## Failure modes

| Sintoma | Causa provável | Acção |
|---------|----------------|-------|
| UI “sabe” fee de transferência | Regra na UI | Mover para Domain; UI só mostra DTO |
| Testes flaky de simulação | `Date.now` / Math.random | RandomService + seed |
| Import circular Domain↔Runtime | Wiring errado | Application wires; ver diamond |
| Save carrega com dados lixo | Skip Zod | Falhar com erro de integridade |

## Checklist PR (código)

- [ ] Sem `any` novo
- [ ] Schemas Zod nas fronteiras tocadas
- [ ] Sem violação diamond / ARCHITECTURE_RULES
- [ ] Testes do gate correspondente
- [ ] Docs/ADR se a mudança for estrutural

Ver também: [STYLE_GUIDE.md](../STYLE_GUIDE.md) · [AGENTS.md](../AGENTS.md) · [ARCHITECTURE_RULES.md](../ARCHITECTURE_RULES.md)
