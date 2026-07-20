# Mobile — Android & iOS

Builds release do **Project Phoenix Manager** para telemóvel e tablet.

## Pré-requisitos

| Plataforma | Requisitos |
|------------|------------|
| **Android** | Android Studio ou SDK + `ANDROID_HOME` |
| **iOS** | macOS + Xcode (só em Mac) |

Diagnóstico:

```bash
./scripts/mobile_doctor.sh
```

### Android — avisos comuns

- **cmdline-tools em falta** — Android Studio → SDK Manager → *Android SDK Command-line Tools*
  - Sintoma no build: `Release app bundle failed to strip debug symbols from native libraries`
  - O **APK e o AAB são gerados na mesma**; o aviso afecta sobretudo o tamanho do AAB e upload de símbolos à Play Store
  - Guia: `./scripts/setup_android_cmdline_tools.sh`
- **Licenças** — `flutter doctor --android-licenses`

### Android 15 — edge-to-edge (targetSdk 35)

A partir do **Android 15**, apps que segmentam **SDK 35** são apresentadas **até às extremidades** (conteúdo por trás da barra de estado e navegação). A Play Console avisa se isto não estiver tratado.

**O que o projecto faz:**

| Camada | Ficheiro | Acção |
|--------|----------|--------|
| Nativo | `android/.../MainActivity.kt` | `WindowCompat.setDecorFitsSystemWindows` + contraste nav desactivado |
| Flutter | `packages/phoenix_ui/.../platform_chrome.dart` | `SystemUiMode.edgeToEdge` + barras transparentes |
| Temas | `android/.../values*/styles.xml` | `NormalTheme` com barras transparentes |
| UI | ecrãs com `AppBar` / `SafeArea` / `Scaffold` | Inserções geridas pelo Material 3 |

**Como testar** (emulador API 35 ou telemóvel Android 15+):

1. `./scripts/install_android.sh` (ou AAB de release)
2. Verifica: barra superior/inferior não tapam botões nem texto
3. Navega: menu carreira → jogo → plantel → detalhe de jogo → barra inferior
4. Modos de navegação: **gestos** e **3 botões** (Definições → Sistema → Navegação)
5. Teclado (pesquisa no plantel): campo visível com `adjustResize` no manifest

O aviso da Play Console desaparece após **novo upload** de AAB com edge-to-edge (v0.8.6+).

## Identidade da app

| Plataforma | ID |
|------------|-----|
| Android | `com.phoenix.manager` |
| iOS | `com.phoenix.manager` |
| macOS | `com.phoenix.manager` |

## Assinatura Android (Play Store)

```bash
# 1. Gerar keystore (uma vez)
chmod +x scripts/android_keystore.sh
./scripts/android_keystore.sh

# 2. Configurar
cp apps/phoenix_manager/android/key.properties.example \
   apps/phoenix_manager/android/key.properties
# Editar passwords (e confirma que `storeFile=keystore/phoenix-manager-release.jks`)

# 3. Build assinado
./scripts/build_mobile.sh android
```

Sem `key.properties`, o release usa chave **debug** (só para testes locais).

## Assinatura iOS (App Store / TestFlight)

Builds locais usam `--no-codesign` (instalação directa limitada). Para **TestFlight / App Store**:

1. Conta [Apple Developer](https://developer.apple.com)
2. Abre `apps/phoenix_manager/ios/Runner.xcworkspace` no Xcode
3. Define Team + Bundle ID em *Signing & Capabilities*
4. Product → Archive → Distribute

Ou, com provisioning configurado:

```bash
cd apps/phoenix_manager
flutter build ipa
```

## iOS — plugins (Swift Package Manager)

Os plugins iOS deste projecto usam **Swift Package Manager** (não CocoaPods).
Não precisas de `pod install`.

Se ainda existir integração CocoaPods antiga no Xcode project:

```bash
cd apps/phoenix_manager/ios
pod deintegrate   # opcional — remove vestígios de Pods
```

Depois: `flutter clean && flutter pub get && flutter build ios --release --no-codesign`

## Build

```bash
# Android: APK (sideload) + AAB (Play Store)
./scripts/build_mobile.sh android

# iOS: Runner.app (sem codesign)
./scripts/build_mobile.sh ios

# Ambos (em Mac)
./scripts/build_mobile.sh all
```

Artefactos em `build/release/mobile/`:

| Ficheiro | Uso |
|----------|-----|
| `android/phoenix_manager.apk` | Instalar em dispositivo / emulador |
| `android/phoenix_manager.aab` | Google Play Console |
| `ios/Runner.app` | Xcode Archive / dispositivo com signing |

## Instalação local (sem lojas)

```bash
# Mac → Aplicações + APK Android
./scripts/install_local.sh

# Só Android (USB ou emulador medium_phone)
./scripts/install_android.sh

# Mac já instalado — reabrir
open -a "Phoenix Manager"
```

### Emulador Android

```bash
# Recomendado: arranca emulador + instala + abre a app
./scripts/install_android.sh
```

Se o emulador não aparecer em `adb devices`, arranca manualmente:

```bash
$HOME/Library/Android/sdk/emulator/emulator -avd medium_phone
./scripts/install_android.sh
```

### Telefónio USB

1. Depuração USB activa
2. Cabo USB + confiar no Mac
3. `./scripts/install_android.sh`

## Testar em dev

```bash
# Emulador Android ou dispositivo USB (arranca medium_phone se necessário)
./scripts/run_dev.sh android

# Simulador iOS (Mac + Xcode — arranca Simulator se necessário)
./scripts/run_dev.sh ios
```

O script detecta automaticamente o device id (`emulator-5554`, UUID do simulador, etc.).
Lista dispositivos: `flutter devices`

Comandos úteis durante `flutter run`: `r` hot reload, `R` restart, `d` detach, `q` quit.

## Gráficos Play Store

```bash
./scripts/capture_play_screenshots.sh --install --batch
./scripts/export_feature_graphic.sh
```

Artefactos em `build/release/store/android/`. Ver [`docs/STORE.md`](../../docs/STORE.md).

Microsoft Store (Windows / MSIX): ver secção dedicada em [`docs/STORE.md`](../../docs/STORE.md#microsoft-store--upload-passo-a-passo).

## macOS (local)

```bash
./scripts/install_local.sh    # build release → /Applications
./scripts/test_mac.sh         # saves + checklist
./scripts/run_dev.sh macos    # dev com hot reload
```

## Desktop — ecrã inteiro (Mac / Windows / Linux)

A app abre em **fullscreen** no PC:

| Plataforma | Comportamento | Sair do fullscreen |
|------------|---------------|--------------------|
| **macOS** | Modo ecrã inteiro nativo | Esc ou Controlo+Cmd+F |
| **Windows** | Janela sem moldura a cobrir o monitor | Esc (volta a janela) · F11 (alternar) · Alt+F4 (fechar) |
| **Linux** | `gtk_window_fullscreen` | Esc / F11 (conforme o WM) |

Implementação: `macos/Runner/MainFlutterWindow.swift`, `windows/runner/win32_window.cpp`, `linux/runner/my_application.cc`.

Nome visível no SO: **Phoenix Manager** (Dock / barra de título / propriedades exe no Windows).

Para **fechar a app** em fullscreen: no menu carreira ou no drawer → **Sair do jogo** (só desktop; pede confirmação), ou **Ctrl/⌘+Q**. Guardar rápido: **Ctrl/⌘+S** (slot activo).

## Testar saves (release)

```bash
# macOS + Android (integration_test com SharedPreferences real)
./scripts/test_release_saves.sh

# Só uma plataforma
./scripts/test_release_saves.sh macos
./scripts/test_release_saves.sh android
```

O teste simula: nova carreira Express → simular jornada → guardar → reinício → continuar carreira.

## Antes da loja

- [x] Bundle ID `com.phoenix.manager` (Android, iOS, macOS)
- [x] Ícones e splash (`assets/branding/` + `./scripts/regenerate_branding.sh`)
- [x] Keystore Android (`./scripts/android_keystore.sh`) — ver [`docs/STORE.md`](../../docs/STORE.md) (**guia upload Play Store**)
- [ ] Apple Developer + signing no Xcode — ver [`docs/STORE.md`](../../docs/STORE.md)
- [x] Política de privacidade — [`docs/PRIVACY.md`](../../docs/PRIVACY.md) + [`docs/site/privacy.html`](../../docs/site/privacy.html)
- [ ] URL https publicada (GitHub Pages) — [`docs/site/README.md`](../../docs/site/README.md)
- [ ] Play Console teste interno — [`docs/STORE.md`](../../docs/STORE.md)
- [x] Testar saves (`SharedPreferences`) em build release — `./scripts/test_release_saves.sh`

## Tamanhos de referência (v0.8.0-alpha)

- APK ~49 MB
- AAB ~48 MB  
- iOS Runner.app ~17 MB
