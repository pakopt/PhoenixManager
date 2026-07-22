# Decisões técnicas (ADR log)

Processo: [21-adr-process.md](10-architecture/21-adr-process.md).

Cada entrada usa id **ADR-NNNN** e o template (Status, Context/Decisão, Motivo, Alternativas, Consequences/Resultado).

## Formato

Ver template em [21-adr-process.md](10-architecture/21-adr-process.md). Campos mínimos:

- Status
- Data
- Context / Decisão
- Motivo
- Alternativas
- Consequences
- Resultado

---
## ADR-0035 — Docs-first: contratos de engenharia antes de código Foundation

- **Status:** Accepted
- **Data:** 2026-07-22

### Context

Pressão para scaffold de `packages/domain|runtime|ui` sem contratos accionáveis (coding, ADR, errors, perf, testing, save integrity, release).

### Decision

**Docs-first:** completar os oito contratos de engenharia e Vol. 21 (monorepo docs-only) **antes** de qualquer linha de código de plataforma Foundation / packages alvo novos. Sem scaffold nesta entrega.

### Motivo

Evitar packages vazios sem fronteiras; agentes e humanos seguem contratos explícitos.

### Alternativas

- Scaffold imediato + docs stub (rejeitado: 1A no plano Critical Engineering Docs)
- Só código sem docs (rejeitado)

### Consequences

`pnpm-workspace` / `packages/*` inalterados quanto a packages novos; implementação M1 só após contratos.

### Resultado

Adoptado; ver `10-architecture/20–24`, `80-testing/00-testing-strategy.md`, `60-save-system/07-integrity-security.md`, `85-deployment/07-release-strategy.md`.

---

## ADR-0034 — Platform milestones (Desktop só no M4)

- **Status:** Accepted
- **Data:** 2026-07-22

### Context

O roadmap operacional misturava gameplay desktop cedo com fundações incompletas; faltava ordem canónica headless-first.

### Decision

Milestones de plataforma canónicos: Foundation → Runtime → Football Engine → **Desktop Client (M4)** → Database Editor → Gameplay → Content → Steam Early Access. Documentado em `90-roadmap/00-platform-milestones.md`. M1–M3 são headless/testáveis.

### Motivo

Validar simulação e domínio sem UI; Desktop consome Application estável.

### Alternativas

- Desktop no M1/M2 (rejeitado: UI sobre areia)
- Manter só marcos TS 1–5d como canónicos (rejeitado: legado operacional, não arquitectura)

### Consequences

`v0.1.md` e `plano.md` apontam para o doc de milestones; features de UI não bloqueiam M1–M3.

### Resultado

Adoptado.

---

## ADR-0033 — Runtime não depende de Domain (diamond)

- **Status:** Accepted
- **Data:** 2026-07-22

### Context

O grafo antigo implicava Runtime → Domain, acoplando o motor de tick às regras de futebol e impedindo Runtime reutilizável / testável sem Domain.

### Decision

**Runtime ↛ Domain.** Application depende de Domain **e** Runtime e faz o wiring (injecção de systems). Domain e Runtime são irmãos sobre Infrastructure/Shared — diamond documentado em `10-architecture/03-monorepo.md` e `05-dependencies.md`.

### Motivo

Separar ciclo de vida da simulação das regras de domínio; permitir M2 (Runtime) antes de M3 (Football Engine); alinhar a Vol. 21.

### Alternativas

- Runtime → Domain (rejeitado: acoplamento)
- Domain → Runtime (rejeitado: domínio conheceria o motor)
- Um único package `engine` (rejeitado: mistura responsabilidades)

### Consequences

Imports `runtime` → `domain` são bugs de arquitectura; Package Contracts e ESLint futuro devem bloquear; engines actuais migram incrementalmente.

### Resultado

Adoptado; Vol. 21 + monorepo docs (docs-only nesta fase).

---

## ADR-0032 — Domain Events canónicos: passado + imutáveis; nunca comandos; nunca alteram e…
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
**Domain Events** canónicos: passado + imutáveis; nunca comandos; nunca alteram entidades nem executam lógica (mutação = World Changes); Aggregate publica só os seus; Event Bus ordena/distribui; versioning; replay/log em debug; eventos descartados após o Tick em produção normal. Spec: `17-events/01-domain-events.md`.

### Motivo

Evitar cadeias de chamadas entre systems; desacoplar Media/Finance/AI; alinhar a Event Bus e World Changes.

### Alternativas

Chamadas directas Transfer→Finance; eventos mutáveis; lógica dentro do handler do evento sem World Changes.

### Consequences

UL, RULES, AGENTS, Overview e Simulation Cycle alinhados; inventário inicial de categorias (World/Contract/Player/Match/Club/Finance).

### Resultado

Adoptado.

---

## ADR-0031 — Inserir Volume 6 — Event-Driven Architecture na Architecture Bible. Software …
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
Inserir **Volume 6 — Event-Driven Architecture** na Architecture Bible. Software Architecture…Roadmap passam a Volumes **7…20** (20 volumes). Doc 01 = Domain Events (`17-events/01-domain-events.md`). O módulo Event Bus (Vol 2 / `07-event-system.md`) fica o transporte; Vol 6 é o contrato de eventos.

### Motivo

Separar «o que é um Domain Event» do transporte e dos processos (Vol 5) / packages (Vol 7).

### Alternativas

Expandir só `07-event-system.md`; meter Domain Events dentro de Core Business Processes.

### Consequences

Índices `bible/` renomeados; pasta `17-events/`; links Volume N actualizados.

### Resultado

Adoptado.

---

## ADR-0030 — World Changes é documento próprio (Volume 5 Doc 02): Unit of Work da simulaçã…
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
**World Changes** é documento próprio (Volume 5 Doc 02): Unit of Work da simulação. Domain Systems só propõem; Runtime valida e faz Commit (ou Reject/Rollback). Spec: `16-processes/02-world-changes.md`.

### Motivo

Decisão arquitectural central — merece spec dedicada além da secção no Simulation Cycle; clarifica validação, rollback, testes e caminho multiplayer/paralelo.

### Alternativas

Manter só como secção do Simulation Cycle; permitir mutação directa «por performance».

### Consequences

Índice Vol 5 Doc 02; UL aponta para a spec; sistemas e Runtime implementam o buffer de propostas.

### Resultado

Adoptado.

---

## ADR-0029 — Simulation Cycle canónico: (1) Simulation Tick como unidade genérica (default…
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
**Simulation Cycle** canónico: (1) **Simulation Tick** como unidade genérica (default carreira = 1 dia); (2) **World Changes** — systems propõem alterações, validação global, Commit (proibida mutação directa do World State); (3) **Simulation Scheduler** — ordem e frequência dos systems; (4) **RandomService** — único RNG; (5) Tick = transação lógica; (6) determinismo (DB + save + seed). Acções do utilizador fora do Advance Tick ainda passam por Runtime → World Changes.

### Motivo

Desacoplar escala temporal; validar conflitos antes do Commit; testes/reprodução; performance por frequência; alinhamento Event Bus.

### Alternativas

Só «Advance Day»; systems escrevem World directamente; `Math.random`; cada system decide «é hoje?».

### Consequences

`16-processes/01-simulation-cycle.md`; Overview / data-flow / Event Bus / Module Map / UL / RULES / AGENTS actualizados; implementação futura do Runtime segue este contrato.

### Resultado

Adoptado.

**Refinado:** World Changes elevado a Volume 5 Doc 02 — `16-processes/02-world-changes.md` (entrada seguinte).

---

## ADR-0028 — Inserir Volume 5 — Core Business Processes na Architecture Bible («Como o mun…
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
Inserir **Volume 5 — Core Business Processes** na Architecture Bible («Como o mundo funciona?»). Software Architecture…Roadmap passam a Volumes **6…19** (20 volumes). Doc 01 = Simulation Cycle (`16-processes/01-simulation-cycle.md`). Game Engine (Vol 9) = motores individuais; o ciclo orquestra-os.

### Motivo

Separar processos/orquestração de entidades (Vol 4), packages (Vol 6) e motores (Vol 9).

### Alternativas

Meter Simulation Cycle só em Game Engine / Platform Overview; não renumerar.

### Consequences

Índices `bible/` renomeados; links Volume N actualizados; pasta `16-processes/`.

### Resultado

Adoptado.

---

## ADR-0027 — Regra de Aggregate de vínculo (Architecture Bible inteira): sempre que duas e…
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
**Regra de Aggregate de vínculo** (Architecture Bible inteira): sempre que duas entidades tiverem uma relação com **duração**, **condições** ou **obrigações**, essa relação é um **Aggregate próprio** — nunca um campo simples dentro de outra entidade (`clubId`, `players[]`, `sponsors[]`, …). Canónica em `15-domain/01-overview.md`; reforçada em `ARCHITECTURE_RULES.md`, `AGENTS.md`, `STYLE_GUIDE.md`. Contract Aggregate é a instância principal; a regra aplica-se a qualquer vínculo futuro (incl. CompetitionEntry e afins).

### Motivo

Generaliza Relationships-first e o padrão Contract: evita posse embutida, histórico quebrado e casos especiais; docs e código futuros não reintroduzem campos-vínculo.

### Alternativas

Só aplicar a Contracts laborais; permitir IDs de posse «por simplicidade» em MVP.

### Consequences

Novas Entity Specs e schemas devem passar o teste duração/condições/obrigações antes de embutir campos; ADR de Relationships-first / Contract refinados por esta regra universal.

### Resultado

Adoptado.

---

## ADR-0026 — Contract Aggregate (Volume 4 Doc 02, `15-domain/06-contract-aggregate.md`) é …
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
**Contract Aggregate** (Volume 4 Doc 02, `15-domain/06-contract-aggregate.md`) é a spec canónica do Aggregate Root. O Contract **pertence ao World** (não ao Player nem ao Club). Componentes: Identity, Parties, Duration, Financial Terms, Clauses tipadas, Status (enum — proibido `isActive`), History append-only, Metadata, Lifecycle. Transições só via métodos do Aggregate (`sign()`, `activate()`, …). Especializações: EmploymentContract · LoanContract · SponsorshipContract · StadiumUsageAgreement · BroadcastAgreement · YouthScholarship. `CompetitionEntry` fora da família. Termos históricos PlayerContract/ManagerContract → **EmploymentContract**.

### Motivo

Uma base reutilizável para Player/Manager/Staff; empréstimos e patrocínios deixam de ser modelos ad hoc; uma porta de validação para o ciclo de vida; alinhamento com Contract como eixo.

### Alternativas

Manter PlayerContract/ManagerContract separados; mutar `status` a partir de TransferSystem; boolean `isActive`.

### Consequences

Vol 4 renumerado (Human 01, Contract 02, Player 03); eixo `05-contract.md`, Domain Model, UL, RULES/AGENTS, schemas e Module Map alinhados; ADRs de Contract 1ª classe / eixo refinados.

### Resultado

Adoptado.

---

## ADR-0025 — O Contract não é apenas uma entidade de primeira classe — é o eixo central de…
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
O **Contract** não é apenas uma entidade de primeira classe — é o **eixo central** de todo o domínio do jogo. Organiza Squad, Transfer, Finance laboral, free agents e Player Career. Spec: `15-domain/05-contract.md`. Família: PlayerContract · ManagerContract · Loan. Outras Relationships (Sponsorship, StadiumUsage, CompetitionEntry) permanecem de primeira classe; o Contract é o eixo do ciclo desportivo.

### Motivo

Relationships-first evita posse embutida, mas sem um eixo o modelo fica «tudo são relationships iguais». O jogo gira em torno de quem está contratado a quem.

### Alternativas

Tratar Contract como relationship paritária às outras; modelar o domínio centrado em Player ou Club.

### Consequences

Volume 3 Doc 03; UL, Domain Overview, RULES/AGENTS e Module Map (Finance) actualizados; ADR de «Contract de primeira classe» (2026-07-21) fica **refinado** (não invalidado) por esta elevação.

### Resultado

Adoptado.

**Refinado** (entrada seguinte): Contract Aggregate (Vol 4 Doc 02) unifica especializações e Lifecycle.

---

## ADR-0024 — Em vez de componentes (PhysicalState, MentalState, …) dentro do Player, o mod…
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
Em vez de componentes (PhysicalState, MentalState, …) **dentro** do Player, o modelo usa **Bounded Contexts independentes**: Player Identity · Player Development · Player Health · Player Career · Player Social. O Player é apenas o **ponto de união** (`player:{ulid}`); contextos integram-se por Event Bus e IDs.

### Motivo

Componentes no mesmo agregado ainda concentram o Player como centro. BCs autónomos evitam god-object, permitem evolução e testes isolados, e alinham-se ao Module Map.

### Alternativas

Manter só componentes no Aggregate Root Player; um único People Context monolítico.

### Consequences

`15-domain/04-player.md` e Module Map (People) actualizados; ADR de “componentes no Player” fica superseded nesta parte; Career referencia PlayerContract; Social referencia HumanRelationship.

### Resultado

Adoptado.

---

## ADR-0023 — Player (e outras parties) são Aggregate Roots magros compostos por componente…
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
**Player** (e outras parties) são Aggregate Roots **magros** compostos por **componentes** (Identity, Profile, FootballProfile, PhysicalState, MentalState, ContractReference, Statistics, CareerHistory, Relationships, Metadata). Proibido Player monolítico com milhares de linhas / todos os campos no root.

### Motivo

Entidades gigantes são difíceis de manter, testar e evoluir; a composição distribui responsabilidades e alinha-se a Relationships-first (ContractReference, não contrato embutido).

### Alternativas

God-object Player; herança profunda em vez de composição.

### Consequences

Spec em `15-domain/04-player.md`; Club/Organization seguem o mesmo padrão; código e schemas migram gradualmente para componentes.

### Resultado

Adoptado.

**Superseded** (refinado): Bounded Contexts independentes em vez de componentes *dentro* do Player — ver entrada seguinte.

---

## ADR-0022 — Ubiquitous Language é glossário vivo: qualquer conceito de domínio novo (ex. …
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
Ubiquitous Language é **glossário vivo**: qualquer conceito de domínio novo (ex. Fair Play Financeiro, Cláusula de Rescisão, VAR, Playoff) deve ser acrescentado a `15-domain/03-ubiquitous-language.md` **antes** de ser usado em código ou noutros documentos. A Architecture Bible é a referência oficial da linguagem do projecto.

### Motivo

Evitar deriva semântica ao longo dos anos; uma única porta de entrada para vocabulário partilhado por humanos e IA.

### Alternativas

Actualizar o glossário só no fim de cada marco; permitir nomes ad hoc no código.

### Consequences

PRs/docs/código que introduzam termos sem entrada no glossário estão incompletos. Entrada mínima: termo + definição (+ «NÃO é» se houver risco de ambiguidade).

### Resultado

Adoptado.

---

## ADR-0021 — Ubiquitous Language canónica em `15-domain/03-ubiquitous-language.md` (Volume…
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
**Ubiquitous Language** canónica em `15-domain/03-ubiquitous-language.md` (Volume 3 Doc 02). Termos como Contract, Transfer, Squad, Entry, Registration, Matchday têm um significado único; ambiguidade Contract≠Transfer, Squad≠Club, Registration≠Entry, Matchday≠Calendar Day é proibida em docs/código/IA.

### Motivo

DDD: linguagem partilhada evita centenas de ambiguidades entre documentação, implementação e assistentes.

### Alternativas

Glossário informal; sinónimos livres por documento.

### Consequences

Novos termos entram no glossário **antes** de código ou outros docs. Código prefere nomes do glossário (`PlayerContract`, `CompetitionEntry`).

### Resultado

Adoptado.

---

## ADR-0020 — Human é a spec base de pessoas; especializações estendem Human. Vínculos pess…
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
**Human** é a spec base de pessoas; especializações estendem Human. Vínculos pessoa–pessoa = entidade **HumanRelationship** (kinds: friendship, rivalry, parent, …), distinta das Relationships contratuais (PlayerContract, CompetitionEntry, …).

### Motivo

Evitar FK directa Human→Human e duplicar amizade/rivalidade/família em cada especialização.

### Alternativas

Arrays de IDs no Human; só relationships contratuais.

### Consequences

Player fica só com attrs de futebol + PlayerContract; History append-only; invariantes de Human documentados.

### Resultado

Adoptado em `15-domain/02-human.md`.

---

## ADR-0019 — Inserir Volume 4 — Entity Specification na Architecture Bible; Software Archi…
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
Inserir **Volume 4 — Entity Specification** na Architecture Bible; Software Architecture…Roadmap passam a Volumes **5…18** (20 volumes). Doc 01 = Human Entity.

### Motivo

O Domain Model define taxonomias; as specs por entidade (grupos, invariantes, eventos) precisam de volume próprio.

### Alternativas

Meter specs só sob Volume 3; misturar com Database schemas.

### Consequences

`15-domain/02-human.md` + `bible/04-entity-specification.md`; links Volume N actualizados.

### Resultado

Adoptado.

---

## ADR-0018 — Três Event Buses físicos — DomainEventBus, ApplicationEventBus, Infrastructur…
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
Três Event Buses físicos — **DomainEventBus**, **ApplicationEventBus**, **InfrastructureEventBus** — com regras estritas de publicação/consumo por camada. Transportes em Shared / Events; contratos em `docs/17-events/01|02|03-*.md`.

### Motivo

Um único bus mistura factos de domínio (futebol), de aplicação (save/settings) e técnicos (compile/cache), enfraquecendo Bounded Contexts e a regra “Domain Systems só via eventos de domínio”.

### Alternativas

- Um bus tipado com união `Domain | Application | Infrastructure` (menos isolamento)
- Híbrido: Domain dedicado + App/Infra no mesmo canal
- Buses definidos só dentro de cada camada sem API partilhada em Shared (implementações divergentes)

### Consequences

Documentação e código futuro usam três APIs; bridging entre buses exige ADR; Flutter legado `EventBus` classifica-se depois (fora deste ADR). Spec: [2026-07-22-three-level-event-buses-design.md](superpowers/specs/2026-07-22-three-level-event-buses-design.md).

### Resultado

Três buses + acesso estrito adoptados no contrato da plataforma.

---

## ADR-0017 — Três pilares de engenharia na Architecture Bible — Simulation Runtime, Data A…
- **Status:** Accepted
- **Data:** 2026-07-22

### Decision
Três **pilares de engenharia** na Architecture Bible — Simulation Runtime, Data Architecture, Domain Architecture — como camada acima dos volumes 1–20 (satélites). Índices em `docs/bible/pillars/`.

### Motivo

Evitar dezenas de documentos isolados que redefinem Tick, World State, IDs e Bounded Contexts; manter a Bible como manual de engenharia consistente.

### Alternativas

- Consolidar volumes existentes dentro dos pilares (fundir Vol. 5/3–4/9) nesta fase
- Substituir a grelha 1–20 pelos três pilares sem satélites numerados
- Um único ficheiro `00-engineering-pillars.md` com três secções

### Consequences

Docs novos obrigam cabeçalho de pilares; fases B/C podem fundir prosa e limpar satélites. Spec: [2026-07-22-three-engineering-pillars-design.md](superpowers/specs/2026-07-22-three-engineering-pillars-design.md).

### Resultado

Camada de pilares + regra operacional adoptadas (estrutura nesta entrega).

---

## ADR-0016 — Parties do Domain Model usam taxonomias Human · Organization · Place · Compet…
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
Parties do Domain Model usam taxonomias **Human · Organization · Place · Competition**, com especializações (Player/Manager/…, Club/Federation/Sponsor/…, Nation/Stadium/…, League/Cup/…). Atributos comuns no tipo base; papel na especialização. Mantém-se Relationships-first.

### Motivo

Modelar só «Player / Club / Manager» duplica identidade humana e organiza o mundo à volta de futebol em vez de abstrações reutilizáveis (editor, media, federações, locais).

### Alternativas

Tipos planos sem herança/composição; só entidades de futebol.

### Consequences

Schemas partilham base; ID continua `{concreteType}:{ulid}`; Module Map / entity system alinhados; especializações novas entram na taxonomia (ou ADR).

### Resultado

Adoptado em `15-domain/01-overview.md`.

---

## ADR-0015 — IDs de entidade = `{type}:{ulid}` (ex.: `player:01HZX4YB8J7N…`, `club:01HZX52…
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
IDs de entidade = **`{type}:{ulid}`** (ex.: `player:01HZX4YB8J7N…`, `club:01HZX52J…`). ULID como identificador; prefixo de tipo. Slugs humanos e sequenciais (`plr_000001`) **não** são a chave primária.

### Motivo

Sequenciais tipados acoplam-se a contadores; slugs como PK misturam identidade com marketing e complicam mods/renames. ULID é único, ordenável no tempo e gerável offline; o prefixo evita ambiguidade entre tipos.

### Alternativas

Slugs kebab-case como PK (ADR anterior); `plr_000001` / `club_000145`; UUID v4 sem prefixo.

### Consequences

`12-ids.md` e STYLE_GUIDE actualizados. ADR de slugs como PK fica **superseded**. Nome/código humano pode existir como atributo; mods fazem override pelo mesmo `id`. Implementação migra gradualmente.

### Resultado

Adoptado; supersede IDs = slugs.

---

## ADR-0014 — Domain Model é Relationships-first: parties (Player, Club, Stadium, Sponsor, …
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
Domain Model é **Relationships-first**: parties (Player, Club, Stadium, Sponsor, Competition, Manager, …) não «possuem» umas às outras. Vínculos canónicos = PlayerContract, ManagerContract, SponsorshipAgreement, StadiumUsage, **CompetitionEntry** (Club ↔ Competition por época).

### Motivo

Posse embutida (`clubId`, `clubIds[]`) impede free agents, empréstimos, partilha de estádio e inscrição por época sem hacks. Relationships têm vida própria.

### Alternativas

Modelar em torno de Player/Club com FKs embutidas; Entry só como campo da Competition.

### Consequences

`15-domain/01-overview.md` é canónico; schemas alinham-se (Competition sem lista de clubes como posse); Bounded Contexts tratam Contracts/Entries como relationships.

### Resultado

Adoptado.

---

## ADR-0013 — SSOT de entidades do jogo = Volume 3 — Domain Model. Nenhuma entidade nova se…
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
SSOT de entidades do jogo = **Volume 3 — Domain Model**. Nenhuma entidade nova sem documentação neste volume.

### Motivo

Evitar entidades inventadas só no código ou só nos schemas sem modelo.

### Alternativas

SSOT só em Volume Database; entidades ad hoc.

### Consequences

Schemas (Vol 6) e packages (Vol 4) seguem o Domain Model.

### Resultado

Adoptado.

---

## ADR-0012 — Contract (e ManagerContract, SponsorshipContract, StadiumUsage) são entidades…
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
**Contract** (e ManagerContract, SponsorshipContract, StadiumUsage) são entidades de primeira classe / Aggregate Roots ou entidades próprias. Player e Manager **não** referenciam Club directamente. Relação temporal = entidade, nunca campo embutido.

### Motivo

Empréstimos, free agents, histórico, partilha de estádio e patrocínios com datas/cláusulas exigem vida própria do vínculo.

### Alternativas

`clubId` / `sponsors[]` embutidos no Player/Club (modelo JSON inicial).

### Consequences

Domain Model Overview é canónico; schemas conceptuais alinham-se ao alvo; implementação migra gradualmente.

### Resultado

Adoptado em `15-domain/01-overview.md`.

**Refinado** (2026-07-22): Contract elevado a **eixo central**; depois **Contract Aggregate** (Vol 4 Doc 02) — ver ADRs posteriores e `15-domain/06-contract-aggregate.md`.

---

## ADR-0011 — Inserir Volume 3 — Domain Model na Architecture Bible; Software Architecture……
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
Inserir **Volume 3 — Domain Model** na Architecture Bible; Software Architecture…Roadmap passam a Volumes **4…17** (17 volumes).

### Motivo

Entidades e agregados do jogo não são Platform Architecture nem organização de packages; precisam de SSOT próprio.

### Alternativas

Meter Domain Model dentro de Database (Vol 6); manter 16 volumes.

### Consequences

`15-domain/` + `bible/03-domain-model.md`; links «Volume N» actualizados.

### Resultado

Adoptado.

---

## ADR-0010 — O Domain do Module Map organiza-se em Bounded Contexts (DDD), não em pastas/g…
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
O Domain do Module Map organiza-se em **Bounded Contexts** (DDD), não em pastas/grupos. Contextos canónicos iniciais: Football, People, Finance, Media, World, Development, Reputation, AI. Integração só via **Domain Event Bus** e IDs.

### Motivo

Pastas sugerem organização de ficheiros; Bounded Contexts definem limites de linguagem e ownership — alinhado a DDD e a systems substituíveis.

### Alternativas

Manter «grupos» Economy/People; um único Domain monolítico.

### Consequences

Owner de módulo = Bounded Context. Novos conceitos entram num contexto existente ou ADR para contexto novo. Packages (Volume 4) podem espelhar contexts, mas o mapa conceptual não é a árvore de pastas.

### Resultado

Adoptado em `19-module-map.md`.

---

## ADR-0009 — Platform Module Map = inventário fino da plataforma: 8 categorias (Applicatio…
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
**Platform Module Map** = inventário fino da plataforma: 8 categorias (Applications, Application Services, Domain, Infrastructure, Database, Assets, Tooling, Shared) e 4 níveis de dependência Applications → Application Services → Domain → Infrastructure → Shared. Cada módulo com ficha (6 perguntas + identificação). A planta dos **10 macro-módulos** (Overview) mantém-se; o mapa não a substitui. Apps alargadas: Scenario Editor, Competition Editor, Benchmark, etc.

### Motivo

A planta sozinha não lista use cases nem Bounded Contexts do Domain; o catálogo fino permite ownership, testes e desenvolvimento paralelo / IA sem inventar módulos fora de sítio.

### Alternativas

Só os 10 macros; mapear directo a packages (Volume 3); preencher já as ~138 fichas.

### Consequences

`19-module-map.md` é o inventário; módulo novo numa categoria existente; categoria de topo nova → ADR. Produto Compiler/Validator ≠ serviço Infrastructure homónimo. Bible Vol 2 Doc 02 = Module Map; Database / Event Bus → Docs 03–04.

### Resultado

Adoptado.

---

## ADR-0008 — Internamente o guarda-chuva é Phoenix Platform. Phoenix Manager designa só o …
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
Internamente o guarda-chuva é **Phoenix Platform**. **Phoenix Manager** designa só o jogo. Produtos nomeados: Phoenix Database Editor, Phoenix Compiler, Phoenix Validator, Phoenix CLI, Phoenix Simulator (+ futuras ferramentas).

### Motivo

Chamar a tudo «Phoenix Manager» confunde plataforma com um único cliente e dificulta falar de Editor/CLI/Simulator como iguais.

### Alternativas

Manter «Phoenix Manager» como nome do monorepo/projecto; prefixo genérico «Phoenix» sem Platform.

### Consequences

Docs e ADRs usam Platform no âmbito interno; marketing do jogo pode continuar a dizer Phoenix Manager. Módulos 1–3 do overview mapeiam para estes produtos.

### Resultado

Adoptado em `10-architecture/01-overview.md` e visão.

---

## ADR-0007 — Planta canónica da Phoenix Platform = 10 macro-módulos: Desktop Client · Data…
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
Planta canónica da Phoenix Platform = **10 macro-módulos**: Desktop Client · Database Editor · Future Tools · Application Layer · Simulation Runtime · World State · Domain Systems · Event Bus · Infrastructure · Compiled Database. Nenhum módulo fora desta lista sem ADR. Event Bus obrigatório entre Domain Systems.

### Motivo

As «6 camadas» misturavam carga/I/O com tempo e não elevavam Editor, Tools, Event Bus nem Compiled Database a blocos de primeira classe. A planta de 10 módulos é a visão operacional da plataforma.

### Alternativas

Manter só as 6 camadas; acrescentar módulos ad hoc sem ADR.

### Consequences

`01-overview.md` é a planta; 6 camadas ficam só na tabela de transição. Application sem regras de futebol. Match/Finance/… substituíveis sem tocar UI. Escalabilidade (multiplayer, cloud, workshop, API, companion) sem reestruturação.

### Resultado

Adoptado; supersede a narrativa primária das 6 camadas.

---

## ADR-0006 — Separar a Architecture Bible em Volume 2 — Platform Architecture e Volume 3 —…
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
Separar a Architecture Bible em **Volume 2 — Platform Architecture** e **Volume 3 — Software Architecture**; renumerar Technology…Roadmap para 4…16.

### Motivo

Há diferença enorme entre como a plataforma está organizada (Runtime/World/Systems/clientes) e como o software está organizado (monorepo, packages, dependências).

### Alternativas

Manter um único Volume «Architecture» misturando ambos.

### Consequences

Índices e links da Bible actualizados; novos docs escolhem o volume certo pela pergunta (plataforma vs código).

### Resultado

Adoptado; 16 volumes.

---

## ADR-0005 — Seis camadas canónicas: Runtime → World → Systems → Simulation Engine → Appli…
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
Seis camadas canónicas: **Runtime → World → Systems → Simulation Engine → Application → UI**.

### Motivo

Separar load (Runtime), estado (World), regras (Systems), relógio (Simulation Engine), use cases (Application) e React (UI). O Simulation Engine só faz Next Hour → Run Systems → Events → Finish.

### Alternativas

Pilha curta Platform → Simulation → Runtime → Game; misturar World com Runtime; chamar a tudo Engine.

### Consequences

Calendar como dados no World; Systems independentes; UI/Application sem I/O. Substitui «Core Engine / Domain Systems» como nomes de camada (mapeamento na overview).

### Resultado

Adoptado em `10-architecture/01-overview.md`.

**Superseded** pela decisão dos 10 macro-módulos (mesma data, entrada mais abaixo).

---

## ADR-0004 — Phoenix Platform — pilha canónica Platform → Simulation → Runtime → Game. Des…
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
**Phoenix Platform** — pilha canónica **Platform → Simulation → Runtime → Game**. Desktop Game, Database Editor e Future Tools são clientes; a simulação e o runtime não pertencem ao Game.

### Motivo

«Só um jogo» amararia a arquitectura à UI de carreira. A ordem deixa explícito: Platform dona o produto; Simulation as regras; Runtime os dados; Game só apresenta e pede use cases.

### Alternativas

App monolítica centrada no desktop; diagrama só com «clients à volta do engine» sem ordenar Runtime abaixo de Simulation.

### Consequences

Application Services e contratos partilhados; novas ferramentas não forkam a simulação. Canónico em `10-architecture/01-overview.md`.

### Resultado

Adoptado.

---

## ADR-0003 — IDs de entidade = slugs estáveis human-readable (`benfica`, `joao-silva`), nã…
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
IDs de entidade = **slugs estáveis** human-readable (`benfica`, `joao-silva`), não IDs opacos (`plr_00000001`).

### Motivo

Legibilidade no editor e mods; alinhamento com código e dados actuais; o `id` permanece estável mesmo quando o nome de display muda.

### Alternativas

IDs opacos prefixados (`club_00000342`); híbrido opaco + slug de display.

### Consequences

Proibir embutir o nome famoso no id de forma frágil (renomear display ≠ mudar id). Relações só por id. Documentação em `20-database/12-ids.md`.

### Resultado

Slugs adoptados; IDs opacos rejeitados neste ciclo.

**Superseded** pela decisão `{type}:{ulid}` (mesma data / ciclo posterior em `DECISIONS.md`).

---

## ADR-0002 — Não chamar todos os módulos de «Engine». Distinção canónica: Core Engine (cic…
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
Não chamar todos os módulos de «Engine». Distinção canónica: **Core Engine** (ciclo de vida da simulação), **Domain Systems** (regras por domínio), **Application Services** (use cases do jogador), **Infrastructure Services** (ficheiros, cache, logging, import/export).

### Motivo

«Engine» para tudo dilui responsabilidades e dificulta DDD/Clean Architecture; Core Engine vs Systems deixa claro quem controla o tempo e quem implementa regras.

### Alternativas

Manter «tudo é Engine» (plano High-Level Architecture inicial); só «services» sem Core Engine nomeado.

### Consequences

Documentação e novos packages usam esta linguagem; pastas/`*-engine` existentes podem migrar gradualmente sem bloquear. Volumes 5–7 da Bible descrevem sobretudo Domain Systems (+ Core Engine no Simulation).

### Resultado

Adoptado; canónico em `10-architecture/01-overview.md` e `ARCHITECTURE_RULES.md`.

---

## ADR-0001 — Electron
- **Status:** Accepted
- **Data:** 2026-07-21

### Decision
Electron

### Motivo

Melhor suporte multiplataforma.

### Alternativas

Tauri

NW.js

Neutralino

### Consequences

Bundle maior e runtime Chromium; ganho em tooling multiplataforma e ecossistema maduro.

### Resultado

Electron escolhido.

---

