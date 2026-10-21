import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_polyline/google_maps_polyline.dart';

/// Directions API anahtarı derleme sırasında verilir:
/// `flutter run --dart-define=DIRECTIONS_API_KEY=...`
const String directionsApiKey = String.fromEnvironment('DIRECTIONS_API_KEY');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'google_maps_polyline',
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _origin = MyPointLatLng(41.0082, 28.9784); // İstanbul
  static const _destination = MyPointLatLng(39.9334, 32.8597); // Ankara

  final _polylineApi = GoogleMapsPolyline();
  Set<Polyline> _polylines = {};
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    if (directionsApiKey.isEmpty) {
      setState(() => _error = 'DIRECTIONS_API_KEY tanımlı değil (--dart-define ile verin).');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _polylineApi.getRouteBetweenCoordinates(
      directionsApiKey,
      _origin,
      _destination,
      travelMode: MyTravelMode.driving,
      detailedPolyline: true,
    );
    if (!mounted) return;

    setState(() {
      _loading = false;
      if (result.isSuccess) {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [for (final p in result.points) LatLng(p.latitude, p.longitude)],
            color: Colors.blue,
            width: 5,
          ),
        };
      } else {
        _error = '${result.status}: ${result.errorMessage}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('google_maps_polyline'),
        actions: [IconButton(onPressed: _loading ? null : _loadRoute, icon: const Icon(Icons.refresh))],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(40.5, 30.9), zoom: 6),
            polylines: _polylines,
          ),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Material(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
                child: Padding(padding: const EdgeInsets.all(12), child: Text(_error!)),
              ),
            ),
        ],
      ),
    );
  }
}
