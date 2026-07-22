# Docs — Phoenix Platform

Documentação **conceptual-first** da **Phoenix Platform** (o jogo **Phoenix Manager** é um cliente). Sem schemas JSON nesta fase: uma pergunta por ficheiro — detalhe em [`STYLE_GUIDE.md`](STYLE_GUIDE.md). Índice lógico: [`bible/README.md`](bible/README.md) (Architecture Bible, 20 volumes). Tracker de marcos: [`plano.md`](plano.md). Regras: [`ARCHITECTURE_RULES.md`](ARCHITECTURE_RULES.md).

A árvore abaixo é a **localização física** dos ficheiros; a Bible organiza o mesmo conteúdo por volume.

## Árvore conceptual

| Pasta | Conteúdo |
|-------|----------|
| [00-project/](00-project/01-vision.md) | Visão do produto (Volume 1 — 01–08) |
| [10-architecture/](10-architecture/01-overview.md) | Platform + Software Architecture + tech (Volumes 2, 7–8) |
| [15-domain/](15-domain/01-overview.md) | Domain Model + Entity Spec (Volumes 3–4) |
| [16-processes/](16-processes/01-simulation-cycle.md) | Core Business Processes (Volume 5) |
| [17-events/](17-events/01-domain-events.md) | Event-Driven Architecture (Volume 6) — Domain · Application · Infrastructure |
| [20-database/](20-database/01-database.md) | BD + schemas (Volume 9 — 01–18) |
| [30-engines/](30-engines/01-simulation.md) | Systems / engines (Volumes 10–12) |
| [40-ui/](40-ui/01-design-system.md) | UI (Volume 13 — 01–07) |
| [50-editor/](50-editor/01-editor.md) | Database Editor (Volume 14 — 01–08) |
| [60-save-system/](60-save-system/01-save-files.md) | Save System (Volume 16 — 01–05) |
| [70-modding/](70-modding/01-mod-system.md) | Modding (Volume 15 — 01–05) |
| [80-testing/](80-testing/01-unit-tests.md) | Testing + Performance (Volumes 17–18) |
| [85-deployment/](85-deployment/01-windows.md) | Deployment (Volume 19 — 01–06) |
| [90-roadmap/](90-roadmap/v0.1.md) | Roadmap (Volume 20 — MVP…v2.0) |
| [specs/player/](specs/player/player-schema.md) | Specs de domínio — Player (rating, growth, contract, …) |

### 00-project

- [01-vision.md](00-project/01-vision.md)
- [02-pillars.md](00-project/02-pillars.md)
- [03-target-audience.md](00-project/03-target-audience.md)
- [04-design-principles.md](00-project/04-design-principles.md)
- [05-product-goals.md](00-project/05-product-goals.md)
- [06-non-goals.md](00-project/06-non-goals.md)
- [07-success-metrics.md](00-project/07-success-metrics.md)
- [08-feature-priorities.md](00-project/08-feature-priorities.md)

### 10-architecture

- [01-overview.md](10-architecture/01-overview.md)
- [02-tech-stack.md](10-architecture/02-tech-stack.md)
- [03-monorepo.md](10-architecture/03-monorepo.md)
- [04-folder-structure.md](10-architecture/04-folder-structure.md)
- [05-dependencies.md](10-architecture/05-dependencies.md)
- [06-data-flow.md](10-architecture/06-data-flow.md)
- [07-event-system.md](10-architecture/07-event-system.md)
- [08-state-management.md](10-architecture/08-state-management.md)
- [09-plugin-system.md](10-architecture/09-plugin-system.md)
- [10-electron.md](10-architecture/10-electron.md)
- [11-react.md](10-architecture/11-react.md)
- [12-tailwind.md](10-architecture/12-tailwind.md)
- [13-shadcn.md](10-architecture/13-shadcn.md)
- [14-typescript.md](10-architecture/14-typescript.md)
- [15-zod.md](10-architecture/15-zod.md)
- [16-build-system.md](10-architecture/16-build-system.md)
- [17-ci.md](10-architecture/17-ci.md)
- [18-testing.md](10-architecture/18-testing.md)

### 20-database

- [01-database.md](20-database/01-database.md)
- [02-schema-player.md](20-database/02-schema-player.md)
- [03-schema-club.md](20-database/03-schema-club.md)
- [04-schema-manager.md](20-database/04-schema-manager.md)
- [05-schema-competition.md](20-database/05-schema-competition.md)
- [06-schema-nation.md](20-database/06-schema-nation.md)
- [07-schema-stadium.md](20-database/07-schema-stadium.md)
- [08-schema-sponsor.md](20-database/08-schema-sponsor.md)
- [09-schema-referee.md](20-database/09-schema-referee.md)
- [10-schema-agent.md](20-database/10-schema-agent.md)
- [11-entity-system.md](20-database/11-entity-system.md)
- [12-ids.md](20-database/12-ids.md)
- [13-indexes.md](20-database/13-indexes.md)
- [14-schema-media.md](20-database/14-schema-media.md)
- [15-schema-staff.md](20-database/15-schema-staff.md)
- [16-mod-packs.md](20-database/16-mod-packs.md)
- [17-database-versioning.md](20-database/17-database-versioning.md)
- [18-database-validation.md](20-database/18-database-validation.md)

### 30-engines

- [01–12](30-engines/01-simulation.md) (simulation, match, calendar, transfer, finance, training, youth, reputation, ai, media, competition, injury)
- [13-possession.md](30-engines/13-possession.md)
- [14-passing.md](30-engines/14-passing.md)
- [15-shooting.md](30-engines/15-shooting.md)
- [16-defending.md](30-engines/16-defending.md)
- [17-set-pieces.md](30-engines/17-set-pieces.md)
- [18-match-injuries.md](30-engines/18-match-injuries.md)
- [19-cards.md](30-engines/19-cards.md)
- [20-fatigue.md](30-engines/20-fatigue.md)
- [21-match-player-ratings.md](30-engines/21-match-player-ratings.md)
- [22-manager-ai.md](30-engines/22-manager-ai.md)
- [23-transfer-ai.md](30-engines/23-transfer-ai.md)
- [24-youth-ai.md](30-engines/24-youth-ai.md)
- [25-scouting-ai.md](30-engines/25-scouting-ai.md)
- [26-finance-ai.md](30-engines/26-finance-ai.md)
- [27-personality-engine.md](30-engines/27-personality-engine.md)
- [28-weather-engine.md](30-engines/28-weather-engine.md)
- [29-scheduling-engine.md](30-engines/29-scheduling-engine.md)

### 40-ui

- [01-design-system.md](40-ui/01-design-system.md)
- [02-navigation.md](40-ui/02-navigation.md)
- [03-components.md](40-ui/03-components.md)
- [04-pages.md](40-ui/04-pages.md)
- [05-layouts.md](40-ui/05-layouts.md)
- [06-accessibility.md](40-ui/06-accessibility.md)
- [07-themes.md](40-ui/07-themes.md)

### 50-editor

- [01-editor.md](50-editor/01-editor.md)
- [02-import-export.md](50-editor/02-import-export.md)
- [03-validation.md](50-editor/03-validation.md)
- [04-bulk-editing.md](50-editor/04-bulk-editing.md)
- [05-import.md](50-editor/05-import.md)
- [06-export.md](50-editor/06-export.md)
- [07-diff-viewer.md](50-editor/07-diff-viewer.md)
- [08-undo.md](50-editor/08-undo.md)
- [09-history.md](50-editor/09-history.md)

### 60-save-system

- [01-save-files.md](60-save-system/01-save-files.md)
- [02-patches.md](60-save-system/02-patches.md)
- [03-compression.md](60-save-system/03-compression.md)
- [04-migration.md](60-save-system/04-migration.md)
- [05-versioning.md](60-save-system/05-versioning.md)
- [06-cloud-saves.md](60-save-system/06-cloud-saves.md)

### 70-modding

- [01-mod-system.md](70-modding/01-mod-system.md)
- [02-data-packs.md](70-modding/02-data-packs.md)
- [03-versioning.md](70-modding/03-versioning.md)
- [04-override-rules.md](70-modding/04-override-rules.md)
- [05-priority.md](70-modding/05-priority.md)
- [06-workshop-integration.md](70-modding/06-workshop-integration.md)

### 80-testing

- [01-unit-tests.md](80-testing/01-unit-tests.md)
- [02-performance.md](80-testing/02-performance.md)
- [03-validation.md](80-testing/03-validation.md)
- [04-memory.md](80-testing/04-memory.md)
- [05-caching.md](80-testing/05-caching.md)
- [06-perf-indexes.md](80-testing/06-perf-indexes.md)
- [07-lazy-loading.md](80-testing/07-lazy-loading.md)
- [08-parallel-simulation.md](80-testing/08-parallel-simulation.md)
- [09-profiling.md](80-testing/09-profiling.md)
- [10-integration.md](80-testing/10-integration.md)
- [11-simulation-validation.md](80-testing/11-simulation-validation.md)
- [12-regression.md](80-testing/12-regression.md)
- [13-performance-tests.md](80-testing/13-performance-tests.md)

### 85-deployment

- [01-windows.md](85-deployment/01-windows.md)
- [02-macos.md](85-deployment/02-macos.md)
- [03-steam.md](85-deployment/03-steam.md)
- [04-auto-update.md](85-deployment/04-auto-update.md)
- [05-crash-reports.md](85-deployment/05-crash-reports.md)
- [06-telemetry.md](85-deployment/06-telemetry.md)

### 90-roadmap

- [v0.1.md](90-roadmap/v0.1.md)
- [v0.2.md](90-roadmap/v0.2.md)
- [v1.0.md](90-roadmap/v1.0.md)
- [v2.0.md](90-roadmap/v2.0.md)

## Outros

| Ficheiro / pasta | Conteúdo |
|---|---|
| [bible/](bible/README.md) | Architecture Bible — índice lógico (20 volumes) |
| [plano.md](plano.md) | Plano vivo — marcos TS |
| [ARCHITECTURE_RULES.md](ARCHITECTURE_RULES.md) | Regras transversais |
| [modelo-conceptual.md](modelo-conceptual.md) | Stub — redirecciona para esta árvore |
| [PRIVACY.md](PRIVACY.md) | Política de privacidade |
| [superpowers/](superpowers/) | Specs e planos por marco |
| [legacy/](legacy/) | Docs Flutter / lojas arquivados |

Artefactos locais de build **não** vivem aqui.
