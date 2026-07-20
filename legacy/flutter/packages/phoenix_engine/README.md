# phoenix_engine — Phoenix Simulation Engine (PSE)

Motor universal de simulação desportiva. Project Phoenix Manager é a primeira app.

## Camadas PSE

```
Core → World → Simulation → EventBus → Save → Database → API (futuro)
```

## Boot flow

```
Config → Logger → DI → Database → World → Simulation
```

## Alpha v0.1

- `WorldState` — Digital Twin snapshot
- `WorldManager.advanceDays()` — tick headless
- `SaveManager` — serialize/deserialize JSON
- `SimulationEngine` — 3 velocidades temporais (stub)
