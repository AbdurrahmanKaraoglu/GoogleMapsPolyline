// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Route Planner';

  @override
  String get chooseRoute => 'Choose route';

  @override
  String get routeMenu => 'Route';

  @override
  String get origin => 'Origin';

  @override
  String get destination => 'Destination';

  @override
  String get modeDriving => 'Car';

  @override
  String get modeWalking => 'Walk';

  @override
  String get modeBicycling => 'Bike';

  @override
  String get modeTransit => 'Transit';

  @override
  String get detailedRoute => 'Detailed route (step by step)';

  @override
  String get calculating => 'Calculating route…';

  @override
  String get connectionError => 'Connection error';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get status => 'Status';

  @override
  String get points => 'Points';

  @override
  String get mode => 'Mode';

  @override
  String get placeIstanbul => 'Istanbul';

  @override
  String get placeAnkara => 'Ankara';

  @override
  String get placeIzmir => 'Izmir';

  @override
  String get placeAntalya => 'Antalya';

  @override
  String get placeSultanahmet => 'Sultanahmet';

  @override
  String get placeGalataTower => 'Galata Tower';

  @override
  String get demoTitle => 'Demo mode: sample routes';

  @override
  String get demoBody =>
      'No DIRECTIONS_API_KEY was provided, so bundled sample polylines are decoded offline with PolylineCodec. Run with --dart-define=DIRECTIONS_API_KEY=... for live routes.';

  @override
  String get demoStatus => 'Demo';
}
