# Release Strategy

Como lançamos Alpha, Beta e Stable — e o que bloqueia Steam Early Access?

Milestones de produto/plataforma: [00-platform-milestones.md](../90-roadmap/00-platform-milestones.md).

## Canais

| Canal | Audiência | Critério de entrada |
|-------|-----------|---------------------|
| **Internal / Dev** | Equipa | Branch verde local; docs alinhados |
| **Alpha** | Testers fechados | M4+ jogável mínimo; saves migram ou avisam; crashes conhecidos listados |
| **Beta** | Testers alargados | Sem data loss conhecido; perf budgets mínimos; mods amostra OK |
| **Stable** | Loja / GA | Critérios EA ou 1.0; suporte a N−1 saves |
| **Steam Early Access** | Público Steam | Ver checklist abaixo |

## Sempre

1. Notas de release: mudanças de **save schema**, mods, e migrações.
2. Tag git + artefacto reproduzível (CI).
3. Smoke: new game → advance → save → load → advance.
4. Rollback plan: build anterior ainda instala e abre saves Alpha/Beta da mesma major schema se prometido.
5. Telemetry/crash opt-in e privacy ([06-telemetry.md](06-telemetry.md), PRIVACY).

## Nunca

1. Publicar breaking save sem migração ou aviso bloqueante.
2. Prometer “Stable” com data loss conhecido.
3. Ship Desktop (canal público) antes de M4 na [ordem de milestones](../90-roadmap/00-platform-milestones.md) como “plataforma completa”.
4. Hotfix de schema sem bump `schemaVersion`.

## Migrações e save compat

| Situação | Acção |
|----------|-------|
| schema N→N+1 | Migração automática no load; teste regression |
| App antiga + save novo | Mensagem “actualiza o jogo” |
| Mod quebra com build novo | Compat range no manifest; bloquear apply |

Detalhe: [07-integrity-security.md](../60-save-system/07-integrity-security.md).

## Steam Early Access — entry criteria

- [ ] Milestone **Content → Steam EA** atingido (pós Gameplay mínimo)
- [ ] Desktop Client (M4) estável o suficiente para sessão de carreira
- [ ] Save load/save fiável; corrupção tratada (fail closed + backup)
- [ ] Pelo menos um caminho de época / calendário compreensível
- [ ] Página Steam + build Steamworks pipe ([03-steam.md](03-steam.md))
- [ ] Política de updates (Alpha/Beta branch ou opt-in) comunicada
- [ ] Sem execução de código arbitrário via mods
- [ ] Known issues publicadas

## Failure modes

| Sintoma | Fix |
|---------|-----|
| Jogadores perdem carreiras | Parar rollout; hotfix migração; restaurar canal anterior |
| Crash no first-run | Bloquear promote Beta→EA |
| Perf injogável em DB grande | Perf gate + índices antes de EA |

Ver também: [Volume 19](../bible/19-deployment.md) · [04-auto-update.md](04-auto-update.md)
