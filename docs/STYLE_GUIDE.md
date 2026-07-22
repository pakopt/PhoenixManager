Funções:

camelCase

Classes:

PascalCase

Constantes:

UPPER_CASE

IDs:

`{type}:{ulid}` (ex.: `player:01HZX4YB8J7N…`) — ver `20-database/12-ids.md`

JSON:

camelCase

Pastas:

kebab-case

Interfaces:

PascalCase

Enums:

PascalCase

## Documentação

Cada documento responde a **uma** pergunta (título/ficheiro = a pergunta).

Exemplos:

- Como funciona o mercado de transferências? → `transfer-engine.md` (hoje: `30-engines/04-transfer.md`)
- Como é calculado o potencial? → `specs/player/player-growth.md`
- Como funciona o calendário? → `calendar-engine.md` (hoje: `30-engines/03-calendar.md`)

Se um rascunho misturar duas perguntas, dividir em dois ficheiros.

**Pilares:** docs novos (Club, Match, Transfer, Finance, …) declaram no topo qual(is) pilar(es) tocam — [bible/pillars/README.md](bible/pillars/README.md) — e não redefinem conceitos dos pilares.

A árvore numerada actual (`01-`, `02-`, …) mantém-se; o princípio aplica-se a **conteúdo e intenção**, não exige rename imediato.

Organização lógica: Architecture Bible — **3 pilares** (`bible/pillars/`) + satélites (20 volumes em `bible/`). Localização física: pastas numeradas (`00-project/` … `90-roadmap/`) e `specs/`.

**Modelação:** relação entre duas entidades com duração, condições ou obrigações → **Aggregate próprio**, nunca campo embutido — ver `15-domain/01-overview.md` (Regra de Aggregate de vínculo) e `ARCHITECTURE_RULES.md`.

Nada entra na Architecture Bible sem pensarmos primeiro se ainda fará sentido daqui a 10 anos (ver `bible/README.md`).
