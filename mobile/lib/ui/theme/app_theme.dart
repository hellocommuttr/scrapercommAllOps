import 'package:flutter/material.dart';

/// Commuttr's own colours. Deliberately not Golden Arrow's livery (green/yellow): the
/// app is independent and must not look official.
abstract final class Brand {
  /// Accent for text and icons on dark backgrounds (6.9:1 on black).
  static const orange = Color(0xFFFF4A1C);

  /// Filled buttons: white text on this meets WCAG AA (4.6:1).
  static const orangeDeep = Color(0xFFD93C14);

  /// Accent for text on light backgrounds (4.9:1 on white).
  static const orangeInk = Color(0xFFC2360B);
}

/// Surface and status colours the Material scheme has no slot for.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.card,
    required this.cardBorder,
    required this.muted,
    required this.accentText,
    required this.success,
    required this.warning,
    required this.warningSurface,
    required this.infoSurface,
  });

  final Color card;
  final Color cardBorder;
  final Color muted;
  final Color accentText;
  final Color success;
  final Color warning;
  final Color warningSurface;
  final Color infoSurface;

  static const dark = AppColors(
    card: Color(0xFF141414),
    cardBorder: Color(0xFF2A2A2A),
    muted: Color(0xFFA3A3A3),
    accentText: Brand.orange,
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    warningSurface: Color(0xFF2A2210),
    infoSurface: Color(0xFF1A1A1A),
  );

  static const light = AppColors(
    card: Colors.white,
    cardBorder: Color(0xFFE3E3E3),
    muted: Color(0xFF5F5F5F),
    accentText: Brand.orangeInk,
    success: Color(0xFF15803D),
    warning: Color(0xFF92400E),
    warningSurface: Color(0xFFFFF4DB),
    infoSurface: Color(0xFFF1F1F1),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) => t < 0.5 ? this : (other as AppColors? ?? this);
}

extension AppThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}

abstract final class AppTheme {
  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final c = isDark ? AppColors.dark : AppColors.light;
    final scheme = ColorScheme.fromSeed(seedColor: Brand.orange, brightness: b).copyWith(
      primary: isDark ? Brand.orange : Brand.orangeInk,
      onPrimary: Colors.white,
      primaryContainer: Brand.orangeDeep,
      onPrimaryContainer: Colors.white,
      surface: isDark ? Colors.black : const Color(0xFFF7F7F7),
      onSurface: isDark ? Colors.white : const Color(0xFF111111),
      onSurfaceVariant: c.muted,
      surfaceContainerLowest: isDark ? Colors.black : Colors.white,
      surfaceContainerLow: c.card,
      surfaceContainer: c.card,
      surfaceContainerHigh: isDark ? const Color(0xFF1C1C1C) : const Color(0xFFF0F0F0),
      surfaceContainerHighest: isDark ? const Color(0xFF242424) : const Color(0xFFE8E8E8),
      outline: c.cardBorder,
      outlineVariant: c.cardBorder,
      error: isDark ? const Color(0xFFFF6B6B) : const Color(0xFFB3261E),
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: b);
    final text = base.textTheme.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      extensions: [c],
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        // Pushed screens (Help & Support, Notifications, Edit Profile…) use a large bold
        // title beside the back arrow, as in the designs.
        titleTextStyle: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 26),
        toolbarHeight: 64,
      ),
      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: c.cardBorder),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.cardBorder, space: 1, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Brand.orangeDeep,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 52),
          shape: shape,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(48, 48),
          side: BorderSide(color: c.cardBorder),
          shape: shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.accentText, minimumSize: const Size(48, 44)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: c.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
            color: s.contains(WidgetState.selected) ? scheme.primary : c.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? scheme.primary : c.muted),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: c.muted,
        indicatorColor: scheme.primary,
        dividerColor: c.cardBorder,
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: c.cardBorder),
        backgroundColor: c.card,
        selectedColor: Brand.orangeDeep,
        secondarySelectedColor: Brand.orangeDeep,
        checkmarkColor: Colors.white,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : c.muted),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Brand.orangeDeep : null),
      ),
      listTileTheme: ListTileThemeData(iconColor: scheme.onSurface, minVerticalPadding: 10),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF0E0E0E) : Colors.white,
        surfaceTintColor: Colors.transparent,
        // Off: the designs' sheets have none, and Stacked's custom sheets would draw it
        // floating above the sheet.
        showDragHandle: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
