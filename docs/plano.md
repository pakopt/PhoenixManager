# Plano — Project Phoenix Manager

**Versão:** TS Marco 5d  
**Actualizado:** 21 de Julho de 2026  
**Fase actual:** **TypeScript — Marco 5d Mod Editor**

Desktop: painéis **Plantel**, **Mercado**, **Finanças** e **Ofertas**; **Caixa** no cabeçalho. Fee = `rating × 100 000`; saldo inicial `5 000 000`. Ledger persistido: salários por jornada (`rating × 1 000`), bilheteira em casa (`reputation × 10 000`, ≤1 por jornada), transferências in/out. Mercado NPC: até 3 transferências entre clubes por jornada; propostas do jogador com resposta imediata (aceitar/rejeitar/contra única); 0–2 bids NPC sobre o plantel gerido — inbox **Ofertas**. **Mods:** editor de clubes e jogadores (criar pack, override/remover, badges core/mod/new); carreira via **Aplicar mods / reiniciar** (sem hot-reload).

## Marcos

| Marco | Conteúdo | Estado |
|-------|----------|--------|
| **1** | Monorepo TS + database + season CLI | ✅ |
| **2** | Electron + avançar jornada | ✅ |
| **3** | Saves (deltas) + mods + UI Guardar/Carregar | ✅ |
| **3.5** | Entity patches (club reputation) no save v2 | ✅ |
| **4** | Match L1 (highlight) + taça knockout | ✅ |
| **5a** | Squad + mercado (read-only) | ✅ |
| **5a.2** | Buy/sell (fee, caixa, save balance/patches) | ✅ |
| **5b** | Finance ledger (wages, gate ≤1/jornada, transfer rows, Finanças UI) | ✅ |
| **5c** | Club AI (NPC↔NPC ≤3/jornada, propostas/contras, npc_bid, Ofertas UI) | ✅ |
| **5d** | Mod editor (createMod, loadEditorWorld, upsert/remove club & player, Zod + refs, UI Mods) | ✅ |

## Comandos

```bash
pnpm install
pnpm test
pnpm typecheck
pnpm season -- --seed 42
pnpm dev:desktop
```

Saves v2: `saves/<slot>/save.json` inclui `patches.clubs`, `patches.players`, `balance`, `ledger` (opcional), `pendingOffers` (opcional) e estado da taça.  
Vitória numa jornada: `reputation +1` (máx. 100).  
Clube gerido: timeline L1 (~12 eventos); resto L3. Taça após J5/J10/J15 — highlight preferido se houver jogo de taça.  
Mod editor 5d: `database/core/` só leitura; edição só clubes/jogadores em `database/mods/`; **5d.2** (nações, competições, lobby sem auto-start) fora de âmbito.
