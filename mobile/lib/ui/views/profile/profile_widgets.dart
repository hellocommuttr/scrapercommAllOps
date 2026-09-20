import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// The mockups' page title: 28–30 pt bold white title, optional grey subtitle, an
/// optional back arrow before it and an optional action (the bell) at the top right.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle, this.showBack = false, this.trailing});

  final String title;
  final String? subtitle;
  final bool showBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(showBack ? 4 : 16, 12, 4, 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBack) const BackButton(),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: showBack ? 2 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: TextStyle(fontSize: 14, color: context.colors.muted)),
                ],
              ],
            ),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

/// The mockups' "red-outlined" button: orange border, orange text and icon.
class AccentOutlinedButton extends StatelessWidget {
  const AccentOutlinedButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.expand = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  /// Full width, as for "Log out".
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.accentText;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: BorderSide(color: onPressed == null ? context.colors.cardBorder : accent, width: 1.2),
        minimumSize: expand ? const Size.fromHeight(52) : const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18),
      ),
    );
  }
}

/// The profile photo from `SettingsService.photoBase64`, or a person icon.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.photoBase64, this.radius = 48});

  final String? photoBase64;
  final double radius;

  static Uint8List? decode(String? base64) {
    if (base64 == null || base64.isEmpty) return null;
    try {
      return base64Decode(base64);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = decode(photoBase64);
    final c = context.colors;
    return Semantics(
      image: true,
      label: bytes == null ? 'No profile photo' : 'Profile photo',
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.card,
          border: Border.all(color: c.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: bytes == null
            ? Icon(Icons.person_outline_rounded, size: radius * 1.1, color: c.muted)
            : Image.memory(
                bytes,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => Icon(Icons.person_outline_rounded, size: radius * 1.1, color: c.muted),
              ),
      ),
    );
  }
}

/// A square-ish favourites tile: orange outline icon, title and grey subtitle.
class FavouriteTile extends StatelessWidget {
  const FavouriteTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: '$title, $subtitle',
      excludeSemantics: true,
      child: Material(
        color: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: c.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 26, color: c.accentText),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: c.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
