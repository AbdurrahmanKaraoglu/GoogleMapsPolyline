// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Rota Planlayıcı';

  @override
  String get chooseRoute => 'Rota seç';

  @override
  String get routeMenu => 'Rota';

  @override
  String get origin => 'Başlangıç';

  @override
  String get destination => 'Varış';

  @override
  String get modeDriving => 'Araç';

  @override
  String get modeWalking => 'Yürüyüş';

  @override
  String get modeBicycling => 'Bisiklet';

  @override
  String get modeTransit => 'Toplu taşıma';

  @override
  String get detailedRoute => 'Ayrıntılı rota (adım adım)';

  @override
  String get calculating => 'Rota hesaplanıyor…';

  @override
  String get connectionError => 'Bağlantı hatası';

  @override
  String get error => 'Hata';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get status => 'Durum';

  @override
  String get points => 'Nokta';

  @override
  String get mode => 'Mod';

  @override
  String get missingApiKey => 'DIRECTIONS_API_KEY tanımlı değil. Uygulamayı --dart-define ile başlatın.';

  @override
  String get placeIstanbul => 'İstanbul';

  @override
  String get placeAnkara => 'Ankara';

  @override
  String get placeIzmir => 'İzmir';

  @override
  String get placeAntalya => 'Antalya';

  @override
  String get placeSultanahmet => 'Sultanahmet';

  @override
  String get placeGalataTower => 'Galata Kulesi';
}
