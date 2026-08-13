Nunca usar any.

**Contratos de engenharia (obrigatório):** Coding Standards · ADR Process · Package Contracts · Error Handling · Performance · Testing Strategy · Save Integrity · Release Strategy — ver `10-architecture/20–24`, `80-testing/00-testing-strategy.md`, `60-save-system/07-integrity-security.md`, `85-deployment/07-release-strategy.md`. Package novo → Package Contract **antes** de código. Monorepo alvo / diamond: Vol. 21 + `03-monorepo.md` / `05-dependencies.md` (**Runtime ↛ Domain**). Milestones: `90-roadmap/00-platform-milestones.md` (Desktop = M4). ADRs: `DECISIONS.md` (`ADR-NNNN`).

Planta = **10 macro-módulos** (`01-overview.md`). Inventário = Module Map (`19-module-map.md`); dependências diamond + Module Map; módulo novo → categoria do mapa; categoria de topo → ADR. Internamente: **Phoenix Platform**; **Phoenix Manager** = só o jogo.

Pilares de engenharia (fonte de verdade): Simulation Runtime · Data Architecture · Domain Architecture — `docs/bible/pillars/`. Docs satélite referenciam pilares; não redefinem Tick, World State, World Changes, Event Buses, IDs, Aggregate de vínculo, nem BCs.

Regras nos Domain Systems (**Bounded Contexts**); Domain Model = Human/Organization/Place/Competition + Relationships-first; **vínculo com duração/condições/obrigações = Aggregate próprio** (nunca campo embutido); **Contract** = eixo + Aggregate no World (`05-contract.md`, `06-contract-aggregate.md`); Ubiquitous Language = glossário vivo; **Player** = união de BCs Identity/Development/Health/Career/Social (`15-domain/04-player.md`); Entity Spec = Vol 4; **Simulation Cycle** = Vol 5; **Domain Events** = Vol 6 (`17-events/01-domain-events.md`, `02-application-events.md`, `03-infrastructure-events.md`) — past-tense, imutáveis, sem lógica; só Domain Event Bus entre Domain Systems; Application/Infrastructure usam os seus próprios buses; Events ≠ World Changes. Coordenação no Simulation Runtime; estado no World State (só após Commit). UI sem lógica. Application sem regras de futebol.

Todos os IDs são string `{type}:{ulid}` (ver `20-database/12-ids.md`).

Todos os schemas usam Zod.

Todo package tem testes.

Nunca criar dependências circulares.

Preferir funções puras.

Usar composição em vez de herança.

Nunca aceder diretamente ao filesystem fora do package database / Infrastructure.

Nunca criar lógica na UI.

Cada entidade deve ter:

schema

type

repository

validators
