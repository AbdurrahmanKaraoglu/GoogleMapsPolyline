import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_polyline/google_maps_polyline.dart';
import 'package:intl/intl.dart';

import 'demo_routes.dart';
import 'l10n/app_localizations.dart';

/// The Directions API key is provided at build time:
/// `flutter run --dart-define=DIRECTIONS_API_KEY=...`
const String directionsApiKey = String.fromEnvironment('DIRECTIONS_API_KEY');

const _brandNavy = Color(0xFF0B2545);
const _brandBlue = Color(0xFF1D4ED8);

void main() {
  runApp(const RouteDemoApp());
}

class RouteDemoApp extends StatelessWidget {
  const RouteDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: _brandNavy, primary: _brandNavy, secondary: _brandBlue);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: _brandNavy,
            selectedForegroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
      home: const RouteScreen(),
    );
  }
}

/// Predefined demo routes.
class _Preset {
  const _Preset(this.origin, this.originName, this.destination, this.destinationName, this.demoPolyline);
  final MyPointLatLng origin;
  final String Function(AppLocalizations) originName;
  final MyPointLatLng destination;
  final String Function(AppLocalizations) destinationName;

  /// Sample polyline shown in demo mode (no API key).
  final String demoPolyline;

  String title(AppLocalizations l) => '${originName(l)} → ${destinationName(l)}';
}

final _presets = [
  _Preset(
    const MyPointLatLng(41.0082, 28.9784),
    (l) => l.placeIstanbul,
    const MyPointLatLng(39.9334, 32.8597),
    (l) => l.placeAnkara,
    demoIstanbulAnkara,
  ),
  _Preset(
    const MyPointLatLng(38.4237, 27.1428),
    (l) => l.placeIzmir,
    const MyPointLatLng(36.8969, 30.7133),
    (l) => l.placeAntalya,
    demoIzmirAntalya,
  ),
  _Preset(
    const MyPointLatLng(41.0054, 28.9768),
    (l) => l.placeSultanahmet,
    const MyPointLatLng(41.0256, 28.9744),
    (l) => l.placeGalataTower,
    demoSultanahmetGalata,
  ),
];

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  GoogleMapController? _map;

  _Preset _preset = _presets.first;
  MyTravelMode _mode = MyTravelMode.driving;
  bool _detailed = true;

  bool _loading = false;
  ResultPolyline? _result;

  /// Without a Directions API key the app shows bundled sample routes.
  bool get _demo => directionsApiKey.isEmpty;

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The first request needs the locale, which is only available here.
    if (!_started) {
      _started = true;
      _loadRoute();
    }
  }

  Future<void> _loadRoute() async {
    if (_demo) {
      // Decoded offline with the package's PolylineCodec; no network request.
      final points = PolylineCodec.decode(_preset.demoPolyline);
      setState(() => _result = ResultPolyline(status: 'OK', points: points));
      _fitToRoute(points);
      return;
    }
    setState(() => _loading = true);
    // The package's messages and the API's error_message follow the app language.
    final polylineApi = GoogleMapsPolyline(language: Localizations.localeOf(context).languageCode);
    final result = await polylineApi.getRouteBetweenCoordinates(
      directionsApiKey,
      _preset.origin,
      _preset.destination,
      travelMode: _mode,
      detailedPolyline: _detailed,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = result;
    });
    if (result.isSuccess) _fitToRoute(result.points);
  }

  void _fitToRoute(List<MyPointLatLng> points) {
    if (_map == null || points.isEmpty) return;
    var south = points.first.latitude, north = south;
    var west = points.first.longitude, east = west;
    for (final p in points) {
      south = math.min(south, p.latitude);
      north = math.max(north, p.latitude);
      west = math.min(west, p.longitude);
      east = math.max(east, p.longitude);
    }
    _map!.animateCamera(
      CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east)), 72),
    );
  }

  Set<Polyline> get _polylines {
    final result = _result;
    if (result == null || !result.isSuccess) return const {};
    final points = [for (final p in result.points) LatLng(p.latitude, p.longitude)];
    return {
      Polyline(polylineId: const PolylineId('casing'), points: points, color: _brandNavy, width: 9, zIndex: 0),
      Polyline(polylineId: const PolylineId('route'), points: points, color: _brandBlue, width: 5, zIndex: 1),
    };
  }

  Set<Marker> _markers(AppLocalizations l) => {
    Marker(
      markerId: const MarkerId('origin'),
      position: LatLng(_preset.origin.latitude, _preset.origin.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(title: l.origin, snippet: _preset.originName(l)),
    ),
    Marker(
      markerId: const MarkerId('destination'),
      position: LatLng(_preset.destination.latitude, _preset.destination.longitude),
      infoWindow: InfoWindow(title: l.destination, snippet: _preset.destinationName(l)),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(39.5, 32.0), zoom: 5.5),
            polylines: _polylines,
            markers: _markers(AppLocalizations.of(context)),
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            padding: const EdgeInsets.only(top: 230, bottom: 150),
            onMapCreated: (controller) {
              _map = controller;
              final result = _result;
              if (result != null && result.isSuccess) _fitToRoute(result.points);
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  _PlannerCard(
                    preset: _preset,
                    mode: _mode,
                    detailed: _detailed,
                    loading: _loading,
                    demo: _demo,
                    onPresetChanged: (p) {
                      setState(() => _preset = p);
                      _loadRoute();
                    },
                    onModeChanged: (m) {
                      setState(() => _mode = m);
                      _loadRoute();
                    },
                    onDetailedChanged: (v) {
                      setState(() => _detailed = v);
                      _loadRoute();
                    },
                  ),
                  if (_demo) ...[const SizedBox(height: 12), const _DemoBanner()],
                  const Spacer(),
                  _ResultCard(result: _result, loading: _loading, mode: _mode, demo: _demo, onRetry: _loadRoute),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlannerCard extends StatelessWidget {
  const _PlannerCard({
    required this.preset,
    required this.mode,
    required this.detailed,
    required this.loading,
    required this.demo,
    required this.onPresetChanged,
    required this.onModeChanged,
    required this.onDetailedChanged,
  });

  final _Preset preset;
  final MyTravelMode mode;
  final bool detailed;
  final bool loading;

  /// Travel mode and detail do not apply to the bundled sample routes.
  final bool demo;
  final ValueChanged<_Preset> onPresetChanged;
  final ValueChanged<MyTravelMode> onModeChanged;
  final ValueChanged<bool> onDetailedChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: _brandNavy, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.alt_route, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(l.appTitle, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                PopupMenuButton<_Preset>(
                  tooltip: l.chooseRoute,
                  enabled: !loading,
                  onSelected: onPresetChanged,
                  itemBuilder: (_) => [for (final p in _presets) PopupMenuItem(value: p, child: Text(p.title(l)))],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l.routeMenu, style: text.labelLarge?.copyWith(color: _brandBlue)),
                        const Icon(Icons.expand_more, color: _brandBlue, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Stop(icon: Icons.trip_origin, color: _brandBlue, label: l.origin, value: preset.originName(l)),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 11),
                width: 2,
                height: 10,
                color: const Color(0xFFCBD5E1),
              ),
            ),
            _Stop(
              icon: Icons.place,
              color: const Color(0xFFDC2626),
              label: l.destination,
              value: preset.destinationName(l),
            ),
            const SizedBox(height: 12),
            SegmentedButton<MyTravelMode>(
              showSelectedIcon: false,
              segments: [
                for (final m in const [MyTravelMode.driving, MyTravelMode.walking, MyTravelMode.bicycling])
                  ButtonSegment(value: m, icon: Icon(_modeIcon(m)), label: Text(_modeLabel(l, m))),
              ],
              selected: {mode},
              onSelectionChanged: loading || demo ? null : (s) => onModeChanged(s.first),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: Text(l.detailedRoute, style: text.bodyMedium)),
                Switch(value: detailed, onChanged: loading || demo ? null : onDetailedChanged),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({required this.icon, required this.color, required this.label, required this.value});

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 10),
        SizedBox(
          width: 72,
          child: Text(label, style: text.bodySmall?.copyWith(color: const Color(0xFF64748B))),
        ),
        Expanded(
          child: Text(value, style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.loading,
    required this.mode,
    required this.demo,
    required this.onRetry,
  });

  final ResultPolyline? result;
  final bool loading;
  final MyTravelMode mode;
  final bool demo;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    final r = result;

    if (loading || r == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)),
              const SizedBox(width: 14),
              Text(l.calculating, style: text.bodyLarge),
            ],
          ),
        ),
      );
    }

    if (!r.isSuccess) {
      return Card(
        color: const Color(0xFFFEF2F2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFECACA)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFB91C1C)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.status == ResultPolyline.statusError ? l.connectionError : (r.status ?? l.error),
                      style: text.labelLarge?.copyWith(color: const Color(0xFFB91C1C), fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(r.errorMessage ?? '', style: text.bodySmall),
                  ],
                ),
              ),
              TextButton(onPressed: onRetry, child: Text(l.retry)),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 14),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 84,
                width: double.infinity,
                child: CustomPaint(painter: _RoutePreviewPainter(r.points)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Metric(
                  label: l.status,
                  value: demo ? l.demoStatus : r.status!,
                  icon: demo ? Icons.science_outlined : Icons.check_circle,
                  color: demo ? const Color(0xFFB45309) : const Color(0xFF15803D),
                ),
                const _Divider(),
                _Metric(
                  label: l.points,
                  value: NumberFormat.decimalPattern(l.localeName).format(r.points.length),
                  icon: Icons.timeline,
                  color: _brandBlue,
                ),
                const _Divider(),
                _Metric(
                  label: l.mode,
                  value: demo ? '—' : _modeLabel(l, mode),
                  icon: _modeIcon(mode),
                  color: _brandNavy,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          Text(label, style: text.bodySmall?.copyWith(color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(width: 1, height: 48, color: const Color(0xFFE2E8F0));
}

String _modeLabel(AppLocalizations l, MyTravelMode m) => switch (m) {
  MyTravelMode.driving => l.modeDriving,
  MyTravelMode.walking => l.modeWalking,
  MyTravelMode.bicycling => l.modeBicycling,
  MyTravelMode.transit => l.modeTransit,
};

IconData _modeIcon(MyTravelMode m) => switch (m) {
  MyTravelMode.driving => Icons.directions_car_outlined,
  MyTravelMode.walking => Icons.directions_walk,
  MyTravelMode.bicycling => Icons.pedal_bike,
  MyTravelMode.transit => Icons.directions_transit,
};

/// Shown when the app runs without a Directions API key.
class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    return Card(
      color: const Color(0xFFFFFBEB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFFDE68A)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFB45309), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.demoTitle,
                    style: text.labelLarge?.copyWith(color: const Color(0xFF92400E), fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(l.demoBody, style: text.bodySmall?.copyWith(color: const Color(0xFF78350F))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws the route shape without a map, so it is visible even when the map
/// has no Maps SDK key.
class _RoutePreviewPainter extends CustomPainter {
  _RoutePreviewPainter(this.points);

  final List<MyPointLatLng> points;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)), background);
    if (points.length < 2) return;

    // Equirectangular projection around the route's mean latitude.
    final meanLat = points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final kx = math.cos(meanLat * math.pi / 180);
    var minX = double.infinity, maxX = -double.infinity, minY = double.infinity, maxY = -double.infinity;
    for (final p in points) {
      minX = math.min(minX, p.longitude * kx);
      maxX = math.max(maxX, p.longitude * kx);
      minY = math.min(minY, p.latitude);
      maxY = math.max(maxY, p.latitude);
    }
    const pad = 14.0;
    final w = size.width - 2 * pad, h = size.height - 2 * pad;
    final scale = math.min(w / math.max(maxX - minX, 1e-9), h / math.max(maxY - minY, 1e-9));
    final dx = pad + (w - (maxX - minX) * scale) / 2, dy = pad + (h - (maxY - minY) * scale) / 2;
    Offset project(MyPointLatLng p) => Offset(dx + (p.longitude * kx - minX) * scale, dy + (maxY - p.latitude) * scale);

    final path = Path()..moveTo(project(points.first).dx, project(points.first).dy);
    for (final p in points.skip(1)) {
      final o = project(p);
      path.lineTo(o.dx, o.dy);
    }
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      path,
      stroke
        ..color = _brandNavy
        ..strokeWidth = 6,
    );
    canvas.drawPath(
      path,
      stroke
        ..color = _brandBlue
        ..strokeWidth = 3,
    );
    canvas.drawCircle(project(points.first), 6, Paint()..color = Colors.white);
    canvas.drawCircle(project(points.first), 4, Paint()..color = _brandBlue);
    canvas.drawCircle(project(points.last), 6, Paint()..color = const Color(0xFFDC2626));
  }

  @override
  bool shouldRepaint(_RoutePreviewPainter old) => !identical(old.points, points);
}
