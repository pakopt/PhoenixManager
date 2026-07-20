# Branding — Phoenix Manager

Assets fonte e regeneração de ícones/splash nativos.

## Cores da marca

| Token | Hex | Uso |
|-------|-----|-----|
| Primary | `#2E7D32` | Verde Phoenix (tema UI) |
| Surface | `#0A0E14` | Fundo escuro / splash |

Definidas em `packages/phoenix_ui/lib/src/theme/phoenix_theme.dart`.

## Ficheiros fonte

| Ficheiro | Uso |
|----------|-----|
| `assets/branding/icon.png` | Ícone da app (1024×1024) — todas as plataformas |
| `assets/branding/splash.png` | Logo centrado no splash |

Substitui estes PNGs para mudar o visual; depois regenera os nativos.

## Regenerar ícones e splash

**Na raiz do monorepo:**

```bash
./scripts/regenerate_branding.sh
```

**Ou a partir de `apps/phoenix_manager/`:**

```bash
./regenerate_branding.sh
```

Equivalente manual:

Gera automaticamente:

- **Android** — `mipmap-*`, adaptive icon, splash `drawable*`
- **iOS** — `AppIcon.appiconset`, splash `LaunchImage`
- **macOS** — `AppIcon.appiconset`
- **Windows** — `app_icon.ico`
- **Web** — `web/icons/`, `favicon.png`, `manifest.json`
- **Linux** — `linux/icons/app_icon.png` (janela + `.desktop`)

## Testar

```bash
./scripts/run_dev.sh android
./scripts/run_dev.sh ios
./scripts/run_dev.sh macos
```

Ou rebuild release: `./scripts/build_mobile.sh all`

## Lojas / Steam

- **Google Play** — ícone 512×512 (exporta de `icon.png`)
- **App Store** — usa `Icon-App-1024x1024@1x.png` gerado
- **Steam** — capsule art é separado (store page); o ícone desktop usa macOS/Windows assets
