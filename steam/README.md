# Steam — Project Phoenix Manager

Configuração [SteamPipe](https://partner.steamgames.com/doc/sdk/uploading) para publicar builds desktop do Flutter.

## Pré-requisitos

1. **Conta Steamworks Partner** — [partner.steamgames.com](https://partner.steamgames.com) (taxa única ~100 USD).
2. **App ID** — criar app em *Apps → Create New App*.
3. **Depots** — em *Edit Steamworks Settings → SteamPipe → Depots*, criar **nesta ordem**:
   - Windows (`STEAM_DEPOT_WINDOWS`)
   - macOS (`STEAM_DEPOT_MACOS`)
   - Linux (`STEAM_DEPOT_LINUX`)
4. **Steamworks SDK** — descarregar e extrair; apontar `STEAM_SDK_ROOT` no `steam.env`.
5. **Conta de build** — utilizador dedicado em *Users & Permissions* (não uses a conta pessoal).

## Configuração local

```bash
cp steam/steam.env.example steam/steam.env
```

Edita `steam/steam.env` com os IDs reais do Steamworks (não deixes `0000000` nem `/path/to/...`).

Corre o diagnóstico antes de build/upload:

```bash
chmod +x scripts/steam_doctor.sh
./scripts/steam_doctor.sh
```

`steam/steam.env` está no `.gitignore` — **nunca commits credenciais**.

> **Nota:** Corre cada comando **numa linha separada**. Não coles linhas que começam com `#` — o zsh tenta executá-las como comando.

## Build por plataforma

Corre **num runner de cada OS** (Flutter não faz cross-compile Windows a partir de macOS):

```bash
# macOS
./scripts/build_steam.sh macos

# Linux (incl. Steam Deck)
./scripts/build_steam.sh linux

# Windows
./scripts/build_steam.sh windows
```

Conteúdo em `build/steam/content/{windows,macos,linux}/`.

### MVP: só depot macOS

Se só tens build macOS (como agora), configura em `steam/steam.env`:

```bash
STEAM_PLATFORMS=macos
STEAM_APP_ID="1234567"        # App ID do teu jogo
STEAM_DEPOT_MACOS="1234568"   # ID do depot macOS (Steamworks → Depots)
```

No Steamworks, cria **um depot macOS** com OS **macOS** e associa ao teu App. Os depots Windows/Linux podem ficar para mais tarde — não entram no upload com `STEAM_PLATFORMS=macos`.

Conteúdo actual (já pronto):

```
build/steam/content/macos/phoenix_manager.app   (~42 MB)
```

Launch option macOS em *Installation → Launch Options*:

```
phoenix_manager.app/Contents/MacOS/phoenix_manager
```

### macOS + Steam

O script aplica `Release-Steam.entitlements` (sem App Sandbox) — necessário para overlay/API Steam. Restaura os entitlements normais após o build.

## Gerar VDFs

```bash
./steam/scripts/generate_vdfs.sh
# → steam/generated/*.vdf
```

## Upload (steamcmd)

```bash
./scripts/upload_steam.sh
```

Requer SDK instalado e login steamcmd. Usa branch `beta` por defeito — altera em `steam.env` antes de `default`.

## Launch options (Steamworks)

Configurar em *Edit Steamworks Settings → Installation → Launch Options*:

| OS | Executable |
|----|------------|
| Windows | `phoenix_manager.exe` |
| macOS | `phoenix_manager.app/Contents/MacOS/phoenix_manager` |
| Linux | `phoenix_manager` |

## Checklist pré-lançamento

- [ ] Store page completa (capsules, trailer, descrição)
- [ ] Build no depot macOS (ou nos 3 depots quando tiveres runners Windows/Linux)
- [ ] Branch `beta` testada com conta de teste
- [ ] `SetLive` → `default` apenas no dia de lançamento
- [ ] Content survey + pricing configurados
- [ ] Saves em `SharedPreferences` — testar paths em build Steam (não dev)

## Steamworks API (futuro)

Achievements Steam, cloud saves e overlay exigem integrar o SDK nativo (ex. `dart:ffi` + Steamworks). Esta pasta cobre **distribuição via SteamPipe**; a integração runtime fica para uma fase posterior.

## CI (opcional)

Ver `.github/workflows/steam-upload.yml.example` — upload automático com secrets `STEAM_*`.

## Resolução de problemas

### `zsh: command not found: #`

Colaste um comentário como comando. Corre só:

```bash
./scripts/build_steam.sh macos
./steam/scripts/generate_vdfs.sh
./scripts/upload_steam.sh
```

### `unable to find utility "xcodebuild"`

O build macOS precisa do **Xcode** (não basta Flutter/Chrome):

```bash
xcode-select --install
# ou, se Xcode já está na App Store:
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
flutter doctor
```

Depois repete `./scripts/build_steam.sh macos`.

### `STEAM_SDK_ROOT must point to Steamworks SDK`

1. Entra em [partner.steamgames.com](https://partner.steamgames.com) → **Downloads** → **Steamworks SDK**
2. Extrai o ZIP (ex. `~/steamworks_sdk`)
3. Em `steam/steam.env`:

```bash
STEAM_SDK_ROOT="$HOME/steamworks_sdk"
STEAM_APP_ID="1234567"          # App ID real
STEAM_DEPOT_WINDOWS="1234568"   # IDs dos depots criados no dashboard
STEAM_DEPOT_MACOS="1234569"
STEAM_DEPOT_LINUX="1234570"
```

Sem conta Steamworks Partner aprovada não consegues obter App ID nem SDK — o passo anterior é obrigatório.
