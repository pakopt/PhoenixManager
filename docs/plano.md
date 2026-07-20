# Plano — Project Phoenix Manager

**Versão:** TS Marco 3.5  
**Actualizado:** 20 de Julho de 2026  
**Fase actual:** **TypeScript — Marco 3.5 Entity Patches**

## Marcos

| Marco | Conteúdo | Estado |
|-------|----------|--------|
| **1** | Monorepo TS + database + season CLI | ✅ |
| **2** | Electron + avançar jornada | ✅ |
| **3** | Saves (deltas) + mods + UI Guardar/Carregar | ✅ |
| **3.5** | Entity patches (club reputation) no save v2 | ✅ |
| **4** | Match camada 1 + competition-engine | ⏳ |
| **5+** | Transfer, finance, club-ai, editor | ⏳ |

## Comandos

```bash
pnpm install
pnpm test
pnpm typecheck
pnpm season -- --seed 42
pnpm dev:desktop
```

Saves v2: `saves/<slot>/save.json` inclui `patches.clubs`.  
Vitória numa jornada: `reputation +1` (máx. 100).
