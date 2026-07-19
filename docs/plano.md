# Plano — Project Phoenix Manager

**Versão:** v0.8.53  
**Actualizado:** 20 de Julho de 2026  
**Fase actual:** **E — Lançamento**

Documento vivo do roadmap. O plano detalhado de arquitectura (PSE, GDD, motores) vive no **Cursor plan** (`phoenix_manager_game_2a890b62.plan.md`) e em [`docs/roadmap/master-roadmap-v1.md`](roadmap/master-roadmap-v1.md); este ficheiro reflecte **o que está feito** e **o que falta para publicar**.

---

## Visão

**Engine First** — o **Phoenix Simulation Engine (PSE v0.8)** é o coração; o **Project Phoenix Manager** é a 1.ª app jogável.

- **Modo Express** — jornadas rápidas, highlights animados, época em sessões curtas  
- **Modo Diretor** — gestão completa (mercado, staff, taça, finanças)  
- **Offline-first** — saves locais, sem conta, sem analytics  
- **Stack:** Flutter monorepo (`phoenix_core` → `phoenix_engine` → `phoenix_ui` → `phoenix_manager`)

---

## Fases — resumo

| Fase | Conteúdo | Estado |
|------|----------|--------|
| **A** | PSE headless, match engine, economia | ✅ |
| **B** | Liga, taça, lesões, staff, mercado | ✅ |
| **C** | UI Flutter, saves, Express/Diretor | ✅ |
| **D** | Polimento v0.8 — conquistas, palmarés, lab, UX | ✅ |
| **E** | Lançamento — Mac, Android, lojas | 🔄 **em curso** |
| **F** | Pós-v1 — Steam, IA avançada, multiplayer | ⏸️ adiado |

---

## Fase E — Lançamento (checklist)

### Plataformas locais

| Item | Estado | Notas |
|------|--------|-------|
| macOS release → `/Applications` | ✅ | `./scripts/install_local.sh` |
| Android APK sideload | ✅ | `./scripts/install_android.sh` |
| Android AAB assinado | ✅ | `build/release/mobile/android/phoenix_manager.aab` |
| iOS build (SwiftPM, no-codesign) | ✅ | `./scripts/build_mobile.sh ios` |
| Dev android/ios (`run_dev.sh`) | ✅ | Auto-detect + arranque emulador |
| Saves release (Mac + Android) | ✅ | `./scripts/test_release_saves.sh` |
| Testes CI (`test_all.sh`) | ✅ | |

### Lojas — Google Play

| Item | Estado | Acção |
|------|--------|-------|
| Keystore release | ✅ | `android/keystore/` + `key.properties` |
| Guia upload Play Store | ✅ | [`docs/STORE.md`](STORE.md#google-play--upload-passo-a-passo) |
| Política privacidade (texto) | ✅ | [`docs/PRIVACY.md`](PRIVACY.md) + ecrã in-app |
| **Site privacidade (HTML)** | ✅ | [`docs/site/privacy.html`](site/privacy.html) |
| **Scripts gráficos loja** | ✅ | `play_console_brief.sh`, `package_play_store.sh`, screenshots, gráficos |
| **Publicar URL https** | ✅ | [pakopt.github.io/PhoenixManager/privacy.html](https://pakopt.github.io/PhoenixManager/privacy.html) |
| Screenshots telemóvel | ✅ | `./scripts/capture_play_screenshots_auto.sh` (flutter drive → Mac) |
| Screenshots desktop (PC) | ✅ | `./scripts/capture_desktop_screenshots.sh` (macOS fullscreen) |
| Feature graphic 1024×500 | ✅ | `./scripts/export_feature_graphic.sh` |
| Conta Play Developer | ✅ | Conta aprovada (Jul 2026) |
| Teste interno Play Console | 🔄 | Ficha da loja + AAB — aguardar revisão Google |
| Produção Play Store | ⏳ | Após validar teste interno |

### Lojas — App Store

| Item | Estado | Acção |
|------|--------|-------|
| iOS SwiftPM (sem CocoaPods) | ✅ | Ver [`MOBILE.md`](../apps/phoenix_manager/MOBILE.md) |
| Screenshots App Store (prep) | ✅ | `./scripts/capture_app_store_screenshots.sh` |
| Pacote App Store (ZIP) | ✅ | `./scripts/package_app_store.sh` |
| Conta Apple Developer | ⏳ | ~99 USD/ano |
| Signing + Archive Xcode | ⏳ | `Runner.xcodeproj` |
| TestFlight | ⏳ | `flutter build ipa` |
| App Store Connect | ⏳ | Mesma URL privacidade |

### Lojas — Microsoft Store

| Item | Estado | Acção |
|------|--------|-------|
| Identidade Partner Center no `msix_config` | ✅ | `PhoenixManager.PhoenixManager` + publisher CN validado |
| Scripts MSIX (`doctor/build/package/brief`) | ✅ | `./scripts/msix_doctor.sh`, `build_msix.sh`, `package_msix_store.sh`, `msix_partner_brief.sh` |
| Guia de publicação MSIX | ✅ | [`docs/STORE.md`](STORE.md#microsoft-store--upload-passo-a-passo) |
| Publicação no Partner Center | ⏳ | Upload do package `.msix` e submissão |

### Steam

| Item | Estado | Notas |
|------|--------|-------|
| Scripts SteamPipe | ✅ | [`steam/README.md`](../steam/README.md) |
| Upload Steam | ⏸️ | Adiado — falta conta Steamworks |

### Beta local (sem lojas)

| Item | Estado | Acção |
|------|--------|-------|
| Guia beta local | ✅ | [`docs/BETA.md`](BETA.md) |
| Pacote APK testadores | ✅ | `./scripts/local_beta.sh` |
| Roteiro QA manual | ✅ | `./scripts/qa_manual.sh` |

### Qualidade pré-lançamento

```bash
./scripts/phase_e_status.sh          # panorama Fase E
./scripts/launch_doctor.sh
SAVE_TEST=1 ./scripts/launch_doctor.sh   # opcional
./scripts/mobile_doctor.sh
./scripts/test_all.sh
./scripts/test_mac.sh                # saves Mac ✅
./scripts/test_android.sh            # saves Android ✅ (emulador ligado)
./scripts/clean_dev_artifacts.sh     # libertar disco (flutter clean)
CLEAN_GRADLE=1 ./scripts/clean_dev_artifacts.sh   # inclui ~/.gradle/caches
./scripts/repair_gradle.sh           # cache Gradle corrompido após limpeza
```

---

## Próximas acções (Play Console — teste fechado activo)

> **Conta Play Developer aprovada** · app já em **testes fechados**.
>
> **Requisito Google (contas pessoais novas):** ≥ **12 testadores opted-in** no teste fechado durante **14 dias contínuos**, depois **candidatar-te a acesso a produção** no Dashboard. Só metê-los na lista de emails **não conta** — têm de aceitar o link, instalar pela Play Store e manter-se opted-in.
>
> **Freeze polish UI:** levantado em **v0.8.31** para o redesign FootSim × Phoenix (sidebar + dashboard 3 colunas). Sem lógica nova de jogo — só apresentação.
>
> **Bloqueio actual:** recrutar e manter 12–16 testadores 14 dias → candidatar produção.

### 1. Play Store — 12 testadores × 14 dias (agora)

1. **Testar e lançar** → **Teste fechado** → **Testadores** → lista com **14–16 emails** (buffer contra desistências).
2. Enviar o **link de adesão** oficial da Console (não APK sideload):
   `./scripts/play_testers_invite.sh 'URL_DO_LINK'` — mensagem + checklist
3. Acompanhar opted-in e dias: `./scripts/play_14day_tracker.sh`  
   Gravar: `DAY=1 OPTED_IN=12 CLOCK_START=AAAA-MM-DD ./scripts/play_14day_tracker.sh --save`  
   Follow-up: `--follow-up`
4. Cada pessoa: abrir o link no telemóvel → **Tornar-me testador** → instalar/actualizar na Play Store.
5. Na Console, confirmar que ≥12 aparecem como **opted-in** — aí começa a contagem dos 14 dias (se descer abaixo de 12, o relógio arrisca-se).
6. Após 14 dias contínuos com ≥12: Dashboard → **candidatar a acesso a produção** (questionário):
   `./scripts/play_production_apply.sh` — rascunhos PT/EN
7. Depois da aprovação → **Produção** → promover release / enviar para revisão.

Detalhe oficial: [requisitos de teste Play](https://support.google.com/googleplay/android-developer/answer/14151465) · guia local: [`docs/STORE.md`](STORE.md) §9c–10

**AAB actual:** `build/release/mobile/android/phoenix_manager.aab` (v0.8.53, versionCode 54)

Convite / QA para amigos: [`docs/BETA.md`](BETA.md) · textos: `./scripts/play_console_brief.sh`

### 2. Beta local (paralelo / fallback)

```bash
./scripts/local_beta.sh          # ZIP APK + instruções para testadores Android
./scripts/install_local.sh       # Mac release → /Applications
./scripts/qa_manual.sh           # roteiro QA manual
```

Guia: [`docs/BETA.md`](BETA.md)

### 3. Qualidade automática

```bash
./scripts/test_all.sh
./scripts/test_mac.sh
./scripts/test_android.sh        # emulador ou USB
SAVE_TEST=1 ./scripts/launch_doctor.sh
```

### 4. App Store — preparação (sem conta ainda)

```bash
./scripts/capture_app_store_screenshots.sh   # simulador iOS
./scripts/package_app_store.sh               # ZIP screenshots
./scripts/app_store_brief.sh                 # textos quando tiveres Apple Developer
```

### 5. Play Store — checklist upload

1. ~~Conta Play Developer~~ ✅
2. ~~Teste fechado + ficha + IARC + Data safety~~ ✅
3. **12 testadores × 14 dias** opted-in → candidatar produção — [`docs/STORE.md`](STORE.md) §9c
4. Produção após aprovação Google — [`docs/STORE.md`](STORE.md) §10

### 6. Gráficos Play Store (já feitos ✅)

Saída: `build/release/store/android/` — reutilizar quando a conta activar.

### 7. Steam (mais tarde)

1. Conta Steamworks  
2. `steam/steam.env`  
3. `./scripts/upload_steam.sh`

---

## Documentação

| Documento | Conteúdo |
|-----------|----------|
| [`README.md`](../README.md) | Visão geral, comandos, arquitectura |
| [`docs/plano.md`](plano.md) | Este ficheiro — roadmap vivo (Fase E) |
| [`docs/roadmap/master-roadmap-v1.md`](roadmap/master-roadmap-v1.md) | Sincronização plano mestre ↔ código |
| [`docs/BETA.md`](BETA.md) | Beta local sem lojas (APK/Mac + QA) |
| [`docs/STORE.md`](STORE.md) | Play Store + App Store + Microsoft Store |
| [`docs/PRIVACY.md`](PRIVACY.md) | Política privacidade (fonte Markdown) |
| [`docs/site/privacy.html`](site/privacy.html) | Política para URL pública |
| [`apps/phoenix_manager/MOBILE.md`](../apps/phoenix_manager/MOBILE.md) | Build mobile, signing, dev |
| [`apps/phoenix_manager/BRANDING.md`](../apps/phoenix_manager/BRANDING.md) | Ícones, splash, assets loja |
| [`steam/README.md`](../steam/README.md) | SteamPipe (adiado) |

---

## Versões e releases

| Campo | Valor actual |
|-------|--------------|
| `versionName` | `0.8.53` |
| `versionCode` | `54` |
| Package / Bundle ID | `com.phoenix.manager` |

**Próxima release:** editar `apps/phoenix_manager/pubspec.yaml`:

```yaml
version: 0.8.53+54   # nome visível + versionCode (obrigatório incrementar +N)
```

Depois: `./scripts/build_mobile.sh android` → novo AAB · `./scripts/check_app_version_sync.sh`

---

## Histórico recente (Fase E + v0.8.x)

- ✅ **v0.8.53** — Correcções: transfers por época, upgrades nas despesas, salários pós-transferência, táctica por slot (versionCode 54)  
- ✅ **v0.8.52** — Correcções Finanças: transferências in/out, P&L mensal, bilheteira/salários no save (versionCode 53)  
- ✅ **v0.8.51** — Build Microsoft Store / Partner Center (Pacotes MSIX) (versionCode 52)  
- ✅ **v0.8.50** — Submissão Microsoft Store (Partner Center em rascunho) (versionCode 51)  
- ✅ **v0.8.49** — Classificação FootSim (tabela completa + despromoção) · Microsoft Store MSIX (versionCode 50)  
- ✅ **v0.8.48** — Upgrades de instalações (treino/academia) nas Finanças (versionCode 49)  
- ✅ **v0.8.47** — Emblemas maiores no «PRÓXIMO JOGO» da Dashboard (versionCode 48)  
- ✅ **v0.8.46** — Polish UI FootSim: crests classificação/calendário/mercado · header Táctica (versionCode 47)  
- ✅ **v0.8.45** — Emblemas dos clubes na Dashboard (próximo jogo, lista, mini-tabela; versionCode 46)  
- ✅ **v0.8.44** — Finanças FootSim (visão geral, massa salarial, instalações, patrocínio; versionCode 45)  
- ✅ **v0.8.43** — Correcções gerais: «Guardar e sair» à primeira · fluxo de saída do menu (versionCode 44)  
- ✅ **v0.8.42** — Dashboard full-width desktop · snackbars de conquista corrigidos (versionCode 43)  
- ✅ **v0.8.41** — Transferências FootSim · ofertas / livres · compra no motor (versionCode 42)  
- ✅ **v0.8.40** — Treinos FootSim · clubes clicáveis / ficha · prefs por slot (versionCode 41)  
- ✅ **v0.8.39** — GDR «O Sindicato» na liga · posições de jogador · kit/UI classificação (versionCode 40)  
- ✅ **v0.8.38** — táctica: jogadores arrastáveis no campo + posições persistentes (versionCode 39)  
- ✅ **v0.8.37** — táctica: campo redesenhado, markers/slots corrigidos, XI mais inteligente (versionCode 38)  
- ✅ **v0.8.36** — correcção de bugs: plantéis 16, táctica persistente, testes 5 clubes (versionCode 37)  
- ✅ **v0.8.35** — actualização teste fechado Play (versionCode 36)  
- ✅ **v0.8.34** — actualização teste fechado Play (versionCode 35)  
- ✅ **v0.8.33** — ecrã de Táctica FootSim × Phoenix (formação, XI, campo; versionCode 34)  
- ✅ **v0.8.32** — A Coruja na Liga Phoenix (logo/identidade/equipas) · Phoenix FC jogável · plantel tabela + Inbox (versionCode 33)  
- ✅ **v0.8.31** — redesign UI FootSim × Phoenix (sidebar, top bar CTA, dashboard 3 colunas; versionCode 32)  
- ✅ **v0.8.30** — build teste fechado (versionCode 31)  
- ✅ **v0.8.29** — actualização teste fechado Play (versionCode 30)  
- ✅ **v0.8.28** — actualização teste fechado Play (versionCode 29)  
- ✅ **v0.8.27** — actualização teste fechado Play (versionCode 28)  
- ✅ **v0.8.26** — assets desktop (screenshots PC) · pacote Play · branding alinhado  
- ✅ **v0.8.25** — título Phoenix Manager · logo de marca no menu · arte PSE no site  
- ✅ **Scripts disco/Gradle** — `clean_dev_artifacts.sh`, `repair_gradle.sh`, `install_local.sh` verifica espaço  
- ✅ **v0.8.24** — roteiro beta auto-marca · aviso ao carregar save · badge live  
- ✅ **v0.8.23** — aviso ao sair por guardar · progresso roteiro  
- ✅ **v0.8.22** — roteiro no menu carreira · feedback com progresso · chip «Por guardar»  
- ✅ **v0.8.21** — roteiro beta in-app · aviso guardar (modo Diretor)  
- ✅ **v0.8.20** — «Novidades» ao actualizar · tracker 12×14 · sync AppVersion no CI  
- ✅ **Script candidatura produção** — `play_production_apply.sh` (rascunhos questionário PT/EN)  
- ✅ **v0.8.19** — sheet first-run (novos testadores) · modos de jogo partilhados  
- ✅ **v0.8.18** — sync versão UI · dicas dashboard rotativas · feedback/bug no drawer  
- ✅ **v0.8.17** — Semantics ordenação plantel · **freeze polish UI** (pivot Play)  
- ✅ **v0.8.16** — Semantics Finanças/Clube · tooltips pesquisa e Lab  
- ✅ **v0.8.15** — Mercado/FFP a11y · atalhos Ctrl/⌘+S/Q · snacks save · taça por sortear  
- ✅ **v0.8.14** — MoneyFormat staff/eventos · Semantics chips · SafeArea detalhe jogo/jogador  
- ✅ **v0.8.13** — acessibilidade (plantel, treino, jogos, tabela) + tooltips rail + Lab PT  
- ✅ **v0.8.12** — «Sair do jogo» no menu/drawer (desktop)  
- ✅ **v0.8.11** — branding desktop (Phoenix Manager) + F11 fullscreen Win + QA  
- ✅ **v0.8.10** — desktop fullscreen (Mac / Windows Esc / Linux)  
- ✅ **v0.8.9** — QA Play (roteiro 17 passos) + acessibilidade (conquistas, linhas forma)  
- ✅ **v0.8.8** — forma recente vazia no dashboard + docs Play actualizados (0.8.x, notas, brief)  
- ✅ **v0.8.7** — datas bracket taça unificadas + empty states (academia, dashboard)  
- ✅ **v0.8.6** — datas legíveis (taça, conquistas) + acessibilidade (forma V/E/D, placar jogo) + **edge-to-edge Android 15**  
- ✅ **v0.8.5** — textos PT-PT (destaques, ficha jogador, academia) + notas Play actualizadas  
- ✅ **v0.8.4** — alertas pré-jogo (modo Diretor) + empty state staff  
- ✅ **v0.8.3** — datas legíveis (calendário, dashboard, finanças, mercado, taça, forma, cabeçalho, saves) + scroll classificação  
- ✅ **v0.8.2** — finanças (resultado época), calendário (scroll + filtro), treino, relato completo, dica dashboard  
- ✅ Scripts loja/beta leem versão de `pubspec.yaml` (`read_app_version.sh`)  
- ✅ **v0.8.1** — polish UX: empty states, conquistas, datas, modos de jogo, toasts  

- ✅ Keystore Android + AAB/APK release assinados  
- ✅ iOS migrado para Swift Package Manager (sem CocoaPods)  
- ✅ `run_dev.sh` — auto-detect android/ios + arranque emulador  
- ✅ Guia Play Store completo em `docs/STORE.md`  
- ✅ Site estático privacidade em `docs/site/`
- ✅ Scripts screenshots automáticos (`flutter drive` → `build/release/store/android/screenshots/`)  
- ✅ GitHub Pages — [privacidade online](https://pakopt.github.io/PhoenixManager/privacy.html)  
- ✅ Validação Mac — saves release + UserDefaults (`test_mac.sh`)  
- ✅ Validação Android — saves release no emulador (`test_android.sh`)  
- ✅ `play_console_day1.sh` — guia upload quando conta activar  
- ✅ Beta local — `local_beta.sh`, `docs/BETA.md`, `qa_manual.sh`  
- ✅ Screenshots App Store — 5 capturas iOS (`capture_app_store_screenshots.sh`)  
- ✅ Play Console — conta aprovada · **teste fechado activo** · AAB **v0.8.53+54**  
- 🔄 Microsoft Store — Partner Center submissão em rascunho · Pacotes MSIX ⏳  
- ✅ Microsoft Store — scripts MSIX + guia Partner Center (`docs/STORE.md`)  
- 🔄 Produção — **≥12 opted-in × 14 dias** → candidatar acesso → promover (`docs/STORE.md` §9c–10) · `./scripts/play_14day_tracker.sh`  
- ✅ Desktop — fullscreen Mac / Windows / Linux + «Sair do jogo»  
- ✅ Polish UI v0.8.x — freeze v0.8.17–0.8.30; redesign FootSim × Phoenix em v0.8.31; A Coruja em v0.8.32; Táctica em v0.8.33



---

## Contacto

**Suporte / privacidade:** pakopt7@gmail.com
