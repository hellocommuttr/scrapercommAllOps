import 'package:flutter/material.dart';

/// Commuttr's mark.
///
/// Two artworks rather than one: the mark is drawn in black on light backgrounds and in
/// white on dark ones, with the orange eye constant in both. A single tinted image cannot
/// do that, because only part of it changes colour.
///
/// It was previously drawn with a CustomPainter - a route line between two stops - which
/// was crisp and free to ship and was not the logo. Fidelity to the brand wins.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 48, this.onDark});

  final double size;

  /// Force a variant. Left null, it follows the theme, which is what almost every caller
  /// wants; pass it where the mark sits on a surface that is not the theme's own, such as
  /// the always-dark splash.
  final bool? onDark;

  @override
  Widget build(BuildContext context) {
    final dark = onDark ?? Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'Commuttr',
      image: true,
      child: Image.asset(
        dark ? 'assets/images/logo_dark.png' : 'assets/images/logo_light.png',
        width: size,
        height: size,
        // The artwork is 512px square, so it is sharp at every size the app asks for and
        // does not need a resolution-aware variant set.
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
