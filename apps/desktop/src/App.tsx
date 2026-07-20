import { useEffect } from 'react';
import { useSessionStore } from './store';

export default function App() {
  const { snapshot, busy, error, start, advanceDay, reset } = useSessionStore();

  useEffect(() => {
    void start(42);
  }, [start]);

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
            {snapshot.finished ? ' · Época terminada' : ''}
          </p>
        </div>
        <div className="flex gap-2">
          <button
            type="button"
            disabled={busy}
            onClick={() => void reset()}
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
