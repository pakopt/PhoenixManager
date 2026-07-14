# Master Roadmap v1.0 — Sincronização com o código

**Plano mestre (Cursor):** `phoenix_manager_game_2a890b62.plan.md`  
**Roadmap vivo (lançamento):** [`docs/plano.md`](../plano.md)  
**Versão actual:** `0.8.4` · **Fase:** **E — Lançamento**

Este ficheiro liga o **Master Roadmap** do plano de arquitectura ao estado **real** do repositório.

---

## Mapa de fases (plano → implementação)

| Plano (A–D) | Módulos | Versão alvo | Estado no repo |
|-------------|---------|-------------|----------------|
| **A — Fundação** | Core, DB, EventBus, World, Save | v0.1 | ✅ `phoenix_core`, `phoenix_data`, `phoenix_engine` boot |
| **B — Simulação** | Player, Club, Comp, Match, Transfer, Economy | v0.2–v0.6 | ✅ Liga, taça, mercado, staff, lesões |
| **C — Experiência** | UI Flutter, Express/Diretor, saves | v0.7 | ✅ `phoenix_ui`, `phoenix_manager` |
| **D — Polimento** | Conquistas, palmarés, Simulation Lab, UX | v0.8 | ✅ Fase D concluída |
| **E — Lançamento** | Mac, Android, iOS, Play Store, App Store | v0.8α→v1.0 | 🔄 **em curso** — ver [`plano.md`](../plano.md) |
| **F — Pós-v1** | Steam, IA avançada, multiplayer | pós-v1.0 | ⏸️ adiado |

> No plano mestre, «Fase D — Lançamento» (Steam, beta) corresponde à **Fase E** deste repo (lançamento mobile/desktop local).

---

## MVP v1.0 — checklist (plano § Fase 5)

| Funcionalidade MVP | Estado |
|--------------------|--------|
| Carreira + saves locais | ✅ |
| Ligas + taça | ✅ |
| Mercado + contratos | ✅ |
| Treinos + academia | ✅ |
| Staff | ✅ |
| Match Engine 2D + Express | ✅ |
| Finanças | ✅ |
| Conquistas + palmarés | ✅ |
| Simulation Lab (dev) | ✅ |
| Política privacidade + URL | ✅ |
| Android AAB + assets Play Store | ✅ |
| Play Console teste interno | ⏸️ | pausado — conta em verificação; assets prontos |
| Beta local (APK/Mac) | ✅ | `./scripts/local_beta.sh` · [`docs/BETA.md`](../BETA.md) |
| App Store / TestFlight | ⏳ | screenshots ✅ + `package_app_store.sh` |
| Steam | ⏸️ adiado |

**Fora do MVP (pós-v1.0):** seleções, VAR, multiplayer, editor, workshop, 3D, redes sociais.

---

## Quality gates (plano § CI)

| Gate | Estado | Comando |
|------|--------|---------|
| `dart analyze` | ✅ | `./scripts/test_all.sh` |
| Testes unitários + UI | ✅ | idem |
| 100 épocas headless | ✅ | CI `Phoenix Headless CI` |
| Saves release Mac/Android | ✅ | `./scripts/test_mac.sh` · `./scripts/test_android.sh` |
| Launch doctor | ✅ | `./scripts/launch_doctor.sh` |

---

## Próximo passo (Play Store pausada)

1. **Beta local** — `./scripts/local_beta.sh` + partilhar com testadores ([`docs/BETA.md`](../BETA.md))
2. **QA** — `./scripts/qa_manual.sh` + `test_mac.sh` / `test_android.sh`
3. **App Store prep** — `./scripts/capture_app_store_screenshots.sh` (simulador iOS)
4. **Retomar Play Store** quando conta activar → `./scripts/play_console_day1.sh`
5. Após validação testers → produção `0.8.0` (sem sufixo alpha)

---

## Documentos relacionados

| Documento | Conteúdo |
|-----------|----------|
| [`docs/plano.md`](../plano.md) | Checklist Fase E (vivo) |
| [`docs/STORE.md`](../STORE.md) | Play Store + App Store |
| [`README.md`](../../README.md) | Comandos e arquitectura |
| Plano Cursor | Arquitectura GDD/SAD/Engine Spec completa |
