import 'package:phoenix_core/phoenix_core.dart';

/// Central registry — each entity exists once; systems reference by ID.
class WorldRegistry implements WorldRegistryReader {
  WorldRegistry({
    Map<ContinentId, Continent>? continents,
    Map<CountryId, Country>? countries,
    Map<RegionId, Region>? regions,
    Map<CityId, City>? cities,
    Map<ClubId, Club>? clubs,
    Map<PlayerId, Player>? players,
    Map<CoachId, Coach>? coaches,
    Map<StaffId, StaffMember>? staff,
    Map<CompetitionId, Competition>? competitions,
    Map<MatchId, MatchFixture>? fixtures,
    Map<MatchId, MatchResult>? matchResults,
    Map<CompetitionId, List<StandingEntry>>? standings,
    Map<ClubId, ClubFinance>? clubFinances,
    List<TransferRecord>? transfers,
    Map<AchievementId, UnlockedAchievement>? unlockedAchievements,
    Map<int, Set<String>>? seasonHonours,
  })  : continents = continents ?? {},
        countries = countries ?? {},
        regions = regions ?? {},
        cities = cities ?? {},
        clubs = clubs ?? {},
        players = players ?? {},
        coaches = coaches ?? {},
        staff = staff ?? {},
        competitions = competitions ?? {},
        fixtures = fixtures ?? {},
        matchResults = matchResults ?? {},
        standings = standings ?? {},
        clubFinances = clubFinances ?? {},
        transfers = transfers ?? [],
        unlockedAchievements = unlockedAchievements ?? {},
        seasonHonours = seasonHonours ?? {};

  final Map<ContinentId, Continent> continents;
  final Map<CountryId, Country> countries;
  final Map<RegionId, Region> regions;
  final Map<CityId, City> cities;
  final Map<ClubId, Club> clubs;
  final Map<PlayerId, Player> players;
  final Map<CoachId, Coach> coaches;
  final Map<StaffId, StaffMember> staff;
  final Map<CompetitionId, Competition> competitions;
  final Map<MatchId, MatchFixture> fixtures;
  final Map<MatchId, MatchResult> matchResults;
  final Map<CompetitionId, List<StandingEntry>> standings;
  final Map<ClubId, ClubFinance> clubFinances;
  final List<TransferRecord> transfers;
  final Map<AchievementId, UnlockedAchievement> unlockedAchievements;
  final Map<int, Set<String>> seasonHonours;

  SquadQueryService get squadQuery => SquadQueryService(players);
  StaffQueryService get staffQuery => StaffQueryService(staff);

  void registerClub(Club club) => clubs[club.id] = club;
  void registerPlayer(Player player) => players[player.id] = player;
  void registerCoach(Coach coach) => coaches[coach.id] = coach;
  void registerStaff(StaffMember member) => staff[member.id] = member;
  void registerCompetition(Competition competition) =>
      competitions[competition.id] = competition;
  void registerFixture(MatchFixture fixture) => fixtures[fixture.id] = fixture;

  Club? getClub(ClubId id) => clubs[id];
  Player? getPlayer(PlayerId id) => players[id];
  Coach? getCoach(CoachId id) => coaches[id];
  Competition? getCompetition(CompetitionId id) => competitions[id];
  MatchFixture? getFixture(MatchId id) => fixtures[id];

  List<MatchFixture> fixturesOnDate(GameDate date) {
    return fixtures.values
        .where((fixture) => fixture.date == date && !fixture.isPlayed)
        .toList();
  }

  WorldRegistry copyWith({
    Map<ClubId, Club>? clubs,
    Map<PlayerId, Player>? players,
    Map<MatchId, MatchFixture>? fixtures,
    Map<MatchId, MatchResult>? matchResults,
    Map<CompetitionId, List<StandingEntry>>? standings,
    Map<ClubId, ClubFinance>? clubFinances,
    List<TransferRecord>? transfers,
  }) {
    return WorldRegistry(
      continents: continents,
      countries: countries,
      regions: regions,
      cities: cities,
      clubs: clubs ?? Map.from(this.clubs),
      players: players ?? Map.from(this.players),
      coaches: coaches,
      staff: Map.from(this.staff),
      competitions: competitions,
      fixtures: fixtures ?? Map.from(this.fixtures),
      matchResults: matchResults ?? Map.from(this.matchResults),
      standings: standings ?? Map.from(this.standings),
      clubFinances: clubFinances ?? Map.from(this.clubFinances),
      transfers: transfers ?? List.from(this.transfers),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'continents': continents.values.map((e) => e.toMap()).toList(),
      'countries': countries.values.map((e) => e.toMap()).toList(),
      'regions': regions.values.map((e) => e.toMap()).toList(),
      'cities': cities.values.map((e) => e.toMap()).toList(),
      'clubs': clubs.values.map((e) => e.toMap()).toList(),
      'players': players.values.map((e) => e.toMap()).toList(),
      'coaches': coaches.values.map((e) => e.toMap()).toList(),
      'staff': staff.values.map((e) => e.toMap()).toList(),
      'competitions': competitions.values.map((e) => e.toMap()).toList(),
      'fixtures': fixtures.values.map((e) => e.toMap()).toList(),
      'matchResults': matchResults.values.map((e) => e.toMap()).toList(),
      'standings': standings.map(
        (compId, entries) => MapEntry(
          compId.value,
          entries.map((e) => e.toMap()).toList(),
        ),
      ),
      'clubFinances': clubFinances.values.map((e) => e.toMap()).toList(),
      'transfers': transfers.map((e) => e.toMap()).toList(),
      'unlockedAchievements':
          unlockedAchievements.values.map((e) => e.toMap()).toList(),
      'seasonHonours': seasonHonours.map(
        (year, honours) => MapEntry('$year', honours.toList()),
      ),
    };
  }

  factory WorldRegistry.fromMap(Map<String, dynamic> map) {
    final standingsRaw = map['standings'] as Map<dynamic, dynamic>? ?? {};
    return WorldRegistry(
      continents: {
        for (final item in _list(map['continents']))
          Continent.fromMap(item).id: Continent.fromMap(item),
      },
      countries: {
        for (final item in _list(map['countries']))
          Country.fromMap(item).id: Country.fromMap(item),
      },
      regions: {
        for (final item in _list(map['regions']))
          Region.fromMap(item).id: Region.fromMap(item),
      },
      cities: {
        for (final item in _list(map['cities']))
          City.fromMap(item).id: City.fromMap(item),
      },
      clubs: {
        for (final item in _list(map['clubs']))
          Club.fromMap(item).id: Club.fromMap(item),
      },
      players: {
        for (final item in _list(map['players']))
          Player.fromMap(item).id: Player.fromMap(item),
      },
      coaches: {
        for (final item in _list(map['coaches']))
          Coach.fromMap(item).id: Coach.fromMap(item),
      },
      staff: {
        for (final item in _list(map['staff']))
          StaffMember.fromMap(item).id: StaffMember.fromMap(item),
      },
      competitions: {
        for (final item in _list(map['competitions']))
          Competition.fromMap(item).id: Competition.fromMap(item),
      },
      fixtures: {
        for (final item in _list(map['fixtures']))
          MatchFixture.fromMap(item).id: MatchFixture.fromMap(item),
      },
      matchResults: {
        for (final item in _list(map['matchResults']))
          MatchResult.fromMap(item).matchId: MatchResult.fromMap(item),
      },
      standings: {
        for (final entry in standingsRaw.entries)
          CompetitionId(entry.key as String): (entry.value as List)
              .map(
                (e) => StandingEntry.fromMap(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
      },
      clubFinances: {
        for (final item in _list(map['clubFinances']))
          ClubFinance.fromMap(item).clubId: ClubFinance.fromMap(item),
      },
      transfers: _list(map['transfers'])
          .map((e) => TransferRecord.fromMap(e))
          .toList(),
      unlockedAchievements: Map.fromEntries(
        _list(map['unlockedAchievements']).map((item) {
          final unlocked = UnlockedAchievement.fromMap(item);
          return MapEntry(unlocked.id, unlocked);
        }),
      ),
      seasonHonours: _parseSeasonHonours(map['seasonHonours']),
    );
  }

  static Map<int, Set<String>> _parseSeasonHonours(dynamic raw) {
    if (raw is! Map) {
      return {};
    }
    return {
      for (final entry in raw.entries)
        int.parse(entry.key as String): (entry.value as List)
            .map((e) => e as String)
            .toSet(),
    };
  }

  static List<Map<String, dynamic>> _list(dynamic raw) {
    return (raw as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Replaces all registry data in-place (used when loading a save).
  void replaceWith(WorldRegistry source) {
    _replaceMap(continents, source.continents);
    _replaceMap(countries, source.countries);
    _replaceMap(regions, source.regions);
    _replaceMap(cities, source.cities);
    _replaceMap(clubs, source.clubs);
    _replaceMap(players, source.players);
    _replaceMap(coaches, source.coaches);
    _replaceMap(staff, source.staff);
    _replaceMap(competitions, source.competitions);
    _replaceMap(fixtures, source.fixtures);
    _replaceMap(matchResults, source.matchResults);
    _replaceMap(standings, source.standings);
    _replaceMap(clubFinances, source.clubFinances);
    transfers
      ..clear()
      ..addAll(source.transfers);
    _replaceMap(unlockedAchievements, source.unlockedAchievements);
    seasonHonours
      ..clear()
      ..addAll(source.seasonHonours.map(
        (year, honours) => MapEntry(year, Set<String>.from(honours)),
      ));
  }

  void _replaceMap<K, V>(Map<K, V> target, Map<K, V> source) {
    target
      ..clear()
      ..addAll(source);
  }
}
