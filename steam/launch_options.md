# Steam Launch Options — Phoenix Manager

Paste into **Steamworks → Edit Steam Settings → Installation → General → Launch Options**.

## Windows

```
phoenix_manager.exe
```

## macOS

```
phoenix_manager.app/Contents/MacOS/phoenix_manager
```

## Linux / Steam Deck

```
phoenix_manager
```

## Working directory

Steam sets CWD to the depot root automatically. Saves use `shared_preferences` (platform-specific user data dir), not the install folder.

## Beta branch testing

1. Upload with `STEAM_BRANCH=beta` in `steam/steam.env`.
2. Steamworks → Builds → set build live on **beta**.
3. Steam client → Properties → Betas → select your beta branch.
