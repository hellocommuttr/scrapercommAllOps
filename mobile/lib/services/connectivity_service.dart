import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:stacked/stacked.dart';

/// Whether the app can reach the API.
///
/// connectivity_plus only says a network interface exists — a phone on Wi-Fi with no
/// internet, or with no airtime, still reports "connected". So the truth comes from
/// requests: a failed request marks us offline, a successful one marks us online, and
/// the platform signal is only used to notice "definitely no network" early.
class ConnectivityService with ListenableServiceMixin {
  ConnectivityService() {
    listenToReactiveValues([_offline, _metered]);
  }

  final ReactiveValue<bool> _offline = ReactiveValue(false);
  final ReactiveValue<bool> _metered = ReactiveValue(false);
  StreamSubscription<List<ConnectivityResult>>? _sub;

  bool get isOffline => _offline.value;

  /// On mobile data (not Wi-Fi): maps stay off in data-saver mode.
  bool get isMetered => _metered.value;

  Future<void> start() async {
    try {
      _apply(await Connectivity().checkConnectivity());
      _sub = Connectivity().onConnectivityChanged.listen(_apply);
    } catch (_) {
      // Unsupported platform: rely on request outcomes alone.
    }
  }

  void _apply(List<ConnectivityResult> results) {
    final none = results.isEmpty || results.every((r) => r == ConnectivityResult.none);
    if (none) {
      _offline.value = true;
    } else if (_offline.value) {
      // Back on a network: optimistic until a request says otherwise.
      _offline.value = false;
    }
    _metered.value = results.contains(ConnectivityResult.mobile) && !results.contains(ConnectivityResult.wifi);
  }

  DateTime? _lastSuccess;

  void reportSuccess() {
    _lastSuccess = DateTime.now();
    if (_offline.value) _offline.value = false;
  }

  /// A request failed for lack of network. A timeout straight after other requests came
  /// back is one slow request, not a lost connection: searching from a place asked for
  /// journeys with a change, took longer than the timeout, and told a rider looking at
  /// fresh results that they were offline.
  void reportOffline({bool timedOut = false}) {
    if (timedOut && _lastSuccess != null && DateTime.now().difference(_lastSuccess!) < recentSuccess) return;
    if (!_offline.value) _offline.value = true;
  }

  /// How recently a request must have succeeded for a timeout not to count as offline.
  static const recentSuccess = Duration(seconds: 45);

  void dispose() => _sub?.cancel();
}
