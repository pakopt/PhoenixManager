import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/util/money_format.dart';

enum InboxCategory {
  all,
  match,
  transfer,
  contract,
  injury,
  board,
  news,
}

extension InboxCategoryLabels on InboxCategory {
  String get label => switch (this) {
        InboxCategory.all => 'Tudo',
        InboxCategory.match => 'Jogo',
        InboxCategory.transfer => 'Transferência',
        InboxCategory.contract => 'Contrato',
        InboxCategory.injury => 'Lesão',
        InboxCategory.board => 'Direcção',
        InboxCategory.news => 'Notícias',
      };
}

class InboxMessage {
  const InboxMessage({
    required this.id,
    required this.category,
    required this.title,
    required this.preview,
    required this.body,
    required this.dateLabel,
    required this.icon,
    required this.sortKey,
  });

  final String id;
  final InboxCategory category;
  final String title;
  final String preview;
  final String body;
  final String dateLabel;
  final IconData icon;
  final int sortKey;
}

abstract final class InboxMessageBuilder {
  static List<InboxMessage> fromSession(GameSession session, {int limit = 60}) {
    final events = session.inboxEvents;
    final messages = <InboxMessage>[];
    for (var i = 0; i < events.length && messages.length < limit; i++) {
      final mapped = _map(session, events[i], i);
      if (mapped != null) {
        messages.add(mapped);
      }
    }
    return messages;
  }

  static InboxMessage? _map(GameSession session, PhoenixEvent event, int index) {
    return switch (event) {
      MatchPlayedEvent e => _match(session, e, index),
      TransferCompletedEvent e => _transfer(session, e, index),
      ContractRenewedEvent e => _contract(session, e, index),
      PlayerInjuredEvent e => _injury(session, e, index),
      PlayerRecoveredEvent e => _recovery(session, e, index),
      AchievementUnlockedEvent e => _achievement(session, e, index),
      SeasonFinishedEvent e => _seasonFinished(session, e, index),
      NewSeasonStartedEvent e => _newSeason(e, index),
      SalariesPaidEvent e => _salaries(session, e, index),
      TicketRevenueEvent e => _tickets(session, e, index),
      YouthIntakeEvent e => _youth(session, e, index),
      _ => null,
    };
  }

  static InboxMessage _match(
    GameSession session,
    MatchPlayedEvent e,
    int index,
  ) {
    final home = session.clubName(e.homeClubId);
    final away = session.clubName(e.awayClubId);
    final userId = GameSession.userClubId;
    final involvesUser =
        e.homeClubId == userId || e.awayClubId == userId;
    final isHome = e.homeClubId == userId;
    String? resultWord;
    if (involvesUser) {
      final scored = isHome ? e.homeScore : e.awayScore;
      final conceded = isHome ? e.awayScore : e.homeScore;
      if (scored > conceded) {
        resultWord = 'Vitória';
      } else if (scored == conceded) {
        resultWord = 'Empate';
      } else {
        resultWord = 'Derrota';
      }
    }
    final title = involvesUser
        ? 'Resultado: $resultWord $home ${e.homeScore}-${e.awayScore} $away'
        : 'Resultado: $home ${e.homeScore}-${e.awayScore} $away';
    final venue = involvesUser
        ? (isHome ? 'Jogo em casa' : 'Jogo fora')
        : 'Jogo da jornada';
    final preview =
        '$venue. Placar final: ${e.homeScore}-${e.awayScore}. '
        'xG ${e.homeXg.toStringAsFixed(2)} — ${e.awayXg.toStringAsFixed(2)}.';
    final competition = session.competitionName(e.fixture.competitionId);
    final body = '$venue\n'
        '$competition\n'
        '$home ${e.homeScore} — ${e.awayScore} $away\n\n'
        'xG: ${e.homeXg.toStringAsFixed(2)} — ${e.awayXg.toStringAsFixed(2)}\n'
        'Data: ${DateFormatUtil.gameDate(e.fixture.date)}';
    return InboxMessage(
      id: 'match_${e.fixture.id.value}_$index',
      category: InboxCategory.match,
      title: title,
      preview: preview,
      body: body,
      dateLabel: DateFormatUtil.gameDate(e.fixture.date),
      icon: Icons.emoji_events_outlined,
      sortKey: _dateKey(e.fixture.date) * 1000 + (999 - index),
    );
  }

  static InboxMessage _transfer(
    GameSession session,
    TransferCompletedEvent e,
    int index,
  ) {
    final from = session.clubName(e.record.fromClubId);
    final to = session.clubName(e.record.toClubId);
    final fee = e.record.isFree
        ? 'livre'
        : MoneyFormat.compact(e.record.fee);
    final title = 'Transferência: ${e.playerName}';
    final preview = '$from → $to · $fee';
    final body = '${e.playerName} transferiu-se de $from para $to.\n'
        'Valor: $fee\n'
        'Data: ${DateFormatUtil.gameDate(e.record.date)}';
    return InboxMessage(
      id: 'transfer_${e.record.playerId.value}_${e.record.date}_$index',
      category: InboxCategory.transfer,
      title: title,
      preview: preview,
      body: body,
      dateLabel: DateFormatUtil.gameDate(e.record.date),
      icon: Icons.swap_horiz,
      sortKey: _dateKey(e.record.date) * 1000 + (999 - index),
    );
  }

  static InboxMessage _contract(
    GameSession session,
    ContractRenewedEvent e,
    int index,
  ) {
    final title = 'Contrato renovado: ${e.playerName}';
    final preview =
        'Até ${e.newContractEndYear} · ${MoneyFormat.perMonth(e.newSalary)}';
    final body = '${e.playerName} renovou contrato por ${e.extensionYears} '
        'época(s).\n'
        'Novo fim: ${e.newContractEndYear}\n'
        'Salário: ${MoneyFormat.perMonth(e.newSalary)}\n'
        'Data: ${DateFormatUtil.gameDate(e.date)}';
    return InboxMessage(
      id: 'contract_${e.playerId.value}_${e.newContractEndYear}_$index',
      category: InboxCategory.contract,
      title: title,
      preview: preview,
      body: body,
      dateLabel: DateFormatUtil.gameDate(e.date),
      icon: Icons.assignment_turned_in_outlined,
      sortKey: _dateKey(e.date) * 1000 + (999 - index),
    );
  }

  static InboxMessage _injury(
    GameSession session,
    PlayerInjuredEvent e,
    int index,
  ) {
    final title = 'Lesão: ${e.playerName}';
    final preview = '${e.daysOut} dias de baixa';
    final body = '${e.playerName} sofreu uma lesão.\n'
        'Tempo estimado: ${e.daysOut} dias\n'
        'Clube: ${session.clubName(e.clubId)}\n'
        'Data: ${DateFormatUtil.gameDate(e.date)}';
    return InboxMessage(
      id: 'injury_${e.playerId.value}_${e.date}_$index',
      category: InboxCategory.injury,
      title: title,
      preview: preview,
      body: body,
      dateLabel: DateFormatUtil.gameDate(e.date),
      icon: Icons.healing,
      sortKey: _dateKey(e.date) * 1000 + (999 - index),
    );
  }

  static InboxMessage _recovery(
    GameSession session,
    PlayerRecoveredEvent e,
    int index,
  ) {
    final title = 'Recuperação: ${e.playerName}';
    final preview = 'Disponível para jogar';
    final body = '${e.playerName} recuperou da lesão e está disponível.\n'
        'Clube: ${session.clubName(e.clubId)}';
    return InboxMessage(
      id: 'recover_${e.playerId.value}_$index',
      category: InboxCategory.injury,
      title: title,
      preview: preview,
      body: body,
      dateLabel: '—',
      icon: Icons.check_circle_outline,
      sortKey: 999000 - index,
    );
  }

  static InboxMessage _achievement(
    GameSession session,
    AchievementUnlockedEvent e,
    int index,
  ) {
    final name = session.achievementTitle(e.achievementId);
    final title = 'Conquista: $name';
    final preview = 'Época ${e.seasonYear}';
    final body = 'Desbloqueaste a conquista «$name».\n'
        'Época ${e.seasonYear}\n'
        'Data: ${DateFormatUtil.gameDate(e.unlockedOn)}';
    return InboxMessage(
      id: 'ach_${e.achievementId.value}_$index',
      category: InboxCategory.board,
      title: title,
      preview: preview,
      body: body,
      dateLabel: DateFormatUtil.gameDate(e.unlockedOn),
      icon: Icons.military_tech_outlined,
      sortKey: _dateKey(e.unlockedOn) * 1000 + (999 - index),
    );
  }

  static InboxMessage _seasonFinished(
    GameSession session,
    SeasonFinishedEvent e,
    int index,
  ) {
    final name = session.competitionName(e.competitionId);
    final title = '$name concluída';
    final preview = 'Época ${e.seasonYear} terminada';
    final body = 'A competição $name terminou (época ${e.seasonYear}).\n'
        'Data: ${DateFormatUtil.gameDate(e.finishedOn)}';
    return InboxMessage(
      id: 'season_end_${e.competitionId.value}_${e.seasonYear}_$index',
      category: InboxCategory.board,
      title: title,
      preview: preview,
      body: body,
      dateLabel: DateFormatUtil.gameDate(e.finishedOn),
      icon: Icons.flag_outlined,
      sortKey: _dateKey(e.finishedOn) * 1000 + (999 - index),
    );
  }

  static InboxMessage _newSeason(NewSeasonStartedEvent e, int index) {
    final title = 'Nova época ${e.seasonYear}';
    final preview = 'Início ${DateFormatUtil.gameDate(e.startDate)}';
    final body = 'A época ${e.seasonYear} começou.\n'
        'Data de início: ${DateFormatUtil.gameDate(e.startDate)}';
    return InboxMessage(
      id: 'season_start_${e.seasonYear}_$index',
      category: InboxCategory.board,
      title: title,
      preview: preview,
      body: body,
      dateLabel: DateFormatUtil.gameDate(e.startDate),
      icon: Icons.restart_alt,
      sortKey: _dateKey(e.startDate) * 1000 + (999 - index),
    );
  }

  static InboxMessage _salaries(
    GameSession session,
    SalariesPaidEvent e,
    int index,
  ) {
    final title = 'Folha salarial processada';
    final preview = MoneyFormat.compact(e.amount);
    final body = 'Foram pagos os salários do clube.\n'
        'Total: ${MoneyFormat.compact(e.amount)}\n'
        'Data: ${DateFormatUtil.gameDate(e.date)}';
    return InboxMessage(
      id: 'sal_${e.clubId.value}_${e.date}_$index',
      category: InboxCategory.board,
      title: title,
      preview: preview,
      body: body,
      dateLabel: DateFormatUtil.gameDate(e.date),
      icon: Icons.payments_outlined,
      sortKey: _dateKey(e.date) * 1000 + (999 - index),
    );
  }

  static InboxMessage _tickets(
    GameSession session,
    TicketRevenueEvent e,
    int index,
  ) {
    final title = 'Receita de bilheteira';
    final preview =
        '${MoneyFormat.compact(e.amount)} · ${e.attendance} espectadores';
    final body = 'Receita de bilheteira registada.\n'
        'Valor: ${MoneyFormat.compact(e.amount)}\n'
        'Assistência: ${e.attendance}\n'
        'Data: ${DateFormatUtil.gameDate(e.date)}';
    return InboxMessage(
      id: 'tix_${e.clubId.value}_${e.date}_$index',
      category: InboxCategory.news,
      title: title,
      preview: preview,
      body: body,
      dateLabel: DateFormatUtil.gameDate(e.date),
      icon: Icons.confirmation_number_outlined,
      sortKey: _dateKey(e.date) * 1000 + (999 - index),
    );
  }

  static InboxMessage _youth(
    GameSession session,
    YouthIntakeEvent e,
    int index,
  ) {
    final title = 'Intake da academia';
    final preview = '${e.players.length} jovens · época ${e.seasonYear}';
    final names = e.players.map((p) => p.name).take(8).join(', ');
    final body = 'Entraram ${e.players.length} jogadores na academia.\n'
        'Época ${e.seasonYear}\n'
        'Nomes: $names\n'
        'Data: ${DateFormatUtil.gameDate(e.date)}';
    return InboxMessage(
      id: 'youth_${e.clubId.value}_${e.seasonYear}_$index',
      category: InboxCategory.news,
      title: title,
      preview: preview,
      body: body,
      dateLabel: DateFormatUtil.gameDate(e.date),
      icon: Icons.school_outlined,
      sortKey: _dateKey(e.date) * 1000 + (999 - index),
    );
  }

  static int _dateKey(GameDate date) =>
      date.year * 10000 + date.month * 100 + date.day;
}
