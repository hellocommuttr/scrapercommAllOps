import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../data/models/models.dart';
import '../../../services/reference_data_service.dart';
import '../../../services/settings_service.dart';

/// Transport preferences, default depart time, notifications and accessibility: the
/// four preference rows shared by Profile and Edit Profile, and the sheets behind them.
/// Every change is saved straight away, on this device only.
class PreferenceRowsModel extends ReactiveViewModel {
  final _settings = locator<SettingsService>();
  final _reference = locator<ReferenceDataService>();
  final _nav = locator<NavigationService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_settings];

  /// What the mockups list when every operator is on.
  static const allOperatorsLabel = 'Golden Arrow, MyCiTi, Metrorail';

  /// Operators Commuttr has timetables for: Golden Arrow, MyCiTi and Metrorail.
  List<OperatorRef> operators = const [OperatorRef.goldenArrow, OperatorRef.myciti, OperatorRef.metrorail];

  Future<void> init() async {
    final list = await _reference.operators();
    if (list.isNotEmpty) operators = list;
    rebuildUi();
  }

  // -- transport

  /// The operators switched on; an empty stored set means all of them.
  Set<String> get selectedOperators {
    final all = operators.map((o) => o.code).toSet();
    final chosen = _settings.preferredOperators.intersection(all);
    return chosen.isEmpty ? all : chosen;
  }

  bool isSelected(OperatorRef o) => selectedOperators.contains(o.code);

  /// At least one operator stays on, so the last one can't be switched off.
  bool canToggle(OperatorRef o) => !isSelected(o) || selectedOperators.length > 1;

  Future<void> toggleOperator(OperatorRef o, bool on) async {
    if (!on && !canToggle(o)) return;
    final next = {...selectedOperators};
    if (on) {
      next.add(o.code);
    } else {
      next.remove(o.code);
    }
    final all = operators.map((x) => x.code).toSet();
    await _settings.setPreferredOperators(next.length == all.length ? <String>{} : next);
  }

  String get transportSummary {
    final chosen = selectedOperators;
    if (chosen.length == operators.length) return allOperatorsLabel;
    return operators.where((o) => chosen.contains(o.code)).map((o) => o.name).join(', ');
  }

  // -- depart time

  int? get defaultDepartMinutes => _settings.defaultDepartMinutes;

  String get departSummary => formatDepart(defaultDepartMinutes);

  static String formatDepart(int? minutes) {
    if (minutes == null) return 'Depart now';
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> setDefaultDepartMinutes(int? minutes) => _settings.setDefaultDepartMinutes(minutes);

  // -- notifications

  void openNotifications() => _nav.navigateToPreferencesView();

  // -- accessibility

  static const minTextScale = 1.0;
  static const maxTextScale = 1.6;

  double get textScale => _settings.textScale.clamp(minTextScale, maxTextScale);
  Future<void> setTextScale(double v) => _settings.setTextScale(double.parse(v.toStringAsFixed(1)));

  bool get boldText => _settings.boldText;
  Future<void> setBoldText(bool v) => _settings.setBoldText(v);

  bool get reduceMotion => _settings.reduceMotion;
  Future<void> setReduceMotion(bool v) => _settings.setReduceMotion(v);
}
