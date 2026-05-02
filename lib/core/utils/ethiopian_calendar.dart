import 'package:tsiwa_mahber/core/constants/app_constants.dart';
import 'package:tsiwa_mahber/core/l10n/app_strings.dart';
import 'package:tsiwa_mahber/core/theme/app_theme.dart';

class EthiopianDate {
  final int year;
  final int month;
  final int day;

  const EthiopianDate({
    required this.year,
    required this.month,
    required this.day,
  });

  String get monthName => AppConstants.ethiopianMonthName(month);

  String get formatted => '$monthName $day, $year';

  String get shortFormatted => '$monthName $day';

  @override
  String toString() => '$year-$month-$day';

  @override
  bool operator ==(Object other) =>
      other is EthiopianDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);
}

class EthiopianCalendar {
  EthiopianCalendar._();

  static bool _isEthiopianLeapYear(int year) {
    return (year % 4) == 3;
  }

  static EthiopianDate fromGregorian(DateTime date) {
    final jdn = _gregorianToJdn(date.year, date.month, date.day);
    return _jdnToEthiopian(jdn);
  }

  static DateTime toGregorian(EthiopianDate ethDate) {
    final jdn = _ethiopianToJdn(ethDate.year, ethDate.month, ethDate.day);
    return _jdnToGregorian(jdn);
  }

  static EthiopianDate today() {
    return fromGregorian(DateTime.now());
  }

  static int _gregorianToJdn(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;

    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }

  static DateTime _jdnToGregorian(int jdn) {
    final a = jdn + 32044;
    final b = (4 * a + 3) ~/ 146097;
    final c = a - (146097 * b) ~/ 4;
    final d = (4 * c + 3) ~/ 1461;
    final e = c - (1461 * d) ~/ 4;
    final m = (5 * e + 2) ~/ 153;

    final day = e - (153 * m + 2) ~/ 5 + 1;
    final month = m + 3 - 12 * (m ~/ 10);
    final year = 100 * b + d - 4800 + m ~/ 10;

    return DateTime(year, month, day);
  }

  static int _ethiopianToJdn(int year, int month, int day) {
    return (1723856 + 365) +
        365 * (year - 1) +
        year ~/ 4 +
        30 * (month - 1) +
        day -
        1;
  }

  static EthiopianDate _jdnToEthiopian(int jdn) {
    final r = ((jdn - 1723856) % 1461);
    final n = (r % 365) + 365 * (r ~/ 1460);

    final year = 4 * ((jdn - 1723856) ~/ 1461) + (r ~/ 365) - (r ~/ 1460);
    final month = (n ~/ 30) + 1;
    final day = (n % 30) + 1;

    return EthiopianDate(year: year, month: month, day: day);
  }

  static int daysInMonth(int year, int month) {
    if (month >= 1 && month <= 12) return 30;
    if (month == 13) return _isEthiopianLeapYear(year) ? 6 : 5;
    return 0;
  }

  static int daysUntilMonthlyDay(int targetDay) {
    final now = today();
    if (targetDay < 1 || targetDay > 30) return -1;

    if (now.day < targetDay) {
      return targetDay - now.day;
    } else if (now.day == targetDay) {
      return 0;
    } else {
      final daysLeftInMonth = daysInMonth(now.year, now.month) - now.day;
      return daysLeftInMonth + targetDay;
    }
  }

  static int daysUntilDate(int targetMonth, int targetDay) {
    if (targetMonth < 1 || targetMonth > 13) return -1;
    if (targetDay < 1 || targetDay > 30) return -1;

    final now = today();
    int targetYear = now.year;

    final targetGreg = toGregorian(
      EthiopianDate(year: targetYear, month: targetMonth, day: targetDay),
    );
    final nowGreg = DateTime.now();
    final todayGreg = DateTime(nowGreg.year, nowGreg.month, nowGreg.day);

    var diff = targetGreg.difference(todayGreg).inDays;
    if (diff < 0) {
      final nextYearGreg = toGregorian(
        EthiopianDate(year: targetYear + 1, month: targetMonth, day: targetDay),
      );
      diff = nextYearGreg.difference(todayGreg).inDays;
    }

    return diff;
  }

  static String daysUntilText(int days) {
    if (days < 0) return '';
    if (days == 0) return S.today;
    if (days == 1) return S.tomorrow;
    return _am ? '$days ቀናት ቀርተዋል' : '$days days left';
  }

  static bool get _am => LocaleProvider.instance.isAmharic;
}
