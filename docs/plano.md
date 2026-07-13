# Plano — Project Phoenix Manager

**Versão:** v0.8.0-alpha  
**Actualizado:** 13 de Julho de 2026  
**Fase actual:** **E — Lançamento**

Documento vivo do roadmap. O plano detalhado de arquitectura (PSE, GDD, motores) vive no Cursor plan; este ficheiro reflecte **o que está feito** e **o que falta para publicar**.

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
| **Scripts gráficos loja** | ✅ | `capture_play_screenshots_auto.sh`, `export_feature_graphic.sh`, `prepare_play_store.sh` |
| **Publicar URL https** | ⏳ | Push → [pakopt/PhoenixManager](https://github.com/pakopt/PhoenixManager) + activar Pages |
| Screenshots telemóvel | ✅ | `./scripts/capture_play_screenshots_auto.sh` (flutter drive → Mac) |
| Feature graphic 1024×500 | ✅ | `./scripts/export_feature_graphic.sh` |
| Conta Play Developer | ⏳ | ~25 USD, verificação identidade |
| Teste interno Play Console | ⏳ | Upload AAB + lista testadores |
| Produção Play Store | ⏳ | Após validar teste interno |

### Lojas — App Store

| Item | Estado | Acção |
|------|--------|-------|
| iOS SwiftPM (sem CocoaPods) | ✅ | Ver [`MOBILE.md`](../apps/phoenix_manager/MOBILE.md) |
| Conta Apple Developer | ⏳ | ~99 USD/ano |
| Signing + Archive Xcode | ⏳ | `Runner.xcodeproj` |
| TestFlight | ⏳ | `flutter build ipa` |
| App Store Connect | ⏳ | Mesma URL privacidade |

### Steam

| Item | Estado | Notas |
|------|--------|-------|
| Scripts SteamPipe | ✅ | [`steam/README.md`](../steam/README.md) |
| Upload Steam | ⏸️ | Adiado — falta conta Steamworks |

### Qualidade pré-lançamento

```bash
./scripts/launch_doctor.sh
SAVE_TEST=1 ./scripts/launch_doctor.sh   # opcional
./scripts/mobile_doctor.sh
./scripts/test_all.sh
```

---

## Próximas acções (ordem recomendada)

### 1. Publicar política de privacidade (bloqueante Play Store)

```bash
./scripts/setup_github_pages.sh   # git init + checklist segredos
```

1. Push do repo para GitHub (se ainda não estiver)
2. Activar **GitHub Pages** — ver [`docs/site/README.md`](site/README.md)
3. URL final: `https://pakopt.github.io/PhoenixManager/privacy.html`
4. Colar URL na Play Console → Política de privacidade
5. Confirmar em [`docs/STORE.md`](STORE.md) (URL já documentada)

### 2. Play Store — teste interno

1. Conta [Play Console](https://play.google.com/console/signup)
2. `./scripts/build_mobile.sh android`
3. Upload `build/release/mobile/android/phoenix_manager.aab`
4. Preencher ficha, IARC, Data safety (respostas no guia STORE)
5. ≥2 screenshots + ícone 512 + feature graphic 1024×500
6. Instalar no telemóvel via link de teste interno

### 3. Gráficos da loja

```bash
# Automático (recomendado) — integration test + gravação directa no Mac
./scripts/capture_play_screenshots_auto.sh

# Manual guiado — 5 ecrãs com adb screencap
./scripts/capture_play_screenshots.sh --install --batch

# Pacote completo loja (AAB + screenshots + gráficos)
./scripts/prepare_play_store.sh
# ou sem rebuild: SKIP_BUILD=1 ./scripts/prepare_play_store.sh

# Feature graphic 1024×500 (Chrome headless)
./scripts/export_feature_graphic.sh
```

Saída: `build/release/store/android/` (`screenshots/`, `icon-512.png`, `feature-graphic.png`)

Ecrãs sugeridos: menu carreira, dashboard, plantel, Express, classificação.

### 4. App Store (quando tiveres Apple Developer)

1. Xcode → Signing & Capabilities  
2. `flutter build ipa`  
3. TestFlight → testers → App Store

### 5. Steam (mais tarde)

1. Conta Steamworks  
2. `steam/steam.env`  
3. `./scripts/upload_steam.sh`

---

## Documentação

| Documento | Conteúdo |
|-----------|----------|
| [`README.md`](../README.md) | Visão geral, comandos, arquitectura |
| [`docs/plano.md`](plano.md) | Este ficheiro — roadmap vivo |
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
| `versionName` | `0.8.0-alpha` |
| `versionCode` | `1` |
| Package / Bundle ID | `com.phoenix.manager` |

**Próxima release:** editar `apps/phoenix_manager/pubspec.yaml`:

```yaml
version: 0.8.1+2   # nome visível + versionCode (obrigatório incrementar +N)
```

Depois: `./scripts/build_mobile.sh android` → novo AAB.

---

## Histórico recente (Fase E)

- ✅ Keystore Android + AAB/APK release assinados  
- ✅ iOS migrado para Swift Package Manager (sem CocoaPods)  
- ✅ `run_dev.sh` — auto-detect android/ios + arranque emulador  
- ✅ Guia Play Store completo em `docs/STORE.md`  
- ✅ Site estático privacidade em `docs/site/`  
- ✅ Scripts screenshots automáticos (`flutter drive` → `build/release/store/android/screenshots/`)  
- ✅ `setup_github_pages.sh` — git init + validação keystore  
- 🔄 Push GitHub + Pages + upload Play Console  

---

## Contacto

**Suporte / privacidade:** pakopt7@gmail.com
