import { useEffect } from 'react';
import { useSessionStore } from './store';

function cupRoundLabel(round: 'qf' | 'sf' | 'final'): string {
  switch (round) {
    case 'qf':
      return 'Quartos de final';
    case 'sf':
      return 'Meias-finais';
    case 'final':
      return 'Final';
  }
}

export default function App() {
  const {
    snapshot,
    busy,
    error,
    saves,
    mods,
    selectedMods,
    selectedManagedClubId,
    start,
    advanceDay,
    save,
    load,
    refreshLists,
    toggleMod,
  } = useSessionStore();

  useEffect(() => {
    void (async () => {
      await refreshLists();
      await start(42, []);
    })();
  }, [start, refreshLists]);

  if (!snapshot && busy) {
    return (
      <div className="flex min-h-screen items-center justify-center text-[var(--muted)]">
        A carregar sessão…
      </div>
    );
  }

  if (!snapshot) {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center gap-4 p-8">
        <p className="text-red-300">{error ?? 'Sem sessão'}</p>
        <button
          type="button"
          className="rounded-md bg-[var(--accent)] px-4 py-2 font-medium text-[var(--accent-fg)]"
          onClick={() => void start(42)}
        >
          Tentar de novo
        </button>
      </div>
    );
  }

  return (
    <div className="mx-auto flex min-h-screen max-w-5xl flex-col gap-6 p-6 md:p-8">
      <header className="flex flex-wrap items-end justify-between gap-4 border-b border-[var(--border)] pb-4">
        <div>
          <p className="text-sm uppercase tracking-[0.2em] text-[var(--muted)]">Phoenix Manager</p>
          <h1 className="mt-1 text-3xl font-semibold tracking-tight">{snapshot.competitionName}</h1>
          <p className="mt-1 text-[var(--muted)]">
            Jornada {snapshot.matchday} / {snapshot.totalMatchdays} · seed {snapshot.seed}
            {snapshot.modIds.length > 0 ? ` · mods: ${snapshot.modIds.join(', ')}` : ''}
            {snapshot.finished ? ' · Época terminada' : ''}
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <button
            type="button"
            disabled={busy}
            onClick={() => void save()}
            className="rounded-md border border-[var(--border)] bg-[var(--surface)] px-4 py-2 text-sm hover:bg-[#243040] disabled:opacity-50"
          >
            Guardar
          </button>
          <button
            type="button"
            disabled={busy}
            onClick={() => void start(42)}
            className="rounded-md border border-[var(--border)] bg-[var(--surface)] px-4 py-2 text-sm hover:bg-[#243040] disabled:opacity-50"
          >
            Nova sessão
          </button>
          <button
            type="button"
            disabled={busy || snapshot.finished}
            onClick={() => void advanceDay()}
            className="rounded-md bg-[var(--accent)] px-4 py-2 text-sm font-semibold text-[var(--accent-fg)] disabled:opacity-40"
          >
            {busy ? 'A simular…' : 'Avançar jornada'}
          </button>
        </div>
      </header>

      {error ? <p className="rounded-md bg-red-950/50 px-3 py-2 text-sm text-red-200">{error}</p> : null}

      <div className="grid gap-4 md:grid-cols-2">
        <section className="rounded-lg border border-[var(--border)] bg-[var(--surface)]/80 p-4">
          <h2 className="mb-3 text-sm font-medium uppercase tracking-wider text-[var(--muted)]">
            Mods (nova sessão)
          </h2>
          {mods.length === 0 ? (
            <p className="text-sm text-[var(--muted)]">Nenhum mod em database/mods.</p>
          ) : (
            <ul className="space-y-2">
              {mods.map((m) => (
                <li key={m.id}>
                  <label className="flex cursor-pointer items-center gap-2 text-sm">
                    <input
                      type="checkbox"
                      checked={selectedMods.includes(m.id)}
                      onChange={() => toggleMod(m.id)}
                    />
                    <span>{m.name}</span>
                  </label>
                </li>
              ))}
            </ul>
          )}
          <button
            type="button"
            disabled={busy}
            className="mt-3 rounded-md border border-[var(--border)] px-3 py-1.5 text-xs hover:bg-[#243040] disabled:opacity-50"
            onClick={() => void start(42, selectedMods)}
          >
            Aplicar mods / reiniciar
          </button>
          <label className="mt-4 block text-sm">
            <span className="mb-1 block font-medium">Clube gerido</span>
            <select
              value={selectedManagedClubId ?? snapshot.managedClubId}
              disabled={busy}
              onChange={(event) =>
                void start(42, selectedMods, event.target.value)
              }
              className="w-full rounded-md border border-[var(--border)] bg-black/20 px-3 py-2 text-sm disabled:opacity-50"
            >
              {snapshot.clubs.map((club) => (
                <option key={club.id} value={club.id}>
                  {club.name}
                </option>
              ))}
            </select>
          </label>
        </section>

        <section className="rounded-lg border border-[var(--border)] bg-[var(--surface)]/80 p-4">
          <h2 className="mb-3 text-sm font-medium uppercase tracking-wider text-[var(--muted)]">
            Saves
          </h2>
          {saves.length === 0 ? (
            <p className="text-sm text-[var(--muted)]">Ainda sem saves. Avança e guarda.</p>
          ) : (
            <ul className="space-y-2">
              {saves.map((s) => (
                <li key={s.slotId} className="flex items-center justify-between gap-2 text-sm">
                  <span className="truncate">
                    {s.label}{' '}
                    <span className="text-[var(--muted)]">
                      · J{s.matchday}
                      {s.modIds.length ? ` · ${s.modIds.join(',')}` : ''}
                    </span>
                  </span>
                  <button
                    type="button"
                    disabled={busy}
                    className="shrink-0 rounded border border-[var(--border)] px-2 py-1 text-xs hover:bg-[#243040] disabled:opacity-50"
                    onClick={() => void load(s.slotId)}
                  >
                    Carregar
                  </button>
                </li>
              ))}
            </ul>
          )}
        </section>
      </div>

      <section className="rounded-lg border border-[var(--border)] bg-[var(--surface)]/80 p-4">
        <h2 className="mb-3 text-sm font-medium uppercase tracking-wider text-[var(--muted)]">
          Última jornada
        </h2>
        {snapshot.lastResults.length === 0 ? (
          <p className="text-sm text-[var(--muted)]">Ainda sem jogos. Avança a primeira jornada.</p>
        ) : (
          <ul className="grid gap-2 sm:grid-cols-2">
            {snapshot.lastResults.map((r) => (
              <li
                key={`${r.homeClubId}-${r.awayClubId}-${snapshot.matchday}`}
                className="flex items-center justify-between rounded-md bg-black/20 px-3 py-2 text-sm"
              >
                <span className="truncate pr-2">
                  {r.homeName} <span className="text-[var(--muted)]">vs</span> {r.awayName}
                </span>
                <span className="font-mono tabular-nums">
                  {r.homeGoals}–{r.awayGoals}
                </span>
              </li>
            ))}
          </ul>
        )}
      </section>

      <div className="grid gap-4 md:grid-cols-2">
        <section className="rounded-lg border border-[var(--border)] bg-[var(--surface)]/80 p-4">
          <h2 className="mb-3 text-sm font-medium uppercase tracking-wider text-[var(--muted)]">
            O teu jogo
          </h2>
          {!snapshot.highlight ? (
            <p className="text-sm text-[var(--muted)]">
              Ainda não há um jogo do teu clube nesta jornada.
            </p>
          ) : (
            <>
              <p className="text-lg font-semibold tabular-nums">
                {snapshot.highlight.homeName} {snapshot.highlight.homeGoals}–{snapshot.highlight.awayGoals}{' '}
                {snapshot.highlight.awayName}
              </p>
              {snapshot.highlight.events.length === 0 ? (
                <p className="mt-3 text-sm text-[var(--muted)]">Sem eventos registados.</p>
              ) : (
                <ol className="mt-3 space-y-2">
                  {snapshot.highlight.events.map((event, index) => (
                    <li
                      key={`${event.minute}-${event.clubId}-${index}`}
                      className="rounded-md bg-black/20 px-3 py-2 text-sm"
                    >
                      <span className="mr-2 font-mono text-[var(--muted)]">
                        {event.minute}&apos;
                      </span>
                      {event.text}
                    </li>
                  ))}
                </ol>
              )}
            </>
          )}
        </section>

        <section className="rounded-lg border border-[var(--border)] bg-[var(--surface)]/80 p-4">
          <h2 className="mb-3 text-sm font-medium uppercase tracking-wider text-[var(--muted)]">
            Taça
          </h2>
          {!snapshot.cup ? (
            <p className="text-sm text-[var(--muted)]">Taça indisponível.</p>
          ) : (
            <>
              <p className="text-sm font-medium">
                {cupRoundLabel(snapshot.cup.round)}
                {snapshot.cup.completed ? ' · concluída' : ''}
              </p>
              <ul className="mt-3 space-y-2">
                {snapshot.cup.ties.map((tie) => (
                  <li
                    key={`${tie.homeClubId}-${tie.awayClubId}`}
                    className="flex items-center justify-between gap-2 rounded-md bg-black/20 px-3 py-2 text-sm"
                  >
                    <span className="truncate">
                      {tie.homeName} <span className="text-[var(--muted)]">vs</span> {tie.awayName}
                    </span>
                    {tie.result ? (
                      <span className="shrink-0 font-mono tabular-nums">
                        {tie.result.homeGoals}–{tie.result.awayGoals}
                      </span>
                    ) : null}
                  </li>
                ))}
              </ul>
              {!snapshot.cup.completed && snapshot.cup.nextRoundAfterMatchday ? (
                <p className="mt-3 text-sm text-[var(--muted)]">
                  Próxima ronda após jornada {snapshot.cup.nextRoundAfterMatchday}.
                </p>
              ) : null}
            </>
          )}
        </section>
      </div>

      <section className="overflow-hidden rounded-lg border border-[var(--border)] bg-[var(--surface)]/80">
        <h2 className="border-b border-[var(--border)] px-4 py-3 text-sm font-medium uppercase tracking-wider text-[var(--muted)]">
          Classificação
        </h2>
        <div className="overflow-x-auto">
          <table className="w-full min-w-[640px] text-left text-sm">
            <thead className="bg-black/25 text-[var(--muted)]">
              <tr>
                <th className="px-3 py-2 font-medium">#</th>
                <th className="px-3 py-2 font-medium">Clube</th>
                <th className="px-3 py-2 font-medium">Rep</th>
                <th className="px-3 py-2 font-medium">J</th>
                <th className="px-3 py-2 font-medium">V</th>
                <th className="px-3 py-2 font-medium">E</th>
                <th className="px-3 py-2 font-medium">D</th>
                <th className="px-3 py-2 font-medium">GM</th>
                <th className="px-3 py-2 font-medium">GS</th>
                <th className="px-3 py-2 font-medium">Pts</th>
              </tr>
            </thead>
            <tbody>
              {snapshot.table.map((row, i) => (
                <tr key={row.clubId} className="border-t border-[var(--border)]/70">
                  <td className="px-3 py-2 tabular-nums text-[var(--muted)]">{i + 1}</td>
                  <td className="px-3 py-2 font-medium">{row.clubName}</td>
                  <td className="px-3 py-2 tabular-nums text-[var(--muted)]">{row.reputation}</td>
                  <td className="px-3 py-2 tabular-nums">{row.played}</td>
                  <td className="px-3 py-2 tabular-nums">{row.won}</td>
                  <td className="px-3 py-2 tabular-nums">{row.drawn}</td>
                  <td className="px-3 py-2 tabular-nums">{row.lost}</td>
                  <td className="px-3 py-2 tabular-nums">{row.goalsFor}</td>
                  <td className="px-3 py-2 tabular-nums">{row.goalsAgainst}</td>
                  <td className="px-3 py-2 font-semibold tabular-nums">{row.points}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
