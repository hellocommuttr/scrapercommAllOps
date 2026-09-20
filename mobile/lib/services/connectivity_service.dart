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

  void reportSuccess() {
    if (_offline.value) _offline.value = false;
  }

  void reportOffline() {
    if (!_offline.value) _offline.value = true;
  }

  void dispose() => _sub?.cancel();
}
