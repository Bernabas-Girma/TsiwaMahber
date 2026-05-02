class AppConstants {
  AppConstants._();

  static const String appName = 'Tsiwa';
  static const String appNameAmharic = 'ጽዋ';
  static const String appFullName = 'ጽዋ ማህበር አስተዳደር';

  static const String defaultAreaId = 'gelan';
  static const String defaultAreaName = 'የገላን ፅዋ ማህበሮች';
  static const String defaultAreaShortName = 'ገላን';
  static const String defaultAreaLocation =
      'Addis Ababa, Kality Gelan Condominium';
  static const String defaultAreaDescription = 'የገላን አካባቢ ፅዋ ማህበሮች አስተዳደር';

  static const List<String> ethiopianMonths = [
    'መስከረም',
    'ጥቅምት',
    'ሕዳር',
    'ታኅሣሥ',
    'ጥር',
    'የካቲት',
    'መጋቢት',
    'ሚያዝያ',
    'ግንቦት',
    'ሰኔ',
    'ሐምሌ',
    'ነሐሴ',
  ];

  static String ethiopianMonthName(int month) {
    if (month < 1 || month > 12) return '';
    return ethiopianMonths[month - 1];
  }
}
