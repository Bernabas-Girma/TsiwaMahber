import 'package:flutter/material.dart';

/// Identifiers for all available themes.
enum AppThemeMode {
  dark,
  light,
  ocean,
  sunset,
  forest,
  lavender,
  midnight,
  rose,
  coffee,
  emerald,
  royal,
  cherry,
}

class PremiumThemeConfig {
  final String name;
  final String nameAm;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textMuted;
  final Brightness brightness;

  const PremiumThemeConfig({
    required this.name,
    required this.nameAm,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textMuted,
    required this.brightness,
  });
}

class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFF0F0F10);
  static const Color surface = Color(0xFF1B1B1F);
  static const Color primary = Color(0xFFFFC107);
  static const Color secondary = Color(0xFF8D3B2F);
  static const Color textPrimary = Colors.white;
  static const Color textMuted = Colors.grey;
  static const Color success = Colors.green;
  static const Color error = Colors.red;

  // Light theme colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1B1B1F);

  static const Map<AppThemeMode, PremiumThemeConfig> premiumThemes = {
    AppThemeMode.ocean: PremiumThemeConfig(
      name: 'Ocean',
      nameAm: 'ውቅያኖስ',
      primary: Color(0xFF0288D1),
      secondary: Color(0xFF0097A7),
      background: Color(0xFF0A1929),
      surface: Color(0xFF132F4C),
      textPrimary: Colors.white,
      textMuted: Color(0xFF8796A5),
      brightness: Brightness.dark,
    ),
    AppThemeMode.sunset: PremiumThemeConfig(
      name: 'Sunset',
      nameAm: 'ፀሐይ ስትጠልቅ',
      primary: Color(0xFFFF6B35),
      secondary: Color(0xFFD81B60),
      background: Color(0xFF1A0A2E),
      surface: Color(0xFF2D1B4E),
      textPrimary: Colors.white,
      textMuted: Color(0xFFA889C8),
      brightness: Brightness.dark,
    ),
    AppThemeMode.forest: PremiumThemeConfig(
      name: 'Forest',
      nameAm: 'ደን',
      primary: Color(0xFF4CAF50),
      secondary: Color(0xFF2E7D32),
      background: Color(0xFF0D1F0D),
      surface: Color(0xFF1B3A1B),
      textPrimary: Colors.white,
      textMuted: Color(0xFF81A681),
      brightness: Brightness.dark,
    ),
    AppThemeMode.lavender: PremiumThemeConfig(
      name: 'Lavender',
      nameAm: 'ላቬንደር',
      primary: Color(0xFF7C4DFF),
      secondary: Color(0xFFE040FB),
      background: Color(0xFFF3E5F5),
      surface: Colors.white,
      textPrimary: Color(0xFF1B1B2F),
      textMuted: Color(0xFF7E7E9A),
      brightness: Brightness.light,
    ),
    AppThemeMode.midnight: PremiumThemeConfig(
      name: 'Midnight',
      nameAm: 'እኩለ ሌሊት',
      primary: Color(0xFF00BCD4),
      secondary: Color(0xFF26C6DA),
      background: Color(0xFF0D0D1A),
      surface: Color(0xFF14142B),
      textPrimary: Color(0xFFE0E0FF),
      textMuted: Color(0xFF6B6B8D),
      brightness: Brightness.dark,
    ),
    AppThemeMode.rose: PremiumThemeConfig(
      name: 'Rose Gold',
      nameAm: 'ሮዝ ወርቅ',
      primary: Color(0xFFE91E63),
      secondary: Color(0xFFFF5252),
      background: Color(0xFFFFF0F0),
      surface: Colors.white,
      textPrimary: Color(0xFF2D1B1B),
      textMuted: Color(0xFF8D6B6B),
      brightness: Brightness.light,
    ),
    AppThemeMode.coffee: PremiumThemeConfig(
      name: 'Coffee',
      nameAm: 'ቡና',
      primary: Color(0xFFD7A86E),
      secondary: Color(0xFF8B6914),
      background: Color(0xFF1C1108),
      surface: Color(0xFF2D1E0F),
      textPrimary: Color(0xFFF5E6D3),
      textMuted: Color(0xFF9C8B76),
      brightness: Brightness.dark,
    ),
    AppThemeMode.emerald: PremiumThemeConfig(
      name: 'Emerald',
      nameAm: 'ኤመራልድ',
      primary: Color(0xFF00C853),
      secondary: Color(0xFF009688),
      background: Color(0xFFE8F5E9),
      surface: Colors.white,
      textPrimary: Color(0xFF1B2D1B),
      textMuted: Color(0xFF6B8D6B),
      brightness: Brightness.light,
    ),
    AppThemeMode.royal: PremiumThemeConfig(
      name: 'Royal',
      nameAm: 'ንጉሳዊ',
      primary: Color(0xFFFFD700),
      secondary: Color(0xFF9C27B0),
      background: Color(0xFF0D0033),
      surface: Color(0xFF1A0052),
      textPrimary: Color(0xFFF0E6FF),
      textMuted: Color(0xFF8B6BB5),
      brightness: Brightness.dark,
    ),
    AppThemeMode.cherry: PremiumThemeConfig(
      name: 'Cherry Blossom',
      nameAm: 'የቼሪ ፍሬ',
      primary: Color(0xFFF06292),
      secondary: Color(0xFFCE93D8),
      background: Color(0xFFFCE4EC),
      surface: Colors.white,
      textPrimary: Color(0xFF2D1B24),
      textMuted: Color(0xFF9E7B8A),
      brightness: Brightness.light,
    ),
  };

  static ThemeData buildTheme(PremiumThemeConfig config) {
    final isDark = config.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: config.brightness,
      scaffoldBackgroundColor: config.background,
      colorScheme: ColorScheme(
        brightness: config.brightness,
        primary: config.primary,
        secondary: config.secondary,
        surface: config.surface,
        error: error,
        onPrimary: isDark ? Colors.black : Colors.white,
        onSecondary: Colors.white,
        onSurface: config.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? config.background : config.surface,
        foregroundColor: config.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: config.surface,
        elevation: isDark ? 2 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: config.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: config.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: config.primary),
        ),
        labelStyle: TextStyle(color: config.textMuted),
        hintStyle: TextStyle(color: config.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: config.primary,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return config.primary;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return config.primary.withValues(alpha: 0.5);
          }
          return isDark ? Colors.grey.shade800 : Colors.grey.shade300;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: config.surface,
        contentTextStyle: TextStyle(color: config.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        thickness: 0.5,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.5);
          }
          return Colors.grey.shade800;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade800,
        thickness: 0.5,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: lightSurface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightSurface,
        contentTextStyle: const TextStyle(color: lightTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 0.5,
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.dark;

  AppThemeMode get mode => _mode;

  // Keep backward-compatible isDarkMode getter
  bool get isDarkMode =>
      _mode == AppThemeMode.dark ||
      (AppTheme.premiumThemes[_mode]?.brightness == Brightness.dark);

  ThemeData get theme {
    switch (_mode) {
      case AppThemeMode.dark:
        return AppTheme.darkTheme;
      case AppThemeMode.light:
        return AppTheme.lightTheme;
      default:
        final config = AppTheme.premiumThemes[_mode];
        if (config != null) return AppTheme.buildTheme(config);
        return AppTheme.darkTheme;
    }
  }

  void setTheme(AppThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _mode = _mode == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;
    notifyListeners();
  }
}

class LocaleProvider extends ChangeNotifier {
  static LocaleProvider? _instance;

  static LocaleProvider get instance {
    _instance ??= LocaleProvider();
    return _instance!;
  }

  bool _isAmharic = true;

  bool get isAmharic => _isAmharic;

  String get languageCode => _isAmharic ? 'am' : 'en';

  void toggleLanguage() {
    _isAmharic = !_isAmharic;
    notifyListeners();
  }

  @override
  // ignore: must_call_super
  void dispose() {
    // Singleton — must never be disposed.
  }
}
