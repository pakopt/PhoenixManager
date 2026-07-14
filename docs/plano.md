# Plano — Project Phoenix Manager

**Versão:** v0.8.5  
**Actualizado:** 13 de Julho de 2026  
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
| Feature graphic 1024×500 | ✅ | `./scripts/export_feature_graphic.sh` |
| Conta Play Developer | ⏸️ | **Pausado** — em verificação Google; assets prontos |
| Teste interno Play Console | ⏸️ | Retomar com `./scripts/play_console_day1.sh` |
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
./scripts/test_mac.sh                # saves Mac
./scripts/test_android.sh            # saves Android (emulador ligado)
```

---

## Próximas acções (Play Store pausada até aprovação)

> **Conta Play Console em verificação** — não bloqueia o resto da Fase E. Foco em beta local, QA e prep iOS.

### 1. Beta local (agora)

```bash
./scripts/local_beta.sh          # ZIP APK + instruções para testadores Android
./scripts/install_local.sh       # Mac release → /Applications
./scripts/qa_manual.sh           # roteiro QA manual
```

Guia: [`docs/BETA.md`](BETA.md)

### 2. Qualidade automática

```bash
./scripts/test_all.sh
./scripts/test_mac.sh
./scripts/test_android.sh        # emulador ou USB
SAVE_TEST=1 ./scripts/launch_doctor.sh
```

### 3. App Store — preparação (sem conta ainda)

```bash
./scripts/capture_app_store_screenshots.sh   # simulador iOS
./scripts/package_app_store.sh               # ZIP screenshots
./scripts/app_store_brief.sh                 # textos quando tiveres Apple Developer
```

### 4. Play Store — retomar quando conta activar ⏸️

```bash
./scripts/play_console_day1.sh
```

1. ~~Conta Play Developer~~ ✅ (aguardar verificação Google)
2. Upload AAB + ficha + IARC + Data safety — [`docs/STORE.md`](STORE.md)

### 5. Gráficos Play Store (já feitos ✅)

Saída: `build/release/store/android/` — reutilizar quando a conta activar.

### 6. Steam (mais tarde)

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
| [`docs/STORE.md`](STORE.md) | Play Store + App Store passo a passo |
| [`docs/PRIVACY.md`](PRIVACY.md) | Política privacidade (fonte Markdown) |
| [`docs/site/privacy.html`](site/privacy.html) | Política para URL pública |
| [`apps/phoenix_manager/MOBILE.md`](../apps/phoenix_manager/MOBILE.md) | Build mobile, signing, dev |
| [`apps/phoenix_manager/BRANDING.md`](../apps/phoenix_manager/BRANDING.md) | Ícones, splash, assets loja |
| [`steam/README.md`](../steam/README.md) | SteamPipe (adiado) |

---

## Versões e releases

| Campo | Valor actual |
|-------|--------------|
| `versionName` | `0.8.5` |
| `versionCode` | `6` |
| Package / Bundle ID | `com.phoenix.manager` |

**Próxima release:** editar `apps/phoenix_manager/pubspec.yaml`:

```yaml
version: 0.8.5+6   # nome visível + versionCode (obrigatório incrementar +N)
```

Depois: `./scripts/build_mobile.sh android` → novo AAB.

---

## Histórico recente (Fase E + v0.8.x)

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
- ⏸️ Play Console → retomar após verificação Google  

---

## Contacto

**Suporte / privacidade:** pakopt7@gmail.com
