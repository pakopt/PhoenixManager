# Project Phoenix Manager

**Engine First** — o jogo é a primeira app sobre o **Phoenix Simulation Engine (PSE)**.

## Arquitetura

```
apps/phoenix_manager     ← Flutter UI (Fase C)
        ↓
packages/phoenix_ui      ← widgets + ecrãs (zero lógica)
        ↓
packages/phoenix_engine  ← PSE headless
        ↓
packages/phoenix_core    ← domain + config
```

## Monorepo

| Package / App | Versão | Descrição |
|---------------|--------|-----------|
| `packages/phoenix_core` | v0.8 | Domain, Match + Economy models |
| `packages/phoenix_engine` | v0.8 | **PSE** — simulação headless |
| `packages/phoenix_data` | v0.8 | Config loaders (YAML) |
| `packages/phoenix_tools` | v0.8 | Simulation Lab |
| `packages/phoenix_ui` | v0.8 | **UI Flutter** — apresentação |
| `apps/phoenix_manager` | v0.8 | App jogável |

## Fase D / v0.8 — Polimento UI

| Funcionalidade | Estado |
|----------------|--------|
| Academia (tab em Treinos) | ✅ |
| Wonderkids + intake recente | ✅ |
| Detalhe jogador com stat bars | ✅ |
| Detalhe jogo com comparação visual | ✅ |
| Layout responsivo (NavigationRail ≥900px) | ✅ |
| Migração save legacy v0.7 → slot 0 | ✅ |
| **Injury Engine** (lesões pós-jogo, recuperação) | ✅ |
| Ecrã **Clube** (treinador + infra + médico) | ✅ |
| **Staff completo** (9 roles + impacto PSE) | ✅ |
| Bónus psicólogo + nutricionista | ✅ |
| Alertas contratos a expirar + dashboard | ✅ |
| **Taça Phoenix** no dashboard (estado + campeão) | ✅ |
| **Renovação manual de contratos** | ✅ |
| **Taça Phoenix** (eliminatória 4 clubes + chave visual) | ✅ |
| **Conquistas** (10 marcos + persistência no save) | ✅ |
| **Resumo de época** no dashboard | ✅ |
| **Tabela** com tabs Liga/Taça | ✅ |
| **Nova época** (rollover liga + taça) | ✅ |
| **Palmarés** (troféus por época + tab Clube) | ✅ |
| **Estatísticas de carreira** (V/E/D, golos, troféus) | ✅ |
| **Save slots** enriquecidos (época, posição, troféus) | ✅ |
| **Forma recente** (últimos 5 jogos no dashboard) | ✅ |
| **Mercado** (janela + tabs Clube/Liga) | ✅ |
| **Simulation Lab** (UI headless + balanceamento) | ✅ |
| **Lab: presets xG/economia + comparar corridas** | ✅ |
| **Conquistas: toast + progresso dashboard** | ✅ |
| **Lab: export CSV** | ✅ |
| **Build scripts** (test_all + release web/macos) | ✅ |
| **Jogar agora** (quick play Express / continuar save) | ✅ |
| **Branding** (ícone + splash nativos) | ✅ |
| **Launch scripts** (doctor + build_all + CI APK) | ✅ |
| **Saves release** (integration_test Mac + Android) | ✅ |
| **Privacidade** (docs + ecrã in-app) | ✅ |
| **UX polish** (layout, plantel, feedback, dinheiro) | ✅ |

## Fase E — Lançamento (em curso)

**Versão actual:** `0.8.42+43` · AAB: `build/release/mobile/android/phoenix_manager.aab`
**Bloqueio Play:** ≥12 testadores opted-in × 14 dias → candidatar produção ([`docs/STORE.md`](docs/STORE.md) §9c) · `./scripts/play_14day_tracker.sh`

| Plataforma | Estado |
|------------|--------|
| Web (Chrome) | ✅ dev |
| **Android** (APK + AAB) | ✅ teste fechado Play · AAB v0.8.42 |
| **macOS** | ✅ em /Applications (`com.phoenix.manager`) · fullscreen |
| **Windows** | ✅ build desktop · fullscreen (Esc restaura janela) |
| **Linux** | ✅ build desktop · fullscreen (SteamPipe) |
| **Steam (SteamPipe + scripts)** | ⏸️ mais tarde |

## Fase C / v0.7 — Interface Flutter

UI **pergunta, motor responde** — zero lógica de jogo nos widgets.

| Funcionalidade | Estado |
|----------------|--------|
| Menu carreira (3 slots) | ✅ |
| Save / Load multi-slot (SharedPreferences) | ✅ |
| Modo Express vs Diretor | ✅ |
| Dashboard, Plantel, **Treinos**, Calendário (Liga + Taça), Tabela | ✅ |
| Mercado + Finanças (breakdown salarial) | ✅ |
| Match (campo 2D + highlights) | ✅ |
| Detalhe jogador | ✅ |

### Modos de jogo

- **Express** — botão "Simular jornada", top 6 highlights, autosave
- **Diretor** — avanço dia/semana, todos os detalhes

### Ecrãs

- [Flutter 3.24+](https://docs.flutter.dev/get-started/install)
- Dart 3.5+ (incluído no Flutter)

### Primeira execução

```bash
# 1. Instalar Flutter (macOS)
brew install --cask flutter

# 2. Gerar pastas de plataforma (só na primeira vez)
cd apps/phoenix_manager
flutter create . --project-name phoenix_manager
flutter pub get

# 3. Correr
flutter run -d macos    # ou chrome, ios, android…
```

### Motor headless (sem UI)

```bash
dart pub get
dart test packages/phoenix_core packages/phoenix_data packages/phoenix_engine packages/phoenix_tools

dart run bin/phoenix_headless.dart --match
dart run bin/phoenix_headless.dart --season
dart run bin/phoenix_headless.dart --economy
```

### Simulation Lab (UI)

No menu de carreira, abre **Laboratório de simulação** para correr simulações headless (época completa, N épocas ou N dias) num mundo isolado — útil para balanceamento sem afectar saves. Presets de **xG** (padrão / alto / baixo) e **economia** (padrão / generosa / apertada). Botões **Comparar xG** / **Comparar economia** correm duas simulações e mostram tabela side-by-side.

### Testes e builds

```bash
# Jogar (dev, hot reload)
chmod +x scripts/run_dev.sh
./scripts/run_dev.sh macos      # ou chrome, android, ios

# Build release já compilado
./scripts/run_release.sh

# Todos os testes (Dart + Flutter)
chmod +x scripts/test_all.sh
./scripts/test_all.sh

# Builds de release (web + macOS no macOS)
chmod +x scripts/build_release.sh
./scripts/build_release.sh
# Artefactos em build/release/

# Mobile (Android + iOS)
chmod +x scripts/build_mobile.sh scripts/mobile_doctor.sh
./scripts/mobile_doctor.sh
./scripts/build_mobile.sh android   # APK + AAB
./scripts/build_mobile.sh ios       # Runner.app (Mac)
# Ver apps/phoenix_manager/MOBILE.md

# Diagnóstico pré-lançamento (branding + Steam + mobile + testes)
chmod +x scripts/launch_doctor.sh scripts/build_all.sh
./scripts/launch_doctor.sh

# Incluir teste de saves (mais lento — emulador Android)
SAVE_TEST=1 ./scripts/launch_doctor.sh

# Testar saves em release (Mac + Android)
./scripts/test_release_saves.sh

# Testes + builds (Mac: web, macOS, mobile, Steam)
./scripts/build_all.sh auto

# Ícones e splash
./scripts/regenerate_branding.sh
# Ver apps/phoenix_manager/BRANDING.md

# Limpar caches locais (~GiB: Flutter build, Gradle, Steam temp)
./scripts/clean_dev_artifacts.sh
# CLEAN_RELEASE=1 …  # também apaga build/release (AAB/APK)
```

### Steam

Ver **[steam/README.md](steam/README.md)** — configuração completa SteamPipe.

```bash
cp steam/steam.env.example steam/steam.env   # App ID + depot IDs
./scripts/build_steam.sh macos               # ou windows | linux
./steam/scripts/generate_vdfs.sh
./scripts/upload_steam.sh                    # requer Steamworks SDK
```

## Fases anteriores

- **B.2 / v0.3** — Match Engine (45 segmentos, xG, momentum, highlights)
- **B.3 / v0.4** — Economy (finanças, treinos, transferências, jovens)

## Próximo passo (Fase E — Lançamento)

**Plano vivo:** [`docs/plano.md`](docs/plano.md)

**Agora:** teste fechado activo — recrutar **12 testadores × 14 dias** → produção

```bash
./scripts/play_testers_invite.sh 'URL_DO_LINK'   # mensagem WhatsApp/email
./scripts/play_console_brief.sh                  # textos loja
./scripts/phase_e_status.sh                      # panorama Fase E
```

1. ~~Testar saves Mac/Android~~ → `test_mac.sh` / `test_android.sh` ✅
2. ~~Política de privacidade~~ → https://pakopt.github.io/PhoenixManager/privacy.html
3. ~~Play Console teste fechado~~ ✅ — ficha / IARC / Data safety
4. **12 × 14** — convites opted-in ([`docs/STORE.md`](docs/STORE.md) §9c)
5. **Produção** — após aprovação Google no Dashboard
6. App Store prep — screenshots iOS (`capture_app_store_screenshots.sh`)
7. Apple Developer — `./scripts/app_store_brief.sh`
8. Steam — adiado

```bash
./scripts/install_local.sh          # Mac release
./scripts/local_beta.sh             # Android beta ZIP
./scripts/package_play_store.sh     # (quando Play activar)
```
