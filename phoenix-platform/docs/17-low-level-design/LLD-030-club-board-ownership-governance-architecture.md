# LLD-030 — Club Board, Ownership & Governance Architecture

**Low-Level Design**

| Campo | Valor |
|-------|-------|
| **Versão** | 1.1 |
| **Estado** | Baseline |
| **Prioridade** | Crítica |
| **ID índice** | 17.L30 |
| **Pacote alvo** | `@phoenix/domain` · `simulation-board` · tipos em `shared` / `engine-api` |
| **Dependências** | [LLD-017](LLD-017-football-data-model-entity-architecture.md) · [LLD-019](LLD-019-club-entity-architecture.md) · [LLD-024](LLD-024-transfer-market-contracts-negotiation-architecture.md) · [LLD-028](LLD-028-club-finance-economy-business-architecture.md) · [LLD-029](LLD-029-stadium-facilities-infrastructure-architecture.md) · [LLD-002](LLD-002-world-clock-temporal-simulation-engine.md) · [LLD-004](LLD-004-event-bus-delivery-pipeline.md) · [SDS-023](../09-blueprints/SDS-023-board-ownership.md) · [PSP-026](../12-psp/systems/PSP-026-board.md) · [Runtime](../02-architecture/Runtime.md) |
| **ADR fundação** | [ADR-0077](../04-decisions/ADR-0077.md) · [ADR-0109](../04-decisions/ADR-0109.md) · [ADR-0182](../04-decisions/ADR-0182.md) · [ADR-0187](../04-decisions/ADR-0187.md) · [ADR-0191](../04-decisions/ADR-0191.md) · [ADR-0192](../04-decisions/ADR-0192.md) |
| **ADR desenho** | [ADR-0193](../04-decisions/ADR-0193.md) **Club Governance** · Autonomous Club Governance Model · Institutional DNA Evolution · Board Personality Matrix · Strategic Decision Engine · Fan Pressure Index · Governance Stability Model · Long-Term Vision Planner · Institutional Crisis Engine · Governance Digital Twin |
| **Changelog v1.0** | Club Governance (12): Ownership · Shareholders · President · Board of Directors · Executive Committee · Governance Policies · Strategic Planning · Club Objectives · Investor Relations · Fan Relations · Decision Engine · Governance History · oito inovações · Baseline · Direcção≠só orçamento · IIM · Ownership→Board→Executive→Sporting · aprofunda SDS-023 · PSP-026 · ADR-0077/0109 · LLD-019 Governance |
| **Changelog v1.1** | **Club Governance** (13): **Ownership Engine** · **Shareholder Manager** · President · **Board Personality Matrix** · Executive Committee · Governance Policies · Strategic Planning · Decision Engine · **Fan Pressure Index** · **Governance Stability Model** · **Institutional Crisis Engine** · **Governance Digital Twin** · Governance History (§4 · §40) — Personality/Pressure/Stability/Crisis/Twin 1ª classe; Ownership/Shareholders renomeados; Board of Directors · Club Objectives · Investor/Fan Relations (v1.0) → capacidade / absorvidos |
| **Nota homónimos** | **Club Governance** (este LLD) = governação institucional do clube — aprofunda [SDS-023](../09-blueprints/SDS-023-board-ownership.md) · [PSP-026](../12-psp/systems/PSP-026-board.md) · [ADR-0077](../04-decisions/ADR-0077.md) · [ADR-0109](../04-decisions/ADR-0109.md). **Ownership Engine** · **Shareholder Manager** · **Board Personality Matrix** · **Fan Pressure Index** · **Governance Stability Model** · **Institutional Crisis Engine** · **Governance Digital Twin** = 1ª classe (v1.1). **Board of Directors** / **Club Objectives** / **Investor Relations** / **Fan Relations** (v1.0) → estrutura de cargos sob Personality Matrix · Executive; objectivos sob Strategic Planning; investor/fan sinais sob Ownership/Shareholder/Pressure — não ramos §4. **≠ Architecture Governance**. **≠** [GPS-003](../26-gameplay/GPS-003-club-management-board-expectations-organizational-governance.md) **Club Management Architecture** (norma GPS de experiência · expectativas · cultura · avaliação — [ADR-0274](../04-decisions/ADR-0274.md); sinónimo v1.0 Club Governance & Board Management Architecture). Sporting Management = mandato sob Decision/Executive. **IIM** ≠ estratégia actual. **Fan Pressure** ≠ Supporters SoT. **Decision Engine** ≠ AI Manager. **Governance Digital Twin** ≠ Club Organization Digital Twin GPS-003 · ≠ Club/Finance/Infra/Architecture Twin. Rascunho “ADR-137…” = ADR-0193 (alias ADR-142); **ADR-0137** = Media; alias ADR-137 = [ADR-0188](../04-decisions/ADR-0188.md) Player Development. |

**Implementação F70 (2026-08-06):** wire Sat→Pressure — `fanPressure = 100 − boardSatisfaction` · `SatisfactionDerivedFanPressure` · world permanece v21. **Fora:** dims · buckets · Twin genérico (= F71+).

**Implementação F69 (2026-08-06):** wire `boardSatisfaction` em `boardApproves` / `boardEffective` · UI `· Sat{n}` · world permanece v21. **Fora:** Sat→Pressure F70 ✅ · dims · buckets · Twin genérico (= F71+).

**Implementação F68 (2026-08-06):** Results→Satisfaction stub — `boardSatisfaction` = `reputation.results` · UI `Sat:` · world v21. **Fora:** Wire Board F69 ✅ · Pressure F70 ✅ · dims / Twin genérico (= F71+).

**Implementação F67 (2026-08-06):** Governance Digital Twin stub HoF — `INDUCT_HOF` / `STATUS_QUO` preview · UI `GovTwin:`.  
**Implementação F73 (2026-08-08):** Twin **commit** INDUCT · `twinSatisfactionBonus` · `lastTwinScenario` · world v22.  
**Implementação F74 (2026-08-08):** `FIRE_MANAGER` preview/commit (espelho inverso INDUCT) · world v23.  
**Implementação F75 (2026-08-08):** `NEW_INVESTOR` preview/commit (espelho INDUCT) · world v24.  
**Implementação F76 (2026-08-08):** `BUDGET_UP` preview/commit (espelho INDUCT) · world v25.  
**Implementação F77 (2026-08-08):** Governance History ring (`governanceHistory`) em Twin commit · world v26.  
**Implementação F78 (2026-08-08):** Bridge + UI `GovHist:` compacto · nav F78 · world permanece **v26**.  
**Implementação F79 (2026-08-08):** History `kind`/`label` · `appendDecision` · bridge `gov-decision` · world **v27**.  
**Implementação F80 (2026-08-08):** Auto-log `President`/`Ownership` no UpsertCareerRecord · world permanece **v27**.  
**Implementação F81 (2026-08-08):** Auto-log `Shareholders` no UpsertCareerRecord · world permanece **v27**.  
**Implementação F82 (2026-08-08):** `clubCash` stub · Twin `BUDGET_UP`/+1M · `NEW_INVESTOR`/+500k · `FIRE`/0 · bridge · world **v28**.  
**Implementação F83 (2026-08-09):** Twin preview `clubCash` from→to · UI ` · Cash 10.0M` · nav F83 · world permanece **v28**.  
**Implementação F84 (2026-08-09):** `majorityInfluence = sum(b²)/100` · default 28 · nav F84 · world permanece **v28**.  
**Implementação F85 (2026-08-09):** Personality mapa Sat→eixos (prudence=100−Sat) · nav F85 · world permanece **v28**.  
**Implementação F86 (2026-08-09):** `cashHistory` ring · Twin append · UI `CashHist:` · world **v29**.  
**Implementação F87 (2026-08-09):** `ClubCash.adjust` · `adjustClubCash` · bridge `cash-adjust` · nav F87 · world permanece **v29**.  
**Implementação F88 (2026-08-09):** Wages `−10k/dia` · Matchday `+50k` · nav F88 · world permanece **v29**. **Fora:** financialHealth.  
**Implementação F89 (2026-08-09):** `ClubCash.financialHealth(cash)=(cash/100_000).coerceIn(0,100)` derivado · bridge `hof.financialHealth` · UI ` · FH{n}` · nav F89 · world permanece **v29**. **Fora:** campo persistido · bands · Health Index LLD-028 completo.  
**Implementação F90 (2026-08-09):** `financialHealthBand` Crit/Weak/Ok/Strong · bridge · UI ` · FH{n} {band}` · nav F90 · world permanece **v29**. **Fora:** campo persistido · Health Index LLD-028 · `setClubCash`.  
**Implementação F91 (2026-08-09):** `ClubCash.set` · `setClubCash` · bridge `cash-set` · nav F91 · world permanece **v29**. **Fora:** UI form · FH persistido · Health Index LLD-028.  
**Implementação F92 (2026-08-09):** Crit band → `boardEffective −5` (`CRIT_BOARD_PENALTY`) · Twin herda · nav F92 · world permanece **v29**. **Fora:** Weak/Ok penalties · FH persistido · LLD-028.  
**Implementação F93 (2026-08-09):** UI `CashForm` Adjust/Set · hooks bridge · Dashboard + SidePanel · nav F93 · world permanece **v29**. **Fora:** UI milhões · FH persistido · LLD-028.  
**Implementação F94 (2026-08-09):** Weak band → `boardEffective −2` (`WEAK_BOARD_PENALTY`) · Crit continua `−5` · nav F94 · world permanece **v29**. **Fora:** Ok/Strong penalties · FH persistido · LLD-028.  
**Implementação F95 (2026-08-09):** Ok band → `boardEffective −1` (`OK_BOARD_PENALTY`) · escala Crit5/Weak2/Ok1/Strong0 · nav F95 · world permanece **v29**. **Fora:** Strong penalty · FH persistido · UI penalty · LLD-028.  
**Implementação F96 (2026-08-09):** `boardCashPenalty(cash)` · bridge · UI ` · −{n}` (omit Strong) · nav F96 · world permanece **v29**. **Fora:** FH persistido · UI milhões · LLD-028.  
**Implementação F97 (2026-08-10):** `CareerRecord.financialHealth` + `financialHealthBand` write-through (`ClubCash.adjust` · Twin · fromSession) · save/load · world **v30** · nav F97. **Fora:** LLD-028 Health Index · UI milhões.  
**Implementação F98 (2026-08-10):** CashForm input milhões (`0.25`→250k) · bridge intacto · nav F98 · world permanece **v30**. **Fora:** toggle M/raw · LLD-028.  
**Implementação F99 (2026-08-11):** Sponsor stub diário `+5k` em `advanceDays` (`REASON_SPONSOR`) · CashHist · nav F99 · world permanece **v30**. **Fora:** Twin `CASH_CRISIS` · contratos · LLD-028.  
**Implementação F100 (2026-08-11):** Twin `CASH_CRISIS` (espelho inverso BUDGET_UP: −1M · board−5 · P+5 · sat−5) · preview/commit · CashHist · world **v31** · nav F100. **Fora:** auto-trigger · Crisis Engine · LLD-028.  
**Implementação F101 (2026-08-11):** Botão UI `Cash Crisis` · hook `govtwin-commit` · Dashboard + SidePanel · nav F101 · world permanece **v31**. **Fora:** row completa Twin · preview switch · LLD-028.  
**Implementação F102 (2026-08-11):** `GovTwinActions` (Induct/Fire/Investor/Budget/Crisis) · substitui botão único · nav F102 · world permanece **v31**. **Fora:** STATUS_QUO · preview switch · LLD-028.  
**Implementação F103 (2026-08-11):** Preview switch — bridge `govtwin-preview` · select choice + Commit · GovTwin mostra scenario selecionado · nav F103 · world permanece **v31**. **Fora:** STATUS_QUO · mapa 5-previews · LLD-028.  
**Implementação F104 (2026-08-11):** Quo (`STATUS_QUO`) na row Twin · default select · Commit no-op · nav F104 · world permanece **v31**. **Fora:** Commit disabled · LLD-028.  
**Implementação F105 (2026-08-11):** Commit disabled quando Quo selecionado · preview Quo intacto · nav F105 · world permanece **v31**. **Fora:** hide Commit · title hint · LLD-028.  
**Implementação F106 (2026-08-11):** CashForm choice M/Raw · default M · trocar limpa valor · bridge intacto · nav F106 · world permanece **v31**. **Fora:** localStorage · LLD-028.  
**Implementação F107 (2026-08-11):** `ManagerPrefs.cashUnit` M/Raw persistido · CashForm init/write · nav F107 · world permanece **v31**. **Fora:** sync multi-painel · Twin select persist · LLD-028.  
**Implementação F108 (2026-08-11):** `useCashUnit` + `CASH_UNIT_EVENT` · sync Dashboard/SidePanel · limpa valor no sync · nav F108 · world permanece **v31**. **Fora:** Twin select persist · LLD-028.  
**Implementação F109 (2026-08-11):** `govTwinScenario` prefs + `useGovTwinScenario` sync · init prefs→last→Quo · nav F109 · world permanece **v31**. **Fora:** title hint Quo · LLD-028.  
**Implementação F110 (2026-08-12):** Commit `title` busy/`Ocupado` · Quo/`Sem commit em Status Quo` · nav F110 · world permanece **v31**. **Fora:** tooltip custom · LLD-028.  
**Implementação F111 (2026-08-12):** Twin `historyLabel` PT no GovHist · UI `label (scenario)` · Pers nomes PT · nav F111 · world permanece **v31**. **Fora:** auto-log President PT · LLD-028 · Crisis auto-trigger.  
**Implementação F112 (2026-08-12):** UI Health Index lite ` · HI{n}{band}` (= `financialHealth`) · nav F112 · world permanece **v31**. **Fora:** dims multi · ledger · rename interno.

**Implementação F66 (2026-08-06):** Shareholders breakdown 4 buckets (40/25/20/15) · `majorityInfluence=majority` · UI `Sh: a/b/c/d` · world era v20 (agora v21 via F68). **Fora:** Twin F67 ✅ / Sat F68–F70 ✅ / dims (= F71+).

**Implementação F65 (2026-08-06):** stub `PresidentSnapshot` (4y · R50 · L50) · `boardSignal` wire em boardEffective · UI `Pres:` / `· Pres{n}` · world era v19 (agora v21 via F66–F68). **Fora:** Breakdown F66 ✅ / Twin F67 ✅ / Sat F68–F70 ✅ / dims (= F71+).

**Implementação F64 (2026-08-06):** stub `ShareholdersSnapshot` (majorityInfluence) · wire em boardEffective · UI `Sh:` · world era v18 (agora v21 via F65–F68). **Fora:** Breakdown F66 ✅ / President F65 ✅ / Twin F67 ✅ / Sat F68–F70 ✅.

**Implementação F63 (2026-08-06):** wire `ownership.longTermVision` em `boardApproves` / `boardEffective` · UI `· V{n}` · world era v17 (agora v21 via F64–F68). **Fora:** Shareholders F64–F66 ✅ · President F65 ✅ · Twin F67 ✅ · Sat F68–F70 ✅ · dims (= F71+).

**Implementação F62 (2026-08-06):** stub `OwnershipSnapshot` (PRIVATE · longTermVision 50) · persistido · bridge · UI `Own:` · world v17. **Fora:** Wire F63 ✅ · Shareholders F64–F66 ✅ · President F65 ✅ · Twin F67 ✅ · Sat F68–F70 ✅ · dims (= F71+).

**Implementação F61 (2026-08-06):** wire `BoardPersonality.average()` em `boardApproves` / `boardEffective` · bridge `personalityAvg` · UI `Pers{avg}` · world era v16 (agora v17 via F62). **Fora:** Ownership F62 ✅ · Shareholders / Twin · dims dinâmicas · Results→Satisfaction rico (= F63+).

**Implementação F60 (2026-08-05):** stub `BoardPersonality` (Ambição·Prudência·Paciência·Carisma·Competência·Visão = 50) · persistido · bridge · UI `Pers:` · world v16. **Fora:** Wire F61 ✅ · Ownership / Twin · Results→Satisfaction rico (= F62+).

**Implementação F59 (2026-08-05):** UI `P{n} · Δ · at` nos botões Votar e prefixo Pressure no toggle · world era v15 (agora v16 via F60). **Fora:** Personality F60 ✅ · Ownership / Twin · Results→Satisfaction rico (= F61+).

**Implementação F58 (2026-08-05):** `fanPressureHistory` ring datado (máx. 8) · bridge trend/at · UI Pressure no toggle · world v15 (agora v16 via F60). **Fora:** Δ UI F59 ✅ · Personality F60 ✅ · Ownership / Twin · Results→Satisfaction rico (= F61+).

**Implementação F57 (2026-08-05):** stub `FanPressurePort` / `ReputationDerivedFanPressure` no Living HoF (LLD-036) — pressure = `100 − reputationOverall` · `fanPressure` snapshot · fansSentiment = max(legacy, 100−pressure) · world v14 (agora v16 via F58–F60). **Fora:** Ownership / Twin · Results→Satisfaction rico (= F61+). History/Δ/Personality = F58–F60 ✅ · UI prefs = F51–F56 ✅.

**Implementação F50 (2026-08-05):** stub `BoardSentimentPort` / `ReputationBoardSentiment` no Living HoF (LLD-036) — sentiment = `reputationOverall` · snapshot/history · world v13 (agora v14 via F57). **Fora:** Ownership / Personality Matrix / Twin (= F58+). Fan Pressure = F57 ✅ · UI dates/ring/toggle/prefs = F51–F56 ✅.

---

## 1. Objetivo

Definir a **arquitectura completa da governação institucional** dos clubes.

Inclui:

- proprietários;
- acionistas;
- direcção;
- presidente;
- conselho de administração;
- eleições;
- investidores;
- estratégia institucional;
- supervisão.

**Regra de ouro:** a direcção **não** controla apenas o orçamento — controla a **visão futura** do clube ([ADR-0193](../04-decisions/ADR-0193.md) · [ADR-0077](../04-decisions/ADR-0077.md)).

**Fronteiras:**

| Este documento | Não é este documento |
|----------------|----------------------|
| Arquitectura Board / Ownership / Governance | Comportamento detalhado → [SDS-023](../09-blueprints/SDS-023-board-ownership.md) · [PSP-026](../12-psp/systems/PSP-026-board.md) |
| Runtime SoT de governação institucional | Normas GPS de gestão / expectativas / cultura → [GPS-003](../26-gameplay/GPS-003-club-management-board-expectations-organizational-governance.md) ([ADR-0274](../04-decisions/ADR-0274.md)) |
| Strategic Planning / Vision Planner (runtime SoT) | Normas GPS de planeamento de épocas / projecto plurianual (**Strategic Planning Architecture**) → [GPS-006](../26-gameplay/GPS-006-season-planning-long-term-strategy-multi-year-project.md) ([ADR-0277](../04-decisions/ADR-0277.md)) — ≠ este LLD |
| Âncora Governance no Club | [LLD-019](LLD-019-club-entity-architecture.md) (ref; lógica aqui) |
| Orçamento / ledger | [LLD-028](LLD-028-club-finance-economy-business-architecture.md) |
| Transfer / contratos | [LLD-024](LLD-024-transfer-market-contracts-negotiation-architecture.md) |
| Adeptos SoT / sentimento | Supporters SDS-025 · PSP-028 (Fan Pressure consome sinais) |
| Treinador / AI no dia-a-dia | SDS-022 / AI Manager — opera **sob** Sporting Management |
| Architecture Governance (plataforma) | TAS-020 · ADR-0164 |
| Normas TMFBS de propriedade / investidores / grupos multiclube / governação corporativa | [TMFBS-009](../30-transfer-market-football-business/TMFBS-009-club-ownership-investors-multi-club-groups-corporate-governance-architecture.md) ([ADR-0312](../04-decisions/ADR-0312.md)) — ≠ Club Ownership Architecture · Ownership Engine / Governance Digital Twin LLD ≠ Ownership Models / Corporate Governance / Ownership Governance Engine / Ownership Digital Twin TMFBS · este LLD = SoT runtime |
| Normas FCCS de ADN / filosofia / cultura / valores / tradição / legado | [FCCS-002](../31-fan-community-club-culture/FCCS-002-club-identity-culture-philosophy-institutional-dna-architecture.md) ([ADR-0315](../04-decisions/ADR-0315.md)) — ≠ Club Identity Architecture · Institutional DNA Evolution / Ownership Engine LLD ≠ Institutional DNA / Institutional DNA Engine / Institutional Digital Twin FCCS · este LLD = governação runtime |

---

## 2. Filosofia

```
A direção não controla apenas o orçamento.

Controla a visão futura do clube.
```

```
Quem manda?          → Ownership Engine · Shareholder Manager · President · Board Personality Matrix
Quem executa?        → Executive Committee · Sporting Management (mandato)
O que queremos?      → Governance Policies · Strategic Planning
Como decidimos?      → Decision Engine · Twin
Quem pressiona?      → Fan Pressure Index · Crisis Engine
Estamos estáveis?    → Governance Stability Model
O que recordamos?    → Governance History (nunca apagado)
```

**IIM:** mudanças de dono/board **não** resetam Club DNA / identidade histórica ([ADR-0077](../04-decisions/ADR-0077.md)).

---

## 3. Arquitectura geral

```
                 Club Governance
                           │
      ┌────────────────────┼────────────────────┐
      ▼                    ▼                    ▼
 Ownership Engine      Personality Matrix*  Executive
 Shareholder Manager   President            Decision Engine
      ▼                    ▼                    ▼
 Policies · Planning   Fan Pressure         Stability · Crisis
                       Twin                 Governance History
```

\* Personality Matrix = comportamento do Board (cargos SDS-023 absorvidos como capacidade).

Consumo:

```
Club · Finance · Transfer · Infrastructure · Supporters · Media · AI Manager
        → LLD-030 Club Governance
        → SDS-023 · LLD-004 events
```

---

## 4. Componentes — Club Governance

Organização canónica (§40):

```
Club Governance
│
├── Ownership Engine
├── Shareholder Manager
├── President
├── Board Personality Matrix
├── Executive Committee
├── Governance Policies
├── Strategic Planning
├── Decision Engine
├── Fan Pressure Index
├── Governance Stability Model
├── Institutional Crisis Engine
├── Governance Digital Twin
└── Governance History
```

| Componente | Papel |
|------------|-------|
| **Ownership Engine** | Modelo de propriedade · visão longo prazo · DNA Evolution · investor signals — promovido |
| **Shareholder Manager** | Maioritário · institucionais · pequenos · associação — promovido |
| **President** | Mandato · reputação · perfil · visão · tolerância ao risco |
| **Board Personality Matrix** | Ambição·Prudência·Paciência·Carisma·Competência·Visão · cargos Board — 1ª classe (§25) |
| **Executive Committee** | Gestão diária institucional · execução |
| **Governance Policies** | Formação · sustentabilidade · internacionalização · contenção · … |
| **Strategic Planning** | Vision Planner (§29) · objectivos multi-época (absorve Club Objectives) |
| **Decision Engine** | Processo · Strategic Decision (§26) · votação · confiança no treinador |
| **Fan Pressure Index** | Resultados→Satisfação→Pressão→Reação — 1ª classe (§27) |
| **Governance Stability Model** | Estabilidade institucional — 1ª classe (§28) |
| **Institutional Crisis Engine** | Crises institucionais — 1ª classe (§30) |
| **Governance Digital Twin** | What-if institucional — 1ª classe (§31); nunca muta até commit |
| **Governance History** | Ledger institucional imutável |

Inovações (§24–§31) — mapa em §40. **Board of Directors** · **Club Objectives** · **Investor Relations** · **Fan Relations** (v1.0) = capacidade / absorvidos. Sporting Management = mandato sob Decision/Executive.

---

## 5. Ownership Engine — Propriedade

**Componente promovido** (§4).

Modelos: associação · SAD · empresa privada · fundo · individual · estatal.

Visão de longo prazo; **Institutional DNA Evolution** (§25); sinais de investidores (Investor Relations v1.0 = capacidade). Mudanças **não** apagam IIM.

Nome v1.0: Ownership.

---

## 6. Shareholder Manager — Acionistas

**Componente promovido** (§4).

Maioritário · institucionais · pequenos · associação de sócios — poder de influência.

Nome v1.0: Shareholders.

---

## 7. President — Presidente

Possui: mandato · reputação · perfil de liderança · visão estratégica · tolerância ao risco.

Apenas **um** presidente activo (invariante).

---

## 8. Board Personality Matrix — Conselho / personalidade

**Componente de 1ª classe** (§4 · §25).

```
Dirigente
│
├── Ambição
├── Prudência
├── Paciência
├── Carisma
├── Competência
└── Visão
```

Influenciam votações e decisões. Cargos (Presidente · VP · Financeiro · Desportivo · Operacional · Fiscal) = estrutura sob esta matriz — nome v1.0 Board of Directors absorvido.

Alinha ADR-0109 / SDS-023.

---

## 9. Executive Committee — Comité executivo

Gestão diária institucional: despesas (com Finance) · executivos · departamentos · resultados.

≠ Matchday coaching · ≠ Transfer Negotiation SoT.

---

## 10. Governance Policies — Políticas

Exemplos: formação · sustentabilidade financeira · internacionalização · contratação jovem · contenção salarial.

Alimentam Decision Engine · Transfer mandate · Finance Budget.

---

## 11. Strategic Planning — Planeamento

**Long-Term Vision Planner** (§29) · objectivos desportivos/financeiros/patrimoniais/reputacionais (Club Objectives v1.0 absorvido).

Decisões do dia a dia avaliadas face ao plano.

---

## 12. Decision Engine — Processo de decisão

```
Problema → Análise → Discussão → Votação → Decisão → Execução
```

**Strategic Decision Engine** (§26): impacto financeiro · desportivo · institucional · risco · retorno.

Confiança no treinador · avaliação institucional · mudança de liderança. Consome Personality · Pressure · Stability · Crisis · Twin.

---

## 13. Fan Pressure Index — Pressão dos adeptos

**Componente de 1ª classe** (§4 · §27).

```
Resultados → Satisfação → Pressão → Reação da Direção
```

Consome Supporters SDS-025 — **não** é SoT. Nome v1.0: Fan Relations (monitorização absorvida).

---

## 14. Governance Stability Model — Estabilidade

**Componente de 1ª classe** (§4 · §28).

Depende de: resultados · finanças · conflitos internos · confiança dos investidores · apoio dos adeptos.

Mudanças frequentes de liderança afectam o desempenho global.

---

## 15. Institutional Crisis Engine — Crises

**Componente de 1ª classe** (§4 · §30).

Exemplos: conflito direcção↔treinador · protestos · tentativa de aquisição · divergências entre acionistas · escândalos financeiros.

Podem alterar profundamente a trajectória.

---

## 16. Governance Digital Twin — Twin

**Componente de 1ª classe** (§4 · §31).

Simula: despedir treinador · novo investidor · vender jogador-chave · aumentar orçamento · alterar política de contratações.

**Nunca** muta SoT até commit. ≠ Club / Finance / Infra / Architecture Twin.

---

## 17. Governance History — Histórico

Nunca é eliminado. Inclui: presidentes · mandatos · investidores · decisões · políticas adoptadas.

---

## 18. Confiança no treinador & mudança de liderança

Avaliação contínua: resultados · evolução · objectivos · adeptos · balneário.

Mudança por: eleições · demissão · venda · destituição · fim de mandato. IIM preservado.

---

## 19. Eventos

Eventos publicados (via [LLD-004](LLD-004-event-bus-delivery-pipeline.md)):

- eleição;
- mudança de proprietário;
- despedimento do treinador;
- aprovação de investimento;
- alteração estratégica;
- crise institucional;
- limiar de Fan Pressure;
- alerta de estabilidade.

---

## 20. Invariantes

O sistema garante:

- apenas um presidente activo;
- histórico institucional permanente;
- coerência entre decisões e políticas;
- continuidade da governação;
- Twin / Crisis scenarios sem mutar SoT até commit;
- IIM / Club DNA não resetados por mudança de board;
- Board ≠ seleccionador / Match Engine.

---

## 21. Performance

Objectivos: processamento mensal · decisões assíncronas · actualização incremental · baixo impacto na simulação (tick).

---

## 22. Critérios de aceitação

O sistema está concluído quando:

- a direcção reage ao desempenho do clube;
- decisões são coerentes com a estratégia;
- mudanças institucionais influenciam a gestão;
- histórico permanece íntegro;
- Twin · Personality · Pressure · Stability · Crisis cobertos por testes.

---

## 23. Testes

Devem existir testes para: eleições · mudança de proprietário · investimentos · despedimento de treinador · objectivos · sucessão · integração Finance/Fans · Twin isolation · IIM preservado · Pressure/Stability/Crisis.

---

## 24. Inovação — Institutional DNA Evolution → Ownership Engine

Evolução gradual identidade/estratégia sem reset IIM. Vive sob **Ownership Engine** · LLD-019 Club DNA.

---

## 25. Inovação — Board Personality Matrix → Board Personality Matrix (1ª classe)

**Componente de 1ª classe** (§4). Características dos dirigentes influenciam votações.

---

## 26. Inovação — Strategic Decision Engine → Decision Engine

Avaliação multi-dimensional. Vive sob **Decision Engine**.

---

## 27. Inovação — Fan Pressure Index → Fan Pressure Index (1ª classe)

**Componente de 1ª classe** (§4). Pressão contínua dos adeptos.

---

## 28. Inovação — Governance Stability Model → Governance Stability Model (1ª classe)

**Componente de 1ª classe** (§4). Estabilidade vs múltiplos eixos.

---

## 29. Inovação — Long-Term Vision Planner → Strategic Planning

Planos multi-ano. Vive sob **Strategic Planning**.

---

## 30. Inovação — Institutional Crisis Engine → Institutional Crisis Engine (1ª classe)

**Componente de 1ª classe** (§4). Crises que alteram trajectória.

---

## 31. Inovação — Governance Digital Twin → Governance Digital Twin (1ª classe)

**Componente de 1ª classe** (§4). What-if; **nunca** muta até commit.

---

## 32. Track de implementação (orientação)

| ID | Entrega |
|----|---------|
| T1 | Mapa Club Governance v1.1 (§4 · 13) + SDS-023 · PSP-026 · ADR-0077/0109 · LLD-019 |
| T2 | Ownership Engine · Shareholder Manager · IIM bridge · investor signals |
| T3 | President · Board Personality Matrix (1ª classe) · um presidente activo |
| T4 | Executive Committee · Sporting Management (mandato) |
| T5 | Governance Policies · Strategic Planning · Vision Planner · objectivos |
| T6 | Decision Engine · Strategic Decision · confiança no treinador |
| T7 | Fan Pressure Index (1ª classe) |
| T8 | Governance Stability Model · Institutional Crisis Engine (1ª classe) |
| T9 | Governance Digital Twin (1ª classe · isolation) |
| T10 | Governance History · events · suites · integração Finance/Transfer/Fans |

---

## 33. Referências

| Artefacto | Link |
|-----------|------|
| ADR desenho | [ADR-0193](../04-decisions/ADR-0193.md) |
| Norma GPS (experiência) | [GPS-003](../26-gameplay/GPS-003-club-management-board-expectations-organizational-governance.md) · [ADR-0274](../04-decisions/ADR-0274.md) — ≠ este LLD |
| Comportamento / produto | [SDS-023](../09-blueprints/SDS-023-board-ownership.md) · [PSP-026](../12-psp/systems/PSP-026-board.md) |
| IIM / cadeia governação | [ADR-0077](../04-decisions/ADR-0077.md) · [ADR-0109](../04-decisions/ADR-0109.md) |
| Club / Finance / Transfer / Infra | [LLD-019](LLD-019-club-entity-architecture.md) · [LLD-028](LLD-028-club-finance-economy-business-architecture.md) · [LLD-024](LLD-024-transfer-market-contracts-negotiation-architecture.md) · [LLD-029](LLD-029-stadium-facilities-infrastructure-architecture.md) |
| Domain model | [LLD-017](LLD-017-football-data-model-entity-architecture.md) |
| Bus / Clock | [LLD-004](LLD-004-event-bus-delivery-pipeline.md) · [LLD-002](LLD-002-world-clock-temporal-simulation-engine.md) |

---

## 40. Refinamento — Club Governance

```
Club Governance
│
├── Ownership Engine
├── Shareholder Manager
├── President
├── Board Personality Matrix
├── Executive Committee
├── Governance Policies
├── Strategic Planning
├── Decision Engine
├── Fan Pressure Index
├── Governance Stability Model
├── Institutional Crisis Engine
├── Governance Digital Twin
└── Governance History
```

### Regras

1. **Club Governance** é a organização canónica (§4) — 13 componentes.  
2. Direcção = visão futura — não só orçamento.  
3. **Board Personality Matrix** · **Fan Pressure Index** · **Governance Stability Model** · **Institutional Crisis Engine** · **Governance Digital Twin** são 1ª classe.  
4. Ownership→Board→Executive→Sporting (mandato); Board ≠ seleccionador.  
5. IIM / Club DNA não resetados por mudança de propriedade.  
6. Twin / Crisis scenarios **não** mutam até commit.  
7. Board of Directors · Objectives · Investor/Fan Relations (v1.0) → capacidade / absorvidos.  
8. Fan Pressure consome Supporters — não é SoT.  
9. ≠ Architecture Governance (plataforma).  
10. History nunca apagado; um presidente activo.

### Motivo

Taxonomia legível — ownership/shareholders, personalidade do board, pressão, estabilidade, crise e twin explícitos.

### Fronteiras

| Este conceito… | …não é… |
|----------------|---------|
| Club Governance (LLD-030) | Architecture Governance · Club DNA SoT · AI Manager · Match Engine |
| Ownership Engine | Club Identity reset · Ownership (nome v1.0) |
| Shareholder Manager | Finance Ledger SoT · Shareholders (nome v1.0) |
| President | Treinador / seleccionador |
| Board Personality Matrix | Blob Board · só cargos sem personalidade · Board of Directors (nome v1.0) |
| Executive Committee | Transfer Negotiation · Matchday coaching |
| Governance Policies | Hardcode sem override / Twin |
| Strategic Planning | Só reagir ao último resultado · Club Objectives (ramo v1.0) |
| Decision Engine | AI Manager Decision · Match Decision Graph |
| Fan Pressure Index | Supporters SoT · Fan Relations (nome v1.0) |
| Governance Stability Model | Estabilidade cosmético · só inovação |
| Institutional Crisis Engine | RNG sem trajectória · só inovação |
| Governance Digital Twin | Club/Finance/Infra/Architecture Twin · mutar save |
| Governance History | Soft-delete · BI warehouse |
| Investor Relations / Fan Relations / Board of Directors / Club Objectives (v1.0) | Ramos §4 — agora capacidade / absorvidos |

### Mapa inovações → componentes

| Inovação | Onde |
|----------|------|
| Institutional DNA Evolution (§24) | **Ownership Engine** · LLD-019 Club DNA / IIM |
| Board Personality Matrix (§25) | **Board Personality Matrix** |
| Strategic Decision Engine (§26) | **Decision Engine** |
| Fan Pressure Index (§27) | **Fan Pressure Index** |
| Governance Stability Model (§28) | **Governance Stability Model** |
| Long-Term Vision Planner (§29) | **Strategic Planning** |
| Institutional Crisis Engine (§30) | **Institutional Crisis Engine** |
| Governance Digital Twin (§31) | **Governance Digital Twin** |

### Mapa v1.0 → v1.1

| v1.0 | v1.1 |
|------|------|
| Ownership | **Ownership Engine** |
| Shareholders | **Shareholder Manager** |
| Board of Directors | **Board Personality Matrix** (+ cargos capacidade) |
| Club Objectives | Absorvido em Strategic Planning |
| Investor Relations | Capacidade sob Ownership Engine · Shareholder Manager |
| Fan Relations | **Fan Pressure Index** |
| Personality / Pressure / Stability / Crisis / Twin (inov.) | **…** 1ª classe |
| President · Executive · Policies · Planning · Decision · History | (inalterados / reforçados) |

### Mapa SDS-023 → Club Governance

| SDS-023 | LLD-030 |
|---------|---------|
| Ownership | Ownership Engine · Shareholder Manager |
| Board | President · Board Personality Matrix |
| Executive Committee | Executive Committee |
| Sporting Management | Mandato sob Decision / Executive / Planning |
| Personality Matrix | **Board Personality Matrix** |
| Governance Cycle | Decision Engine · Strategic Planning · Stability · Crisis |
| IIM | DNA Evolution · Ownership Engine · LLD-019 |

### Fluxo de governação

```
Ownership Engine / Shareholder Manager / Fan Pressure / Results / Finance
    → Policies · Strategic Planning
    → Decision Engine (Personality · Stability · Crisis · Twin)
    → Mandatos → Finance · Transfer · Infra · Sporting / AI Manager
    → Governance History · Events
```

Ver: [LLD README](README.md) · [ADR-0193](../04-decisions/ADR-0193.md) · [SDS-023](../09-blueprints/SDS-023-board-ownership.md) · [PSP-026](../12-psp/systems/PSP-026-board.md) · [ADR-0077](../04-decisions/ADR-0077.md) · [ADR-0109](../04-decisions/ADR-0109.md) · [LLD-019](LLD-019-club-entity-architecture.md) · [GPS-003](../26-gameplay/GPS-003-club-management-board-expectations-organizational-governance.md) · [ADR-0274](../04-decisions/ADR-0274.md) · [GPS-006](../26-gameplay/GPS-006-season-planning-long-term-strategy-multi-year-project.md) · [ADR-0277](../04-decisions/ADR-0277.md)
