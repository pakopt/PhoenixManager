# Plano — Project Phoenix Manager

**Versão:** TS Marco 5a  
**Actualizado:** 20 de Julho de 2026  
**Fase actual:** **TypeScript — Marco 5a Squad + mercado (read-only)**

Desktop: painéis **Plantel** (jogadores do clube gerido) e **Mercado** (resto do mundo, filtro por posição no cliente).

## Marcos

| Marco | Conteúdo | Estado |
|-------|----------|--------|
| **1** | Monorepo TS + database + season CLI | ✅ |
| **2** | Electron + avançar jornada | ✅ |
| **3** | Saves (deltas) + mods + UI Guardar/Carregar | ✅ |
| **3.5** | Entity patches (club reputation) no save v2 | ✅ |
| **4** | Match L1 (highlight) + taça knockout | ✅ |
| **5a** | Squad + mercado (read-only) | ✅ |
| **5a.2+** | Buy/sell, finance, club-ai, editor | ⏳ |

## Comandos

```bash
pnpm install
pnpm test
pnpm typecheck
pnpm season -- --seed 42
pnpm dev:desktop
```

Saves v2: `saves/<slot>/save.json` inclui `patches.clubs` e estado da taça.  
Vitória numa jornada: `reputation +1` (máx. 100).  
Clube gerido: timeline L1 (~12 eventos); resto L3. Taça após J5/J10/J15 — highlight preferido se houver jogo de taça.
