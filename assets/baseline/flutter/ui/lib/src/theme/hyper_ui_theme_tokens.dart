import 'package:flutter/widgets.dart';

import 'hyper_ui_colors.dart';
import 'hyper_ui_theme.dart';

@immutable
class HyperUiThemeTokens {
  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color primary;
  final Color primaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color border;
  final Color input;
  final Color selectionBackground;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const HyperUiThemeTokens({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.primary,
    required this.primaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.border,
    required this.input,
    required this.selectionBackground,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  factory HyperUiThemeTokens.light({Color? primary}) {
    final effectivePrimary = primary ?? HyperUiColors.primary;
    return HyperUiThemeTokens(
      background: HyperUiColors.background,
      foreground: HyperUiColors.foreground,
      card: HyperUiColors.card,
      cardForeground: HyperUiColors.cardForeground,
      primary: effectivePrimary,
      primaryForeground: HyperUiColors.primaryForeground,
      muted: HyperUiColors.muted,
      mutedForeground: HyperUiColors.mutedForeground,
      border: HyperUiColors.border,
      input: HyperUiColors.input,
      selectionBackground: HyperUiColors.selectionBackground,
      success: HyperUiColors.success,
      warning: HyperUiColors.warning,
      error: HyperUiColors.error,
      info: HyperUiColors.info,
    );
  }

  factory HyperUiThemeTokens.dark({Color? primary}) {
    final effectivePrimary = primary ?? HyperUiColors.primary;
    return HyperUiThemeTokens(
      background: HyperUiColors.darkBackground,
      foreground: HyperUiColors.darkForeground,
      card: HyperUiColors.darkCard,
      cardForeground: HyperUiColors.darkForeground,
      primary: effectivePrimary,
      primaryForeground: HyperUiColors.primaryForeground,
      muted: HyperUiColors.darkMuted,
      mutedForeground: HyperUiColors.darkMutedForeground,
      border: HyperUiColors.darkBorder,
      input: HyperUiColors.darkBorder,
      selectionBackground: const Color(0xFF142544),
      success: HyperUiColors.success,
      warning: HyperUiColors.warning,
      error: HyperUiColors.error,
      info: HyperUiColors.info,
    );
  }

  static HyperUiThemeTokens of(BuildContext context) {
    return HyperUiTheme.of(context).tokens;
  }

  HyperUiThemeTokens copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? cardForeground,
    Color? primary,
    Color? primaryForeground,
    Color? muted,
    Color? mutedForeground,
    Color? border,
    Color? input,
    Color? selectionBackground,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return HyperUiThemeTokens(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      primary: primary ?? this.primary,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      border: border ?? this.border,
      input: input ?? this.input,
      selectionBackground: selectionBackground ?? this.selectionBackground,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  HyperUiThemeTokens lerp(HyperUiThemeTokens other, double t) {
    return HyperUiThemeTokens(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardForeground: Color.lerp(cardForeground, other.cardForeground, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryForeground: Color.lerp(
        primaryForeground,
        other.primaryForeground,
        t,
      )!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      border: Color.lerp(border, other.border, t)!,
      input: Color.lerp(input, other.input, t)!,
      selectionBackground: Color.lerp(
        selectionBackground,
        other.selectionBackground,
        t,
      )!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
