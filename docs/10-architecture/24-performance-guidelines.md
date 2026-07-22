# Performance Guidelines

Quais são as regras de performance da simulação e dos read models?

Hub satélite: [Volume 17](../bible/17-performance.md). Detalhe operacional: pasta `80-testing/` (memory, cache, indexes, …).

## Sempre

1. Preferir **índices / registries / read models** a varrer colecções completas.
2. Medir hot paths com benchmarks/regression antes de “optimizar a olho”.
3. Manter Domain Systems **O(k)** no que tocam no tick (k = entidades relevantes), não O(N) no mundo inteiro por defeito.
4. Usar **RandomService** (seed) — determinismo > micro-optimizações opacas.
5. Documentar complexidade esperada em systems quentes (match day, transfer window).
6. Cache com invalidação explícita ligada a World Changes / eventos.

## Nunca

1. **Full-scan** `world.players` (ou clubs/contracts) quando existe índice ou registry por clube/competição/nação.
2. Carregar a database completa em memória “porque é mais fácil” sem lazy/partitions quando N cresce (dezenas de milhares).
3. Fazer I/O de disco **dentro** do Domain System no tick.
4. Alocar estruturas gigantes temporárias por tick sem pool/reuse em hot paths (quando profiling o exige).
5. Optimizar UI (React) no mesmo PR que muda o motor sem gates separados.
6. Quebrar determinismo por paralelismo sem contrato (ver parallel simulation docs).

## Registry e índices

| Precisas de… | Usa… | Não uses… |
|--------------|------|-----------|
| Jogadores de um clube | índice `byClub` / registry | `players.filter(p => p.clubId === …)` em todo o mundo |
| Contratos activos de uma party | índice do Aggregate / read model | scan global de contracts |
| Jogos do dia | calendário / fixture index | varrer todas as competições |
| Lookup por ID | map id→entity | find em array |

**Regra:** se um query aparece em >1 system ou >1× por tick, merece índice ou read model (Data Architecture pillar).

## Exemplo

**Mau:**

```ts
for (const player of Object.values(world.players)) {
  if (player.clubId === clubId) {
    // ...
  }
}
```

**Bom:**

```ts
const ids = indexes.playersByClub.get(clubId) ?? [];
for (const id of ids) {
  const player = world.players[id];
  // ...
}
```

## Budgets (orientação — ajustar com perf tests)

| Operação | Alvo inicial (dev) |
|----------|-------------------|
| Tick dia sem match massivo | &lt; 50ms (máquina de referência documentada) |
| Match L3 (resultado) | budget em [13-performance-tests.md](../80-testing/13-performance-tests.md) |
| Load save | falhar se &gt; threshold CI |

Números exactos vivem nos perf tests; este doc fixa a **disciplina**.

## Failure modes

| Sintoma | Causa | Fix |
|---------|-------|-----|
| Época CLI demora minutos | scans N² | índices + profiling |
| GC spikes | allocs por tick | reduzir copies; structural sharing |
| UI lag no advance | trabalho no main thread | mover sim para worker/processo; não “optimizar React” primeiro |

Ver também: [06-perf-indexes.md](../80-testing/06-perf-indexes.md) · [09-profiling.md](../80-testing/09-profiling.md) · [pillar Data](../bible/pillars/data-architecture.md)
