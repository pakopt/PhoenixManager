Nunca usar any em TypeScript.
Todos os IDs são string no formato **`{type}:{ulid}`** (ex.: `player:01HZX4YB8J7N…`); o nome de display pode mudar, o `id` não — ver `20-database/12-ids.md`.
Nunca guardar referências diretas entre objetos; usar apenas IDs.
Planta canónica = **10 macro-módulos** — ver `10-architecture/01-overview.md`. Inventário fino = `10-architecture/19-module-map.md` (8 categorias; 4 níveis Applications → … → Shared). Módulo novo numa categoria do mapa; categoria de topo nova → ADR em `DECISIONS.md` (`ADR-NNNN`).

**Contratos de engenharia:** seguir [20-coding-standards.md](10-architecture/20-coding-standards.md), [21-adr-process.md](10-architecture/21-adr-process.md), [22-package-contracts.md](10-architecture/22-package-contracts.md), [23-error-handling.md](10-architecture/23-error-handling.md), [24-performance-guidelines.md](10-architecture/24-performance-guidelines.md), [00-testing-strategy.md](80-testing/00-testing-strategy.md), [07-integrity-security.md](60-save-system/07-integrity-security.md), [07-release-strategy.md](85-deployment/07-release-strategy.md). **Package novo exige Package Contract antes de código.** Layout alvo: [Vol. 21](bible/21-development-architecture.md). **Runtime não depende de Domain** — Application wires ambos ([05-dependencies.md](10-architecture/05-dependencies.md), ADR-0033). Ordem de construção: [00-platform-milestones.md](90-roadmap/00-platform-milestones.md) (Desktop = M4).

**Pilares de engenharia:** [Simulation Runtime](bible/pillars/simulation-runtime.md) · [Data Architecture](bible/pillars/data-architecture.md) · [Domain Architecture](bible/pillars/domain-architecture.md) (`bible/pillars/README.md`). Documentação nova ou satélite **referencia** estes pilares; **proibido** redefinir Tick, World State, World Changes, Event Buses, formato de ID `{type}:{ulid}`, Aggregate de vínculo, ou a organização em Bounded Contexts — só link ao pilar e depois ao volume/pasta oficial.

Domain Systems comunicam só via **Event Bus** / **Domain Events** (passados, imutáveis; sem lógica no evento) — `17-events/01-domain-events.md` (Volume 6).
A lógica de regras vive nos Domain Systems, organizados por **Bounded Context** (DDD) — ver Module Map. Domain Model = taxonomias Human / Organization / Place / Competition + Relationships-first (`15-domain/01-overview.md`). **Regra de vínculo (Bible inteira):** se duas entidades têm relação com **duração**, **condições** ou **obrigações** → essa relação é um **Aggregate próprio**, nunca um campo embutido (`clubId`, `players[]`, …) — ver `15-domain/01-overview.md` § Regra de Aggregate de vínculo. **Contract** = eixo (`15-domain/05-contract.md`) + Aggregate Root no World (`15-domain/06-contract-aggregate.md`); especializações Employment/Loan/Sponsorship/…; Status só via Lifecycle do Aggregate; proibido `isActive`. **Ubiquitous Language** = `15-domain/03-ubiquitous-language.md` (glossário **vivo**: conceito novo entra primeiro aí, só depois no código/docs). **Player** = ponto de união de BCs (Identity, Development, Health, Career, Social) — `15-domain/04-player.md`; proibido god-object. Specs: Volume 4 / `15-domain/`. **Simulação:** `16-processes/01-simulation-cycle.md` (Volume 5) — Simulation Tick; Scheduler; systems **propõem World Changes** (proibido mutar World State directamente); Tick = transação; aleatório só via **RandomService**; determinismo (DB + save + seed). **Eventos:** Volume 6 / `17-events/01-domain-events.md` — past-tense, imutáveis, sem lógica; Events ≠ World Changes. O tempo e a coordenação no Simulation Runtime; o estado no World State (após Commit); I/O na Infrastructure / Compiled Database.
A UI (Desktop Client) nunca contém regras de negócio.
A Application Layer não conhece regras de futebol — só use cases → Simulation Runtime.
Toda a validação passa por Zod.
Cada entidade tem um schema, um tipo TypeScript e um repositório.
Cada package tem testes unitários.
Nenhuma decisão técnica é tomada sem motivo, alternativas e consequências futuras (registar em `DECISIONS.md`).

Dados primeiro: lógica por atributos e estado, nunca por nome de clube ou jogador.
O domínio não conhece países reais nem futebol real — só entidades no World State.
Tudo editável via dados; nada de regras de domínio escondidas no código.
Modding é funcionalidade de primeira classe.
O save não contém a database completa — só deltas, histórico e estado de carreira.
Acções importantes: undo (especialmente no editor), autosave e validação antes de gravar.
Código simples primeiro; todas as decisões devem permitir optimização futura.
Escalabilidade permanente: dezenas de milhares de entidades e centenas de épocas sem mudar a arquitectura.
Compatibilidade de bases e saves entre versões; migração automática quando a quebra for inevitável.
A comunidade cria bases, packs, mods e cenários sem alterar o código do jogo.
A simulação é determinística e orientada por regras, não por scripts específicos.

Dependências: ver `10-architecture/05-dependencies.md` (diamond: Application → Domain e Runtime; **Runtime ↛ Domain**). Nunca UI→Database, Match→React, Finance→Electron.
Nunca aceder ao sistema de ficheiros fora da Infrastructure.
Nunca criar dependências circulares entre Domain Systems.
Um Domain System não conhece nem altera o estado interno de outro — só Event Bus e propostas de **World Changes** (Commit pelo Runtime). Proibido mutar World State directamente.
O Simulation Runtime não conhece React, Electron nem Steam.

Nomes: guarda-chuva = **Phoenix Platform**; produtos = ver Module Map (Manager, Database Editor, Scenario/Competition Editor, Compiler, Validator, CLI, Simulator, Benchmark, …). Não chamar ao projecto inteiro «Phoenix Manager».
