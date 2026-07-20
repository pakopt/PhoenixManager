/// In-game calendar date (Digital Twin clock).
class GameDate implements Comparable<GameDate> {
  const GameDate({
    required this.year,
    required this.month,
    required this.day,
  });

  factory GameDate.start({int year = 2026}) {
    return GameDate(year: year, month: 7, day: 1);
  }

  factory GameDate.fromMap(Map<String, dynamic> map) {
    return GameDate(
      year: map['year'] as int,
      month: map['month'] as int,
      day: map['day'] as int,
    );
  }

  final int year;
  final int month;
  final int day;

  GameDate addDays(int days) {
    var y = year;
    var m = month;
    var d = day + days;

    while (d > _daysInMonth(y, m)) {
      d -= _daysInMonth(y, m);
      m += 1;
      if (m > 12) {
        m = 1;
        y += 1;
      }
    }

    while (d < 1) {
      m -= 1;
      if (m < 1) {
        m = 12;
        y -= 1;
      }
      d += _daysInMonth(y, m);
    }

    return GameDate(year: y, month: m, day: d);
  }

  int _daysInMonth(int y, int m) {
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (m == 2 && _isLeapYear(y)) {
      return 29;
    }
    return days[m - 1];
  }

  bool _isLeapYear(int y) {
    return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'day': day,
    };
  }

  @override
  int compareTo(GameDate other) {
    if (year != other.year) {
      return year.compareTo(other.year);
    }
    if (month != other.month) {
      return month.compareTo(other.month);
    }
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) {
    return other is GameDate &&
        year == other.year &&
        month == other.month &&
        day == other.day;
  }

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
