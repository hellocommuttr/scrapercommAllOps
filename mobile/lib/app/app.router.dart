// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:commuttr/core/service_day.dart' as _i23;
import 'package:commuttr/data/models/models.dart' as _i22;
import 'package:commuttr/services/journey_service.dart' as _i21;
import 'package:commuttr/services/support_service.dart' as _i24;
import 'package:commuttr/ui/views/about/about_view.dart' as _i18;
import 'package:commuttr/ui/views/connection_detail/connection_detail_view.dart'
    as _i6;
import 'package:commuttr/ui/views/edit_profile/edit_profile_view.dart' as _i11;
import 'package:commuttr/ui/views/favourites/favourites_view.dart' as _i10;
import 'package:commuttr/ui/views/help/help_view.dart' as _i14;
import 'package:commuttr/ui/views/legal/legal_content.dart' as _i25;
import 'package:commuttr/ui/views/legal/legal_view.dart' as _i17;
import 'package:commuttr/ui/views/main/main_view.dart' as _i3;
import 'package:commuttr/ui/views/nearby_stops/nearby_stops_view.dart' as _i9;
import 'package:commuttr/ui/views/notifications/notifications_view.dart'
    as _i16;
import 'package:commuttr/ui/views/offline_data/offline_data_view.dart' as _i13;
import 'package:commuttr/ui/views/preferences/preferences_view.dart' as _i12;
import 'package:commuttr/ui/views/report_issue/report_issue_view.dart' as _i15;
import 'package:commuttr/ui/views/route_detail/route_detail_view.dart' as _i7;
import 'package:commuttr/ui/views/startup/startup_view.dart' as _i2;
import 'package:commuttr/ui/views/stop_picker/stop_picker_view.dart' as _i4;
import 'package:commuttr/ui/views/timetable/timetable_view.dart' as _i8;
import 'package:commuttr/ui/views/trip_detail/trip_detail_view.dart' as _i5;
import 'package:flutter/foundation.dart' as _i20;
import 'package:flutter/material.dart' as _i19;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i26;

class Routes {
  static const startupView = '/';

  static const mainView = '/main-view';

  static const stopPickerView = '/stop-picker-view';

  static const tripDetailView = '/trip-detail-view';

  static const connectionDetailView = '/connection-detail-view';

  static const routeDetailView = '/route-detail-view';

  static const timetableView = '/timetable-view';

  static const nearbyStopsView = '/nearby-stops-view';

  static const favouritesView = '/favourites-view';

  static const editProfileView = '/edit-profile-view';

  static const preferencesView = '/preferences-view';

  static const offlineDataView = '/offline-data-view';

  static const helpView = '/help-view';

  static const reportIssueView = '/report-issue-view';

  static const notificationsView = '/notifications-view';

  static const legalView = '/legal-view';

  static const aboutView = '/about-view';

  static const all = <String>{
    startupView,
    mainView,
    stopPickerView,
    tripDetailView,
    connectionDetailView,
    routeDetailView,
    timetableView,
    nearbyStopsView,
    favouritesView,
    editProfileView,
    preferencesView,
    offlineDataView,
    helpView,
    reportIssueView,
    notificationsView,
    legalView,
    aboutView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(Routes.startupView, page: _i2.StartupView),
    _i1.RouteDef(Routes.mainView, page: _i3.MainView),
    _i1.RouteDef(Routes.stopPickerView, page: _i4.StopPickerView),
    _i1.RouteDef(Routes.tripDetailView, page: _i5.TripDetailView),
    _i1.RouteDef(Routes.connectionDetailView, page: _i6.ConnectionDetailView),
    _i1.RouteDef(Routes.routeDetailView, page: _i7.RouteDetailView),
    _i1.RouteDef(Routes.timetableView, page: _i8.TimetableView),
    _i1.RouteDef(Routes.nearbyStopsView, page: _i9.NearbyStopsView),
    _i1.RouteDef(Routes.favouritesView, page: _i10.FavouritesView),
    _i1.RouteDef(Routes.editProfileView, page: _i11.EditProfileView),
    _i1.RouteDef(Routes.preferencesView, page: _i12.PreferencesView),
    _i1.RouteDef(Routes.offlineDataView, page: _i13.OfflineDataView),
    _i1.RouteDef(Routes.helpView, page: _i14.HelpView),
    _i1.RouteDef(Routes.reportIssueView, page: _i15.ReportIssueView),
    _i1.RouteDef(Routes.notificationsView, page: _i16.NotificationsView),
    _i1.RouteDef(Routes.legalView, page: _i17.LegalView),
    _i1.RouteDef(Routes.aboutView, page: _i18.AboutView),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.StartupView: (data) {
      final args = data.getArgs<StartupViewArguments>(
        orElse: () => const StartupViewArguments(),
      );
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) => _i2.StartupView(key: args.key),
        settings: data,
      );
    },
    _i3.MainView: (data) {
      final args = data.getArgs<MainViewArguments>(
        orElse: () => const MainViewArguments(),
      );
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) => _i3.MainView(key: args.key),
        settings: data,
      );
    },
    _i4.StopPickerView: (data) {
      final args = data.getArgs<StopPickerViewArguments>(nullOk: false);
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) => _i4.StopPickerView(
          key: args.key,
          title: args.title,
          forDestination: args.forDestination,
        ),
        settings: data,
      );
    },
    _i5.TripDetailView: (data) {
      final args = data.getArgs<TripDetailViewArguments>(
        orElse: () => const TripDetailViewArguments(),
      );
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) => _i5.TripDetailView(
          key: args.key,
          ride: args.ride,
          plannedJourneyId: args.plannedJourneyId,
        ),
        settings: data,
      );
    },
    _i6.ConnectionDetailView: (data) {
      final args = data.getArgs<ConnectionDetailViewArguments>(nullOk: false);
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) => _i6.ConnectionDetailView(
          key: args.key,
          connection: args.connection,
          date: args.date,
        ),
        settings: data,
      );
    },
    _i7.RouteDetailView: (data) {
      final args = data.getArgs<RouteDetailViewArguments>(nullOk: false);
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i7.RouteDetailView(key: args.key, routeId: args.routeId),
        settings: data,
      );
    },
    _i8.TimetableView: (data) {
      final args = data.getArgs<TimetableViewArguments>(nullOk: false);
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) => _i8.TimetableView(
          key: args.key,
          timetableId: args.timetableId,
          title: args.title,
        ),
        settings: data,
      );
    },
    _i9.NearbyStopsView: (data) {
      final args = data.getArgs<NearbyStopsViewArguments>(
        orElse: () => const NearbyStopsViewArguments(),
      );
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) => _i9.NearbyStopsView(key: args.key),
        settings: data,
      );
    },
    _i10.FavouritesView: (data) {
      final args = data.getArgs<FavouritesViewArguments>(
        orElse: () => const FavouritesViewArguments(),
      );
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) => _i10.FavouritesView(key: args.key),
        settings: data,
      );
    },
    _i11.EditProfileView: (data) {
      final args = data.getArgs<EditProfileViewArguments>(
        orElse: () => const EditProfileViewArguments(),
      );
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) => _i11.EditProfileView(key: args.key),
        settings: data,
      );
    },
    _i12.PreferencesView: (data) {
      final args = data.getArgs<PreferencesViewArguments>(
        orElse: () => const PreferencesViewArguments(),
      );
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) => _i12.PreferencesView(key: args.key),
        settings: data,
      );
    },
    _i13.OfflineDataView: (data) {
      final args = data.getArgs<OfflineDataViewArguments>(
        orElse: () => const OfflineDataViewArguments(),
      );
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) => _i13.OfflineDataView(key: args.key),
        settings: data,
      );
    },
    _i14.HelpView: (data) {
      final args = data.getArgs<HelpViewArguments>(
        orElse: () => const HelpViewArguments(),
      );
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) => _i14.HelpView(key: args.key),
        settings: data,
      );
    },
    _i15.ReportIssueView: (data) {
      final args = data.getArgs<ReportIssueViewArguments>(
        orElse: () => const ReportIssueViewArguments(),
      );
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i15.ReportIssueView(key: args.key, report: args.report),
        settings: data,
      );
    },
    _i16.NotificationsView: (data) {
      final args = data.getArgs<NotificationsViewArguments>(
        orElse: () => const NotificationsViewArguments(),
      );
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) => _i16.NotificationsView(key: args.key),
        settings: data,
      );
    },
    _i17.LegalView: (data) {
      final args = data.getArgs<LegalViewArguments>(nullOk: false);
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) => _i17.LegalView(key: args.key, kind: args.kind),
        settings: data,
      );
    },
    _i18.AboutView: (data) {
      final args = data.getArgs<AboutViewArguments>(
        orElse: () => const AboutViewArguments(),
      );
      return _i19.MaterialPageRoute<dynamic>(
        builder: (context) => _i18.AboutView(key: args.key),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class StartupViewArguments {
  const StartupViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant StartupViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class MainViewArguments {
  const MainViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant MainViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class StopPickerViewArguments {
  const StopPickerViewArguments({
    this.key,
    required this.title,
    this.forDestination = false,
  });

  final _i20.Key? key;

  final String title;

  final bool forDestination;

  @override
  String toString() {
    return '{"key": "$key", "title": "$title", "forDestination": "$forDestination"}';
  }

  @override
  bool operator ==(covariant StopPickerViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.title == title &&
        other.forDestination == forDestination;
  }

  @override
  int get hashCode {
    return key.hashCode ^ title.hashCode ^ forDestination.hashCode;
  }
}

class TripDetailViewArguments {
  const TripDetailViewArguments({this.key, this.ride, this.plannedJourneyId});

  final _i20.Key? key;

  final _i21.Ride? ride;

  final String? plannedJourneyId;

  @override
  String toString() {
    return '{"key": "$key", "ride": "$ride", "plannedJourneyId": "$plannedJourneyId"}';
  }

  @override
  bool operator ==(covariant TripDetailViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.ride == ride &&
        other.plannedJourneyId == plannedJourneyId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ ride.hashCode ^ plannedJourneyId.hashCode;
  }
}

class ConnectionDetailViewArguments {
  const ConnectionDetailViewArguments({
    this.key,
    required this.connection,
    required this.date,
  });

  final _i20.Key? key;

  final _i22.Connection connection;

  final _i23.ServiceDate date;

  @override
  String toString() {
    return '{"key": "$key", "connection": "$connection", "date": "$date"}';
  }

  @override
  bool operator ==(covariant ConnectionDetailViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.connection == connection &&
        other.date == date;
  }

  @override
  int get hashCode {
    return key.hashCode ^ connection.hashCode ^ date.hashCode;
  }
}

class RouteDetailViewArguments {
  const RouteDetailViewArguments({this.key, required this.routeId});

  final _i20.Key? key;

  final int routeId;

  @override
  String toString() {
    return '{"key": "$key", "routeId": "$routeId"}';
  }

  @override
  bool operator ==(covariant RouteDetailViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.routeId == routeId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ routeId.hashCode;
  }
}

class TimetableViewArguments {
  const TimetableViewArguments({
    this.key,
    required this.timetableId,
    required this.title,
  });

  final _i20.Key? key;

  final int timetableId;

  final String title;

  @override
  String toString() {
    return '{"key": "$key", "timetableId": "$timetableId", "title": "$title"}';
  }

  @override
  bool operator ==(covariant TimetableViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.timetableId == timetableId &&
        other.title == title;
  }

  @override
  int get hashCode {
    return key.hashCode ^ timetableId.hashCode ^ title.hashCode;
  }
}

class NearbyStopsViewArguments {
  const NearbyStopsViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant NearbyStopsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class FavouritesViewArguments {
  const FavouritesViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant FavouritesViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class EditProfileViewArguments {
  const EditProfileViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant EditProfileViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class PreferencesViewArguments {
  const PreferencesViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant PreferencesViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class OfflineDataViewArguments {
  const OfflineDataViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant OfflineDataViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class HelpViewArguments {
  const HelpViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant HelpViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class ReportIssueViewArguments {
  const ReportIssueViewArguments({this.key, this.report});

  final _i20.Key? key;

  final _i24.ReportContext? report;

  @override
  String toString() {
    return '{"key": "$key", "report": "$report"}';
  }

  @override
  bool operator ==(covariant ReportIssueViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.report == report;
  }

  @override
  int get hashCode {
    return key.hashCode ^ report.hashCode;
  }
}

class NotificationsViewArguments {
  const NotificationsViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant NotificationsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class LegalViewArguments {
  const LegalViewArguments({this.key, required this.kind});

  final _i20.Key? key;

  final _i25.LegalKind kind;

  @override
  String toString() {
    return '{"key": "$key", "kind": "$kind"}';
  }

  @override
  bool operator ==(covariant LegalViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.kind == kind;
  }

  @override
  int get hashCode {
    return key.hashCode ^ kind.hashCode;
  }
}

class AboutViewArguments {
  const AboutViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AboutViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

extension NavigatorStateExtension on _i26.NavigationService {
  Future<dynamic> navigateToStartupView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.startupView,
      arguments: StartupViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToMainView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.mainView,
      arguments: MainViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToStopPickerView({
    _i20.Key? key,
    required String title,
    bool forDestination = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.stopPickerView,
      arguments: StopPickerViewArguments(
        key: key,
        title: title,
        forDestination: forDestination,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToTripDetailView({
    _i20.Key? key,
    _i21.Ride? ride,
    String? plannedJourneyId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.tripDetailView,
      arguments: TripDetailViewArguments(
        key: key,
        ride: ride,
        plannedJourneyId: plannedJourneyId,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToConnectionDetailView({
    _i20.Key? key,
    required _i22.Connection connection,
    required _i23.ServiceDate date,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.connectionDetailView,
      arguments: ConnectionDetailViewArguments(
        key: key,
        connection: connection,
        date: date,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToRouteDetailView({
    _i20.Key? key,
    required int routeId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.routeDetailView,
      arguments: RouteDetailViewArguments(key: key, routeId: routeId),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToTimetableView({
    _i20.Key? key,
    required int timetableId,
    required String title,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.timetableView,
      arguments: TimetableViewArguments(
        key: key,
        timetableId: timetableId,
        title: title,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToNearbyStopsView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.nearbyStopsView,
      arguments: NearbyStopsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToFavouritesView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.favouritesView,
      arguments: FavouritesViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToEditProfileView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.editProfileView,
      arguments: EditProfileViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToPreferencesView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.preferencesView,
      arguments: PreferencesViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToOfflineDataView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.offlineDataView,
      arguments: OfflineDataViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToHelpView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.helpView,
      arguments: HelpViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToReportIssueView({
    _i20.Key? key,
    _i24.ReportContext? report,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.reportIssueView,
      arguments: ReportIssueViewArguments(key: key, report: report),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToNotificationsView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.notificationsView,
      arguments: NotificationsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToLegalView({
    _i20.Key? key,
    required _i25.LegalKind kind,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.legalView,
      arguments: LegalViewArguments(key: key, kind: kind),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToAboutView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.aboutView,
      arguments: AboutViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithStartupView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.startupView,
      arguments: StartupViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithMainView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.mainView,
      arguments: MainViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithStopPickerView({
    _i20.Key? key,
    required String title,
    bool forDestination = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.stopPickerView,
      arguments: StopPickerViewArguments(
        key: key,
        title: title,
        forDestination: forDestination,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithTripDetailView({
    _i20.Key? key,
    _i21.Ride? ride,
    String? plannedJourneyId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.tripDetailView,
      arguments: TripDetailViewArguments(
        key: key,
        ride: ride,
        plannedJourneyId: plannedJourneyId,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithConnectionDetailView({
    _i20.Key? key,
    required _i22.Connection connection,
    required _i23.ServiceDate date,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.connectionDetailView,
      arguments: ConnectionDetailViewArguments(
        key: key,
        connection: connection,
        date: date,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithRouteDetailView({
    _i20.Key? key,
    required int routeId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.routeDetailView,
      arguments: RouteDetailViewArguments(key: key, routeId: routeId),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithTimetableView({
    _i20.Key? key,
    required int timetableId,
    required String title,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.timetableView,
      arguments: TimetableViewArguments(
        key: key,
        timetableId: timetableId,
        title: title,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithNearbyStopsView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.nearbyStopsView,
      arguments: NearbyStopsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithFavouritesView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.favouritesView,
      arguments: FavouritesViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithEditProfileView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.editProfileView,
      arguments: EditProfileViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithPreferencesView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.preferencesView,
      arguments: PreferencesViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithOfflineDataView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.offlineDataView,
      arguments: OfflineDataViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithHelpView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.helpView,
      arguments: HelpViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithReportIssueView({
    _i20.Key? key,
    _i24.ReportContext? report,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.reportIssueView,
      arguments: ReportIssueViewArguments(key: key, report: report),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithNotificationsView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.notificationsView,
      arguments: NotificationsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithLegalView({
    _i20.Key? key,
    required _i25.LegalKind kind,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.legalView,
      arguments: LegalViewArguments(key: key, kind: kind),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithAboutView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.aboutView,
      arguments: AboutViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }
}
