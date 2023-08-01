import 'package:flutter/material.dart';
import 'package:google_maps_polyline/google_maps_polyline.dart';
// ignore: implementation_imports
import 'package:google_maps_polyline/src/point_latlng.dart';
// ignore: implementation_imports
import 'package:google_maps_polyline/src/utils/my_request_enums.dart';
// ignore: implementation_imports
import 'package:google_maps_polyline/src/utils/result_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    drawPolyline();
  }

  void drawPolyline() async {
    // PolylinePointsFlutter sınıfını oluşturun
    GoogleMapsPolyline polylinePoints = GoogleMapsPolyline();

    // Kendi Google API anahtarınız ile değiştirin
    String googleApiKey = "SİZİN_GOOGLE_API_ANAHTARINIZ";

    // Başlangıç ve hedef koordinatları belirleyin
    MyPointLatLng origin = MyPointLatLng(37.7749, -122.4194); // San Francisco
    MyPointLatLng destination = MyPointLatLng(34.0522, -118.2437); // Los Angeles

    // Rota için API'ya istek gönderin ve sonuç polyline'ini alın
    ResultPolyline result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      origin,
      destination,
      travelMode: MyTravelMode.driving,
    );

    // Başarılı bir şekilde bir rota alındıysa, poliline çizmek için kullanılacak LatLng listesi oluşturun
    if (result.status == "ok" && result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = [];
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude!, point.longitude!));
      }

      // Poliline'ı çizin ve polylines kümesine ekleyin
      polylines.add(Polyline(
        polylineId: const PolylineId("polylineIdString"),
        points: polylineCoordinates,
        color: Colors.blue,
        width: 5,
      ));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Polyline Points Flutter Demo"),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.7749, -122.4194), // San Francisco
          zoom: 10,
        ),
        polylines: polylines,
      ),
    );
  }
}
