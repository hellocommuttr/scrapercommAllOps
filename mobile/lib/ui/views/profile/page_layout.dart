import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Profile and its sub-screens read best as a single column; on wide web this is
/// where the column stops growing.
const maxContentWidth = 720.0;

/// A [ListView] whose content is centred and capped at [maxContentWidth], while the
/// scrollable area still spans the whole window (so the mouse wheel works anywhere).
class ConstrainedListView extends StatelessWidget {
  const ConstrainedListView({super.key, required this.children, this.top = 8, this.bottom = 32});

  final List<Widget> children;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final side = max(0.0, (box.maxWidth - maxContentWidth) / 2);
      return ListView(padding: EdgeInsets.fromLTRB(side, top, side, bottom), children: children);
    },
  );
}

/// "512 bytes", "84 KB", "3.2 MB".
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes bytes';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(1)} MB';
}

/// Cape Town is UTC+2 all year; dates on these screens are shown in Cape Town time.
DateTime _sast(DateTime t) => t.toUtc().add(const Duration(hours: 2));

/// "28 Jul 2026" or, with [withTime], "28 Jul 2026, 12:47" — in Cape Town time.
String formatSastDate(DateTime t, {bool withTime = false}) =>
    DateFormat(withTime ? 'd MMM y, HH:mm' : 'd MMM y').format(_sast(t));

/// The timetable snapshot date from `SettingsService.dataVersion` (an ISO timestamp),
/// or null when there is none yet.
String? formatDataVersion(String? version) {
  if (version == null || version.isEmpty) return null;
  final t = DateTime.tryParse(version);
  return t == null ? version : formatSastDate(t);
}
