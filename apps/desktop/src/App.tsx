import { useEffect, useState } from 'react';
import type { LedgerEntry, OfferKind, OfferStatus } from '@phoenix/contracts';
import { useSessionStore } from './store';

type MarketPositionFilter = 'ALL' | 'GK' | 'DF' | 'MF' | 'FW';

function ledgerTypeLabel(type: LedgerEntry['type']): string {
  switch (type) {
    case 'wages':
      return 'Salários';
    case 'gate':
      return 'Bilheteira';
    case 'transfer_out':
      return 'Transferência (compra)';
    case 'transfer_in':
      return 'Transferência (venda)';
    default: {
      const exhaustive: never = type;
      return exhaustive;
    }
  }
}

function cupRoundLabel(round: 'qf' | 'sf' | 'final'): string {
  switch (round) {
    case 'qf':
      return 'Quartos de final';
    case 'sf':
      return 'Meias-finais';
    case 'final':
      return 'Final';
    default: {
      const exhaustive: never = round;
      return exhaustive;
    }
  }
}

function offerKindLabel(kind: OfferKind): string {
  switch (kind) {
    case 'player_buy':
      return 'Compra';
    case 'player_sell':
      return 'Venda';
    case 'npc_bid':
      return 'Oferta recebida';
    default: {
      const exhaustive: never = kind;
      return exhaustive;
    }
  }
}

function offerStatusLabel(status: OfferStatus): string {
  switch (status) {
    case 'pending':
      return 'Pendente';
    case 'countered':
      return 'Contraproposta';
    default: {
      const exhaustive: never = status;
      return exhaustive;
    }
  }
}

function promptOfferAmount(label: string, defaultAmount: number): number | null {
  const input = window.prompt(label, String(defaultAmount));
  if (input === null) return null;
  const amount = Number(input);
  if (!Number.isFinite(amount) || amount <= 0) {
    window.alert('Introduz um valor válido superior a zero.');
    return null;
  }
  return amount;
}

export default function App() {
  const {
    snapshot,
    busy,
    error,
    lastOfferMessage,
    lastCounterOfferId,
    saves,
    mods,
    selectedMods,
    selectedManagedClubId,
    start,
    advanceDay,
    proposeBuy,
    proposeSell,
    respondOffer,
    acceptCounter,
    declineOffer,
    save,
    load,
    refreshLists,
    toggleMod,
  } = useSessionStore();
  const [marketPositionFilter, setMarketPositionFilter] = useState<MarketPositionFilter>('ALL');

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

  const filteredMarket = snapshot.market.filter(
    (player) => marketPositionFilter === 'ALL' || player.position === marketPositionFilter,
  );
  const revenues = snapshot.ledger.reduce(
    (total, entry) => total + (entry.amount > 0 ? entry.amount : 0),
    0,
  );
  const expenses = snapshot.ledger.reduce(
    (total, entry) => total + (entry.amount < 0 ? -entry.amount : 0),
    0,
  );
  const result = snapshot.ledger.reduce((total, entry) => total + entry.amount, 0);
  const ledgerEntries = [...snapshot.ledger].reverse();

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
          <p className="mt-1 font-medium tabular-nums">Caixa: €{snapshot.balance.toLocaleString('pt-PT')}</p>
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
      {lastOfferMessage ? (
        <div className="flex flex-wrap items-center justify-between gap-2 rounded-md bg-sky-950/50 px-3 py-2 text-sm text-sky-100">
          <span>{lastOfferMessage}</span>
          {lastCounterOfferId ? (
            <span className="flex gap-2">
              <button
                type="button"
                disabled={busy}
                className="rounded bg-[var(--accent)] px-2 py-1 text-xs font-medium text-[var(--accent-fg)] disabled:opacity-50"
                onClick={() => void acceptCounter(lastCounterOfferId)}
              >
                Aceitar contra
              </button>
              <button
                type="button"
                disabled={busy}
                className="rounded border border-[var(--border)] px-2 py-1 text-xs disabled:opacity-50"
                onClick={() => void declineOffer(lastCounterOfferId)}
              >
                Recusar
              </button>
            </span>
          ) : null}
        </div>
      ) : null}

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

      <div className="grid gap-4 md:grid-cols-2">
        <section className="overflow-hidden rounded-lg border border-[var(--border)] bg-[var(--surface)]/80">
          <h2 className="border-b border-[var(--border)] px-4 py-3 text-sm font-medium uppercase tracking-wider text-[var(--muted)]">
            Plantel
          </h2>
          <div className="overflow-x-auto">
            <table className="w-full min-w-[440px] text-left text-sm">
              <thead className="bg-black/25 text-[var(--muted)]">
                <tr>
                  <th className="px-3 py-2 font-medium">Nome</th>
                  <th className="px-3 py-2 font-medium">Pos</th>
                  <th className="px-3 py-2 font-medium">Rating</th>
                  <th className="px-3 py-2 font-medium">Idade</th>
                  <th className="px-3 py-2 font-medium">Fee</th>
                  <th className="px-3 py-2 font-medium">
                    <span className="sr-only">Ação</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                {snapshot.squad.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="px-3 py-4 text-[var(--muted)]">
                      Sem jogadores no plantel.
                    </td>
                  </tr>
                ) : (
                  snapshot.squad.map((player) => (
                    <tr key={player.id} className="border-t border-[var(--border)]/70">
                      <td className="px-3 py-2 font-medium">{player.name}</td>
                      <td className="px-3 py-2 tabular-nums">{player.position}</td>
                      <td className="px-3 py-2 tabular-nums">{player.rating}</td>
                      <td className="px-3 py-2 tabular-nums">{player.age}</td>
                      <td className="px-3 py-2 tabular-nums">
                        €{player.fee.toLocaleString('pt-PT')}
                      </td>
                      <td className="px-3 py-2">
                        <button
                          type="button"
                          disabled={busy || snapshot.squad.length <= 11}
                          className="rounded border border-[var(--border)] px-2 py-1 text-xs hover:bg-[#243040] disabled:opacity-50"
                          onClick={() => {
                            const amount = promptOfferAmount(
                              `Valor pedido por ${player.name}`,
                              player.fee,
                            );
                            if (amount !== null) void proposeSell(player.id, amount);
                          }}
                        >
                          Vender
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </section>

        <section className="overflow-hidden rounded-lg border border-[var(--border)] bg-[var(--surface)]/80">
          <div className="flex flex-wrap items-center justify-between gap-3 border-b border-[var(--border)] px-4 py-3">
            <h2 className="text-sm font-medium uppercase tracking-wider text-[var(--muted)]">
              Mercado
            </h2>
            <label className="flex items-center gap-2 text-xs text-[var(--muted)]">
              <span>Filtro</span>
              <select
                value={marketPositionFilter}
                onChange={(event) =>
                  setMarketPositionFilter(event.target.value as MarketPositionFilter)
                }
                className="rounded-md border border-[var(--border)] bg-black/20 px-2 py-1 text-sm text-[var(--foreground)]"
              >
                <option value="ALL">Todas</option>
                <option value="GK">GK</option>
                <option value="DF">DF</option>
                <option value="MF">MF</option>
                <option value="FW">FW</option>
              </select>
            </label>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full min-w-[600px] text-left text-sm">
              <thead className="bg-black/25 text-[var(--muted)]">
                <tr>
                  <th className="px-3 py-2 font-medium">Nome</th>
                  <th className="px-3 py-2 font-medium">Clube</th>
                  <th className="px-3 py-2 font-medium">Pos</th>
                  <th className="px-3 py-2 font-medium">Rating</th>
                  <th className="px-3 py-2 font-medium">Idade</th>
                  <th className="px-3 py-2 font-medium">Fee</th>
                  <th className="px-3 py-2 font-medium">
                    <span className="sr-only">Ação</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                {filteredMarket.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="px-3 py-4 text-[var(--muted)]">
                      Sem jogadores disponíveis para este filtro.
                    </td>
                  </tr>
                ) : (
                  filteredMarket.map((player) => (
                    <tr key={player.id} className="border-t border-[var(--border)]/70">
                      <td className="px-3 py-2 font-medium">{player.name}</td>
                      <td className="px-3 py-2">{player.clubName}</td>
                      <td className="px-3 py-2 tabular-nums">{player.position}</td>
                      <td className="px-3 py-2 tabular-nums">{player.rating}</td>
                      <td className="px-3 py-2 tabular-nums">{player.age}</td>
                      <td className="px-3 py-2 tabular-nums">
                        €{player.fee.toLocaleString('pt-PT')}
                      </td>
                      <td className="px-3 py-2">
                        <button
                          type="button"
                          disabled={busy}
                          className="rounded bg-[var(--accent)] px-2 py-1 text-xs font-medium text-[var(--accent-fg)] disabled:opacity-50"
                          onClick={() => {
                            const amount = promptOfferAmount(
                              `Oferta por ${player.name}`,
                              player.fee,
                            );
                            if (amount !== null) void proposeBuy(player.id, amount);
                          }}
                        >
                          Comprar
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </section>
      </div>

      <section className="overflow-hidden rounded-lg border border-[var(--border)] bg-[var(--surface)]/80">
        <h2 className="border-b border-[var(--border)] px-4 py-3 text-sm font-medium uppercase tracking-wider text-[var(--muted)]">
          Ofertas{' '}
          <span className="rounded-full bg-black/30 px-2 py-0.5 text-xs tabular-nums">
            {snapshot.pendingOffers.length}
          </span>
        </h2>
        <div className="overflow-x-auto">
          <table className="w-full min-w-[780px] text-left text-sm">
            <thead className="bg-black/25 text-[var(--muted)]">
              <tr>
                <th className="px-3 py-2 font-medium">Tipo</th>
                <th className="px-3 py-2 font-medium">Jogador</th>
                <th className="px-3 py-2 font-medium">Clubes</th>
                <th className="px-3 py-2 font-medium">Valor</th>
                <th className="px-3 py-2 font-medium">Estado</th>
                <th className="px-3 py-2 font-medium">
                  <span className="sr-only">Ações</span>
                </th>
              </tr>
            </thead>
            <tbody>
              {snapshot.pendingOffers.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-3 py-4 text-[var(--muted)]">
                    Sem ofertas pendentes.
                  </td>
                </tr>
              ) : (
                snapshot.pendingOffers.map((offer) => (
                  <tr key={offer.id} className="border-t border-[var(--border)]/70">
                    <td className="px-3 py-2">{offerKindLabel(offer.kind)}</td>
                    <td className="px-3 py-2 font-medium">{offer.playerName}</td>
                    <td className="px-3 py-2 text-[var(--muted)]">
                      {offer.fromClubName} → {offer.toClubName}
                    </td>
                    <td className="px-3 py-2 tabular-nums">
                      €{offer.amount.toLocaleString('pt-PT')}
                      {offer.counterAmount === undefined ? null : (
                        <span className="block text-xs text-amber-200">
                          Contra: €{offer.counterAmount.toLocaleString('pt-PT')}
                        </span>
                      )}
                    </td>
                    <td className="px-3 py-2">{offerStatusLabel(offer.status)}</td>
                    <td className="px-3 py-2">
                      <div className="flex flex-wrap justify-end gap-2">
                        {offer.kind === 'npc_bid' && offer.status === 'pending' ? (
                          <>
                            <button
                              type="button"
                              disabled={busy}
                              className="rounded bg-[var(--accent)] px-2 py-1 text-xs font-medium text-[var(--accent-fg)] disabled:opacity-50"
                              onClick={() => void respondOffer(offer.id, 'accept')}
                            >
                              Aceitar
                            </button>
                            <button
                              type="button"
                              disabled={busy}
                              className="rounded border border-[var(--border)] px-2 py-1 text-xs disabled:opacity-50"
                              onClick={() => void respondOffer(offer.id, 'reject')}
                            >
                              Recusar
                            </button>
                            <button
                              type="button"
                              disabled={busy}
                              className="rounded border border-amber-700 px-2 py-1 text-xs text-amber-200 disabled:opacity-50"
                              onClick={() => {
                                const amount = promptOfferAmount(
                                  `Contraproposta por ${offer.playerName}`,
                                  offer.fairFee,
                                );
                                if (amount !== null) {
                                  void respondOffer(offer.id, 'counter', amount);
                                }
                              }}
                            >
                              Contrapropor
                            </button>
                          </>
                        ) : null}
                        {offer.status === 'countered' ? (
                          <>
                            <button
                              type="button"
                              disabled={busy}
                              className="rounded bg-[var(--accent)] px-2 py-1 text-xs font-medium text-[var(--accent-fg)] disabled:opacity-50"
                              onClick={() => void acceptCounter(offer.id)}
                            >
                              Aceitar contra
                            </button>
                            <button
                              type="button"
                              disabled={busy}
                              className="rounded border border-[var(--border)] px-2 py-1 text-xs disabled:opacity-50"
                              onClick={() => void declineOffer(offer.id)}
                            >
                              Recusar
                            </button>
                          </>
                        ) : null}
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>

      <section className="overflow-hidden rounded-lg border border-[var(--border)] bg-[var(--surface)]/80">
        <h2 className="border-b border-[var(--border)] px-4 py-3 text-sm font-medium uppercase tracking-wider text-[var(--muted)]">
          Finanças
        </h2>
        <dl className="grid grid-cols-3 divide-x divide-[var(--border)] border-b border-[var(--border)]">
          <div className="px-4 py-3">
            <dt className="text-xs uppercase tracking-wider text-[var(--muted)]">Receitas</dt>
            <dd className="mt-1 font-medium tabular-nums text-emerald-300">
              €{revenues.toLocaleString('pt-PT')}
            </dd>
          </div>
          <div className="px-4 py-3">
            <dt className="text-xs uppercase tracking-wider text-[var(--muted)]">Despesas</dt>
            <dd className="mt-1 font-medium tabular-nums text-red-300">
              €{expenses.toLocaleString('pt-PT')}
            </dd>
          </div>
          <div className="px-4 py-3">
            <dt className="text-xs uppercase tracking-wider text-[var(--muted)]">Resultado</dt>
            <dd
              className={`mt-1 font-medium tabular-nums ${
                result < 0 ? 'text-red-300' : 'text-emerald-300'
              }`}
            >
              €{result.toLocaleString('pt-PT')}
            </dd>
          </div>
        </dl>
        <div className="overflow-x-auto">
          <table className="w-full min-w-[680px] text-left text-sm">
            <thead className="bg-black/25 text-[var(--muted)]">
              <tr>
                <th className="px-3 py-2 font-medium">Jornada</th>
                <th className="px-3 py-2 font-medium">Tipo</th>
                <th className="px-3 py-2 font-medium">Valor</th>
                <th className="px-3 py-2 font-medium">Saldo após</th>
                <th className="px-3 py-2 font-medium">Nota</th>
              </tr>
            </thead>
            <tbody>
              {ledgerEntries.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-3 py-4 text-[var(--muted)]">
                    Ainda não há movimentos financeiros nesta época.
                  </td>
                </tr>
              ) : (
                ledgerEntries.map((entry) => (
                  <tr key={entry.id} className="border-t border-[var(--border)]/70">
                    <td className="px-3 py-2 tabular-nums">{entry.matchday}</td>
                    <td className="px-3 py-2">{ledgerTypeLabel(entry.type)}</td>
                    <td
                      className={`px-3 py-2 tabular-nums ${
                        entry.amount < 0 ? 'text-red-300' : 'text-emerald-300'
                      }`}
                    >
                      €{entry.amount.toLocaleString('pt-PT')}
                    </td>
                    <td className="px-3 py-2 tabular-nums">
                      €{entry.balanceAfter.toLocaleString('pt-PT')}
                    </td>
                    <td className="px-3 py-2 text-[var(--muted)]">{entry.note ?? '—'}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
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
