import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('tr')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Route Planner'**
  String get appTitle;

  /// No description provided for @chooseRoute.
  ///
  /// In en, this message translates to:
  /// **'Choose route'**
  String get chooseRoute;

  /// No description provided for @routeMenu.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeMenu;

  /// No description provided for @origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get origin;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @modeDriving.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get modeDriving;

  /// No description provided for @modeWalking.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get modeWalking;

  /// No description provided for @modeBicycling.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get modeBicycling;

  /// No description provided for @modeTransit.
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get modeTransit;

  /// No description provided for @detailedRoute.
  ///
  /// In en, this message translates to:
  /// **'Detailed route (step by step)'**
  String get detailedRoute;

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating route…'**
  String get calculating;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @placeIstanbul.
  ///
  /// In en, this message translates to:
  /// **'Istanbul'**
  String get placeIstanbul;

  /// No description provided for @placeAnkara.
  ///
  /// In en, this message translates to:
  /// **'Ankara'**
  String get placeAnkara;

  /// No description provided for @placeIzmir.
  ///
  /// In en, this message translates to:
  /// **'Izmir'**
  String get placeIzmir;

  /// No description provided for @placeAntalya.
  ///
  /// In en, this message translates to:
  /// **'Antalya'**
  String get placeAntalya;

  /// No description provided for @placeSultanahmet.
  ///
  /// In en, this message translates to:
  /// **'Sultanahmet'**
  String get placeSultanahmet;

  /// No description provided for @placeGalataTower.
  ///
  /// In en, this message translates to:
  /// **'Galata Tower'**
  String get placeGalataTower;

  /// No description provided for @demoTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo mode: sample routes'**
  String get demoTitle;

  /// No description provided for @demoBody.
  ///
  /// In en, this message translates to:
  /// **'No DIRECTIONS_API_KEY was provided, so bundled sample polylines are decoded offline with PolylineCodec. Run with --dart-define=DIRECTIONS_API_KEY=... for live routes.'**
  String get demoBody;

  /// No description provided for @demoStatus.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get demoStatus;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
