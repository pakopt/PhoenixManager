# LLD-028 — Club Finance, Economy & Business Architecture

**Low-Level Design**

| Campo | Valor |
|-------|-------|
| **Versão** | 1.1 |
| **Estado** | Baseline |
| **Prioridade** | Crítica |
| **ID índice** | 17.L28 |
| **Pacote alvo** | `@phoenix/domain` · `simulation-economy` · `simulation-finance` · tipos em `shared` / `engine-api` |
| **Dependências** | [LLD-019](LLD-019-club-entity-architecture.md) · [LLD-020](LLD-020-competition-league-tournament-architecture.md) · [LLD-024](LLD-024-transfer-market-contracts-negotiation-architecture.md) · [LLD-026](LLD-026-scouting-recruitment-knowledge-architecture.md) · [LLD-027](LLD-027-medical-injuries-fitness-sports-science-architecture.md) · [LLD-002](LLD-002-world-clock-temporal-simulation-engine.md) · [LLD-004](LLD-004-event-bus-delivery-pipeline.md) · [DS-006](../15-data-specs/DS-006-financial-data-model.md) · [DS-022](../15-data-specs/DS-022-finance-analytics-data-model.md) · [SDS-017](../09-blueprints/SDS-017-financial-system.md) · [PSP-024](../12-psp/systems/PSP-024-economy.md) · [Runtime](../02-architecture/Runtime.md) |
| **ADR fundação** | [ADR-0075](../04-decisions/ADR-0075.md) · [ADR-0103](../04-decisions/ADR-0103.md) · [ADR-0120](../04-decisions/ADR-0120.md) · [ADR-0136](../04-decisions/ADR-0136.md) · [ADR-0182](../04-decisions/ADR-0182.md) · [ADR-0187](../04-decisions/ADR-0187.md) |
| **ADR desenho** | [ADR-0191](../04-decisions/ADR-0191.md) **Club Finance** · Financial Ledger & Sustainability Model · Double-Entry Financial Ledger · Dynamic Cash Flow Engine · Financial Health Index · Multi-Year Budget Planner · Revenue Diversification Engine · Economic Shock Simulator · Investment Return Analyzer · Financial Digital Twin |
| **Changelog v1.0** | Club Finance (12): Accounting · Revenue · Expense · Budget · Cash Flow Engines · Assets · Liabilities · Investments · Sponsors · Financial Planning · Compliance · Financial History · oito inovações · Baseline · Lucro≠Liquidez≠Património · Double-Entry · aprofunda PSP-024 · SDS-017 · DS-006 · ADR-0075/0103/0120 · Club `FinancialLedger` âncora (LLD-019) |
| **Changelog v1.1** | **Club Finance** (14): **Accounting Ledger** · Revenue Engine · Expense Engine · Cash Flow Engine · **Budget Planner** · **Assets Manager** · **Liabilities Manager** · **Sponsorship Engine** · **Investment Engine** · **Financial Health Index** · **Economic Shock Simulator** · **Investment Return Analyzer** · **Financial Digital Twin** · Financial History (§4 · §40) — Health/Shock/Return/Twin 1ª classe; Accounting/Budget/Assets/Liabilities/Sponsors/Investments renomeados; Financial Planning · Compliance (v1.0) → capacidade / regras sob Health Index · Budget · packs FFP |
| **Nota homónimos** | **Club Finance** (este LLD) = arquitectura financeira do clube · economia de negócio — aprofunda [PSP-024](../12-psp/systems/PSP-024-economy.md) · [SDS-017](../09-blueprints/SDS-017-financial-system.md) · [DS-006](../15-data-specs/DS-006-financial-data-model.md) · [ADR-0075](../04-decisions/ADR-0075.md) · [ADR-0103](../04-decisions/ADR-0103.md) · [ADR-0120](../04-decisions/ADR-0120.md). **Accounting Ledger** · **Budget Planner** · **Assets/Liabilities Managers** · **Sponsorship/Investment Engines** · **Financial Health Index** · **Economic Shock Simulator** · **Investment Return Analyzer** · **Financial Digital Twin** = 1ª classe (v1.1). **Financial Planning** / **Compliance** (v1.0) → planeamento multi-época sob Budget Planner; FFP/licenciamento como regras configuráveis (inputs) — não ramos §4. **GFEM** = macro; **Finance Analytics** (DS-022) consome ≠ SoT. **Financial Agreement** (DS-014) ≠ Ledger. **Financial Digital Twin** ≠ Club/Player/Athlete/Transfer Twin (nome v1.0: Club Financial Digital Twin). **Financial Health Index** alinha **Financial Health Score** (ADR-0120). Rascunho “ADR-135…” = ADR-0191 (alias ADR-140); **ADR-0135** = Stadium; alias ADR-135 = [ADR-0186](../04-decisions/ADR-0186.md) Tactical AI. |

---

## 1. Objetivo

Definir a **arquitectura financeira completa** do Phoenix Manager.

Inclui:

- receitas;
- despesas;
- fluxo de caixa;
- orçamentos;
- dívida;
- investimentos;
- patrocínios;
- direitos televisivos;
- sustentabilidade financeira.

**Regra de ouro:** o dinheiro é um recurso limitado; **lucro ≠ liquidez ≠ património** ([ADR-0191](../04-decisions/ADR-0191.md) · [ADR-0075](../04-decisions/ADR-0075.md) · [ADR-0103](../04-decisions/ADR-0103.md)).

**Fronteiras:**

| Este documento | Não é este documento |
|----------------|----------------------|
| Arquitectura Club Finance / Economy & Business | Schema campo-a-campo → [DS-006](../15-data-specs/DS-006-financial-data-model.md) |
| Comportamento financeiro do clube | [SDS-017](../09-blueprints/SDS-017-financial-system.md) · [PSP-024](../12-psp/systems/PSP-024-economy.md) |
| Âncora `FinancialLedger` no Club | [LLD-019](LLD-019-club-entity-architecture.md) (ref; lógica aqui) |
| Analytics / Decision Intelligence | [DS-022](../15-data-specs/DS-022-finance-analytics-data-model.md) (consome; ≠ SoT) |
| Transfer / Contract obligations | [LLD-024](LLD-024-transfer-market-contracts-negotiation-architecture.md) → eventos → Ledger |
| Custos médicos / scouting como categorias | [LLD-027](LLD-027-medical-injuries-fitness-sports-science-architecture.md) · [LLD-026](LLD-026-scouting-recruitment-knowledge-architecture.md) (sinais; Finance contabiliza) |
| Macro economia / GFEM | [PSP-024](../12-psp/systems/PSP-024-economy.md) |
| Normas SES de economia / fluxos / mercado na simulação | [SES-004](../27-simulation-engine/SES-004-economy-simulation-financial-systems-market-dynamics.md) ([ADR-0285](../04-decisions/ADR-0285.md)) — ≠ Football Economy Architecture · Club Finance SES-004 · este LLD = SoT runtime clube |
| Normas TMFBS de valorização dinâmica / activos / pricing | [TMFBS-004](../30-transfer-market-football-business/TMFBS-004-dynamic-player-valuation-financial-assets-market-pricing-architecture.md) ([ADR-0307](../04-decisions/ADR-0307.md)) — ≠ Dynamic Player Valuation Architecture · Accounting Ledger / Financial Twin LLD ≠ Financial Asset Model / Financial Asset Digital Twin TMFBS · este LLD = SoT runtime clube |
| Normas TMFBS de FFP / sustentabilidade / conformidade | [TMFBS-006](../30-transfer-market-football-business/TMFBS-006-financial-fair-play-club-sustainability-regulatory-compliance-architecture.md) ([ADR-0309](../04-decisions/ADR-0309.md)) — ≠ Financial Compliance Architecture · FFP packs / Accounting Ledger / Financial Twin LLD ≠ Financial Compliance Engine / Regulatory Digital Twin TMFBS · este LLD = SoT runtime clube |
| Normas TMFBS de patrocínios / branding / receitas comerciais | [TMFBS-007](../30-transfer-market-football-business/TMFBS-007-sponsorship-commercial-rights-branding-revenue-generation-architecture.md) ([ADR-0310](../04-decisions/ADR-0310.md)) — ≠ Commercial Business Architecture · Sponsorship Engine / Merchandising LLD ≠ Commercial Business Engine / Commercial Digital Twin TMFBS · este LLD = SoT runtime clube |
| Normas TMFBS de direitos TV / streaming / audiências / receitas de transmissão | [TMFBS-008](../30-transfer-market-football-business/TMFBS-008-media-rights-broadcasting-revenue-global-football-media-architecture.md) ([ADR-0311](../04-decisions/ADR-0311.md)) — ≠ Global Football Media Architecture · Accounting Ledger / Sponsorship Engine LLD ≠ Broadcasting Rights / Media Distribution Engine / Media Digital Twin TMFBS · este LLD = SoT runtime clube |
| Normas TMFBS de economia global / macroeconomia / ciclos / câmbios / choques | [TMFBS-010](../30-transfer-market-football-business/TMFBS-010-global-football-economy-macroeconomic-dynamics-long-term-financial-ecosystem-architecture.md) ([ADR-0313](../04-decisions/ADR-0313.md)) — ≠ Global Football Economy Architecture · Economic Shock Simulator / Financial Twin LLD ≠ Economic Shocks / Global Football Economy Engine / Global Economy Digital Twin TMFBS · este LLD = SoT runtime clube |

---

## 2. Filosofia

```
O dinheiro é um recurso limitado.

Todas as decisões financeiras possuem consequências presentes e futuras.
```

```
Quanto tenho?        → Cash Flow Engine · Assets Manager
Quanto ganho/gasto?  → Revenue Engine · Expense Engine
O que planeio?       → Budget Planner
Estou saudável?      → Financial Health Index (+ regras FFP)
O que choca?         → Economic Shock Simulator
O que rende?         → Investment Engine · Investment Return Analyzer
O que simulo?        → Financial Digital Twin
O que recordo?       → Financial History (nunca apagado)
```

**Lucro anual ≠ liquidez diária.** Um clube pode ter lucro contabilístico e problemas de caixa — e o inverso.

---

## 3. Arquitectura geral

```
                 Club Finance
                           │
      ┌────────────────────┼────────────────────┐
      ▼                    ▼                    ▼
 Accounting Ledger     Revenue*             Cash Flow
 Budget Planner        Expense              Assets · Liabilities Mgr
      ▼                    ▼                    ▼
 Health Index          Sponsorship Eng.     Investment Engine
 Shock · Twin          Diversification      Return Analyzer
                       Financial History
```

\* Revenue inclui bilheteira · TV · merchandising · prémios · academia · transferências (como fluxos).

Consumo:

```
Club · Competition · Transfer · Contract · Matchday · Facilities · Board
        → LLD-028 Club Finance
        → DS-006 · FinancialLedger refs · LLD-004 events
```

---

## 4. Componentes — Club Finance

Organização canónica (§40):

```
Club Finance
│
├── Accounting Ledger
├── Revenue Engine
├── Expense Engine
├── Cash Flow Engine
├── Budget Planner
├── Assets Manager
├── Liabilities Manager
├── Sponsorship Engine
├── Investment Engine
├── Financial Health Index
├── Economic Shock Simulator
├── Investment Return Analyzer
├── Financial Digital Twin
└── Financial History
```

| Componente | Papel |
|------------|-------|
| **Accounting Ledger** | Livro contínuo · Double-Entry (§26) · amortizações · depreciações · impostos — promovido (nome) |
| **Revenue Engine** | Fontes de receita · Diversification (§30) |
| **Expense Engine** | Categorias de despesa · faseamento |
| **Cash Flow Engine** | Liquidez diária · Dynamic Cash Flow (§27) |
| **Budget Planner** | Orçamentos por época / departamento · Multi-Year (§29) — promovido |
| **Assets Manager** | Caixa · estádio · CT · academia · jogadores (contabilístico) · marcas — promovido |
| **Liabilities Manager** | Empréstimos · salários em dívida · fornecedores · impostos · obrigações — promovido |
| **Sponsorship Engine** | Contratos comerciais · objectivos · bónus · cláusulas — promovido |
| **Investment Engine** | Capex · ciclo de investimento — promovido |
| **Financial Health Index** | Liquidez·solvabilidade·sustentabilidade·crescimento·estabilidade — 1ª classe (§28) |
| **Economic Shock Simulator** | Eventos económicos / adaptação — 1ª classe (§31) |
| **Investment Return Analyzer** | Custo→Benefícios→Retorno→Impacto — 1ª classe (§32) |
| **Financial Digital Twin** | What-if financeiro — 1ª classe (§33); nunca muta até commit |
| **Financial History** | Ledger / arquivo imutável |

Inovações (§26–§33) — mapa em §40. **Financial Planning** / **Compliance** (v1.0) = capacidade: multi-época sob Budget Planner; FFP/licenciamento como regras configuráveis (inputs Health Index / packs) — não ramos §4. Serviços SDS-017 mapeiam 1:N.

---

## 5. Accounting Ledger — Contabilidade

Cada clube mantém um **livro contabilístico** contínuo.

Inclui: receitas · despesas · ativos · passivos · amortizações · depreciações · impostos.

**Double-Entry** (§26): todo movimento deixa rasto auditável; Σ débito = Σ crédito.

≠ saldo único mutável · ≠ Reporting Analytics SoT (DS-022). Nome v1.0: Accounting Engine.

---

## 6. Revenue Engine — Receitas

Principais fontes:

- bilheteira (§14);
- patrocínios (§12 · Sponsorship Engine);
- direitos televisivos (§13);
- prémios;
- merchandising (§14);
- transferências (fluxos de venda — origem Transfer LLD-024);
- academia;
- competições.

**Revenue Diversification Engine** (§30) avalia dependência entre fontes.

---

## 7. Expense Engine — Despesas

Principais categorias:

- salários;
- prémios;
- manutenção;
- infraestruturas;
- viagens;
- departamento médico (consumo LLD-027 — Finance contabiliza);
- scouting (consumo LLD-026);
- academia.

Pagamentos podem ser faseados (alinham Cash Flow).

---

## 8. Cash Flow Engine — Fluxo de caixa

```
Receitas → Entradas → Saldo Diário → Pagamentos → Saldo Atual
```

O clube pode ter **lucro anual** e **problemas de liquidez**.

**Dynamic Cash Flow** (§27): diário · prestações de transferências · salários · receitas sazonais · impostos.

≠ só P&L anual.

---

## 9. Budget Planner — Orçamentos

Cada época define:

- orçamento salarial;
- orçamento de transferências;
- investimento em infraestruturas;
- academia;
- departamento médico.

**Multi-Year Budget Planner** (§29): Época Actual → +1 → +2 → +3.

Orçamento **influencia** decisões (Transfer Twin · Board · AI) — não é cosmético. Nome v1.0: Budget Engine.

---

## 10. Assets Manager — Ativos

Incluem: dinheiro · estádio · centro de treinos · academia · jogadores (valor contabilístico / amortização) · marcas registadas.

Asset Lifecycle (ADR-0120): Aquisição → Utilização → Valorização/Depreciação → Venda.

Facilities SoT estrutural → [DS-021](../15-data-specs/DS-021-stadium-facilities-data-model.md); Finance regista impacto económico. Nome v1.0: Assets.

---

## 11. Liabilities Manager — Passivos

Incluem: empréstimos · salários em dívida · fornecedores · impostos · obrigações financeiras (incl. transferências a prazo).

Nome v1.0: Liabilities.

---

## 12. Sponsorship Engine — Patrocínios

Cada contrato possui: duração · valor · objectivos · cláusulas · bónus.

Perda / incumprimento de objectivos → eventos · possível Shock (§16). Nome v1.0: Sponsors.

---

## 13. Direitos televisivos

Dependem de: competição · classificação · país · audiência · contratos comerciais.

Fonte sob **Revenue Engine**; regras de distribuição sob Competition / packs — Finance aplica lançamentos.

---

## 14. Merchandising & Bilheteira

**Merchandising** influenciado por: popularidade · títulos · estrelas · massa adepta · marketing.

**Bilheteira** depende de: capacidade · preços · importância · rivalidade · forma.

Ambos sob Revenue Engine.

---

## 15. Investment Engine — Investimentos

Exemplos: ampliar estádio · renovar academia · construir centro médico · melhorar instalações.

Ciclo de capex; retorno medido por **Investment Return Analyzer** (§18). Nome v1.0: Investments.

---

## 16. Financial Health Index — Saúde financeira

**Componente de 1ª classe** (§4 · §28).

Calcula continuamente: liquidez · solvabilidade · endividamento · margem operacional · risco financeiro · crescimento · estabilidade.

Influencia patrocinadores, investidores e direcção. Consome sinais de FFP/licenciamento (regras configuráveis — não ramo Compliance §4).

Alinha **Financial Health Score** (ADR-0120).

**Implementação F112 (2026-08-12 · Living HoF):** UI alias ` · HI{n}{band}` sobre stub `financialHealth` (= cash/100k · bands Crit/Weak/Ok/Strong · F89–F97). **Não** é o índice multi-dim completo · **sem** Accounting Ledger double-entry neste slice · world **v31**.

---

## 17. Economic Shock Simulator — Choques

**Componente de 1ª classe** (§4 · §31).

Exemplos: perda de patrocinador · descida de divisão · crise económica · aumento de custos energéticos · redução de assistência.

Cenários via Twin — commit explícito para impacto real.

---

## 18. Investment Return Analyzer — Retorno

**Componente de 1ª classe** (§4 · §32).

```
Investimento → Custo → Benefícios → Retorno → Impacto Financeiro
```

Mede o verdadeiro valor de infraestruturas e projectos.

---

## 19. Financial Digital Twin — Twin

**Componente de 1ª classe** (§4 · §33).

Antes de aprovar uma decisão, a IA / Board pode simular: contratação · estádio · aumento salarial · venda de ativos · novo patrocínio.

Estima liquidez, orçamento e sustentabilidade **antes** do commit.

**Nunca** muta o ledger até commit. Nome inov./v1.0: Club Financial Digital Twin. ≠ Club Digital Twin (LLD-019) · ≠ Transfer / Athlete Twin.

---

## 20. Financial History — Histórico

Ledger / arquivo imutável. Append-only; correcções = novos lançamentos.

---

## 21. Fair Play / Compliance (capacidade)

O motor suporta regras **configuráveis** (limites salariais · equilíbrio orçamental · dívida · licenciamento).

**Não** é ramo §4 (v1.1): valida via packs / Health Index / Budget — **não** escreve lançamentos (ADR-0103). Nome v1.0: Compliance.

---

## 22. Eventos

Eventos publicados (via [LLD-004](LLD-004-event-bus-delivery-pipeline.md)):

- novo patrocinador;
- incumprimento;
- lucro anual;
- prejuízo;
- investimento;
- venda de ativos;
- alerta de liquidez;
- violação / near-miss FFP;
- choque económico (simulado vs aplicado).

---

## 23. Invariantes

O sistema garante:

- balanços consistentes (Σ débito = Σ crédito);
- histórico permanente;
- dupla validação contabilística;
- integridade financeira;
- Twin / Scenario / Shock sem side-effect no ledger real;
- liquidez ≠ lucro ≠ património derivados do mesmo SoT.

---

## 24. Performance

Objectivos: processamento mensal · actualização incremental · consolidação anual · baixo consumo de memória · cash flow diário sem full scan do histórico.

---

## 25. Critérios de aceitação

O sistema está concluído quando:

- receitas e despesas permanecem consistentes;
- orçamento influencia decisões;
- liquidez é correctamente simulada;
- histórico financeiro é preservado;
- Double-Entry · Health Index · Twin (isolation) cobertos por testes.

---

## 26. Inovação — Double-Entry Financial Ledger → Accounting Ledger

Todas as operações utilizam **partidas dobradas**.

```
Receita Bilheteira → Caixa (+) → Receitas Operacionais (+)
```

Rastra auditável. Vive sob **Accounting Ledger** (1ª classe).

---

## 27. Inovação — Dynamic Cash Flow Engine → Cash Flow Engine

Fluxo de caixa **diário**: pagamentos faseados · prestações · salários · sazonalidade · impostos.

Dificuldades temporárias mesmo com bom balanço anual.

---

## 28. Inovação — Financial Health Index → Financial Health Index (1ª classe)

**Componente de 1ª classe** (§4). Liquidez · solvabilidade · sustentabilidade · crescimento · estabilidade.

≠ Ability · ≠ Club Health Index genérico sem dimensão financeira.

---

## 29. Inovação — Multi-Year Budget Planner → Budget Planner

```
Época Atual → +1 Ano → +2 Anos → +3 Anos
```

**Componente de 1ª classe** como **Budget Planner**.

---

## 30. Inovação — Revenue Diversification Engine → Revenue Engine

Avalia dependência das fontes. Vive sob **Revenue Engine**.

---

## 31. Inovação — Economic Shock Simulator → Economic Shock Simulator (1ª classe)

**Componente de 1ª classe** (§4). Eventos económicos; adaptação; commit explícito.

---

## 32. Inovação — Investment Return Analyzer → Investment Return Analyzer (1ª classe)

**Componente de 1ª classe** (§4). Custo → Benefícios → Retorno → Impacto.

---

## 33. Inovação — Club Financial Digital Twin → Financial Digital Twin (1ª classe)

**Componente de 1ª classe** (§4). What-if financeiro; **nunca** muta até commit.

---

## 34. Track de implementação (orientação)

| ID | Entrega |
|----|---------|
| T1 | Mapa Club Finance v1.1 (§4 · 14) + DS-006 · SDS-017 · PSP-024 · LLD-019 FinancialLedger |
| T2 | Accounting Ledger · Double-Entry · History append-only |
| T3 | Revenue · Expense Engines · TV · bilheteira · merch · Diversification |
| T4 | Cash Flow Engine · Dynamic diário · liquidez ≠ lucro |
| T5 | Budget Planner · Multi-Year |
| T6 | Assets Manager · Liabilities Manager · Asset Lifecycle |
| T7 | Sponsorship Engine · Investment Engine |
| T8 | Financial Health Index (1ª classe) · regras FFP (capacidade) |
| T9 | Economic Shock Simulator · Investment Return Analyzer (1ª classe) |
| T10 | Financial Digital Twin (1ª classe · isolation) · events · suites |

---

## 35. Testes

Devem existir testes para:

- receitas;
- despesas;
- fluxo de caixa;
- patrocínios;
- investimentos / retorno;
- incumprimentos / choques;
- licenciamento / FFP;
- balanços (Double-Entry);
- Twin sem mutação até commit;
- orçamento a bloquear / avisar decisões fora de limite;
- Health Index coerente com ledger.

---

## 36. Referências

| Artefacto | Link |
|-----------|------|
| ADR desenho | [ADR-0191](../04-decisions/ADR-0191.md) |
| Schema / comportamento | [DS-006](../15-data-specs/DS-006-financial-data-model.md) · [SDS-017](../09-blueprints/SDS-017-financial-system.md) · [PSP-024](../12-psp/systems/PSP-024-economy.md) |
| Analytics (consumo) | [DS-022](../15-data-specs/DS-022-finance-analytics-data-model.md) · [ADR-0136](../04-decisions/ADR-0136.md) |
| Ledger / Double-Entry / Health | [ADR-0075](../04-decisions/ADR-0075.md) · [ADR-0103](../04-decisions/ADR-0103.md) · [ADR-0120](../04-decisions/ADR-0120.md) |
| Club / Transfer / Competition | [LLD-019](LLD-019-club-entity-architecture.md) · [LLD-024](LLD-024-transfer-market-contracts-negotiation-architecture.md) · [LLD-020](LLD-020-competition-league-tournament-architecture.md) |
| Scouting / Medical (custos) | [LLD-026](LLD-026-scouting-recruitment-knowledge-architecture.md) · [LLD-027](LLD-027-medical-injuries-fitness-sports-science-architecture.md) |
| Bus / Clock | [LLD-004](LLD-004-event-bus-delivery-pipeline.md) · [LLD-002](LLD-002-world-clock-temporal-simulation-engine.md) |
| Filosofia economia | [Football Economy](../11-prd/15-economy-framework/FootballEconomy.md) |

---

## 40. Refinamento — Club Finance

```
Club Finance
│
├── Accounting Ledger
├── Revenue Engine
├── Expense Engine
├── Cash Flow Engine
├── Budget Planner
├── Assets Manager
├── Liabilities Manager
├── Sponsorship Engine
├── Investment Engine
├── Financial Health Index
├── Economic Shock Simulator
├── Investment Return Analyzer
├── Financial Digital Twin
└── Financial History
```

### Regras

1. **Club Finance** é a organização canónica (§4) — 14 componentes.  
2. Lucro ≠ liquidez ≠ património — um único saldo **não** representa a situação.  
3. **Double-Entry** obrigatório; History append-only.  
4. **Financial Health Index** · **Economic Shock Simulator** · **Investment Return Analyzer** · **Financial Digital Twin** são 1ª classe.  
5. Twin / Scenario / Shock **não** mutam ledger até commit.  
6. Schema → DS-006; serviços SDS-017 mapeiam; Analytics DS-022 consome.  
7. Club âncora via `FinancialLedger` (LLD-019) — lógica completa aqui / SDS-017.  
8. FFP/Compliance (v1.0) → regras configuráveis (capacidade), não ramo §4.  
9. Transfer / Contract → Accounting Ledger / Cash Flow.  
10. GFEM = macro; History nunca apagado.

### Motivo

Taxonomia legível — ledger, gestores, engines comerciais, saúde, choques, retorno e twin explícitos.

### Fronteiras

| Este conceito… | …não é… |
|----------------|---------|
| Club Finance (LLD-028) | GFEM macro · Finance Analytics SoT · Contract Financial Agreement |
| Accounting Ledger | Saldo único mutável · Accounting Engine (nome v1.0) · Reporting UI |
| Revenue Engine | Transfer Negotiation SoT |
| Expense Engine | Staff / Medical / Scouting comportamento SoT |
| Cash Flow Engine | Só P&L anual |
| Budget Planner | Cosmético · Budget Engine (nome v1.0) |
| Assets Manager | Facilities/Player entity SoT · Assets (nome v1.0) |
| Liabilities Manager | Contract clauses SoT · Liabilities (nome v1.0) |
| Sponsorship Engine | Media/Branding SoT · Sponsors (nome v1.0) |
| Investment Engine | Capex mágico · Investments (nome v1.0) |
| Financial Health Index | Ability · Form · só sob Planning (v1.0) |
| Economic Shock Simulator | RNG sem adaptação · só sob Planning (v1.0) |
| Investment Return Analyzer | Investimento sem medição · só sob Investments (v1.0) |
| Financial Digital Twin | Club/Transfer/Athlete Twin · mutar save · Club Financial Digital Twin (nome inov.) |
| Financial History | BI warehouse · soft-delete |
| Financial Planning / Compliance (v1.0) | Ramos §4 — agora capacidade / inputs |

### Mapa inovações → componentes

| Inovação | Onde |
|----------|------|
| Double-Entry Financial Ledger (§26) | **Accounting Ledger** · Financial History |
| Dynamic Cash Flow Engine (§27) | **Cash Flow Engine** |
| Financial Health Index (§28) | **Financial Health Index** |
| Multi-Year Budget Planner (§29) | **Budget Planner** |
| Revenue Diversification Engine (§30) | **Revenue Engine** |
| Economic Shock Simulator (§31) | **Economic Shock Simulator** |
| Investment Return Analyzer (§32) | **Investment Return Analyzer** |
| Club Financial Digital Twin (§33) | **Financial Digital Twin** |

### Mapa v1.0 → v1.1

| v1.0 | v1.1 |
|------|------|
| Accounting Engine | **Accounting Ledger** |
| Budget Engine | **Budget Planner** |
| Assets · Liabilities | **Assets Manager** · **Liabilities Manager** |
| Sponsors · Investments | **Sponsorship Engine** · **Investment Engine** |
| Financial Planning | Dissolvido → Health Index · Shock · Twin · Budget (planeamento) |
| Compliance | Capacidade FFP / packs (não ramo §4) |
| Health / Shock / Return / Twin (inov.) | **…** 1ª classe |
| Financial History | Financial History |
| Revenue · Expense · Cash Flow | (inalterados) |

### Mapa SDS-017 serviços → Club Finance

| Serviço SDS-017 | Componentes LLD-028 |
|-----------------|---------------------|
| Ledger · Audit | Accounting Ledger · Financial History |
| Treasury | Cash Flow Engine · Assets Manager (caixa) |
| Budget | Budget Planner |
| Forecast · Twin | Budget Planner · Financial Digital Twin · Shock |
| Compliance | Capacidade FFP → Health Index / packs |
| Reporting | Financial Health Index · statements — Analytics DS-022 consome |

### Fluxo económico

```
Matchday / TV / Sponsorship / Transfer / Prizes
    → Revenue · Expense Engines
    → Accounting Ledger (Double-Entry) · Cash Flow (diário)
    → Budget Planner vs actual · Financial Health Index
    → Events (+ regras FFP)
    (Shock · Return Analyzer · Financial Digital Twin aconselham sem mutar até commit)
    → Financial History
```

Ver: [LLD README](README.md) · [ADR-0191](../04-decisions/ADR-0191.md) · [DS-006](../15-data-specs/DS-006-financial-data-model.md) · [SDS-017](../09-blueprints/SDS-017-financial-system.md) · [PSP-024](../12-psp/systems/PSP-024-economy.md) · [LLD-019](LLD-019-club-entity-architecture.md) · [LLD-024](LLD-024-transfer-market-contracts-negotiation-architecture.md)
